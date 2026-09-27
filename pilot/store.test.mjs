import test from 'node:test';
import assert from 'node:assert/strict';
import { openStore, normalizeIntake, IntakeError, ConflictError } from './store.mjs';

const payload = {
  source: 'web_form', external_message_id: 'demo-001', consent: true,
  name: 'Sample Customer', email: 'Sample@Example.com', message: 'I was charged twice. Urgent help please.'
};

test('two deliveries persist one customer, case, and creation event', () => {
  const store = openStore();
  try {
    const first = store.intake(payload);
    const second = store.intake(payload);
    assert.equal(first.duplicate, false);
    assert.equal(second.duplicate, true);
    assert.equal(first.caseId, second.caseId);
    assert.equal(first.department, 'BILLING');
    assert.equal(first.priority, 'HIGH');
    assert.equal(first.requiresHumanReview, true);
    assert.equal(store.count('customers'), 1);
    assert.equal(store.count('cases'), 1);
    assert.equal(store.count('case_events'), 1);
  } finally { store.close(); }
});

test('a second message from the same email creates a new case but not a customer', () => {
  const store = openStore();
  try {
    store.intake(payload);
    store.intake({ ...payload, external_message_id: 'demo-002', message: 'Can I get a quote?' });
    assert.equal(store.count('customers'), 1);
    assert.equal(store.count('cases'), 2);
  } finally { store.close(); }
});

test('reused message ID with different content is rejected without new writes', () => {
  const store = openStore();
  try {
    store.intake(payload);
    assert.throws(() => store.intake({ ...payload, message: 'Changed message' }), ConflictError);
    assert.equal(store.count('cases'), 1);
    assert.equal(store.count('case_events'), 1);
  } finally { store.close(); }
});

test('invalid contact and absent consent do not write records', () => {
  const store = openStore();
  try {
    assert.throws(() => store.intake({ ...payload, consent: false }), IntakeError);
    assert.throws(() => store.intake({ ...payload, email: 'invalid' }), IntakeError);
    assert.equal(store.count('cases'), 0);
  } finally { store.close(); }
});

test('sales inquiry is routed without automatic billing approval', () => {
  const result = normalizeIntake({ ...payload, message: 'Can I get a quote?' });
  assert.equal(result.department, 'SALES');
  assert.equal(result.priority, 'NORMAL');
  assert.equal(result.requiresHumanReview, false);
});
