type JsonObject = Record<string, unknown>;

type StatsigDefinition = JsonObject & {
  id: string;
  name: string;
  description: string;
  isEnabled: boolean;
};

type StatsigManifest = {
  dynamicConfigs: StatsigDefinition[];
  gates: StatsigDefinition[];
};

type Fetch = typeof fetch;

const apiBase = "https://statsigapi.net/console/v1";
const apiVersion = "20240601";

export function validateManifest(value: unknown): StatsigManifest {
  if (!isObject(value)) throw new Error("Statsig manifest must be an object");
  const dynamicConfigs = definitions(value.dynamicConfigs, "dynamicConfigs");
  const gates = definitions(value.gates, "gates");
  const ids = [...dynamicConfigs, ...gates].map((definition) => definition.id);
  if (new Set(ids).size !== ids.length) {
    throw new Error("Statsig manifest IDs must be unique");
  }
  return { dynamicConfigs, gates };
}

export async function syncManifest(
  manifest: StatsigManifest,
  apiKey: string,
  fetcher: Fetch = fetch,
) {
  if (apiKey.length === 0) {
    throw new Error("STATSIG_CONSOLE_API_KEY is required");
  }
  for (const definition of manifest.gates) {
    await syncDefinition("gates", definition, apiKey, fetcher);
  }
  for (const definition of manifest.dynamicConfigs) {
    await syncDefinition("dynamic_configs", definition, apiKey, fetcher);
  }
}

async function syncDefinition(
  collection: "gates" | "dynamic_configs",
  definition: StatsigDefinition,
  apiKey: string,
  fetcher: Fetch,
) {
  const entityUrl = `${apiBase}/${collection}/${
    encodeURIComponent(definition.id)
  }`;
  const read = await fetcher(entityUrl, { headers: headers(apiKey) });
  if (read.status === 404) {
    const created = await fetcher(`${apiBase}/${collection}`, {
      method: "POST",
      headers: headers(apiKey),
      body: JSON.stringify({
        ...definition,
        rules: [],
      }),
    });
    await requireSuccess(created, `create ${definition.id}`);
    console.log(`created ${definition.id}`);
    return;
  }
  const { id: _id, ...patch } = definition;
  const current = await responseData(read, `read ${definition.id}`);
  if (matchesDefinition(current, patch)) {
    console.log(`unchanged ${definition.id}`);
    return;
  }
  const updated = await fetcher(entityUrl, {
    method: "PATCH",
    headers: headers(apiKey),
    body: JSON.stringify(patch),
  });
  await requireSuccess(updated, `update ${definition.id}`);
  console.log(`updated ${definition.id}`);
}

function headers(apiKey: string) {
  return {
    "Content-Type": "application/json",
    "STATSIG-API-KEY": apiKey,
    "STATSIG-API-VERSION": apiVersion,
  };
}

async function requireSuccess(response: Response, action: string) {
  if (response.ok) return;
  const body = await response.text();
  throw new Error(`${action} failed (${response.status}): ${body}`);
}

async function responseData(response: Response, action: string) {
  await requireSuccess(response, action);
  const body = await response.json();
  if (!isObject(body) || !isObject(body.data)) {
    throw new Error(`${action} returned an invalid response`);
  }
  return body.data;
}

function matchesDefinition(current: JsonObject, desired: JsonObject) {
  return Object.entries(desired).every(([key, value]) =>
    stableJson(current[key]) === stableJson(value)
  );
}

function stableJson(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableJson).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableJson(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function definitions(value: unknown, key: string): StatsigDefinition[] {
  if (!Array.isArray(value)) throw new Error(`${key} must be an array`);
  return value.map((item, index) => {
    if (!isObject(item)) throw new Error(`${key}[${index}] must be an object`);
    if (
      typeof item.id !== "string" || item.id.length < 3 ||
      typeof item.name !== "string" || item.name.length < 3 ||
      typeof item.description !== "string" ||
      typeof item.isEnabled !== "boolean"
    ) {
      throw new Error(`${key}[${index}] has invalid required fields`);
    }
    return item as StatsigDefinition;
  });
}

function isObject(value: unknown): value is JsonObject {
  return typeof value === "object" && value != null && !Array.isArray(value);
}

if (import.meta.main) {
  const manifestUrl = new URL("./manifest.json", import.meta.url);
  const manifest = validateManifest(
    JSON.parse(await Deno.readTextFile(manifestUrl)),
  );
  if (Deno.args.includes("--check")) {
    console.log(
      `valid Statsig manifest (${manifest.gates.length} gates, ` +
        `${manifest.dynamicConfigs.length} dynamic config)`,
    );
  } else {
    await syncManifest(
      manifest,
      Deno.env.get("STATSIG_CONSOLE_API_KEY") ?? "",
    );
  }
}
