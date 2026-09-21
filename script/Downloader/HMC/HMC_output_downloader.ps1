Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-Usage {
    Write-Error 'Usage: .\download_month.ps1 SSH_TARGET REMOTE_BASE_PATH YEAR MONTH DESTINATION_PATH'
    Write-Error '  SSH_TARGET: user@host or an SSH alias from ~/.ssh/config'
    Write-Error '  REMOTE_BASE_PATH: directory containing the domain folders'
}

if ($args.Count -ne 5) {
    Show-Usage
    exit 1
}

$SshTarget = $args[0]
$RemoteBase = $args[1].TrimEnd('/', '\')
$Year = $args[2]
$Month = $args[3]
$DestinationBase = $args[4]

if ($Year -notmatch '^[0-9]{4}$') {
    Write-Error "Invalid year: $Year"
    exit 1
}

if ($Month -notmatch '^(0?[1-9]|1[0-2])$') {
    Write-Error "Invalid month: $Month"
    exit 1
}
$Month = '{0:D2}' -f [int]$Month

function ConvertTo-RemoteShellQuoted([string]$Value) {
    return "'$($Value.Replace("'", "'\''"))'"
}

function Invoke-Ssh([string]$Command) {
    $output = & ssh -- $SshTarget $Command
    if ($LASTEXITCODE -ne 0) {
        throw "SSH command failed on ${SshTarget}: $Command"
    }
    return $output
}

function Test-RemoteDirectory([string]$RemotePath) {
    $RemotePathQuoted = ConvertTo-RemoteShellQuoted $RemotePath
    & ssh -- $SshTarget "test -d $RemotePathQuoted"
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 255) {
        throw "SSH connection failed on ${SshTarget} while checking: $RemotePath"
    }
    return $exitCode -eq 0
}

$RemoteBaseQuoted = ConvertTo-RemoteShellQuoted $RemoteBase
$Domains = @(Invoke-Ssh "find $RemoteBaseQuoted -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort") |
    Where-Object { $_.Trim() -ne '' }

if ($Domains.Count -eq 0) {
    Write-Error "No domain folders found under ${SshTarget}:$RemoteBase"
    exit 1
}

function Copy-Month([string]$RelativePath) {
    $RemotePath = "$RemoteBase/$RelativePath"

    if (-not (Test-RemoteDirectory $RemotePath)) {
        Write-Warning "Skipping missing remote path: $RelativePath"
        return
    }

    $DestinationPath = Join-Path $DestinationBase ($RelativePath -replace '/', [IO.Path]::DirectorySeparatorChar)
    $DestinationParent = Split-Path -Parent $DestinationPath
    New-Item -ItemType Directory -Path $DestinationParent -Force | Out-Null

    Write-Host "Downloading $RelativePath"
    $ScpSource = "${SshTarget}:$RemotePath"
    & scp -r -- $ScpSource "$DestinationParent/"
    if ($LASTEXITCODE -ne 0) {
        throw "SCP transfer failed for ${SshTarget}:$RemotePath"
    }
}

foreach ($Domain in $Domains) {
    foreach ($ModelRoot in @('model_results', 'model_state')) {
        foreach ($Frequency in @('gridded', 'point')) {
            Copy-Month "$Domain/$ModelRoot/$Frequency/$Year/$Month"
        }

        Copy-Month "$Domain/$ModelRoot/time_series/$Year-$Month"
    }
}

Write-Host "Selected assets copied to: $DestinationBase"