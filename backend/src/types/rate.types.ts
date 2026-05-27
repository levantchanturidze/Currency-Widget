export interface ExchangeRate {
  source: string;
  currency: string;
  buy: number | null;
  sell: number | null;
  timestamp: string;
}

export interface ExchangeRateWithFlags extends ExchangeRate {
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
  rates: ExchangeRateWithFlags[];
  sourceStatuses: SourceStatus[];
  lastUpdated: string;
  fromCache: boolean;
}

export type ServiceFetcher = () => Promise<ExchangeRate[]>;
