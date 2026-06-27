# Backend Adapter Notes

The shipped app works without backend credentials.

## Recommended Backend
- Supabase
- Why:
  - Postgres gives us a clean home for the expanded dictionary.
  - Edge Functions provide a small, versioned API surface.
  - Row Level Security keeps user data isolated while content stays server-owned.

## Tables
- `profiles`
- `review_states`
- `review_logs`
- `saved_entries`
- `daily_plans`
- `content_entries`
- `content_import_batches`
- `purchases`
- `entitlements`
- `device_tokens`

## Merge Rules
- Local data is source of truth offline.
- Review logs append only.
- Review states resolve by latest `updatedAt`.
- Saved entries merge by `(userId, entryId)`.
- Content updates do not erase user progress.

## Recommended Dictionary API Shape
- `GET /functions/v1/fetchContentUpdates`
- Auth: bearer token if needed
- Response options:
  - JSON: `{ items: [HanziEntry], count, updatedAfter, limit }`
  - CC-CEDICT text: raw dictionary lines in standard syntax

Query parameters:
- `format=json|cedict`
- `limit=5000`
- `updated_after=2026-06-22T00:00:00Z`
- `category=basics|food|travel|...`
- `premium=true|false`
- `hsk_level=HSK 1`

Example JSON shape:
```json
[
  {
    "id": "stable-uuid",
    "simplified": "你好",
    "traditional": "你好",
    "pinyin": "nǐ hǎo",
    "pinyinNumeric": "ni3 hao3",
    "pinyinSearch": "ni hao",
    "definitions": ["hello", "hi"],
    "partOfSpeech": "phrase",
    "hskLevel": "HSK 1",
    "frequencyRank": 100,
    "radical": null,
    "radicalMeaning": null,
    "strokeCount": null,
    "components": ["你", "好"],
    "categories": ["basics"],
    "exampleChineseSimplified": "你好，我叫安娜。",
    "exampleChineseTraditional": "你好，我叫安娜。",
    "examplePinyin": "Nǐ hǎo, wǒ jiào Ānnà.",
    "exampleEnglish": "Hello, my name is Anna.",
    "usageNote": "Use this as a standard greeting.",
    "memoryHook": "你 means you, 好 means good.",
    "toneTip": "Both syllables are third tone.",
    "commonMistake": "Do not flatten hǎo.",
    "relatedEntryIds": [],
    "isPremium": true,
    "createdAt": "2026-06-22T00:00:00Z",
    "updatedAt": "2026-06-22T00:00:00Z"
  }
]
```

## Credentials
- Keep secrets in excluded env/config files.
- Use Keychain only for auth/session tokens.
- Current project URL: `https://bbktobbqcouxifnrqqnf.supabase.co`
- The key you provided is the publishable/anon key, which is safe for the client but not enough for server-side imports.
- I still need the `service_role` key to run the bulk import or deploy scripts against your Supabase project.

## Included Example
- Edge function: [`edge_functions/fetchContentUpdates.ts`](/Users/abrahambelayneh/MandarinDrift/Backend/edge_functions/fetchContentUpdates.ts)
- Env template: [`Backend/.env.example`](/Users/abrahambelayneh/MandarinDrift/Backend/.env.example)
- Schema includes `content_entries` for JSON-mode serving.
- Bulk importer: [`tools/import_cedict.mjs`](/Users/abrahambelayneh/MandarinDrift/Backend/tools/import_cedict.mjs)

## Expanded Dataset Workflow
1. Run [`supabase_schema.sql`](</Users/abrahambelayneh/MandarinDrift/Backend/supabase_schema.sql>) in your Supabase project.
2. Load a large licensed dictionary into `content_entries`.
3. Track each import in `content_import_batches`.
4. Deploy `fetchContentUpdates` as a Supabase Edge Function.
5. Point the iOS app at the function URL in `ChineseDictionaryAPIURL`.

## Bulk import
- Dry run:
  - `SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... node Backend/tools/import_cedict.mjs --dry-run`
- Full upload:
  - `SUPABASE_URL=... SUPABASE_SERVICE_ROLE_KEY=... node Backend/tools/import_cedict.mjs`
- Optional overrides:
  - `--source-url https://cc-cedict.org/editor/editor_export_cedict.php?c=gz`
  - `--source-file /path/to/cedict.txt`
- The importer uses the public CC-CEDICT download and upserts rows into `content_entries` with stable IDs so repeated imports are idempotent.

## Notes
- Keep the dictionary source licensed and attributable.
- If you later add sync, keep the local app store-first and merge remote content by stable IDs.
