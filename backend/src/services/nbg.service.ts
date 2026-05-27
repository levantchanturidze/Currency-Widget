/**
 * National Bank of Georgia — official JSON API.
 * Provides central-bank reference rates (no bid/ask spread).
 * We expose buy = sell = official rate; callers can detect this because
 * NBG never produces divergent buy/sell values.
 *
 * API docs: https://nbg.gov.ge/en/monetary-policy/currency
 * Endpoint : GET https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies/en/json
 */

import { ExchangeRate } from '../types/rate.types';
import { fetchJson, now } from '../utils/http.utils';
import { logger } from '../utils/logger';

const SOURCE = 'NBG';
const API_URL =
  'https://nbg.gov.ge/gw/api/ct/monetarypolicy/currencies/en/json';

const TARGET_CURRENCIES = new Set(['USD', 'EUR', 'GBP', 'RUB', 'TRY', 'CNY', 'CHF', 'JPY']);

interface NbgCurrency {
  code: string;
  quantity: number;
  rateFormated: string;
  rate: number;
  name: string;
  diff: number;
  diffFormated: string;
  validFromDate: string;
}

interface NbgResponse {
  date: string;
  currencies: NbgCurrency[];
}

export async function fetchNbgRates(): Promise<ExchangeRate[]> {
  const data = await fetchJson<NbgResponse[]>(API_URL);

  if (!Array.isArray(data) || data.length === 0) {
    throw new Error('Unexpected NBG API response shape');
  }

  const { currencies, date } = data[0];
  const timestamp = date ? new Date(date).toISOString() : now();

  const rates: ExchangeRate[] = [];

  for (const c of currencies) {
    if (!TARGET_CURRENCIES.has(c.code)) continue;

    // NBG publishes rates per `quantity` units (e.g. JPY is per 100).
    // Normalise to per-1-unit rate.
    const rate = c.quantity > 1 ? c.rate / c.quantity : c.rate;
    const rounded = Math.round(rate * 10000) / 10000;

    rates.push({
      source: SOURCE,
      currency: c.code,
      buy: rounded,   // official rate — no spread
      sell: rounded,
      timestamp,
    });
  }

  logger.info(SOURCE, `Fetched ${rates.length} rates for ${new Date(timestamp).toLocaleDateString()}`);
  return rates;
}
