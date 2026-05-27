import { SourceStatus } from '../types/rate.types';
import './SourceBadge.css';

interface Props {
  status: SourceStatus;
}

function formatLatency(ms: number): string {
  if (ms === 0) return '—';
  return ms < 1000 ? `${ms}ms` : `${(ms / 1000).toFixed(1)}s`;
}

function formatTime(iso: string | null): string {
  if (!iso) return '—';
  return new Date(iso).toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
}

export function SourceBadge({ status }: Props) {
  return (
    <div className={`source-badge ${status.success ? 'source-badge--up' : 'source-badge--down'}`}>
      <div className="source-badge__indicator" aria-hidden="true" />
      <div className="source-badge__info">
        <span className="source-badge__name">{status.name}</span>
        {status.success ? (
          <span className="source-badge__meta">
            {status.rateCount} rates · {formatLatency(status.latencyMs)}
          </span>
        ) : (
          <span className="source-badge__error" title={status.error}>
            unavailable
          </span>
        )}
        <span className="source-badge__time">{formatTime(status.timestamp)}</span>
      </div>
    </div>
  );
}
