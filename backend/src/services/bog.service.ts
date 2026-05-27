/**
 * Bank of Georgia (BOG) — exchange rates.
 *
 * BOG redirected bog.ge to bankofgeorgia.ge. The internal JSON endpoint
 * is publicly accessible at:
 *   GET https://bankofgeorgia.ge/api/currencies/GetExchangeRate
 *
 * Response shape: { data: [{ ccy, buyRate, sellRate, ... }] }
 */

import { ExchangeRate } from '../types/rate.types';
import { fetchJson, now } from '../utils/http.utils';
import { logger } from '../utils/logger';

const SOURCE = 'BOG';
const API_URL = 'https://bankofgeorgia.ge/api/currencies/GetExchangeRate';

interface BogCurrency {
  ccy: string;
  buyRate: number;
  sellRate: number;
  dgtlBuyRate: number;
  dgtlSellRate: number;
  currentRate: number;
}

interface BogApiResponse {
  data: BogCurrency[];
}

export async function fetchBogRates(): Promise<ExchangeRate[]> {
  const response = await fetchJson<BogApiResponse>(API_URL, {
    headers: {
      Referer: 'https://bankofgeorgia.ge/',
      Accept: 'application/json',
    },
  });

  if (!response?.data || !Array.isArray(response.data)) {
    throw new Error('Unexpected BOG API response shape');
  }

  const timestamp = now();
  const rates: ExchangeRate[] = response.data
    .filter((c) => c.ccy && c.buyRate > 0 && c.sellRate > 0)
    .map((c) => ({
      source: SOURCE,
      currency: c.ccy.toUpperCase(),
      buy: c.buyRate,
      sell: c.sellRate,
      timestamp,
    }));

  logger.info(SOURCE, `Fetched ${rates.length} rates via API`);
  return rates;
}
