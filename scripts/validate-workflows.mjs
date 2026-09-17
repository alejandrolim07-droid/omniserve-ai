import fs from 'node:fs';
import path from 'node:path';

const repo = path.resolve(new URL('..', import.meta.url).pathname);
const manifest = JSON.parse(fs.readFileSync(path.join(repo, 'manifest/workflows.json'), 'utf8'));
const errors = [];
for (const item of manifest) {
  const file = path.join(repo, item.path);
  if (!fs.existsSync(file)) { errors.push(`Missing: ${item.path}`); continue; }
  try {
    const w = JSON.parse(fs.readFileSync(file, 'utf8'));
    if (!w.name || !Array.isArray(w.nodes) || !w.connections) errors.push(`Invalid n8n shape: ${item.path}`);
    const names = new Set(w.nodes.map(n => n.name));
    for (const [source, outputs] of Object.entries(w.connections)) {
      if (!names.has(source)) errors.push(`Unknown source ${source}: ${item.path}`);
      for (const channel of outputs.main ?? []) for (const edge of channel) if (!names.has(edge.node)) errors.push(`Unknown target ${edge.node}: ${item.path}`);
    }
  } catch (error) { errors.push(`${item.path}: ${error.message}`); }
}
if (manifest.length !== 100) errors.push(`Expected 100 manifest entries, found ${manifest.length}`);
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
console.log(`Validated ${manifest.length} OmniServe workflows.`);
