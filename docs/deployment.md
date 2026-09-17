# Deployment Checklist

## Database

- [ ] Run migrations `001` through `004` in order.
- [ ] Confirm `automation_events`, `approval_requests`, and `audit_log` exist.
- [ ] Confirm `process_automation_event` and `decide_approval` are callable with the service-role key.
- [ ] Configure backups and retention.

## n8n

- [ ] Import all 100 workflows.
- [ ] Attach the Supabase Header Auth credential.
- [ ] Attach OpenAI only to workflows that need it.
- [ ] Test each workflow with test webhooks.
- [ ] Verify a database event and audit record for each test.
- [ ] Verify high-risk tests create `PENDING` approval requests.
- [ ] Activate only validated workflows.

## Operations

- [ ] Set approval owners and monetary thresholds.
- [ ] Add failure notifications and on-call routing.
- [ ] Add provider-specific Gmail, Twilio, Slack, Notion, Stripe, and CRM nodes.
- [ ] Document incident response and rollback.
- [ ] Review RLS and least-privilege access.
- [ ] Obtain legal/privacy review for voice recording, PII, consent, and retention.

## Evidence required before claiming production-ready

For each workflow record: test timestamp, n8n execution ID, result, Supabase event ID, reviewer, and activation status.
