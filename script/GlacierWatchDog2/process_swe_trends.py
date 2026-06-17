import argparse
import gzip
import os
import re
import tempfile
from datetime import datetime

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xarray as xr

FILE_PATTERN = re.compile(r"S3M_(\d{12})\.nc\.gz$")


def find_region_directories(root_dir):
    """Return sorted region directories under the root directory."""
    return sorted(
        entry for entry in os.listdir(root_dir)
        if os.path.isdir(os.path.join(root_dir, entry))
    )


def collect_september_first_files(root_dir, region_name, start_year=None, end_year=None):
    """Collect SWE files for the given region (all files are already September 1st)."""
    region_path = os.path.join(root_dir, region_name)
    year_to_file = {}

    if not os.path.isdir(region_path):
        return {}

    for filename in os.listdir(region_path):
        match = FILE_PATTERN.match(filename)
        if not match:
            continue

        timestamp = datetime.strptime(match.group(1), "%Y%m%d%H%M")
        if start_year and timestamp.year < start_year:
            continue
        if end_year and timestamp.year > end_year:
            continue

        # Keep the earliest timestamp for each year (in case of duplicates)
        current = year_to_file.get(timestamp.year)
        if current is None or timestamp < current[0]:
            year_to_file[timestamp.year] = (timestamp, os.path.join(region_path, filename))

    return {
        year: path
        for year, (_, path) in sorted(year_to_file.items())
    }


def read_swe_from_gz(file_path, variable_name="SWE"):
    """Open a gzipped NetCDF file and return the SWE DataArray with negative values masked."""
    with tempfile.NamedTemporaryFile(suffix=".nc", delete=False) as tmp:
        tmp_path = tmp.name
        with gzip.open(file_path, "rb") as gz_file:
            tmp.write(gz_file.read())
    
    try:
        ds = xr.open_dataset(tmp_path, engine="netcdf4")
        available_vars = list(ds.variables)
        if variable_name not in ds.variables:
            fallback = next((v for v in available_vars if v.lower() == variable_name.lower()), None)
            if fallback is None:
                ds.close()
                raise ValueError(
                    f"Variable '{variable_name}' not found in {file_path}. Available vars: {available_vars}"
                )
            variable_name = fallback

        da = ds[variable_name].load()
        ds.close()

        da = da.where(da >= 0)
        return da
    finally:
        os.unlink(tmp_path)


def summarize_swe(da):
    """Return summary statistics for a data field."""
    return {
        "mean_value": float(np.nanmean(da.values)),
        "sum_value": float(np.nansum(da.values)),
        "valid_count": int(np.count_nonzero(~np.isnan(da.values))),
    }


def build_trend_dataframe(root_dir, region_names, variables=None, start_year=None, end_year=None):
    """Build a trend DataFrame containing mean values for specified variables on September 1st for each region and year."""
    if variables is None:
        variables = ["SWE"]
    
    trends = []

    for region_name in region_names:
        files = collect_september_first_files(root_dir, region_name, start_year, end_year)
        if not files:
            continue

        for year, file_path in files.items():
            for variable_name in variables:
                try:
                    da = read_swe_from_gz(file_path, variable_name=variable_name)
                    summary = summarize_swe(da)
                    trends.append(
                        {
                            "region": region_name,
                            "year": year,
                            "variable": variable_name,
                            "file_path": file_path,
                            "mean_value": summary["mean_value"],
                            "sum_value": summary["sum_value"],
                            "valid_count": summary["valid_count"],
                        }
                    )
                except ValueError as e:
                    print(f"Warning: {e}")
                    continue

    df = pd.DataFrame(trends)
    if df.empty:
        raise RuntimeError("No September 1st files found for the requested regions and year range.")

    return df.sort_values(["region", "variable", "year"]).reset_index(drop=True)


def plot_trend(df, output_path, value_column="mean_value"):
    """Plot trend lines for each region (one figure per region)."""
    regions = df["region"].unique()
    variables = df["variable"].unique()
    num_vars = len(variables)
    
    base_name, ext = os.path.splitext(output_path)
    
    for region in regions:
        region_df = df[df["region"] == region]
        fig, axes = plt.subplots(1, num_vars, figsize=(7 * num_vars, 6))
        if num_vars == 1:
            axes = [axes]

        for idx, variable in enumerate(variables):
            ax = axes[idx]
            var_df = region_df[region_df["variable"] == variable]
            
            ax.plot(var_df["year"], var_df[value_column], marker="o", color="steelblue", linewidth=2, markersize=6)
            ax.set_xlabel("Year")
            ax.set_ylabel(f"Mean {variable}")
            ax.set_title(f"{region} - September 1st {variable} Trend")
            ax.grid(True, alpha=0.3)

        plt.tight_layout()
        region_output = f"{base_name}_{region}{ext}"
        plt.savefig(region_output, dpi=200)
        plt.close()
        print(f"  Saved: {region_output}")


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Process gzipped NetCDF files and plot September 1st trends by region."
    )
    parser.add_argument("root_dir", help="Root directory containing one folder per region.")
    parser.add_argument(
        "--regions",
        nargs="*",
        default=None,
        help="Optional subset of region folder names to process. If omitted, all region folders are used.",
    )
    parser.add_argument(
        "--variables",
        nargs="*",
        default=["SWE"],
        help="Variables to extract from NetCDF files (default: SWE).",
    )
    parser.add_argument(
        "--start-year",
        type=int,
        default=None,
        help="Start year for the trend selection.",
    )
    parser.add_argument(
        "--end-year",
        type=int,
        default=None,
        help="End year for the trend selection.",
    )
    parser.add_argument(
        "--output-csv",
        default="swe_september_first_trend.csv",
        help="CSV file path to write the trend table.",
    )
    parser.add_argument(
        "--output-plot",
        default="swe_september_first_trend.png",
        help="Output plot image path.",
    )
    return parser.parse_args()


def main():
    args = parse_arguments()

    if args.regions:
        region_names = args.regions
    else:
        region_names = find_region_directories(args.root_dir)

    df = build_trend_dataframe(
        args.root_dir,
        region_names,
        variables=args.variables,
        start_year=args.start_year,
        end_year=args.end_year,
    )

    df.to_csv(args.output_csv, index=False)
    plot_trend(df, args.output_plot)
    print(f"Trend table written to: {args.output_csv}")
    print(f"Trend plot written to: {args.output_plot}")


if __name__ == "__main__":
    main()
