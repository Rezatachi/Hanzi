#!/usr/bin/env node

import { createHash } from "node:crypto";
import { gunzipSync } from "node:zlib";

const DEFAULT_SOURCE_URL = "https://cc-cedict.org/editor/editor_export_cedict.php?c=gz";
const DEFAULT_BATCH_SIZE = 500;
const NAMESPACE = "mandarin-drift-cc-cedict";

const args = parseArgs(process.argv.slice(2));
const supabaseUrl = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const sourceUrl = args.sourceUrl ?? DEFAULT_SOURCE_URL;
const batchSize = Math.max(1, Number.parseInt(args.batchSize ?? `${DEFAULT_BATCH_SIZE}`, 10));
const dryRun = args.dryRun;

if (!supabaseUrl && !dryRun) {
  console.error("Missing SUPABASE_URL.");
  process.exit(1);
}

if (!serviceRoleKey && !dryRun) {
  console.error("Missing SUPABASE_SERVICE_ROLE_KEY.");
  process.exit(1);
}

const sourceText = await loadCedictText(sourceUrl, args.sourceFile);
const rows = parseCedict(sourceText, sourceUrl);
const uniqueRows = dedupeRows(rows);

console.log(`Parsed ${rows.length} entries, ${uniqueRows.length} unique rows.`);

if (dryRun) {
  console.log("Dry run enabled. No rows were uploaded.");
  process.exit(0);
}

const schemaReady = await probeSupabaseSchema({ supabaseUrl, serviceRoleKey });
if (!schemaReady.contentEntries) {
  console.error("Missing public.content_entries. Run Backend/supabase_schema.sql in Supabase first.");
  process.exit(1);
}

await recordImportBatch({
  supabaseUrl,
  serviceRoleKey,
  sourceName: "cc-cedict",
  sourceUrl,
  entryCount: uniqueRows.length,
}).catch((error) => {
  console.warn(`Skipping import batch record: ${error.message}`);
});

for (let index = 0; index < uniqueRows.length; index += batchSize) {
  const batch = uniqueRows.slice(index, index + batchSize);
  const start = index + 1;
  const end = index + batch.length;
  process.stdout.write(`Uploading ${start}-${end} of ${uniqueRows.length}...\r`);
  await upsertRows({
    supabaseUrl,
    serviceRoleKey,
    rows: batch,
  });
}

process.stdout.write("\n");
console.log("CC-CEDICT import complete.");

