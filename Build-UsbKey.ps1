#requires -version 4.0 -runasadministrator
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidatePattern({^[A-Z]:$})]
    [string]
    $TargetDrive,

    [switch]$Force = $false
)

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

$PSScriptFilePath = (Get-Item $MyInvocation.MyCommand.Path).FullName
$PSScriptRoot = Split-Path $PSScriptFilePath -Parent

function Get-Drive {
    param($deviceID)
    $drive = Get-WmiObject "Win32_Volume WHERE DriveLetter='$deviceID'"
    if (-not $drive) {
        throw "Drive not found"
    }
    $drive
}

function Format-Drive {
    param($drive, $label)
    # http://msdn.microsoft.com/en-us/library/windows/desktop/aa390432(v=vs.85).aspx
    $quick = $true
    $compressed = $false
    $null = $drive.Format("FAT32", $quick, 4096, $label, $compressed)
}

if (-not $Force -and
    @(gci $TargetDrive).Length -ne 0) {
    throw "Drive contains files but -Force not supplied; aborting"
}

$drive = Get-Drive $TargetDrive
Format-Drive $drive Neo4j
gci (Join-Path $PSScriptRoot .\USBKEY) | cpi -Destination $TargetDrive -Recurse
[System.Media.SystemSounds]::Asterisk.Play();
