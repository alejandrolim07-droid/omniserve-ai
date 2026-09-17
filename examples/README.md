# OmniServe Example Payloads

These files provide safe fictional data for demonstrating each department. They use the common OmniServe request contract and contain no real customer information or credentials.

| File | Suggested workflow |
|---|---|
| `customer-operations.json` | Omnichannel Intake or Case Creation |
| `sales-growth.json` | Lead Capture or AI Lead Qualification |
| `service-delivery.json` | Service Request Intake or Work Order Creation |
| `finance-admin.json` | Invoice Generation or Refund Request Processing |
| `data-intelligence.json` | Central Event Collection or KPI Dashboard Updates |
| `qa-risk-governance.json` | AI Confidence Gate or Human Approval Control |

## PowerShell example

Start the selected workflow in n8n using **Listen for test event**, then run:

```powershell
$body = Get-Content ".\examples\customer-operations.json" -Raw

Invoke-RestMethod `
  -Uri "http://localhost:5678/webhook-test/omniserve-case-creation" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

For an active workflow, replace `webhook-test` with `webhook`.

## Expected low-risk result

The response should contain `success: true`, an event ID, no approval ID, and status `READY`.

## Expected approval result

Set `amount` to `1500`, `confidence` below `0.70`, or `forceHumanReview` to `true`. The response should contain status `AWAITING_APPROVAL` and Supabase should contain a pending `approval_requests` record.

