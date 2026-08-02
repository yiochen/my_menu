---
status: accepted
---

# Retain content-free AI usage records

MyMenu will durably record the identity charged, operation type, units,
timestamp, outcome, and idempotency key needed to enforce AI quotas and support
billing, but no menu content or content-derived identifiers. Detailed records
expire after 90 days; only billing-period totals remain afterward for account
and payment history.
