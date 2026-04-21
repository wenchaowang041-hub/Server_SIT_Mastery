const https = require('https');

const HOST = process.env.BMC_HOST || '10.121.176.138';
const USER = process.env.BMC_USER || 'Administrator';
const PASS = process.env.BMC_PASS;

if (!PASS) {
  console.error('Missing BMC_PASS. Example:');
  console.error('$env:BMC_HOST="10.121.176.138"; $env:BMC_USER="Administrator"; $env:BMC_PASS="***"; node bmc_sel_check.js');
  process.exit(1);
}

const BASE = `https://${HOST}`;
const AUTH = Buffer.from(`${USER}:${PASS}`).toString('base64');

function apiGet(path) {
  return new Promise((resolve, reject) => {
    https.get(
      `${BASE}${path}`,
      {
        rejectUnauthorized: false,
        headers: { Authorization: `Basic ${AUTH}` }
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          try {
            resolve(JSON.parse(data));
          } catch {
            resolve(data);
          }
        });
      }
    ).on('error', reject);
  });
}

async function fetchAllEntryRefs() {
  let all = [];
  let skip = 0;
  const top = 200;

  while (true) {
    const resp = await apiGet(`/redfish/v1/Systems/1/LogServices/Log1/Entries?$top=${top}&$skip=${skip}`);
    if (resp.Members) {
      all = all.concat(resp.Members);
    }

    const next = resp['Members@odata.nextLink'];
    if (!next || next.includes(`$skip=${skip}`)) {
      break;
    }

    skip += top;
    if (skip > 2000) {
      break;
    }
  }

  console.log(`Total entry refs: ${all.length}`);
  return all;
}

async function fetchBatchDetails(ids, concurrency = 5) {
  const results = [];

  for (let i = 0; i < ids.length; i += concurrency) {
    const batch = ids.slice(i, i + concurrency);
    const batchResults = await Promise.all(batch.map((id) => apiGet(id['@odata.id'])));
    results.push(...batchResults);

    if (results.length % 200 < concurrency) {
      process.stderr.write(`Fetched ${results.length} entries...\n`);
    }
  }

  return results;
}

async function main() {
  const refs = await fetchAllEntryRefs();
  refs.reverse();

  process.stderr.write('Fetching all entry details...\n');
  const entries = await fetchBatchDetails(refs, 10);
  entries.sort((a, b) => (a.Created || '').localeCompare(b.Created || ''));

  const sevCounts = {};
  for (const entry of entries) {
    const sev = entry.Severity || 'Unknown';
    sevCounts[sev] = (sevCounts[sev] || 0) + 1;
  }

  console.log('\n=== Severity Summary ===');
  for (const [sev, count] of Object.entries(sevCounts)) {
    console.log(`${sev}: ${count}`);
  }

  const critical = entries.filter((entry) => entry.Severity === 'Critical');
  console.log(`\n=== CRITICAL Events (${critical.length} total) ===`);
  for (const entry of critical) {
    console.log(`[${entry.Created}] ${entry.Id}: ${(entry.Message || entry.Name || '').substring(0, 200)}`);
  }

  const warnings = entries.filter((entry) => entry.Severity === 'Warning');
  console.log(`\n=== WARNING Events (${warnings.length} total) ===`);
  for (const entry of warnings) {
    console.log(`[${entry.Created}] ${entry.Id}: ${(entry.Message || entry.Name || '').substring(0, 200)}`);
  }

  console.log('\n=== First 50 entries (chronological) ===');
  for (let i = 0; i < Math.min(50, entries.length); i += 1) {
    const entry = entries[i];
    console.log(`[${entry.Created}] ${entry.Id} Sev=${entry.Severity} ${(entry.Message || entry.Name || '').substring(0, 150)}`);
  }

  console.log('\n=== Last 30 entries ===');
  const start = Math.max(0, entries.length - 30);
  for (let i = start; i < entries.length; i += 1) {
    const entry = entries[i];
    console.log(`[${entry.Created}] ${entry.Id} Sev=${entry.Severity} ${(entry.Message || entry.Name || '').substring(0, 150)}`);
  }

  const latest = entries[entries.length - 1];
  if (latest) {
    console.log(`\nLatest entry time: ${latest.Created}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
