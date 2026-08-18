---
status: accepted
---

# Separate account state from menu state

In V1, MyMenu accounts persist only identity, paid entitlement, and AI usage
needed to restore service access and enforce quotas across installations. Live
menu content remains device-local even for signed-in customers, preserving the
privacy boundary while accepting two deliberately separate notions of
portability: service access follows the account, live menu state does not.
The same account may be active on multiple devices with shared entitlement and
allowance while every device keeps an independent live menu.
