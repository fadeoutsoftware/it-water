# Traiettorie Regionali — SWE & Ice Thickness Processing

This repository contains tools to collect and analyse first-September model output files (gzipped NetCDF) produced with the S3M naming convention. It includes:

- [process_swe_trends.py](process_swe_trends.py) — Python script to extract variables (default `SWE`) from gzipped NetCDF files, compute summary statistics on September 1st files and produce CSV + per-region plots.
- [PSDownloadFisrtSeptember.ps1](PSDownloadFisrtSeptember.ps1) — PowerShell helper (user-supplied) to download or collect the "first September" files into a local directory structure.

**Prerequisites**
- Python 3.8+ (recommended inside a virtual environment)
- Install Python dependencies:

```bash
pip install -r requirements.txt
```

**Data layout expected by `process_swe_trends.py`**
- Root directory contains one folder per region (folder name = region name).
- For each region folder, all first-September gzipped NetCDF files are present and follow the filename pattern:

```
S3M_YYYYMMDDHHMM.nc.gz
```

Example (partial):
```
data/RegionA/S3M_202309011200.nc.gz
data/RegionA/S3M_202409011200.nc.gz
...
```

If you use `PSDownloadFisrtSeptember.ps1`, run it to populate the `data/` folder before running the Python script.

**process_swe_trends.py — What it does**
- Walks the region folders provided by `root_dir`.
- For each gzipped file matching `S3M_YYYYMMDDHHMM.nc.gz`, it selects one file per year (the earliest timestamp if duplicates exist).
- Decompresses each `.nc.gz` to a temporary `.nc` file and opens it with `xarray`/`netCDF4`.
- Extracts one or more variables (default: `SWE`; you can also request `Ice_Thickness` or other variable names available in your files).
- Replaces negative values with `NaN` (masking values < 0) before summary.
- Computes simple summaries per file: mean, sum and valid cell count.
- Produces:
  - A CSV table with rows: `region`, `year`, `variable`, `mean_value`, `sum_value`, `valid_count`, `file_path`.
  - One PNG per region (named `<output_basename>_<RegionName>.png`) with one subplot per requested variable showing the year-by-year mean values.

**Basic usage**

Process only `SWE` (default):

```bash
python process_swe_trends.py data/
```

Process both `SWE` and `Ice_Thickness` (example):

```bash
python process_swe_trends.py data/ --variables SWE Ice_Thickness --start-year 2023 --end-year 2050 --output-csv swe_trend.csv --output-plot swe_trend.png
```

This will write `swe_trend.csv` and per-region PNG files such as `swe_trend_RegionA.png`.

If you only want specific regions:

```bash
python process_swe_trends.py data/ --regions RegionA RegionB --variables SWE
```

**PSDownloadFisrtSeptember.ps1 — Typical behaviour & example**

The PowerShell script is intended to download or gather the S3M first-September files into a local folder structure that matches the input expected by `process_swe_trends.py`.

Common usage pattern (the script's exact parameters may vary):

```powershell
# Example that downloads or copies files into .\data\<RegionName> folders
.\PSDownloadFisrtSeptember.ps1 -TargetDir .\data -StartYear 2023 -EndYear 2069 -Regions RegionA,RegionB
```

After running it, verify that each region folder contains files named like `S3M_202309011200.nc.gz`.

**Notes & troubleshooting**
- The script uses `netCDF4` (PyPI package name `netCDF4`) via `xarray`. If you see build errors for low-level geospatial packages (e.g., `gdal`), you can often avoid them for this script — `gdal` is not required.
- If you get `ModuleNotFoundError: No module named 'netCDF4'`, install with:

```bash
pip install netCDF4
```

- If `xarray` cannot open compressed streams directly, the script writes each `.nc.gz` to a temporary `.nc` file before opening; temporary files are removed after read.

**Output examples**

CSV snippet (header):

```
region,year,variable,file_path,mean_value,sum_value,valid_count
RegionA,2023,SWE,./data/RegionA/S3M_202309011200.nc.gz,0.1234,12345.6,10000
RegionA,2024,SWE,./data/RegionA/S3M_202409011200.nc.gz,0.0987,9876.5,10002
RegionA,2023,Ice_Thickness,./data/RegionA/S3M_202309011200.nc.gz,0.55,55000.0,10000
```

Per-region plot files (one per region) show year on the x-axis and mean variable value on the y-axis.

