# Backend Adapter Notes

The shipped app works without backend credentials.

## Suggested Production Backend
- Supabase or custom API
- Tables:
  - users
  - profiles
  - review_states
  - review_logs
  - saved_entries
  - daily_plans
  - content_entries
  - purchases
  - entitlements
  - device_tokens

## Merge Rules
- Local data is source of truth offline.
- Review logs append only.
- Review states resolve by latest `updatedAt`.
- Saved entries merge by `(userId, entryId)`.
- Content updates do not erase user progress.

## Recommended Dictionary API Shape
- `GET /dictionary/mandarin`
- Example Supabase edge path: `POST/GET /functions/v1/fetchContentUpdates`
- Auth: bearer token if needed
- Response options:
  - JSON: array of `HanziEntry`
  - CC-CEDICT text: raw dictionary lines in standard syntax

Query parameters:
- `format=json|cedict`
- `limit=5000`
- `updated_after=2026-06-22T00:00:00Z`

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

## Included Example
- Edge function: [`edge_functions/fetchContentUpdates.ts`](/Users/abrahambelayneh/MandarinDrift/Backend/edge_functions/fetchContentUpdates.ts)
- Env template: [`Backend/.env.example`](/Users/abrahambelayneh/MandarinDrift/Backend/.env.example)
- Schema includes `content_entries` for JSON-mode serving.
