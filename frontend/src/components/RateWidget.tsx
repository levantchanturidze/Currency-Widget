import { useRates } from '../hooks/useRates';
import { RateTable } from './RateTable';
import { SourceBadge } from './SourceBadge';
import './RateWidget.css';

function LoadingSkeleton() {
  return (
    <div className="skeleton-wrapper" aria-label="Loading exchange rates">
      <div className="skeleton skeleton--title" />
      <div className="skeleton-badges">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="skeleton skeleton--badge" />
        ))}
      </div>
      <div className="skeleton skeleton--table" />
    </div>
  );
}

function ErrorBanner({ message, onRetry }: { message: string; onRetry: () => void }) {
  return (
    <div className="error-banner" role="alert">
      <div className="error-banner__icon">⚠</div>
      <div className="error-banner__body">
        <strong>Could not load rates</strong>
        <span>{message}</span>
      </div>
      <button className="error-banner__retry" onClick={onRetry}>
        Retry
      </button>
    </div>
  );
}

function formatTimestamp(date: Date | null): string {
  if (!date) return '—';
  return date.toLocaleTimeString('en-GB', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  });
}

export function RateWidget() {
  const { data, loading, error, lastFetchedAt, secondsUntilRefresh, refresh, forceRefresh } =
    useRates();

  return (
    <div className="rate-widget">
      {/* ── Header ── */}
      <div className="rate-widget__header">
        <div className="rate-widget__title-block">
          <h1 className="rate-widget__title">Georgian Exchange Rates</h1>
          <p className="rate-widget__subtitle">
            Aggregated from 5 sources · rates in GEL per 1 unit
          </p>
        </div>

        <div className="rate-widget__controls">
          {data?.fromCache && (
            <span className="rate-widget__cache-badge" title="Data served from cache">
              cached
            </span>
          )}
          <div className="rate-widget__refresh-info">
            <span className="rate-widget__updated">
              Updated {formatTimestamp(lastFetchedAt)}
            </span>
            <span className="rate-widget__countdown">
              Next refresh in {secondsUntilRefresh}s
            </span>
          </div>
          <button
            className="rate-widget__refresh-btn"
            onClick={forceRefresh}
            disabled={loading}
            title="Force refresh all sources"
          >
            <span className={`refresh-icon ${loading ? 'refresh-icon--spinning' : ''}`}>↻</span>
            Refresh
          </button>
        </div>
      </div>

      {/* ── Source status bar ── */}
      {data && (
        <div className="rate-widget__sources" aria-label="Source status">
          {data.sourceStatuses.map((status) => (
            <SourceBadge key={status.name} status={status} />
          ))}
        </div>
      )}

      {/* ── Content area ── */}
      <div className="rate-widget__body">
        {loading && !data && <LoadingSkeleton />}

        {error && !data && (
          <ErrorBanner message={error} onRetry={refresh} />
        )}

        {error && data && (
          <div className="rate-widget__stale-warning" role="status">
            ⚠ Showing stale data — {error}
          </div>
        )}

        {data && (
          <RateTable
            currencies={data.currencies}
            sources={data.sources}
            rates={data.rates}
          />
        )}
      </div>
    </div>
  );
}
