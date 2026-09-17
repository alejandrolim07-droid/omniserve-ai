# Examples for All 100 OmniServe Workflows

Every example below uses fictional data. It shows a realistic trigger and the expected business outcome. Provider-specific actions such as sending email, processing Stripe payments, or creating calendar events require the corresponding n8n credential and provider node during deployment.

## Customer Operations

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 1 | Omnichannel Intake | Maria submits “I was charged twice” through a web form; n8n standardizes the contact and message into a customer request. |
| 2 | Identity Matching | The request contains `maria@example.com`; Supabase returns Maria’s existing customer ID instead of creating another profile. |
| 3 | Customer 360 Update | Maria supplies a new phone number; the shared customer profile is updated while previous cases remain connected. |
| 4 | Intent Classification | The message mentions a duplicate charge and refund; AI labels it `BILLING_REFUND`. |
| 5 | Priority Scoring | A VIP customer reports service loss; the workflow increases the case priority to `CRITICAL`. |
| 6 | Sentiment Detection | “I have contacted you three times” is detected as frustrated sentiment and added to routing context. |
| 7 | SLA Assignment | A high-priority billing case receives a 30-minute response deadline and four-hour resolution target. |
| 8 | Case Creation | The validated request becomes case `CASE-DEMO-001` with owner, priority, department, and audit event. |
| 9 | Duplicate Detection | An open case already contains the same invoice and complaint; the new interaction is attached instead of creating another case. |
| 10 | Department Routing | A refund complaint is routed to Billing while a product inquiry is routed to Sales. |
| 11 | AI Response Draft | AI drafts a polite acknowledgment referencing the invoice and next steps without sending it automatically. |
| 12 | Knowledge Retrieval | The workflow finds the refund policy and duplicate-payment troubleshooting article for the assigned agent. |
| 13 | Human Escalation | Low AI confidence and an angry VIP customer create a senior-agent escalation. |
| 14 | Agent Assignment | A Cebu-based Bisaya-speaking support agent with available capacity receives the case. |
| 15 | Instant Acknowledgment | The customer receives the case number and expected response time immediately after intake. |
| 16 | Follow-Up Scheduling | A callback requested for tomorrow at 2 PM creates a follow-up task for the assigned agent. |
| 17 | Inactivity Reminder | A case waiting on the customer for 48 hours sends a reminder and records the attempt. |
| 18 | Status Notification | Moving a case to `IN_PROGRESS` sends the customer a status update. |
| 19 | Resolution Confirmation | After a refund correction, the customer is asked whether the billing problem is resolved. |
| 20 | Satisfaction Survey | Closing a case sends a one-to-five CSAT question and stores the result. |
| 21 | Complaint Management | A formal complaint about repeated incorrect charges receives a compliance deadline and manager review. |
| 22 | VIP Customer Handling | A strategic account receives priority routing and a dedicated account-owner alert. |
| 23 | Churn-Risk Alert | Repeated complaints, negative sentiment, and reduced activity create a retention alert. |
| 24 | Case Reopening | The customer replies that the problem returned; the closed case is reopened with its original history. |
| 25 | Interaction Timeline | An agent sees the web request, emails, calls, payments, decisions, and case changes in time order. |

