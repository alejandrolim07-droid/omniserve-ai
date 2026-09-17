param([string]$Root = (Resolve-Path "$PSScriptRoot\.."))
$ErrorActionPreference = "Stop"
$files = Get-ChildItem -Path "$Root\n8n-workflows" -Filter "*.json" -Recurse | Sort-Object FullName
Write-Host "Importing $($files.Count) OmniServe workflows into local n8n..."
foreach ($file in $files) {
  Write-Host "Importing $($file.Name)"
  npx n8n import:workflow --input="$($file.FullName)"
}
Write-Host "Import finished. Open http://localhost:5678 and attach credentials before activation."
