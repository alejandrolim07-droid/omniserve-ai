# OmniServe local intake pilot

This is a **working local proof** of persistent intake and deduplication, not the Supabase/n8n production deployment. It uses Node 24's built-in SQLite module and no external packages. Keep the generated database local: it contains names, email addresses, and messages. Use fictional test data only.

```bash
node --test pilot/*.test.mjs
node pilot/server.mjs
```

POST JSON to `http://127.0.0.1:8787/intake` with `source`, `external_message_id`, `consent: true`, `name`, `email`, and `message`. The first call returns HTTP 201 and a case ID; repeating the same source/message ID and payload returns HTTP 200 with the **same** case ID and `duplicate: true`. Reusing that ID with different content returns HTTP 409. The database file defaults to `omniserve-pilot.sqlite` at the working directory; set `OMNISERVE_PILOT_DB` to change it.

This pilot does not send email, call an LLM, or integrate with the existing n8n workflow. The next step is a dedicated OmniServe Supabase project and an atomic Postgres version of the same uniqueness constraint and audit event. Do not point it at the separate Ledgerline project.
