import { createHash, randomUUID } from 'node:crypto';
import { DatabaseSync } from 'node:sqlite';

export class IntakeError extends Error {
  constructor(message) {
    super(message);
    this.name = 'IntakeError';
  }
}

export class ConflictError extends IntakeError {
  constructor() {
    super('external_message_id already belongs to a different request');
    this.name = 'ConflictError';
  }
}

function requiredString(value, label, maxLength) {
  if (typeof value !== 'string' || !value.trim() || value.trim().length > maxLength) {
    throw new IntakeError(`${label} must be a nonempty string of at most ${maxLength} characters`);
  }
  return value.trim();
}

export function normalizeIntake(input) {
  if (!input || typeof input !== 'object' || Array.isArray(input)) {
    throw new IntakeError('request must be an object');
  }
  if (input.consent !== true) throw new IntakeError('consent must be true');

  const source = requiredString(input.source ?? 'web_form', 'source', 40).toLowerCase();
  const externalMessageId = requiredString(input.external_message_id, 'external_message_id', 160);
  const name = requiredString(input.name, 'name', 160);
  const email = requiredString(input.email, 'email', 254).toLowerCase();
  const message = requiredString(input.message, 'message', 5000);
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new IntakeError('email is invalid');

  const text = message.toLowerCase();
  const includesAny = (terms) => terms.some((term) => text.includes(term));
  const department = includesAny(['invoice', 'billing', 'charged', 'refund', 'payment'])
    ? 'BILLING'
    : includesAny(['price', 'pricing', 'quote', 'demo', 'purchase'])
      ? 'SALES' : 'CUSTOMER_SUPPORT';
  const priority = includesAny(['security breach', 'fraud', 'account hacked', 'data loss'])
    ? 'CRITICAL'
    : includesAny(['urgent', 'charged twice', 'duplicate charge', 'locked out'])
      ? 'HIGH' : 'NORMAL';
  const requiresHumanReview = department === 'BILLING' || priority === 'HIGH' || priority === 'CRITICAL';
  return { source, externalMessageId, name, email, message, department, priority, requiresHumanReview };
}

export function openStore(filename = ':memory:') {
  const db = new DatabaseSync(filename);
  db.exec(`
    PRAGMA foreign_keys = ON;
    CREATE TABLE IF NOT EXISTS customers (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL
    );
    CREATE TABLE IF NOT EXISTS cases (
      id TEXT PRIMARY KEY, customer_id TEXT NOT NULL REFERENCES customers(id),
      source TEXT NOT NULL, external_message_id TEXT NOT NULL,
      fingerprint TEXT NOT NULL,
      message TEXT NOT NULL, department TEXT NOT NULL, priority TEXT NOT NULL,
      requires_human_review INTEGER NOT NULL, status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      UNIQUE (source, external_message_id)
    );
    CREATE INDEX IF NOT EXISTS cases_customer_idx ON cases(customer_id);
    CREATE TABLE IF NOT EXISTS case_events (
      id TEXT PRIMARY KEY, case_id TEXT NOT NULL REFERENCES cases(id),
      event_type TEXT NOT NULL, created_at TEXT NOT NULL
    );
    CREATE INDEX IF NOT EXISTS case_events_case_idx ON case_events(case_id);
  `);

  const findCase = db.prepare('SELECT id, customer_id, fingerprint, department, priority, requires_human_review, status FROM cases WHERE source = ? AND external_message_id = ?');
  const findCustomer = db.prepare('SELECT id FROM customers WHERE email = ?');
  const insertCustomer = db.prepare('INSERT INTO customers (id, name, email, created_at) VALUES (?, ?, ?, ?)');
  const insertCase = db.prepare('INSERT INTO cases (id, customer_id, source, external_message_id, fingerprint, message, department, priority, requires_human_review, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
  const insertEvent = db.prepare('INSERT INTO case_events (id, case_id, event_type, created_at) VALUES (?, ?, ?, ?)');

  function intake(input) {
    const item = normalizeIntake(input);
    const fingerprint = createHash('sha256').update(JSON.stringify([
      item.source, item.externalMessageId, item.name, item.email, item.message,
    ])).digest('hex');
    db.exec('BEGIN IMMEDIATE');
    try {
      const existing = findCase.get(item.source, item.externalMessageId);
      if (existing) {
        if (existing.fingerprint !== fingerprint) throw new ConflictError();
        db.exec('COMMIT');
        return toResult(existing, true);
      }
      const now = new Date().toISOString();
      let customerId = findCustomer.get(item.email)?.id;
      if (!customerId) {
        customerId = randomUUID();
        insertCustomer.run(customerId, item.name, item.email, now);
      }
      const caseId = randomUUID();
      insertCase.run(caseId, customerId, item.source, item.externalMessageId, fingerprint, item.message,
        item.department, item.priority, Number(item.requiresHumanReview), 'NEW', now);
      insertEvent.run(randomUUID(), caseId, 'CASE_CREATED', now);
      db.exec('COMMIT');
      return toResult(findCase.get(item.source, item.externalMessageId), false);
    } catch (error) {
      db.exec('ROLLBACK');
      throw error;
    }
  }

  return {
    intake,
    count(table) {
      if (!['customers', 'cases', 'case_events'].includes(table)) throw new IntakeError('unknown table');
      return db.prepare(`SELECT count(*) AS count FROM ${table}`).get().count;
    },
    close() { db.close(); },
  };
}

function toResult(row, duplicate) {
  return {
    accepted: true,
    duplicate,
    caseId: row.id,
    customerId: row.customer_id,
    department: row.department,
    priority: row.priority,
    requiresHumanReview: Boolean(row.requires_human_review),
    status: row.status,
  };
}
