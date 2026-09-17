# OmniServe AI Architecture

```mermaid
flowchart TD
    Channels["Customer channels<br/>Voice · Email · Chat · Web · SMS"]
    N8N["n8n automation engine"]
    AI["AI triage<br/>Intent · Priority · Sentiment · Risk"]
    DB["Supabase Customer 360<br/>Customers · Cases · Events · Billing · Audit"]
    Agents["Department agents<br/>Sales · Support · Billing · Operations · QA"]
    Gate["Automated action or human approval"]
    Response["Customer response"]
    Learn["Reporting and continuous improvement"]

    Channels --> N8N
    N8N --> AI
    AI <--> DB
    AI --> Agents
    Agents --> Gate
    Gate --> Response
    Response --> DB
    DB --> Learn
    Learn --> N8N
```

## Design principles

- One shared Customer 360 is the source of truth.
- Each workflow is independently importable and testable.
- Credentials stay in n8n and are never committed to GitHub.
- High-risk, low-confidence and financial actions can require human approval.
- Every important action produces an auditable event.
- Reusable sub-workflows handle authentication, logging, errors and notifications.

## Connected stack

- n8n for orchestration
- Supabase/PostgreSQL for operational data
- OpenAI API for classification, drafting and analysis
- Notion for internal knowledge and operating procedures
- Gmail and Twilio for communication
- Slack for team notifications and approvals
- Payment providers for billing actions
- Analytics tools for dashboards and reporting
