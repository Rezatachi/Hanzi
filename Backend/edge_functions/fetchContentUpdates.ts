// Supabase Edge Function example for Mandarin Drift dictionary sync.
// Serves either JSON HanziEntry rows or CC-CEDICT text stored in object storage.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type DictionaryFormat = "json" | "cedict";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(request.url);
  const format = (url.searchParams.get("format") ?? "json") as DictionaryFormat;
  const limit = Number(url.searchParams.get("limit") ?? "5000");
  const minUpdatedAt = url.searchParams.get("updated_after");
  const category = url.searchParams.get("category");
  const premium = url.searchParams.get("premium");
  const hskLevel = url.searchParams.get("hsk_level");

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const cedictBucket = Deno.env.get("CEDICT_BUCKET") ?? "dictionary";
  const cedictPath = Deno.env.get("CEDICT_OBJECT_PATH") ?? "cedict/cedict_1_0_ts_utf-8_mdbg.txt";

  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Missing backend configuration." }, 500);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  try {
    if (format === "cedict") {
      const { data, error } = await supabase.storage.from(cedictBucket).download(cedictPath);
      if (error || !data) {
        return json({ error: "Unable to load CC-CEDICT object." }, 500);
      }

      return new Response(await data.text(), {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "text/plain; charset=utf-8",
          "Cache-Control": "public, max-age=3600",
        },
      });
    }

    let query = supabase
      .from("content_entries")
      .select("*")
      .order("updated_at", { ascending: false })
      .limit(Number.isFinite(limit) ? Math.min(limit, 10000) : 5000);

    if (minUpdatedAt) {
      query = query.gt("updated_at", minUpdatedAt);
    }
    if (category) {
      query = query.contains("categories", [category]);
    }
    if (premium === "true") {
      query = query.eq("is_premium", true);
    } else if (premium === "false") {
      query = query.eq("is_premium", false);
    }
    if (hskLevel) {
      query = query.eq("hsk_level", hskLevel);
    }

    const { data, error } = await query;
    if (error) {
      return json({ error: error.message }, 500);
    }

    const payload = (data ?? []).map(mapRowToHanziEntry);
    return json(
      {
        items: payload,
        count: payload.length,
        updatedAfter: minUpdatedAt ?? null,
        limit: Number.isFinite(limit) ? Math.min(limit, 10000) : 5000,
      },
      200,
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown failure";
    return json({ error: message }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function mapRowToHanziEntry(row: Record<string, unknown>) {
  return {
    id: row.id,
    simplified: row.simplified,
    traditional: row.traditional,
    pinyin: row.pinyin,
    pinyinNumeric: row.pinyin_numeric,
    pinyinSearch: row.pinyin_search,
    definitions: row.definitions ?? [],
    partOfSpeech: row.part_of_speech ?? null,
    hskLevel: row.hsk_level ?? null,
    frequencyRank: row.frequency_rank ?? null,
    radical: row.radical ?? null,
    radicalMeaning: row.radical_meaning ?? null,
    strokeCount: row.stroke_count ?? null,
    components: row.components ?? [],
    categories: row.categories ?? ["basics"],
    exampleChineseSimplified: row.example_chinese_simplified ?? row.simplified,
    exampleChineseTraditional: row.example_chinese_traditional ?? row.traditional,
    examplePinyin: row.example_pinyin ?? row.pinyin,
    exampleEnglish: row.example_english ?? (Array.isArray(row.definitions) ? row.definitions[0] : ""),
    usageNote: row.usage_note ?? null,
    memoryHook: row.memory_hook ?? null,
    toneTip: row.tone_tip ?? null,
    commonMistake: row.common_mistake ?? null,
    relatedEntryIds: row.related_entry_ids ?? [],
    isPremium: row.is_premium ?? true,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}
