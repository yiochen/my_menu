import { StatsigServerlessClient } from "npm:@statsig/serverless-client@3.33.4";
import { requireEnv } from "./supabase.ts";

export const processingAllowanceConfig = "processing_allowances";
export const captureOrganizationBypassGate =
  "processing_capture_auto_organization_allowance_bypass";
export const dishCoverBypassGate = "processing_dish_cover_gen_allowance_bypass";
export const emergencyEnforcementGate =
  "processing_allowance_emergency_enforcement";

export type ProcessingPolicy = {
  captureOrganizationLimit: number;
  captureOrganizationBypass: boolean;
  dishCoverLimit: number;
  dishCoverBypass: boolean;
};

export type ProcessingPolicyContext = {
  userId: string;
  planKey: string;
};

export interface ProcessingPolicyProvider {
  evaluate(context: ProcessingPolicyContext): Promise<ProcessingPolicy>;
  flush(): Promise<void>;
}

type StatsigUser = {
  userID: string;
  custom: { plan_key: string };
};

export interface StatsigProcessingClient {
  initializeAsync(): Promise<{ success: boolean; error: Error | null }>;
  getDynamicConfig(
    name: string,
    user: StatsigUser,
  ): { value: Record<string, unknown> };
  checkGate(name: string, user: StatsigUser): boolean;
  flush(): Promise<void>;
}

type StatsigProviderOptions = {
  sdkKey?: () => string;
  createClient?: (key: string) => StatsigProcessingClient;
};

export function createStatsigProcessingPolicyProvider(
  options: StatsigProviderOptions = {},
): ProcessingPolicyProvider {
  const sdkKey = options.sdkKey ?? (() => requireEnv("STATSIG_SERVER_KEY"));
  const createClient = options.createClient ??
    ((key) => new StatsigServerlessClient(key) as StatsigProcessingClient);
  let clientPromise: Promise<StatsigProcessingClient> | null = null;

  const initializedClient = () => {
    if (clientPromise == null) {
      clientPromise = initializeClient(sdkKey(), createClient).catch(
        (error) => {
          clientPromise = null;
          throw error;
        },
      );
    }
    return clientPromise;
  };

  return {
    async evaluate(context) {
      try {
        return evaluateProcessingPolicy(await initializedClient(), context);
      } catch (error) {
        if (error instanceof ProcessingPolicyUnavailableError) throw error;
        throw new ProcessingPolicyUnavailableError(error);
      }
    },
    async flush() {
      if (clientPromise == null) return;
      try {
        await (await clientPromise).flush();
      } catch {
        // Exposure logging must never change a completed processing decision.
      }
    },
  };
}

export function evaluateProcessingPolicy(
  client: StatsigProcessingClient,
  context: ProcessingPolicyContext,
): ProcessingPolicy {
  const user: StatsigUser = {
    userID: context.userId,
    custom: { plan_key: context.planKey },
  };
  const config = client.getDynamicConfig(processingAllowanceConfig, user);
  const captureOrganizationLimit = allowanceLimit(
    config.value,
    "capture_auto_organization_limit",
  );
  const dishCoverLimit = allowanceLimit(
    config.value,
    "dish_cover_gen_limit",
  );

  const emergencyEnforcement = safeGate(
    client,
    emergencyEnforcementGate,
    user,
    true,
  );
  const captureOrganizationBypass = safeGate(
    client,
    captureOrganizationBypassGate,
    user,
    false,
  );
  const dishCoverBypass = safeGate(
    client,
    dishCoverBypassGate,
    user,
    false,
  );

  return {
    captureOrganizationLimit,
    captureOrganizationBypass: captureOrganizationBypass &&
      !emergencyEnforcement,
    dishCoverLimit,
    dishCoverBypass: dishCoverBypass && !emergencyEnforcement,
  };
}

export const statsigProcessingPolicyProvider =
  createStatsigProcessingPolicyProvider();

export class ProcessingPolicyUnavailableError extends Error {
  constructor(cause?: unknown) {
    super("processing_policy_unavailable", { cause });
    this.name = "ProcessingPolicyUnavailableError";
  }
}

async function initializeClient(
  key: string,
  createClient: (key: string) => StatsigProcessingClient,
) {
  try {
    const client = createClient(key);
    const details = await client.initializeAsync();
    if (!details.success) {
      throw details.error ??
        new Error("Statsig initialization returned no data");
    }
    return client;
  } catch (error) {
    throw new ProcessingPolicyUnavailableError(error);
  }
}

function allowanceLimit(value: Record<string, unknown>, key: string) {
  const limit = value[key];
  if (typeof limit !== "number" || !Number.isInteger(limit) || limit < 0) {
    throw new ProcessingPolicyUnavailableError(
      new Error(`Invalid Statsig allowance value: ${key}`),
    );
  }
  return limit;
}

function safeGate(
  client: StatsigProcessingClient,
  name: string,
  user: StatsigUser,
  failureValue: boolean,
) {
  try {
    return client.checkGate(name, user);
  } catch {
    return failureValue;
  }
}
