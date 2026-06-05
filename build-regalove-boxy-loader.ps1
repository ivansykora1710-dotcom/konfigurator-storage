param(
  [string]$SourceHtml = "shoptet-vlozenie-regalove-boxy.html",
  [string]$Loader = "assets-loader-rb-v3.js"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root $SourceHtml
$loaderPath = Join-Path $root $Loader

if (!(Test-Path $sourcePath)) {
  throw "Source HTML not found: $sourcePath"
}

if (!(Test-Path $loaderPath)) {
  throw "Loader file not found: $loaderPath"
}

$html = Get-Content -Raw -Path $sourcePath
$bytes = [System.Text.Encoding]::UTF8.GetBytes($html)
$b64 = [Convert]::ToBase64String($bytes)

$loaderContent = Get-Content -Raw -Path $loaderPath
$pattern = "var HTML_B64 = '[^']*';"

if (![regex]::IsMatch($loaderContent, $pattern)) {
  throw "Cannot find HTML_B64 payload in loader: $loaderPath"
}

$updated = [regex]::Replace($loaderContent, $pattern, "var HTML_B64 = '$b64';", 1)
Set-Content -Path $loaderPath -Value $updated -Encoding UTF8

Write-Host "Updated loader:" $loaderPath
Write-Host "Source HTML bytes:" $bytes.Length
Write-Host "Base64 chars:" $b64.Length
