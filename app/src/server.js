import { createApp } from './app.js';
import logger from './logger.js';

const PORT = process.env.PORT || 3000;
const app = createApp();

const server = app.listen(PORT, () => {
  logger.info(`server listening on port ${PORT}`);
});

function shutdown(signal) {
  logger.info(`received ${signal}, shutting down`);
  server.close(() => {
    logger.info('server closed');
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
