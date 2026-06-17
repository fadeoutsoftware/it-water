# --- Configuration ---
$RemoteUser = "mmenapac"
$RemoteHost = "login.g100.cineca.it"
$RemoteBaseDir = "/g100_work/smr_prod/a07smr01/IT-WATER/S3M_output_recover/rcp45"
$LocalTargetDir = "./dataSeptember"

# Date parameters
$Month = "09"
$Day = "01"
$Time = "0000"

# 1. Discover all high-level region directories
$Regions = ssh "${RemoteUser}@${RemoteHost}" "ls -1d ${RemoteBaseDir}/*/" | ForEach-Object { 
    $_.TrimEnd('/').Split('/')[-1] 
}

if (-not $Regions) {
    Write-Host "No regions found." -ForegroundColor Red
    exit
}

# 2. Iterate through each region
foreach ($Region in $Regions) {
    Write-Host "--- Processing Region: $Region ---" -ForegroundColor Cyan
    
    # Discover available years for this specific region
    $RemoteRegionDir = "${RemoteBaseDir}/${Region}"
    $AvailableYears = ssh "${RemoteUser}@${RemoteHost}" "ls -1d ${RemoteRegionDir}/*/" | ForEach-Object {
        $_.TrimEnd('/').Split('/')[-1]
    }

    foreach ($Year in $AvailableYears) {
        $DestDir = Join-Path $LocalTargetDir $Region
        if (-not (Test-Path $DestDir)) { New-Item -Path $DestDir -ItemType Directory | Out-Null }

        $RemoteFile = "${RemoteRegionDir}/${Year}/${Month}/${Day}/S3M_${Year}${Month}${Day}${Time}.nc.gz"
        
        Write-Host "Attempting to download: $Year" -NoNewline
        
        # Execute scp
        scp -q -o BatchMode=yes "${RemoteUser}@${RemoteHost}:${RemoteFile}" "$DestDir/"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " -> Success." -ForegroundColor Green
        } else {
            Write-Host " -> [Skipped/Not Found]" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nProcess completed." -ForegroundColor Cyan