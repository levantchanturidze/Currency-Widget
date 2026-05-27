import { fetchNbgRates } from '../services/nbg.service';
import { fetchTbcRates } from '../services/tbc.service';
import { fetchBogRates } from '../services/bog.service';
import { fetchRicoRates } from '../services/rico.service';
import { fetchKursiRates } from '../services/kursi.service';
import {
  AggregatedResponse,
  ExchangeRate,
  ExchangeRateWithFlags,
  ServiceFetcher,
  SourceStatus,
} from '../types/rate.types';
import { logger } from '../utils/logger';

// Currencies we want to surface (everything else is filtered out).
const TARGET_CURRENCIES = ['USD', 'EUR', 'GBP', 'RUB', 'TRY', 'CNY', 'CHF', 'JPY'];
const SOURCE_ORDER = ['NBG', 'TBC', 'BOG', 'RICO', 'KURSI'];

interface ServiceDescriptor {
  name: string;
  fetch: ServiceFetcher;
}

const SERVICES: ServiceDescriptor[] = [
  { name: 'NBG', fetch: fetchNbgRates },
  { name: 'TBC', fetch: fetchTbcRates },
  { name: 'BOG', fetch: fetchBogRates },
  { name: 'RICO', fetch: fetchRicoRates },
  { name: 'KURSI', fetch: fetchKursiRates },
];

// ── Core logic ───────────────────────────────────────────────────────────────

function deduplicateRates(rates: ExchangeRate[]): ExchangeRate[] {
  const seen = new Map<string, ExchangeRate>();
  for (const rate of rates) {
    const key = `${rate.source}:${rate.currency}`;
    if (!seen.has(key)) seen.set(key, rate);
  }
  return Array.from(seen.values());
}

function flagBestRates(rates: ExchangeRate[]): ExchangeRateWithFlags[] {
  // Group by currency
  const byCurrency = new Map<string, ExchangeRate[]>();
  for (const rate of rates) {
    const bucket = byCurrency.get(rate.currency) ?? [];
    bucket.push(rate);
    byCurrency.set(rate.currency, bucket);
  }

  const result: ExchangeRateWithFlags[] = [];

  for (const [, group] of byCurrency) {
    const validBuy = group.filter((r) => r.buy !== null).map((r) => r.buy as number);
    const validSell = group.filter((r) => r.sell !== null).map((r) => r.sell as number);

    // Best buy  = highest buy rate  (customer gets most GEL per foreign unit)
    // Best sell = lowest sell rate  (customer pays least GEL per foreign unit)
    const maxBuy = validBuy.length > 0 ? Math.max(...validBuy) : null;
    const minSell = validSell.length > 0 ? Math.min(...validSell) : null;

    for (const rate of group) {
      result.push({
        ...rate,
        isBestBuy: maxBuy !== null && rate.buy !== null && rate.buy === maxBuy,
        isBestSell: minSell !== null && rate.sell !== null && rate.sell === minSell,
      });
    }
  }

  return result;
}

// ── Fan-out executor ─────────────────────────────────────────────────────────

export async function aggregateRates(): Promise<AggregatedResponse> {
  const startTime = Date.now();

  const results = await Promise.allSettled(
    SERVICES.map(async (svc) => {
      const t0 = Date.now();
      const rates = await svc.fetch();
      return { name: svc.name, rates, latencyMs: Date.now() - t0 };
    }),
  );

  const allRates: ExchangeRate[] = [];
  const sourceStatuses: SourceStatus[] = [];
  const availableSources: string[] = [];

  for (let i = 0; i < results.length; i++) {
    const svc = SERVICES[i];
    const result = results[i];

    if (result.status === 'fulfilled') {
      const { rates, latencyMs } = result.value;
      const filtered = rates.filter((r) => TARGET_CURRENCIES.includes(r.currency));

      allRates.push(...filtered);
      availableSources.push(svc.name);
      sourceStatuses.push({
        name: svc.name,
        success: true,
        timestamp: filtered[0]?.timestamp ?? new Date().toISOString(),
        rateCount: filtered.length,
        latencyMs,
      });
      logger.debug('Aggregator', `${svc.name}: ${filtered.length} rates in ${latencyMs}ms`);
    } else {
      const err = result.reason as Error;
      logger.error('Aggregator', `${svc.name} failed`, err);
      sourceStatuses.push({
        name: svc.name,
        success: false,
        timestamp: null,
        rateCount: 0,
        error: err.message,
        latencyMs: 0,
      });
    }
  }

  const deduped = deduplicateRates(allRates);
  const flagged = flagBestRates(deduped);

  const presentCurrencies = TARGET_CURRENCIES.filter((c) =>
    deduped.some((r) => r.currency === c),
  );
  const presentSources = SOURCE_ORDER.filter((s) => availableSources.includes(s));

  logger.info(
    'Aggregator',
    `Done in ${Date.now() - startTime}ms — ${flagged.length} rates from ${presentSources.length}/${SERVICES.length} sources`,
  );

  return {
    currencies: presentCurrencies,
    sources: presentSources,
    rates: flagged,
    sourceStatuses,
    lastUpdated: new Date().toISOString(),
    fromCache: false,
  };
}
