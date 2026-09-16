-- ============================================================
-- Real-Time Financial Data Pipeline
-- Database Schema
-- ============================================================

-- Create the TimescaleDB hypertable for real-time price ticks
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


-- Create a reference table for supported crypto assets
CREATE TABLE crypto_assets (
    symbol TEXT UNIQUE,
    "name" TEXT
);