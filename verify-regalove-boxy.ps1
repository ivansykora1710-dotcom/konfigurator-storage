param(
  [string]$SourceHtml = "shoptet-vlozenie-regalove-boxy.html"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root $SourceHtml

if (!(Test-Path $sourcePath)) {
  throw "Source HTML not found: $sourcePath"
}

$html = Get-Content -Raw -Path $sourcePath

function Get-Number($text) {
  if ($null -eq $text) { return $null }
  return [double](($text -replace ",", ".") -replace "[^\d\.]", "")
}

$crateMatches = [regex]::Matches($html, '(?s)(RK964\d{3}):\s*\{\s*code:\s*"(?<code>RK964\d{3})".*?dimensions:\s*"(?<dimensions>[^"]+)".*?\}')
$accessoryBlock = [regex]::Match($html, '(?s)var accessories = \{(?<body>.*?)\n  \};')

if (!$accessoryBlock.Success) {
  throw "Cannot find accessories block."
}

$crateWidths = @{}
foreach ($match in $crateMatches) {
  $code = $match.Groups["code"].Value
  $dims = $match.Groups["dimensions"].Value
  $parts = $dims -split "\s*x\s*"
  if ($parts.Count -ge 2) {
    $crateWidths[$code] = Get-Number $parts[1]
  }
}

$errors = New-Object System.Collections.Generic.List[string]
$rows = [regex]::Matches($accessoryBlock.Groups["body"].Value, '(?s)(RK964\d{3}):\s*\{(?<kit>.*?)\n    \}')

foreach ($row in $rows) {
  $crate = $row.Groups[1].Value
  $expectedWidth = $crateWidths[$crate]
  if ($null -eq $expectedWidth) {
    $errors.Add("${crate}: missing crate dimensions")
    continue
  }

  foreach ($kind in @("front", "inner")) {
    $item = [regex]::Match($row.Groups["kit"].Value, "$kind" + ':\s*\{(?<item>.*?)\}')
    if (!$item.Success) {
      $errors.Add("${crate}: missing $kind divider")
      continue
    }

    $code = [regex]::Match($item.Groups["item"].Value, 'code:\s*"([^"]+)"').Groups[1].Value
    $dimensions = [regex]::Match($item.Groups["item"].Value, 'dimensions:\s*"([^"]+)"').Groups[1].Value
    $dividerWidth = Get-Number (($dimensions -split "\s*x\s*")[0])

    if ([math]::Abs($expectedWidth - $dividerWidth) -gt 0.01) {
      $errors.Add("${crate}: $kind $code has width $dividerWidth cm, expected $expectedWidth cm")
    }
  }
}

if ($errors.Count -gt 0) {
  Write-Host "Compatibility audit failed:" -ForegroundColor Red
  $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host "OK: front and inner divider widths match all crate widths." -ForegroundColor Green
