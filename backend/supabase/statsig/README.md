# Statsig processing policy

`manifest.json` is the version-controlled definition of MyMenu's server-side
processing gates and free allowance values. It intentionally does not contain
account targeting rules or credentials.

Validate the manifest locally:

```sh
deno run --allow-read supabase/statsig/sync.ts --check
```

Create or update the definitions from `backend/`:

```sh
STATSIG_CONSOLE_API_KEY=... deno run --allow-env --allow-net --allow-read \
  supabase/statsig/sync.ts
```

The sync patches definition metadata and default allowance values without
replacing rules created by operators in the Statsig Console.

## Opt in one account

Use the Supabase Auth user UUID as the Statsig `userID`. On the relevant bypass
gate, add a 100% pass rule with both of these conditions:

1. `User ID` is exactly the account UUID.
2. `Current Time` is before the required expiration timestamp.

Put the reason, ticket, and expiration timestamp in the rule name. Do not add
account overrides to `processing_allowance_emergency_enforcement`. Statsig's
configuration history records the operator and change history.

Turning `processing_allowance_emergency_enforcement` on for everyone forces both
allowances to be enforced even while an account-specific bypass rule is passing.
