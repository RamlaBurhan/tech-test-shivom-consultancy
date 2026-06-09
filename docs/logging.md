# Logging

Centralised logging uses the ELK stack in `logging/`, started with `make logging-up`. This stack is for developing and validating the logging setup locally.

## Pipeline

1. The application writes structured JSON logs to stdout via `pino`. Each line carries the service name, environment, level, timestamp and request context.
2. **Filebeat** runs as a container, discovers the application container through Docker autodiscover and reads its log file. It decodes the JSON message body into structured fields before forwarding.
3. **Logstash** receives the events on the beats input, promotes the log level and message into top-level fields and indexes them.
4. **Elasticsearch** stores the events in a daily index, `app-logs-YYYY.MM.dd`.
5. **Kibana** provides search and visualisation at `http://localhost:5601`.

## Trying it out

```bash
make logging-up
make monitoring-up
```

In Kibana create a data view for `app-logs-*` and explore. Because the logs are already structured, fields such as `app.level`, `app.req.method` and `app.res.statusCode` are searchable without grok parsing.

## Notes

- Elasticsearch security is disabled for a frictionless local run. For anything beyond local use, enable security, set credentials and put TLS in front.
- Heap is capped low (`256m`) so the stack fits on a laptop. Size it properly for real workloads.
- The same Filebeat approach works on an EC2 host: ship container logs to a managed Elasticsearch or OpenSearch domain instead of the local one.