## Sales and Growth

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 26 | Lead Capture | Daniel submits a landing-page form for real-estate CRM automation; a new lead record and source are stored. |
| 27 | Lead Enrichment | The company domain is used to add industry, company size, location, and website details. |
| 28 | AI Lead Qualification | The workflow identifies budget, business need, timeline, and decision authority and labels the lead qualified. |
| 29 | Lead Scoring | Strong need, ₱250,000 budget, and a 30-day timeline produce a score of 88/100. |
| 30 | Sales Representative Assignment | A qualified property-industry lead is assigned to the representative specializing in real estate. |
| 31 | Instant Lead Response | Daniel immediately receives a personalized message confirming that the team will contact him. |
| 32 | Personalized Sales Sequence | The lead enters a five-message sequence about lead capture, qualification, and CRM automation. |
| 33 | Meeting Booking | Daniel selects an available Tuesday slot and the meeting is added to the sales calendar. |
| 34 | Meeting Reminder | Email and SMS reminders are scheduled 24 hours and one hour before the meeting. |
| 35 | No-Show Recovery | Daniel misses the call and automatically receives a friendly rescheduling link. |
| 36 | Quote Generation | Selected setup services and monthly support are converted into an itemized quotation. |
| 37 | Proposal Generation | Customer requirements, proposed architecture, timeline, deliverables, and price become a branded proposal. |
| 38 | Discount Approval | A requested 20% discount exceeds the representative’s limit and waits for sales-manager approval. |
| 39 | Proposal Follow-Up | No response after three business days creates a follow-up email and sales task. |
| 40 | CRM Pipeline Update | When the proposal is sent, the opportunity moves from `DISCOVERY` to `PROPOSAL`. |
| 41 | Dormant Lead Reactivation | A lead inactive for 90 days receives a relevant case study and consultation offer. |
| 42 | Upsell Recommendation | A customer using the basic plan is recommended advanced AI qualification based on lead volume. |
| 43 | Cross-Sell Recommendation | A CRM customer is recommended appointment reminders and customer-support automation. |
| 44 | Referral Program | A satisfied customer receives a unique referral code and future conversions are attributed to it. |
| 45 | Sales Forecasting | Pipeline value, stage probability, and historical conversion produce next-month revenue projections. |

## Service Delivery

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 46 | Service Request Intake | An approved customer requests CRM setup; requirements and preferred dates become a service request. |
| 47 | Customer Onboarding | The customer receives setup steps, required documents, access instructions, and an orientation schedule. |
| 48 | Work Order Creation | The approved request becomes a work order with scope, owner, due date, and required resources. |
| 49 | AI Task Breakdown | “Build lead qualification system” becomes tasks for intake, scoring, CRM, notifications, testing, and training. |
| 50 | Team Assignment | Frontend, automation, and database tasks are assigned according to skills and workload. |
| 51 | Capacity Checking | The system detects that the automation engineer is unavailable this week and suggests the next valid start date. |
| 52 | Service Scheduling | Customer availability and team capacity produce a confirmed implementation schedule. |
| 53 | Document Collection | Missing brand guidelines, CRM access, and field definitions trigger a structured document request. |
| 54 | Milestone Tracking | Completing the intake integration updates progress to 25% and notifies stakeholders. |
| 55 | Dependency Alerting | CRM credentials are late, so configuration and testing tasks are marked at risk. |
| 56 | Department Handoff | Sales transfers the signed scope, customer goals, promises, and contact details to delivery. |
| 57 | Pre-Delivery Quality Check | Required test cases, security checks, documentation, and customer acceptance must pass before launch. |
| 58 | Delivery Confirmation | The customer accepts the completed automation and the confirmation is stored with the work order. |
| 59 | Change-Request Management | Adding WhatsApp changes scope, cost, timeline, and approval requirements. |
| 60 | Incident Management | A production webhook failure creates a high-priority incident with owner and response deadline. |
| 61 | Maintenance Scheduling | A monthly integration health check is scheduled for all active customer automations. |
| 62 | Renewal Preparation | Thirty days before renewal, usage, incidents, value delivered, and pricing are prepared for review. |
| 63 | Vendor Coordination | A messaging provider receives configuration requirements and a deadline; its response is tracked. |
| 64 | Delivery SLA Monitoring | A work order approaching its deadline with incomplete dependencies creates an operations alert. |
| 65 | Post-Delivery Review | Seven days after launch, the customer rates delivery and the team records lessons learned. |

