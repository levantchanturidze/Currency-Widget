import { AggregatedResponse } from '../types/rate.types';

const BASE = '/api/rates';

async function handleResponse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`HTTP ${res.status}: ${body}`);
  }
  return res.json() as Promise<T>;
}

export const apiService = {
  async getRates(): Promise<AggregatedResponse> {
    const res = await fetch(BASE, {
      headers: { Accept: 'application/json' },
      signal: AbortSignal.timeout(15_000),
    });
    return handleResponse<AggregatedResponse>(res);
  },

  async refresh(): Promise<AggregatedResponse> {
    const res = await fetch(`${BASE}/refresh`, {
      method: 'POST',
      signal: AbortSignal.timeout(30_000),
    });
    return handleResponse<AggregatedResponse>(res);
  },
};
