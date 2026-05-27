import NodeCache from 'node-cache';
import { AggregatedResponse } from '../types/rate.types';
import { logger } from '../utils/logger';

const TTL = parseInt(process.env.CACHE_TTL ?? '90', 10);
const RATES_KEY = 'aggregated_rates';

const cache = new NodeCache({ stdTTL: TTL, checkperiod: 30, useClones: false });

export const cacheService = {
  get(): AggregatedResponse | undefined {
    const value = cache.get<AggregatedResponse>(RATES_KEY);
    if (value) logger.debug('Cache', `Hit — age: ${TTL - (cache.getTtl(RATES_KEY) ?? 0) / 1000 | 0}s`);
    return value;
  },

  set(data: AggregatedResponse): void {
    cache.set(RATES_KEY, { ...data, fromCache: false });
    logger.debug('Cache', `Stored with TTL=${TTL}s`);
  },

  ttlRemaining(): number {
    const ms = cache.getTtl(RATES_KEY);
    if (!ms) return 0;
    return Math.max(0, Math.floor((ms - Date.now()) / 1000));
  },

  flush(): void {
    cache.del(RATES_KEY);
    logger.info('Cache', 'Flushed');
  },
};
