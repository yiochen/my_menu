import {
  captureOrganizationBypassGate,
  createStatsigProcessingPolicyProvider,
  dishCoverBypassGate,
  emergencyEnforcementGate,
  evaluateProcessingPolicy,
  ProcessingPolicyUnavailableError,
  type StatsigProcessingClient,
} from "../../functions/_shared/processing_policy.ts";

Deno.test("free Statsig config returns the two ten-unit allowances", () => {
  const client = fakeClient();

  const policy = evaluateProcessingPolicy(client, {
    userId: "account-1",
    planKey: "free",
  });

  assertEquals(policy, {
    captureOrganizationLimit: 10,
    captureOrganizationBypass: false,
    dishCoverLimit: 10,
    dishCoverBypass: false,
  });
  assertEquals(client.lastUser, {
    userID: "account-1",
    custom: { plan_key: "free" },
  });
});

Deno.test("operation bypasses are independent", () => {
  const client = fakeClient({
    gates: { [captureOrganizationBypassGate]: true },
  });

  const policy = evaluateProcessingPolicy(client, {
    userId: "account-2",
    planKey: "free",
  });

  assertEquals(policy.captureOrganizationBypass, true);
  assertEquals(policy.dishCoverBypass, false);
});

Deno.test("emergency enforcement defeats every account bypass", () => {
  const client = fakeClient({
    gates: {
      [captureOrganizationBypassGate]: true,
      [dishCoverBypassGate]: true,
      [emergencyEnforcementGate]: true,
    },
  });

  const policy = evaluateProcessingPolicy(client, {
    userId: "account-3",
    planKey: "free",
  });

  assertEquals(policy.captureOrganizationBypass, false);
  assertEquals(policy.dishCoverBypass, false);
});

Deno.test("gate failures always resolve to enforced behavior", () => {
  const client = fakeClient({
    gates: { [captureOrganizationBypassGate]: true },
    throwingGate: emergencyEnforcementGate,
  });

  const policy = evaluateProcessingPolicy(client, {
    userId: "account-4",
    planKey: "free",
  });

  assertEquals(policy.captureOrganizationBypass, false);
  assertEquals(policy.dishCoverBypass, false);
});

Deno.test("missing or malformed allowance config is unavailable", () => {
  for (
    const config of [
      {},
      { capture_auto_organization_limit: 10, dish_cover_gen_limit: 1.5 },
      { capture_auto_organization_limit: -1, dish_cover_gen_limit: 10 },
    ]
  ) {
    assertThrowsPolicyUnavailable(() =>
      evaluateProcessingPolicy(fakeClient({ config }), {
        userId: "account-5",
        planKey: "free",
      })
    );
  }
});

Deno.test("Statsig initialization failure remains retryable", async () => {
  let attempts = 0;
  const provider = createStatsigProcessingPolicyProvider({
    sdkKey: () => "secret-test",
    createClient: () => {
      attempts += 1;
      return fakeClient({ initializeSuccess: false });
    },
  });

  for (let index = 0; index < 2; index += 1) {
    try {
      await provider.evaluate({ userId: "account-6", planKey: "free" });
      throw new Error("Expected policy evaluation to fail");
    } catch (error) {
      assertEquals(error instanceof ProcessingPolicyUnavailableError, true);
    }
  }
  assertEquals(attempts, 2);
});

type FakeOptions = {
  config?: Record<string, unknown>;
  gates?: Record<string, boolean>;
  throwingGate?: string;
  initializeSuccess?: boolean;
};

function fakeClient(options: FakeOptions = {}) {
  const client = {
    lastUser: null as unknown,
    async initializeAsync() {
      return {
        success: options.initializeSuccess ?? true,
        error: options.initializeSuccess === false
          ? new Error("unavailable")
          : null,
      };
    },
    getDynamicConfig(_name: string, user: unknown) {
      client.lastUser = user;
      return {
        value: options.config ?? {
          capture_auto_organization_limit: 10,
          dish_cover_gen_limit: 10,
        },
      };
    },
    checkGate(name: string, user: unknown) {
      client.lastUser = user;
      if (name === options.throwingGate) throw new Error("gate unavailable");
      return options.gates?.[name] ?? false;
    },
    async flush() {},
  };
  return client as StatsigProcessingClient & { lastUser: unknown };
}

function assertThrowsPolicyUnavailable(callback: () => void) {
  try {
    callback();
  } catch (error) {
    if (error instanceof ProcessingPolicyUnavailableError) return;
    throw error;
  }
  throw new Error("Expected ProcessingPolicyUnavailableError");
}

function assertEquals(actual: unknown, expected: unknown) {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
