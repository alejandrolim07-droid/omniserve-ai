import { createServer } from 'node:http';
import { fileURLToPath } from 'node:url';
import { openStore, IntakeError, ConflictError } from './store.mjs';

export function createPilotServer(store) {
  return createServer(async (request, response) => {
    const respond = (status, body) => {
      response.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
      response.end(JSON.stringify(body));
    };
    if (request.method !== 'POST' || request.url !== '/intake') {
      respond(404, { error: 'not found' });
      return;
    }
    try {
      const chunks = [];
      let size = 0;
      for await (const chunk of request) {
        size += chunk.length;
        if (size > 16_384) throw new IntakeError('request too large');
        chunks.push(chunk);
      }
      const result = store.intake(JSON.parse(Buffer.concat(chunks).toString('utf8')));
      respond(result.duplicate ? 200 : 201, result);
    } catch (error) {
      respond(error instanceof ConflictError ? 409 : error instanceof IntakeError || error instanceof SyntaxError ? 400 : 500,
        { error: error instanceof IntakeError || error instanceof SyntaxError ? error.message : 'internal error' });
    }
  });
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const store = openStore(process.env.OMNISERVE_PILOT_DB || 'omniserve-pilot.sqlite');
  const port = Number(process.env.PORT || 8787);
  const server = createPilotServer(store);
  server.listen(port, '127.0.0.1', () => console.log(`OmniServe pilot on http://127.0.0.1:${port}`));
  process.on('SIGINT', () => { server.close(); store.close(); });
}
