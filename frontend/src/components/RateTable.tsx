import { ExchangeRate, RateMatrix, buildRateMatrix } from '../types/rate.types';
import './RateTable.css';

interface Props {
  currencies: string[];
  sources: string[];
  rates: ExchangeRate[];
}

const CURRENCY_NAMES: Record<string, string> = {
  USD: 'US Dollar',
  EUR: 'Euro',
  GBP: 'British Pound',
  RUB: 'Russian Ruble',
  TRY: 'Turkish Lira',
  CNY: 'Chinese Yuan',
  CHF: 'Swiss Franc',
  JPY: 'Japanese Yen',
};

const CURRENCY_FLAGS: Record<string, string> = {
  USD: '🇺🇸',
  EUR: '🇪🇺',
  GBP: '🇬🇧',
  RUB: '🇷🇺',
  TRY: '🇹🇷',
  CNY: '🇨🇳',
  CHF: '🇨🇭',
  JPY: '🇯🇵',
};

function fmt(value: number | null): string {
  if (value === null) return '—';
  return value.toFixed(4);
}

interface RateCellProps {
  rate: ExchangeRate | undefined;
  sourceName: string;
}

function RateCell({ rate, sourceName }: RateCellProps) {
  if (!rate) {
    return (
      <td className="rate-cell rate-cell--empty">
        <span className="rate-cell__na">N/A</span>
      </td>
    );
  }

  // NBG is a reference rate — buy === sell, show as single value
  const isReferenceRate = sourceName === 'NBG' && rate.buy === rate.sell;

  return (
    <td className="rate-cell">
      {isReferenceRate ? (
        <div className="rate-cell__official">
          <span className="rate-cell__label">Ref</span>
          <span
            className={`rate-cell__value ${rate.isBestBuy ? 'rate-cell__value--best-buy' : ''} ${rate.isBestSell ? 'rate-cell__value--best-sell' : ''}`}
          >
            {fmt(rate.buy)}
          </span>
        </div>
      ) : (
        <div className="rate-cell__spread">
          <div className={`rate-cell__row ${rate.isBestBuy ? 'rate-cell__row--best-buy' : ''}`}>
            <span className="rate-cell__label">Buy</span>
            <span className="rate-cell__value">{fmt(rate.buy)}</span>
            {rate.isBestBuy && <span className="rate-cell__badge rate-cell__badge--buy">★</span>}
          </div>
          <div className={`rate-cell__row ${rate.isBestSell ? 'rate-cell__row--best-sell' : ''}`}>
            <span className="rate-cell__label">Sell</span>
            <span className="rate-cell__value">{fmt(rate.sell)}</span>
            {rate.isBestSell && <span className="rate-cell__badge rate-cell__badge--sell">★</span>}
          </div>
        </div>
      )}
    </td>
  );
}

export function RateTable({ currencies, sources, rates }: Props) {
  const matrix: RateMatrix = buildRateMatrix(rates);

  if (currencies.length === 0 || sources.length === 0) {
    return (
      <div className="rate-table-empty">
        No data available from any source.
      </div>
    );
  }

  return (
    <div className="rate-table-wrapper">
      <table className="rate-table">
        <thead>
          <tr>
            <th className="rate-table__currency-header">Currency</th>
            {sources.map((src) => (
              <th key={src} className="rate-table__source-header">
                {src}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {currencies.map((currency) => (
            <tr key={currency} className="rate-table__row">
              <td className="rate-table__currency-cell">
                <span className="rate-table__flag">{CURRENCY_FLAGS[currency] ?? '🏳️'}</span>
                <span className="rate-table__code">{currency}</span>
                <span className="rate-table__name">{CURRENCY_NAMES[currency] ?? currency}</span>
              </td>
              {sources.map((src) => (
                <RateCell key={src} rate={matrix.get(src)?.get(currency)} sourceName={src} />
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      <div className="rate-table__legend">
        <span className="legend-item legend-item--buy">
          <span className="legend-dot legend-dot--buy" /> Best buy rate (highest — you get most GEL)
        </span>
        <span className="legend-item legend-item--sell">
          <span className="legend-dot legend-dot--sell" /> Best sell rate (lowest — you pay least GEL)
        </span>
      </div>
    </div>
  );
}
