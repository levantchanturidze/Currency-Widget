import { Router, Request, Response } from 'express';
import { aggregateRates } from '../aggregator/aggregator.service';
import { cacheService } from '../cache/cache.service';
import { logger } from '../utils/logger';

const router = Router();

// GET /api/rates
router.get('/', async (_req: Request, res: Response): Promise<void> => {
  try {
    const cached = cacheService.get();
    if (cached) {
      res.setHeader('X-Cache', 'HIT');
      res.setHeader('X-Cache-TTL', String(cacheService.ttlRemaining()));
      res.json({ ...cached, fromCache: true });
      return;
    }

    const data = await aggregateRates();
    cacheService.set(data);

    res.setHeader('X-Cache', 'MISS');
    res.json(data);
  } catch (err) {
    logger.error('Routes', 'Unhandled error in GET /api/rates', err);
    res.status(500).json({
      error: 'Failed to fetch exchange rates',
      message: err instanceof Error ? err.message : 'Unknown error',
    });
  }
});

// POST /api/rates/refresh — bypass cache and force a fresh fetch
router.post('/refresh', async (_req: Request, res: Response): Promise<void> => {
  try {
    cacheService.flush();
    const data = await aggregateRates();
    cacheService.set(data);
    res.json(data);
  } catch (err) {
    logger.error('Routes', 'Unhandled error in POST /api/rates/refresh', err);
    res.status(500).json({ error: 'Refresh failed', message: (err as Error).message });
  }
});

// GET /api/rates/status — health check for individual sources
router.get('/status', async (_req: Request, res: Response): Promise<void> => {
  const cached = cacheService.get();
  if (cached) {
    res.json({
      sourceStatuses: cached.sourceStatuses,
      lastUpdated: cached.lastUpdated,
      cacheTtl: cacheService.ttlRemaining(),
    });
    return;
  }
  res.status(204).end();
});

export default router;
