 # HMC output downloader

These scripts download one selected month of HMC output from a remote server
over SSH, using recursive `scp`. The remote dataset must contain one folder per
model domain, for example `AdigeDomain`, `ToscanaDomain`, or `PoBasin`.

## Requirements

- SSH access to the remote server, configured either as `user@host` or as an
	alias in `~/.ssh/config`.
- The OpenSSH `ssh` and `scp` commands available in the shell.
- Read permission for the remote HMC output directory.
- For the Bash script, Bash 4 or newer is recommended because it uses
	`mapfile`.
- For the PowerShell script, Windows PowerShell or PowerShell 7 with OpenSSH
	available on `PATH`.

The scripts do not ask for the password themselves. SSH keys or the normal
OpenSSH password prompt are used by `ssh` and `scp`.

## Scripts

- `HMC_output_downloader.sh`: Bash version for Linux, WSL, or another Unix
	shell.
- `HMC_output_downloader.ps1`: PowerShell version for Windows.

Both scripts have the same arguments:

```text
SSH_TARGET REMOTE_BASE_PATH YEAR MONTH DESTINATION_PATH
```

Where:

- `SSH_TARGET` is the remote login, such as `mmenapac@login.g100.cineca.it`.
- `REMOTE_BASE_PATH` is the remote directory containing the domain folders.
- `YEAR` is a four-digit year, such as `2015`.
- `MONTH` is a month from `1` to `12`; both `7` and `07` are accepted.
- `DESTINATION_PATH` is the local directory where the selected data is stored.

## PowerShell usage

Run this from the HMC Downloader directory:

```powershell
.\HMC_output_downloader.ps1 `
	[user]@login.g100.cineca.it `
	/g100_work/smr_prod/a07smr01/IT-WATER/HMC_output/reanalysis `
	2015 `
	07 `
	.\input
```

The same command can be written on one line:

```powershell
.\HMC_output_downloader.ps1 mmenapac@login.g100.cineca.it /g100_work/smr_prod/a07smr01/IT-WATER/HMC_output/reanalysis 2015 07 .\input
```

## Bash usage

Run this from the HMC Downloader directory:

```bash
bash HMC_output_downloader.sh \
	mmenapac@login.g100.cineca.it \
	/g100_work/smr_prod/a07smr01/IT-WATER/HMC_output/reanalysis \
	2015 \
	07 \
	./input
```

On a Unix filesystem, the Bash script can also be made executable and run
directly:

```bash
chmod +x HMC_output_downloader.sh
./HMC_output_downloader.sh user@host /remote/HMC_output/reanalysis 2015 07 ./input
```

## What the scripts do

1. Validate the year and month.
2. Connect with `ssh` and discover every first-level directory under
	 `REMOTE_BASE_PATH`.
3. For each domain, check these monthly paths:

	 ```text
	 model_results/gridded/YYYY/MM
	 model_results/point/YYYY/MM
	 model_results/time_series/YYYY-MM
	 model_state/gridded/YYYY/MM
	 model_state/point/YYYY/MM
	 model_state/time_series/YYYY-MM
	 ```

4. Skip paths that do not exist on the remote server.
5. Download each existing directory with `scp -r`.
6. Create the required local parent directories and preserve the relative
	 remote structure.

The `model_state/time_series` path is checked for consistency, but it is
normally absent in the HMC output dataset and is therefore skipped.

## Resulting structure

For example, downloading July 2015 to `./input` produces paths like:

```text
input/
└── AdigeDomain/
		├── model_results/
		│   ├── gridded/2015/07/
		│   ├── point/2015/07/
		│   └── time_series/2015-07/
		└── model_state/
				├── gridded/2015/07/
				└── point/2015/07/
```

Existing files are handled by `scp` according to its normal behavior. The
script does not delete files from the destination or from the remote server.
