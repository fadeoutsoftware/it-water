#!/bin/bash
## Script that creates monting directories in the SCRATCH area, in case cleaning procedure have removed them 
## Invoked on the begininng of each round of the automatic orchestrators 
## Minimum computational impact, to keep it on the safe side all logs folders are reported in one single script
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/rcp85
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/rcp45
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_domain_logs/reanalysis

mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_time_logs/rcp85
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_time_logs/rcp45
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_time_logs/reanalysis


mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_archive_logs/rcp85
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_archive_logs/rcp45
mkdir -p /g100_scratch/userexternal/mmenapac/shared/merger_archive_logs/reanalysis
