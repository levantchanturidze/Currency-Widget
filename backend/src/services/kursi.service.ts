/**
 * Kursi.ge — Georgian currency aggregator.
 *
 * Kursi.ge runs a public REST API at api.kursi.ge:8080 that returns
 * their own aggregated best rates (combining NBG, TBC, BOG data).
 *
 * Endpoint: GET https://api.kursi.ge:8080/api/public/currencies
 *
 * Response: [{ baseCurrencyCode, secondaryCurrencyCode, nbgRate,
 *              buyRate, sellRate, bankRates: { TBC, BOG } }]
 *
 * The "Kursi rate" is their own best-composite rate (buy/sell),
 * not NBG or a specific bank.
 */

import { ExchangeRate } from '../types/rate.types';
import { fetchJson, now } from '../utils/http.utils';
import { logger } from '../utils/logger';

const SOURCE = 'KURSI';
const API_URL = 'https://api.kursi.ge:8080/api/public/currencies';

interface KursiCurrency {
  baseCurrencyCode: string;
  secondaryCurrencyCode: string;
  name: string;
  nbgRate: number;
  diff: number;
  buyRate: number;
  sellRate: number;
  bankRates?: {
    TBC?: { buyRate: number; sellRate: number };
    BOG?: { buyRate: number; sellRate: number };
  };
}

export async function fetchKursiRates(): Promise<ExchangeRate[]> {
  const data = await fetchJson<KursiCurrency[]>(API_URL, {
    headers: {
      'Cache-Control': 'no-cache',
      Origin: 'https://www.kursi.ge',
      Referer: 'https://www.kursi.ge/',
    },
  });

  if (!Array.isArray(data) || data.length === 0) {
    throw new Error('Unexpected Kursi API response shape');
  }

  const timestamp = now();

  // Kursi normalises everything as GEL base → secondary currency.
  // We only keep rates where base is GEL (standard Georgian convention).
  const rates: ExchangeRate[] = data
    .filter(
      (c) =>
        c.baseCurrencyCode === 'GEL' &&
        c.secondaryCurrencyCode &&
        c.buyRate > 0 &&
        c.sellRate > 0,
    )
    .map((c) => ({
      source: SOURCE,
      currency: c.secondaryCurrencyCode.toUpperCase(),
      buy: c.buyRate,
      sell: c.sellRate,
      timestamp,
    }));

  logger.info(SOURCE, `Fetched ${rates.length} rates via API`);
  return rates;
}
