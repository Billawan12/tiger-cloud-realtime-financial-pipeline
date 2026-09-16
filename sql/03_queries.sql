-- View the most recent financial ticks
SELECT *
FROM crypto_ticks
ORDER BY time DESC
LIMIT 20;


-- Count total ticks and distinct symbols
SELECT
    COUNT(*) AS total_ticks,
    COUNT(DISTINCT symbol) AS symbols
FROM crypto_ticks;


-- View the available symbols
SELECT DISTINCT symbol
FROM crypto_ticks
ORDER BY symbol;