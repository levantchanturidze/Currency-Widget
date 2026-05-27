import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import ratesRouter from './routes/rates.routes';
import { notFoundHandler, globalErrorHandler } from './middleware/error.middleware';
import { logger } from './utils/logger';

const app = express();
const PORT = parseInt(process.env.PORT ?? '3001', 10);

// ── Middleware ───────────────────────────────────────────────────────────────

app.use(
  cors({
    origin: process.env.ALLOWED_ORIGIN ?? '*',
    methods: ['GET', 'POST'],
  }),
);

app.use(express.json());

// Request logger
app.use((req, _res, next) => {
  logger.debug('HTTP', `${req.method} ${req.path}`);
  next();
});

// ── Routes ───────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

app.use('/api/rates', ratesRouter);

// ── Error handlers ───────────────────────────────────────────────────────────

app.use(notFoundHandler);
app.use(globalErrorHandler);

// ── Start ────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  logger.info('App', `Server running on http://localhost:${PORT}`);
  logger.info('App', `Environment: ${process.env.NODE_ENV ?? 'development'}`);
  logger.info('App', `TBC API key: ${process.env.TBC_API_KEY ? 'configured' : 'not set (using scraping)'}`);
});

export default app;
