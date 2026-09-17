param(
  [string]$BaseUrl = "http://localhost:5678",
  [switch]$Production
)
$ErrorActionPreference = "Continue"
$mode = if ($Production) { "webhook" } else { "webhook-test" }
$payload = @{
  correlationId = "SMOKE-$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
  subjectType = "customer"
  subjectId = "demo-customer-001"
  confidence = 0.95
  message = "OmniServe automated smoke test"
} | ConvertTo-Json

$paths = @("omniserve-sla-assignment", "omniserve-lead-capture", "omniserve-service-request-intake", "omniserve-invoice-generation", "omniserve-central-event-collection", "omniserve-ai-confidence-gate")
foreach ($path in $paths) {
  try {
    $result = Invoke-RestMethod -Uri "$BaseUrl/$mode/$path" -Method POST -ContentType "application/json" -Body $payload
    Write-Host "PASS $path" -ForegroundColor Green
    $result | ConvertTo-Json -Depth 8
  } catch {
    Write-Host "FAIL $path : $($_.Exception.Message)" -ForegroundColor Red
  }
}
