--Create the OHLCV Continuous Aggregate
CREATE MATERIALIZED VIEW one_day_candle
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 day', time) AS bucket,
    symbol,
    FIRST(price, time) AS "open",
    MAX(price) AS high,
    MIN(price) AS low,
    LAST(price, time) AS "close",
    LAST(day_volume, time) AS day_volume
FROM crypto_ticks
GROUP BY bucket, symbol;

--Add the refresh policy
SELECT add_continuous_aggregate_policy(
    'one_day_candle',
    start_offset => INTERVAL '3 days',
    end_offset => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 day'
);

--Query the financial candles
SELECT *
FROM one_day_candle
WHERE symbol = 'BTC/USD'
  AND bucket >= NOW() - INTERVAL '14 days'
ORDER BY bucket;

--Verify the Continuous Aggregate
SELECT
    view_schema,
    view_name
FROM timescaledb_information.continuous_aggregates
WHERE view_name = 'one_day_candle';