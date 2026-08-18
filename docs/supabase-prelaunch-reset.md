# Supabase pre-launch reset

Issue #60 replaces the pre-launch cloud-menu deployment with MyMenu's reduced
service backend. The checked-in baseline contains only service entitlements,
content-free AI usage, ephemeral processing jobs and assets, Supabase Auth,
and the private `processing-media` bucket.

## Release gate

Run the complete local release verification before touching the linked project:

```bash
scripts/verify_local_first_release.sh
```

For the real-provider gate, supply the approved Gemini key and enable both live
evaluation suites:

```bash
RUN_GEMINI_EVALS=1 \
RUN_GEMINI_COVER_EVALS=1 \
GOOGLE_GENERATIVE_AI_API_KEY=... \
scripts/verify_local_first_release.sh
```

The automated release suite covers offline-local capture safety, restart and
retry, idempotent local adoption, review and correction undo, Improve Cover,
account/menu separation, service-owner isolation, acknowledgement cleanup, and
expiry cleanup. Before release, exercise the same capture and Improve Cover
journeys once on a physical iOS device and once on a physical Android device
with a real network interruption.

## Administrative snapshot and reset

The reset script refuses to run unless the operator identifies the project,
chooses an external snapshot destination, attests that no real user depends on
cloud recovery, and separately confirms the destructive reset:

```bash
SUPABASE_PROJECT_REF=... \
SUPABASE_URL=https://PROJECT_REF.supabase.co \
SUPABASE_SERVICE_ROLE_KEY=... \
SNAPSHOT_DIR=/recoverable/external/location \
CONFIRM_NO_REAL_USERS=NO_REAL_USERS_DEPEND_ON_CLOUD_RECOVERY \
CONFIRM_DESTRUCTIVE_RESET=RESET_PRELAUNCH_SUPABASE \
scripts/reset_supabase_prelaunch.sh
```

The script snapshots the `public`, `auth`, and `storage` schemas and data,
copies legacy and processing Storage objects, records the operator attestation,
writes SHA-256 checksums, removes both pre-reset Storage buckets, resets the
linked database from the reduced migrations (which recreates only the private
`processing-media` bucket), and deploys the four checked-in Edge Functions with
pruning enabled. Obtain the service-role key from the project's API settings;
never write it to the snapshot or the repository.

Do not store the snapshot in Git. Preserve it until the release candidate has
passed the physical-device and real-provider gates and the rollback window has
closed.
