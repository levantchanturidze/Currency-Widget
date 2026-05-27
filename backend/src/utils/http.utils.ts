import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';

const DEFAULT_TIMEOUT_MS = parseInt(process.env.REQUEST_TIMEOUT_MS ?? '5000', 10);
const DEFAULT_RETRIES = parseInt(process.env.RETRY_ATTEMPTS ?? '2', 10);

const RETRY_DELAY_BASE_MS = 500;

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  retries = DEFAULT_RETRIES,
  attempt = 0,
): Promise<T> {
  try {
    return await fn();
  } catch (err) {
    if (attempt >= retries) throw err;
    await sleep(RETRY_DELAY_BASE_MS * Math.pow(2, attempt));
    return withRetry(fn, retries, attempt + 1);
  }
}

export async function fetchHtml(
  url: string,
  config: AxiosRequestConfig = {},
): Promise<string> {
  const response: AxiosResponse<string> = await withRetry(() =>
    axios.get<string>(url, {
      timeout: DEFAULT_TIMEOUT_MS,
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        Accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br',
        Connection: 'keep-alive',
      },
      ...config,
    }),
  );
  return response.data;
}

export async function fetchJson<T>(
  url: string,
  config: AxiosRequestConfig = {},
): Promise<T> {
  const response: AxiosResponse<T> = await withRetry(() =>
    axios.get<T>(url, {
      timeout: DEFAULT_TIMEOUT_MS,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'User-Agent': 'CurrencyWidget/1.0',
      },
      ...config,
    }),
  );
  return response.data;
}

export function parseFloat2(value: string | undefined | null): number | null {
  if (value == null) return null;
  const cleaned = value.replace(/[^\d.]/g, '');
  const parsed = parseFloat(cleaned);
  return isNaN(parsed) || parsed <= 0 ? null : parsed;
}

export function now(): string {
  return new Date().toISOString();
}
