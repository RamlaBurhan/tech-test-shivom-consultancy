# Troubleshooting a performance incident

## Scenario

Alerts fire: **HighRequestLatency** then **HighErrorRate**. Users report slow pages and intermittent 500s.

## 1. Confirm and quantify

Start by looking at the signals

- Grafana: is latency up across all routes or one? Did request rate spike first (load) or did latency climb at flat traffic (a dependency or the app itself)?
- Alertmanager: which alerts are firing and since when, so the change can be lined up against a deploy or a traffic change.

## 2. Correlate with logs

In Kibana, filter `app-logs-*` to `app.res.statusCode >= 500` over the incident window. Group by route and message. Structured logs make it quick to see whether the errors are timeouts, upstream failures or unhandled exceptions, and whether they cluster on one instance.

## 3. Check the hosts

node-exporter answers whether this is resource exhaustion:

- CPU saturation (**HighCpuUsage**) points at the app being compute-bound or under-provisioned for the load.
- Memory pressure (**HighMemoryUsage**) suggests a leak or an undersized instance
- Disk (**LowDiskSpace**) can stall logging and databases.

## 4. Form and test a hypothesis

Typical root causes and how to confirm each:

- **A slow or failing dependency** (database, downstream API). Latency concentrated on routes that call it, errors are timeouts. Confirm with dependency metrics and connection-pool saturation.
- **Undersized capacity for a traffic spike**. Request rate rose first, CPU is saturated, latency follows. Confirm by lining up the rate and CPU graphs.
- **A bad release**. The inflection lines up exactly with a deploy. Confirm from the deploy timestamp and roll back.
- **A resource leak**. Memory or connections grow steadily until the instance degrades. Confirm from the slope on the resident-memory series.

## 5. Mitigate and then fix the

- Immediate: roll back the suspect release, scale out (raise `instance_count` and rely on the load balancer), or shed load if a single client is responsible.
- Short term: raise timeouts and pool sizes, add caching, fix the slow query.
- Durable: add a regression test or load test, tune the alert thresholds if they were too slow or too noisy, and capture the finding in a short postmortem.



