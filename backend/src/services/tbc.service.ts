/**
 * TBC Bank — exchange rates.
 *
 * TBC's main website (tbcbank.ge) is a pure client-side Angular app whose
 * exchange-rate API gateway (apigw.tbcbank.ge) requires authentication on
 * all routes — making direct scraping impractical without a headless browser.
 *
 * Strategy (in order):
 *   1. TBC public developer API  GET https://api.tbcbank.ge/v1/currency/rates
 *      Requires header `apikey: <TBC_API_KEY>` from .env.
 *   2. Kursi.ge public API       GET https://api.kursi.ge:8080/api/public/currencies
 *      Kursi aggregates TBC rates in `bankRates.TBC` — publicly accessible.
 *
 * If both fail the aggregator marks TBC as unavailable for that cycle.
 */

import { ExchangeRate } from '../types/rate.types';
import { fetchJson, now } from '../utils/http.utils';
import { logger } from '../utils/logger';

const SOURCE = 'TBC';
const TBC_API_URL = 'https://api.tbcbank.ge/v1/currency/rates';
const KURSI_API_URL = 'https://api.kursi.ge:8080/api/public/currencies';

// ── Strategy 1: TBC developer REST API ──────────────────────────────────────

interface TbcApiRate {
  currency: string;
  buy: number;
  sell: number;
}

async function fetchViaApi(): Promise<ExchangeRate[]> {
  const apiKey = process.env.TBC_API_KEY;
  if (!apiKey) throw new Error('TBC_API_KEY not configured');

  const data = await fetchJson<TbcApiRate[]>(TBC_API_URL, {
    headers: { apikey: apiKey, Accept: 'application/json' },
  });

  if (!Array.isArray(data)) throw new Error('Unexpected TBC API response shape');

  const timestamp = now();
  return data
    .filter((r) => r.currency && r.buy > 0 && r.sell > 0)
    .map((r) => ({
      source: SOURCE,
      currency: r.currency.toUpperCase(),
      buy: r.buy,
      sell: r.sell,
      timestamp,
    }));
}

// ── Strategy 2: Kursi.ge public API (includes TBC bank rates) ───────────────

interface KursiCurrency {
  baseCurrencyCode: string;
  secondaryCurrencyCode: string;
  bankRates?: {
    TBC?: { buyRate: number; sellRate: number };
  };
}

async function fetchViaKursi(): Promise<ExchangeRate[]> {
  const data = await fetchJson<KursiCurrency[]>(KURSI_API_URL, {
    headers: {
      'Cache-Control': 'no-cache',
      Origin: 'https://www.kursi.ge',
      Referer: 'https://www.kursi.ge/',
    },
  });

  if (!Array.isArray(data) || data.length === 0) {
    throw new Error('Kursi API returned empty response');
  }

  const timestamp = now();
  const rates: ExchangeRate[] = [];

  for (const c of data) {
    if (c.baseCurrencyCode !== 'GEL') continue;
    const tbc = c.bankRates?.TBC;
    if (!tbc || !tbc.buyRate || !tbc.sellRate) continue;

    rates.push({
      source: SOURCE,
      currency: c.secondaryCurrencyCode.toUpperCase(),
      buy: tbc.buyRate,
      sell: tbc.sellRate,
      timestamp,
    });
  }

  if (rates.length === 0) throw new Error('No TBC rates found in Kursi response');
  return rates;
}

// ── Public entry point ───────────────────────────────────────────────────────

export async function fetchTbcRates(): Promise<ExchangeRate[]> {
  if (process.env.TBC_API_KEY) {
    try {
      const rates = await fetchViaApi();
      logger.info(SOURCE, `Fetched ${rates.length} rates via TBC developer API`);
      return rates;
    } catch (err) {
      logger.warn(SOURCE, `TBC API failed, falling back to Kursi — ${(err as Error).message}`);
    }
  }

  const rates = await fetchViaKursi();
  logger.info(SOURCE, `Fetched ${rates.length} rates via Kursi (bankRates.TBC)`);
  return rates;
}
