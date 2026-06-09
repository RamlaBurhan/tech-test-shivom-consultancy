import express from 'express';
import pinoHttp from 'pino-http';
import logger from './logger.js';
import { register, metricsMiddleware } from './metrics.js';

const VERSION = process.env.APP_VERSION || '1.0.0';
const startedAt = Date.now();

export function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json());
  app.use(pinoHttp({ logger }));
  app.use(metricsMiddleware);

  app.get('/', (req, res) => {
    res.type('html').send(
      `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Sample Web App</title></head>` +
      `<body><h1>Sample Web App</h1><p>Version ${VERSION}</p>` +
      `<ul><li><a href="/healthz">/healthz</a></li><li><a href="/api/info">/api/info</a></li>` +
      `<li><a href="/metrics">/metrics</a></li></ul></body></html>`
    );
  });

  app.get('/healthz', (req, res) => {
    res.json({ status: 'ok' });
  });

  app.get('/readyz', (req, res) => {
    res.json({ status: 'ready' });
  });

  app.get('/api/info', (req, res) => {
    res.json({
      service: process.env.SERVICE_NAME || 'sample-web-app',
      version: VERSION,
      env: process.env.NODE_ENV || 'development',
      uptimeSeconds: Math.floor((Date.now() - startedAt) / 1000),
    });
  });

  app.get('/api/echo/:value', (req, res) => {
    res.json({ value: req.params.value });
  });

  app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  });

  app.get('/boom', (req, res) => {
    res.status(500).json({ error: 'intentional error for testing alerts' });
  });

  app.use((req, res) => {
    res.status(404).json({ error: 'not found' });
  });

  return app;
}

export default createApp;
