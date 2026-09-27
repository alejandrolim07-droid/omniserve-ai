import test from 'node:test';
import assert from 'node:assert/strict';
import { openStore } from './store.mjs';
import { createPilotServer } from './server.mjs';

test('HTTP webhook creates then deduplicates a persistent case', async () => {
  const store = openStore();
  const server = createPilotServer(store);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  try {
    const url = `http://127.0.0.1:${server.address().port}/intake`;
    const payload = JSON.stringify({ source: 'web_form', external_message_id: 'http-demo-001',
      consent: true, name: 'Demo Customer', email: 'demo@example.com', message: 'I need a quote.' });
    const send = () => fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: payload });
    const first = await send();
    const firstBody = await first.json();
    const second = await send();
    const secondBody = await second.json();
    assert.equal(first.status, 201);
    assert.equal(second.status, 200);
    assert.equal(firstBody.caseId, secondBody.caseId);
    assert.equal(secondBody.duplicate, true);
    assert.equal(store.count('cases'), 1);

    const conflicting = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...JSON.parse(payload), message: 'Another inquiry' }) });
    assert.equal(conflicting.status, 409);
    assert.equal(store.count('cases'), 1);
  } finally {
    await new Promise((resolve) => server.close(resolve));
    store.close();
  }
});
