const isDev = process.env.NODE_ENV !== 'production';

function formatMessage(level: string, source: string, message: string): string {
  return `[${new Date().toISOString()}] [${level.toUpperCase()}] [${source}] ${message}`;
}

export const logger = {
  info(source: string, message: string): void {
    console.log(formatMessage('info', source, message));
  },
  warn(source: string, message: string): void {
    console.warn(formatMessage('warn', source, message));
  },
  error(source: string, message: string, err?: unknown): void {
    const errMsg =
      err instanceof Error ? ` — ${err.message}` : err != null ? ` — ${String(err)}` : '';
    console.error(formatMessage('error', source, message + errMsg));
    if (isDev && err instanceof Error && err.stack) {
      console.error(err.stack);
    }
  },
  debug(source: string, message: string): void {
    if (isDev) console.debug(formatMessage('debug', source, message));
  },
};
