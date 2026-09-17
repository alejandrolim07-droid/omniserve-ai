# Credential Map

Do not paste real keys into workflow JSON, GitHub, screenshots, issues, or chat messages.

## Required for the shared core

| n8n credential | Type | Value | Used by |
|---|---|---|---|
| OmniServe Supabase Service Role | Header Auth | Name `apikey`; value is the Supabase secret/service-role key | Customer 360, event persistence, approvals, audit |
| OmniServe OpenAI | Header Auth | Name `Authorization`; value `Bearer YOUR_OPENAI_API_KEY` | AI workflows 004-006 and future AI action nodes |

## Channel credentials added during runtime rollout

| Credential | Typical n8n type | Purpose |
|---|---|---|
| Gmail or Microsoft 365 | OAuth2 | Email intake and replies |
| Twilio | Twilio API | Voice and SMS |
| Slack | Slack OAuth2 | Internal alerts and approvals |
| Notion | Notion API | Knowledge and operating pages |
| Stripe | Stripe API | Payments, invoices, refunds |
| CRM | Provider OAuth/API | Leads, opportunities, pipeline |
| Analytics | Provider OAuth/API | Dashboards and reporting |

Generated workflows 007-100 use the shared Supabase RPC and import without embedded credentials. Attach provider credentials only when replacing a placeholder department action with a real external action.
