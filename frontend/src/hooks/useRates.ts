import { useState, useEffect, useCallback, useRef } from 'react';
import { AggregatedResponse } from '../types/rate.types';
import { apiService } from '../services/api.service';

const AUTO_REFRESH_MS = 60_000;

interface UseRatesResult {
  data: AggregatedResponse | null;
  loading: boolean;
  error: string | null;
  lastFetchedAt: Date | null;
  secondsUntilRefresh: number;
  refresh: () => Promise<void>;
  forceRefresh: () => Promise<void>;
}

export function useRates(): UseRatesResult {
  const [data, setData] = useState<AggregatedResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastFetchedAt, setLastFetchedAt] = useState<Date | null>(null);
  const [secondsUntilRefresh, setSecondsUntilRefresh] = useState(AUTO_REFRESH_MS / 1000);

  const autoRefreshTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const countdownTimer = useRef<ReturnType<typeof setInterval> | null>(null);

  const resetCountdown = useCallback(() => {
    setSecondsUntilRefresh(AUTO_REFRESH_MS / 1000);
    if (countdownTimer.current) clearInterval(countdownTimer.current);
    countdownTimer.current = setInterval(() => {
      setSecondsUntilRefresh((s) => Math.max(0, s - 1));
    }, 1000);
  }, []);

  const scheduleAutoRefresh = useCallback((fetchFn: () => Promise<void>) => {
    if (autoRefreshTimer.current) clearTimeout(autoRefreshTimer.current);
    autoRefreshTimer.current = setTimeout(fetchFn, AUTO_REFRESH_MS);
    resetCountdown();
  }, [resetCountdown]);

  const fetchRates = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await apiService.getRates();
      setData(result);
      setLastFetchedAt(new Date());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch rates');
    } finally {
      setLoading(false);
    }
  }, []);

  const refresh = useCallback(async () => {
    await fetchRates();
    scheduleAutoRefresh(refresh);
  }, [fetchRates, scheduleAutoRefresh]);

  const forceRefresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await apiService.refresh();
      setData(result);
      setLastFetchedAt(new Date());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Refresh failed');
    } finally {
      setLoading(false);
      scheduleAutoRefresh(refresh);
    }
  }, [refresh, scheduleAutoRefresh]);

  useEffect(() => {
    refresh();
    return () => {
      if (autoRefreshTimer.current) clearTimeout(autoRefreshTimer.current);
      if (countdownTimer.current) clearInterval(countdownTimer.current);
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // Schedule next refresh after data loads
  useEffect(() => {
    if (data && !loading) scheduleAutoRefresh(refresh);
  }, [data, loading]); // eslint-disable-line react-hooks/exhaustive-deps

  return { data, loading, error, lastFetchedAt, secondsUntilRefresh, refresh, forceRefresh };
}