async function loadCedictText(sourceUrlValue, sourceFile) {
  if (sourceFile) {
    const { readFile } = await import("node:fs/promises");
    const buffer = await readFile(sourceFile);
    return buffer.toString("utf8");
  }

  const response = await fetch(sourceUrlValue, {
    headers: {
      "user-agent": "MandarinDrift/1.0",
      accept: "application/octet-stream,text/plain,*/*",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to download CC-CEDICT source: ${response.status} ${response.statusText}`);
  }

  const contentType = response.headers.get("content-type") ?? "";
  const raw = Buffer.from(await response.arrayBuffer());
  if (contentType.includes("gzip") || sourceUrlValue.endsWith(".gz") || isGzip(raw)) {
    return gunzipSync(raw).toString("utf8");
  }

  return raw.toString("utf8");
}

function isGzip(buffer) {
  return buffer.length > 2 && buffer[0] === 0x1f && buffer[1] === 0x8b;
}

function parseCedict(text, sourceUrlValue) {
  const rows = [];
  const lines = text.split(/\r?\n/);

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) {
      continue;
    }

    const match = trimmed.match(/^(\S+)\s+(\S+)\s+\[(.+?)\]\s+\/(.+)\/$/);
    if (!match) {
      continue;
    }

    const [, traditional, simplified, pinyinNumeric, definitionsText] = match;
    const definitions = splitDefinitions(definitionsText);
    if (definitions.length === 0) {
      continue;
    }

    const pinyin = numericPinyinToToneMarks(pinyinNumeric);
    const pinyinSearch = normalizePinyin(pinyinNumeric);
    const id = stableUuid(`${traditional}|${simplified}|${pinyinNumeric}|${definitions.join("|")}`);
    const contentHash = sha256Hex(`${traditional}|${simplified}|${pinyinNumeric}|${definitions.join("|")}`);

    rows.push({
      id,
      simplified,
      traditional,
      pinyin,
      pinyinNumeric,
      pinyinSearch,
      definitions,
      partOfSpeech: null,
      hskLevel: null,
      frequencyRank: null,
      radical: null,
      radicalMeaning: null,
      strokeCount: null,
      components: [],
      categories: ["dictionary"],
      exampleChineseSimplified: simplified,
      exampleChineseTraditional: traditional,
      examplePinyin: pinyin,
      exampleEnglish: definitions[0],
      usageNote: null,
      memoryHook: null,
      toneTip: null,
      commonMistake: null,
      relatedEntryIds: [],
      isPremium: false,
      sourceName: "cc-cedict",
      sourceUrl: sourceUrlValue,
      sourceUpdatedAt: null,
      contentHash,
    });
  }

  return rows;
}

function splitDefinitions(definitionsText) {
  return definitionsText
    .split(/(?<!\\)\//g)
    .map((part) => part.replace(/\\\//g, "/").trim())
    .filter(Boolean);
}

function normalizePinyin(input) {
  return input
    .toLowerCase()
    .replace(/u:/g, "ü")
    .replace(/v/g, "ü")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[1-5]/g, "")
    .replace(/[’'`]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function numericPinyinToToneMarks(input) {
  return input
    .split(/\s+/)
    .map((token) => convertNumericToken(token))
    .join(" ")
    .trim();
}

function convertNumericToken(token) {
  if (!token) {
    return token;
  }

  const match = token.match(/^([a-züv:']+)([1-5])$/i);
  if (!match) {
    return token.replace(/u:/gi, "ü").replace(/v/gi, "ü");
  }

  const [, baseRaw, toneRaw] = match;
  const tone = Number(toneRaw);
  const base = baseRaw.replace(/u:/gi, "ü").replace(/v/gi, "ü");
  if (tone === 5) {
    return base;
  }

  const vowelIndex = findToneVowelIndex(base);
  if (vowelIndex < 0) {
    return base;
  }

  const chars = [...base];
  const char = chars[vowelIndex];
  chars[vowelIndex] = applyToneMark(char, tone);
  return chars.join("");
}

function findToneVowelIndex(token) {
  const lower = token.toLowerCase();
  const vowels = ["a", "e", "o", "i", "u", "ü"];

  const aIndex = lower.indexOf("a");
  if (aIndex >= 0) return aIndex;

  const eIndex = lower.indexOf("e");
  if (eIndex >= 0) return eIndex;

  const ouIndex = lower.indexOf("ou");
  if (ouIndex >= 0) return ouIndex;

  for (let index = lower.length - 1; index >= 0; index -= 1) {
    if (vowels.includes(lower[index])) {
      return index;
    }
  }

  return -1;
}

function applyToneMark(char, tone) {
  const toneMap = {
    a: ["ā", "á", "ǎ", "à"],
    e: ["ē", "é", "ě", "è"],
    i: ["ī", "í", "ǐ", "ì"],
    o: ["ō", "ó", "ǒ", "ò"],
    u: ["ū", "ú", "ǔ", "ù"],
    ü: ["ǖ", "ǘ", "ǚ", "ǜ"],
  };

  const lower = char.toLowerCase();
  const marks = toneMap[lower];
  if (!marks) {
    return char;
  }

  const marked = marks[tone - 1];
  return char === lower ? marked : marked.toUpperCase();
}

function stableUuid(seed) {
  const digest = createHash("sha1").update(`${NAMESPACE}:${seed}`).digest();
  const bytes = Buffer.from(digest.subarray(0, 16));
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  return [...bytes]
    .map((byte, index) => {
      const hex = byte.toString(16).padStart(2, "0");
      if (index === 4 || index === 6 || index === 8 || index === 10) {
        return `-${hex}`;
      }
      return hex;
    })
    .join("");
}

function sha256Hex(input) {
  return createHash("sha256").update(input).digest("hex");
}

function dedupeRows(rows) {
  const seen = new Map();
  for (const row of rows) {
    if (!seen.has(row.id)) {
      seen.set(row.id, row);
    }
  }
  return [...seen.values()];
}

async function upsertRows({ supabaseUrl, serviceRoleKey, rows }) {
  const response = await fetch(`${supabaseUrl.replace(/\/$/, "")}/rest/v1/content_entries?on_conflict=id`, {
    method: "POST",
    headers: {
      apikey: serviceRoleKey,
      authorization: `Bearer ${serviceRoleKey}`,
      "content-type": "application/json",
      prefer: "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify(rows),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Supabase upsert failed: ${response.status} ${response.statusText} ${text}`);
  }
}

async function recordImportBatch({ supabaseUrl, serviceRoleKey, sourceName, sourceUrl, entryCount }) {
  const id = stableUuid(`${sourceName}|${sourceUrl}|${entryCount}`);
  const response = await fetch(`${supabaseUrl.replace(/\/$/, "")}/rest/v1/content_import_batches`, {
    method: "POST",
    headers: {
      apikey: serviceRoleKey,
      authorization: `Bearer ${serviceRoleKey}`,
      "content-type": "application/json",
      prefer: "resolution=merge-duplicates,return=minimal",
    },
    body: JSON.stringify([
      {
        id,
        source_name: sourceName,
        source_url: sourceUrl,
        entry_count: entryCount,
        checksum: sha256Hex(`${sourceName}|${sourceUrl}|${entryCount}`),
      },
    ]),
  });

  if (!response.ok) {
    if (response.status === 404) {
      throw new Error("content_import_batches table is missing. Run Backend/supabase_schema.sql first.");
    }
    const text = await response.text();
    throw new Error(`Batch record failed: ${response.status} ${response.statusText} ${text}`);
  }
}

async function probeSupabaseSchema({ supabaseUrl, serviceRoleKey }) {
  const response = await fetch(`${supabaseUrl.replace(/\/$/, "")}/rest/v1/content_entries?select=id&limit=1`, {
    headers: {
      apikey: serviceRoleKey,
      authorization: `Bearer ${serviceRoleKey}`,
    },
  });

  if (response.status === 404) {
    return { contentEntries: false };
  }
  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Schema probe failed: ${response.status} ${response.statusText} ${text}`);
  }

  return { contentEntries: true };
}

function parseArgs(argv) {
  const result = {};
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (token === "--dry-run") {
      result.dryRun = true;
      continue;
    }
    if (token === "--source-url") {
      result.sourceUrl = argv[index + 1];
      index += 1;
      continue;
    }
    if (token === "--source-file") {
      result.sourceFile = argv[index + 1];
      index += 1;
      continue;
    }
    if (token === "--batch-size") {
      result.batchSize = argv[index + 1];
      index += 1;
      continue;
    }
  }
  return result;
}
