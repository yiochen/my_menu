---
status: accepted
---

# Do not replace an account on offline refresh failure

When a cached signed-in session cannot refresh offline, MyMenu retains the
account identity locally, keeps the device-local menu available, and reports
service access as temporarily unavailable. It creates a guest identity only
after explicit sign-out or confirmation that the account session is invalid,
so network failure cannot silently change service identity.
