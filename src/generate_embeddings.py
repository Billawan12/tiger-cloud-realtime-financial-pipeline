import os

import psycopg2
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer

load_dotenv()

MODEL_NAME = "all-MiniLM-L6-v2"


def create_database_connection():
    return psycopg2.connect(
        database=os.getenv("TIGER_DB_NAME"),
        host=os.getenv("TIGER_DB_HOST"),
        user=os.getenv("TIGER_DB_USER"),
        password=os.getenv("TIGER_DB_PASSWORD"),
        port=os.getenv("TIGER_DB_PORT"),
    )


def main():
    print(f"Loading embedding model: {MODEL_NAME}")
    model = SentenceTransformer(MODEL_NAME)

    conn = create_database_connection()
    cursor = conn.cursor()

    descriptions = [
        (
            "BTC/USD price increased during the latest market observation.",
            "BTC/USD",
            {"market": "crypto", "asset": "Bitcoin", "event": "price_increase"},
        ),
        (
            "BTC/USD price decreased during the latest market observation.",
            "BTC/USD",
            {"market": "crypto", "asset": "Bitcoin", "event": "price_decrease"},
        ),
        (
            "ETH/USD price increased during the latest market observation.",
            "ETH/USD",
            {"market": "crypto", "asset": "Ethereum", "event": "price_increase"},
        ),
        (
            "ETH/USD price decreased during the latest market observation.",
            "ETH/USD",
            {"market": "crypto", "asset": "Ethereum", "event": "price_decrease"},
        ),
        (
            "Bitcoin trading activity showed strong market momentum.",
            "BTC/USD",
            {"market": "crypto", "asset": "Bitcoin", "event": "high_activity"},
        ),
        (
            "Ethereum trading activity showed strong market momentum.",
            "ETH/USD",
            {"market": "crypto", "asset": "Ethereum", "event": "high_activity"},
        ),
    ]

    print("Generating embeddings...")

    for description, symbol, metadata in descriptions:
        embedding = model.encode(description).tolist()

        cursor.execute(
            """
            INSERT INTO financial_embeddings
                ("time", symbol, description, metadata, embedding)
            VALUES
                (NOW(), %s, %s, %s, %s::vector);
            """,
            (
                symbol,
                description,
                __import__("json").dumps(metadata),
                str(embedding),
            ),
        )

    conn.commit()

    cursor.execute(
        "SELECT COUNT(*) FROM financial_embeddings;"
    )

    count = cursor.fetchone()[0]

    cursor.close()
    conn.close()

    print(f"Inserted embeddings successfully.")
    print(f"Total embeddings in database: {count}")


if __name__ == "__main__":
    main()