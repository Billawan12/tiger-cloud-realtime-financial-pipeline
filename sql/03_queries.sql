-- ============================================================
-- Real-Time Financial Data Pipeline
-- Verification and Analysis Queries
-- ============================================================


-- ============================================================
-- 1. View the most recent financial ticks
-- ============================================================

SELECT
    "time",
    symbol,
    price,
    day_volume
FROM crypto_ticks
ORDER BY "time" DESC
LIMIT 20;


-- ============================================================
-- 2. Count total ticks and distinct symbols
-- ============================================================

SELECT
    COUNT(*) AS total_ticks,
    COUNT(DISTINCT symbol) AS symbols
FROM crypto_ticks;


-- ============================================================
-- 3. View the symbols currently stored
-- ============================================================

SELECT DISTINCT
    symbol
FROM crypto_ticks
ORDER BY symbol;


-- ============================================================
-- 4. View the daily OHLCV data for BTC/USD
-- ============================================================

SELECT
    bucket,
    symbol,
    "open",
    high,
    low,
    "close",
    day_volume
FROM one_day_candle
WHERE symbol = 'BTC/USD'
  AND bucket >= NOW() - INTERVAL '14 days'
ORDER BY bucket;


-- ============================================================
-- 5. View daily OHLCV data for all symbols
-- ============================================================

SELECT
    bucket,
    symbol,
    "open",
    high,
    low,
    "close",
    day_volume
FROM one_day_candle
ORDER BY bucket DESC, symbol;


-- ============================================================
-- 6. Verify that crypto_ticks is a TimescaleDB hypertable
-- ============================================================

SELECT
    hypertable_schema,
    hypertable_name
FROM timescaledb_information.hypertables
WHERE hypertable_name = 'crypto_ticks';


-- ============================================================
-- 7. Verify that the Continuous Aggregate exists
-- ============================================================

SELECT
    view_schema,
    view_name
FROM timescaledb_information.continuous_aggregates
WHERE view_name = 'one_day_candle';