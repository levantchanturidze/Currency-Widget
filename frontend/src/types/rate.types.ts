export interface ExchangeRate {
  source: string;
  currency: string;
  buy: number | null;
  sell: number | null;
  timestamp: string;
  isBestBuy: boolean;
  isBestSell: boolean;
}

export interface SourceStatus {
  name: string;
  success: boolean;
  timestamp: string | null;
  rateCount: number;
  error?: string;
  latencyMs: number;
}

export interface AggregatedResponse {
  currencies: string[];
  sources: string[];
  rates: ExchangeRate[];
  sourceStatuses: SourceStatus[];
  lastUpdated: string;
  fromCache: boolean;
}

// Lookup helper: [source][currency] → ExchangeRate
export type RateMatrix = Map<string, Map<string, ExchangeRate>>;

export function buildRateMatrix(rates: ExchangeRate[]): RateMatrix {
  const matrix: RateMatrix = new Map();
  for (const rate of rates) {
    if (!matrix.has(rate.source)) matrix.set(rate.source, new Map());
    matrix.get(rate.source)!.set(rate.currency, rate);
  }
  return matrix;
}
