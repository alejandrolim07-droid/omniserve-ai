# n8n Credential Map

OmniServe workflows reference credentials by purpose. Secret values must be stored in n8n Credentials and must never be committed to GitHub.

## Credentials required now

| n8n credential name | Credential type | Used by | Required value |
|---|---|---|---|
| Supabase Service Role | Header Auth | Customer intake, identity matching, Customer 360 update | Header name `apikey`; value is the Supabase secret/service-role key |
| OpenAI API | Header Auth | Intent classification, priority scoring, sentiment detection | Header name `Authorization`; value is `Bearer YOUR_OPENAI_API_KEY` |

Restrict the Supabase credential to:

`https://rjudsonxkaohbqhxmvvw.supabase.co`

Restrict the OpenAI credential to:

`https://api.openai.com`

## Credentials planned for later departments

| n8n credential name | Credential type | Primary workflows |
|---|---|---|
| Gmail OAuth2 | Gmail OAuth2 | Acknowledgments, follow-ups, invoices and notifications |
| Twilio Account | Twilio | SMS, voice intake and urgent alerts |
| Slack Workspace | Slack OAuth2 | Human approvals, escalations and operational alerts |
| Notion Knowledge Base | Notion API | Knowledge retrieval, procedures and internal documentation |
| Stripe Account | Stripe API | Payment links, refunds, recurring billing and reconciliation |
| Analytics Destination | Provider-specific | KPI dashboards, forecasts and executive reports |
| CRM Connection | Provider-specific | Lead pipeline, ownership, opportunities and sales activity |

## Security rules

1. Never paste API keys into Code nodes, Set nodes, workflow JSON or GitHub.
2. Use separate development and production credentials.
3. Restrict HTTP credentials to the required domains.
4. Use Supabase service-role credentials only in server-side n8n workflows.
5. Rotate any credential immediately if it appears in a screenshot or commit.
6. Require human approval for refunds, discounts, payments, access changes and security actions.
7. Keep imported workflows inactive until credentials and test executions pass.

## Workflow status

- Customer Intake: implemented and previously tested
- Identity Matching: built; requires Supabase credential and runtime test
- Customer 360 Update: built; requires Supabase credential and runtime test
- Intent Classification: built; requires OpenAI credential and runtime test
- Priority Scoring: built; requires OpenAI credential and runtime test
- Sentiment Detection: built; requires OpenAI credential and runtime test