## Finance and Administration

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 66 | Invoice Generation | An accepted proposal creates invoice `INV-DEMO-001` containing setup and monthly-support items. |
| 67 | Payment-Link Delivery | The customer receives the provider’s secure payment URL by email. |
| 68 | Payment Confirmation | A payment webhook marks the invoice paid, creates a receipt event, and notifies the customer. |
| 69 | Overdue Invoice Detection | An invoice seven days past due becomes an overdue item assigned to Finance. |
| 70 | Payment Reminders | Reminders are scheduled three days before, on, and five days after the due date. |
| 71 | Refund Request Processing | A duplicate-payment request collects transaction ID, amount, reason, and evidence. |
| 72 | Refund Approval Routing | A ₱1,500 refund exceeds the automatic threshold and creates a pending human approval. |
| 73 | Payment Reconciliation | The provider transaction is matched with the invoice and duplicate records are flagged. |
| 74 | Expense Capture | A software receipt is uploaded and recorded with vendor, category, project, and amount. |
| 75 | Expense Approval | A large expense waits for the project manager and Finance before reimbursement. |
| 76 | Recurring Billing | Monthly support creates the next invoice and records a retry if payment fails. |
| 77 | Credit-Note Generation | An approved partial refund creates a credit note linked to the original invoice. |
| 78 | Tax Document Preparation | Monthly invoices and payments are organized by tax category for accountant review. |
| 79 | Contract Renewal | A contract expiring in 30 days starts review, pricing, approval, and signature tasks. |
| 80 | Daily Financial Summary | Finance receives totals for paid, overdue, refunded, and unreconciled transactions. |

## Data and Intelligence

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 81 | Central Event Collection | Events from support, sales, delivery, and finance are written to one queryable event history. |
| 82 | Data Validation | A lead without email or phone is rejected with a clear validation error. |
| 83 | Duplicate Data Cleanup | Two profiles with the same email and similar names are proposed for human-reviewed merging. |
| 84 | Unified Customer Profile | Cases, purchases, service orders, payments, and conversations are combined for one customer view. |
| 85 | KPI Dashboard Updates | New executions update SLA compliance, response time, conversion, revenue, and satisfaction metrics. |
| 86 | Demand Forecasting | Six months of service requests are used to estimate next month’s staffing demand. |
| 87 | Anomaly Detection | Refund volume rising three times above normal creates a Finance and Risk alert. |
| 88 | Customer Segmentation | Customers are grouped into new, active, VIP, at-risk, and dormant segments. |
| 89 | Conversation Trend Analysis | A sudden increase in “incorrect charge” complaints becomes an emerging billing trend. |
| 90 | Executive AI Report | Leadership receives a concise report of KPIs, risks, causes, and recommended actions. |

## QA, Risk, and Governance

| # | Workflow | Example trigger and expected result |
|---:|---|---|
| 91 | AI Confidence Gate | A classification with confidence 0.61 is blocked and sent to a person. |
| 92 | Human Approval Control | A manager approves the pending refund and the event changes from awaiting approval to approved. |
| 93 | PII Detection and Redaction | A message containing a card number and government ID is masked before being stored in analytics. |
| 94 | Customer Consent Tracking | Marketing messages are permitted only after the customer’s consent timestamp is recorded. |
| 95 | Role-Based Access Control | A support agent can view cases but cannot approve refunds or export financial data. |
| 96 | Complete Audit Logging | The system records the workflow, actor, resource, decision, timestamp, and details for every important action. |
| 97 | Policy Compliance Check | A proposed refund outside policy is blocked and sent to Compliance. |
| 98 | Fraud and Abuse Detection | Multiple refund requests from the same account and payment create a fraud-review case. |
| 99 | Interaction Quality Scoring | A support conversation is scored for accuracy, empathy, compliance, and resolution quality. |
| 100 | Security Incident and Data Retention | Suspicious access creates an incident while expired records are queued for policy-approved deletion. |

## How to execute an example

Choose the workflow, click **Listen for test event** in n8n, and post the closest JSON file from the `examples/` directory to its test webhook. Confirm the response, `automation_events` row, `audit_log` entry, and any required `approval_requests` row before activation.
