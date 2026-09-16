-- ============================================================
-- AI-Powered Vector Search with pgvector
-- ============================================================

-- 1. Semantic similarity search using cosine distance
SELECT
    symbol,
    "time",
    description,
    metadata,
    embedding <=> (
        SELECT embedding
        FROM financial_embeddings
        WHERE description =
            'BTC/USD price increased during the latest market observation.'
        LIMIT 1
    ) AS cosine_distance
FROM financial_embeddings
ORDER BY cosine_distance
LIMIT 5;


-- 2. Hybrid search: semantic similarity + time filter + metadata filter
SELECT
    symbol,
    "time",
    description,
    metadata,
    embedding <=> (
        SELECT embedding
        FROM financial_embeddings
        WHERE description =
            'BTC/USD price increased during the latest market observation.'
        LIMIT 1
    ) AS cosine_distance
FROM financial_embeddings
WHERE "time" >= NOW() - INTERVAL '7 days'
  AND metadata->>'market' = 'crypto'
ORDER BY cosine_distance
LIMIT 5;


-- 3. L2 (Euclidean) distance
SELECT
    symbol,
    description,
    embedding <-> (
        SELECT embedding
        FROM financial_embeddings
        WHERE description =
            'BTC/USD price increased during the latest market observation.'
        LIMIT 1
    ) AS l2_distance
FROM financial_embeddings
ORDER BY l2_distance
LIMIT 5;


-- 4. Inner-product distance
SELECT
    symbol,
    description,
    embedding <#> (
        SELECT embedding
        FROM financial_embeddings
        WHERE description =
            'BTC/USD price increased during the latest market observation.'
        LIMIT 1
    ) AS inner_product_distance
FROM financial_embeddings
ORDER BY inner_product_distance
LIMIT 5;