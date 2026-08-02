---
status: accepted
---

# Use ephemeral server processing jobs

Server-assisted enrichment will run as asynchronous processing jobs so work can
survive the app closing or losing connectivity, but uploaded inputs and results
will not become durable menu storage. A job and its data expire within 24 hours
and are deleted earlier after the client acknowledges receipt, trading a small
temporary privacy exposure for reliable background processing.
