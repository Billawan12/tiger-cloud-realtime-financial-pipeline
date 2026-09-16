--Create crypto_ticks table
CREATE TABLE crypto_ticks (
    "time" TIMESTAMPTZ,
    symbol TEXT,
    price DOUBLE PRECISION,
    day_volume NUMERIC
) WITH (
    tsdb.hypertable,
    tsdb.segmentby = 'symbol',
    tsdb.orderby = 'time DESC'
);

--Create crypto_assets table
CREATE TABLE crypto_assets (
    symbol TEXT UNIQUE,
    "name" TEXT
);

--Check the hypertable
SELECT
    hypertable_schema,
    hypertable_name
FROM timescaledb_information.hypertables
WHERE hypertable_name = 'crypto_ticks';