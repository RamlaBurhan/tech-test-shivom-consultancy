# Monitoring

The monitoring stack lives in `monitoring/` and runs with `make monitoring-up`. This stack is for developing and validating the logging setup locally.

## Components

- **app** exposes `/metrics` using `prom-client`. It publishes default process metrics (CPU, memory, event loop) plus two custom series: `http_requests_total` and `http_request_duration_seconds`, both labelled by method, route and status code.
- **prometheus** scrapes the app, node-exporter and itself every 15s and evaluates the alert rules.
- **node-exporter** exposes host CPU, memory, disk and network metrics.
- **alertmanager** receives firing alerts and routes them. The receiver is a webhook sink for local testing; wire Slack, PagerDuty or email in `alertmanager/alertmanager.yml`.
- **grafana** is provisioned with Prometheus as a datasource and an application overview dashboard showing request rate, p95 latency, error ratio and process memory.

## Alert rules

Defined in `monitoring/prometheus/alerts.yml`.

Application:

- **HighErrorRate**: 5xx ratio above 5% for 2 minutes (critical).
- **HighRequestLatency**: p95 latency above 1s for 5 minutes (warning).
- **AppInstanceDown**: the app target is unscrapeable for 1 minute (critical).

Host:

- **HighCpuUsage**: CPU above 80% for 5 minutes.
- **HighMemoryUsage**: memory above 85% for 5 minutes.
- **LowDiskSpace**: disk above 85%.

## Trying it out

```bash
make monitoring-up
# drive some traffic, including errors
for i in $(seq 1 20); do curl -s localhost:3000/ >/dev/null; curl -s localhost:3000/boom >/dev/null; done
```

Then check the targets at `http://localhost:9090/targets`, the rules at `http://localhost:9090/alerts`, and the dashboard in Grafana at `http://localhost:3001`. The `/boom` endpoint returns 500s on purpose so the error-rate alert can be demonstrated.
