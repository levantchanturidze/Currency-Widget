/**
 * Rico.ge — Georgian currency exchange company.
 *
 * Rico publishes live buy/sell rates on their homepage in a clear HTML table.
 * We scrape that table with multiple selector fallbacks.
 *
 * Scrape target: https://www.rico.ge
 */

import * as cheerio from 'cheerio';
import { ExchangeRate } from '../types/rate.types';
import { fetchHtml, parseFloat2, now } from '../utils/http.utils';
import { logger } from '../utils/logger';

const SOURCE = 'RICO';
const URL = 'https://www.rico.ge';

export async function fetchRicoRates(): Promise<ExchangeRate[]> {
  const html = await fetchHtml(URL);
  const $ = cheerio.load(html);
  const rates: ExchangeRate[] = [];
  const timestamp = now();

  // Pattern A: Rico renders a rates table where each row has:
  //   [flag/icon] | currency code | buy | sell
  // Common class names observed: .currency-table, .rates-table, .exchange-table
  const tableSelectors = [
    'table.currency-table tr',
    'table.rates-table tr',
    'table.exchange-table tr',
    '.rate-table tr',
    'table tr',
  ];

  for (const selector of tableSelectors) {
    $(selector).each((_, row) => {
      const cells = $(row).find('td');
      if (cells.length < 3) return;

      // Scan all cells for a 3-letter currency code
      let code = '';
      let buyIdx = -1;
      let sellIdx = -1;

      cells.each((i, cell) => {
        const text = $(cell).text().trim();
        if (!code && /^[A-Z]{3}$/.test(text)) {
          code = text;
          buyIdx = i + 1;
          sellIdx = i + 2;
        }
      });

      if (!code || buyIdx < 0 || sellIdx >= cells.length) return;

      const buy = parseFloat2($(cells[buyIdx]).text());
      const sell = parseFloat2($(cells[sellIdx]).text());

      if (buy === null || sell === null || buy <= 0 || sell <= 0) return;
      rates.push({ source: SOURCE, currency: code, buy, sell, timestamp });
    });

    if (rates.length > 0) break;
  }

  // Pattern B: list/card layout (some sites use divs instead of tables)
  if (rates.length === 0) {
    $('[class*="rate"], [class*="currency"], [class*="exchange"]').each((_, el) => {
      const text = $(el).text();
      const codeMatch = text.match(/\b([A-Z]{3})\b/);
      if (!codeMatch) return;

      const numbers = [...text.matchAll(/([\d]+[.,][\d]{2,4})/g)]
        .map((m) => parseFloat(m[1].replace(',', '.')))
        .filter((n) => n > 0);

      if (numbers.length < 2) return;
      rates.push({
        source: SOURCE,
        currency: codeMatch[1],
        buy: numbers[0],
        sell: numbers[1],
        timestamp,
      });
    });
  }

  // Pattern C: inline JSON in script tags
  if (rates.length === 0) {
    $('script').each((_, el) => {
      const content = $(el).html() ?? '';
      if (!content.includes('buy') || !content.includes('sell')) return;
      const matches = [...content.matchAll(/"(?:code|currency)"\s*:\s*"([A-Z]{3})".+?"buy"\s*:\s*([\d.]+).+?"sell"\s*:\s*([\d.]+)/gs)];
      for (const m of matches) {
        rates.push({
          source: SOURCE,
          currency: m[1],
          buy: parseFloat(m[2]),
          sell: parseFloat(m[3]),
          timestamp,
        });
      }
    });
  }

  if (rates.length === 0) {
    throw new Error('Rico scraping: no rates found — selectors may need updating');
  }

  logger.info(SOURCE, `Fetched ${rates.length} rates via scraping`);
  return rates;
}
