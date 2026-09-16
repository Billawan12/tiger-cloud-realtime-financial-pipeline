import os
import time
from datetime import datetime, timezone

import psycopg2
from dotenv import load_dotenv
from psycopg2.extras import execute_values
from twelvedata import TDClient


load_dotenv()


class WebsocketPipeline:
    DB_TABLE = "crypto_ticks"
    DB_COLUMNS = ["time", "symbol", "price", "day_volume"]
    MAX_BATCH_SIZE = 100

    def __init__(self, conn):
        self.conn = conn
        self.current_batch = []
        self.insert_counter = 0

    def _insert_values(self, data):
        if not data:
            return

        cursor = self.conn.cursor()

        sql = f"""
            INSERT INTO {self.DB_TABLE}
            ({','.join(self.DB_COLUMNS)})
            VALUES %s;
        """

        execute_values(cursor, sql, data)
        self.conn.commit()
        cursor.close()

    def _on_event(self, event):
        if event.get("event") != "price":
            return

        timestamp = datetime.fromtimestamp(
            event["timestamp"],
            tz=timezone.utc
        )

        data = (
            timestamp,
            event["symbol"],
            event["price"],
            event.get("day_volume")
        )

        self.current_batch.append(data)

        print(
            f"Received {event['symbol']} "
            f"at {event['price']} | "
            f"batch size: {len(self.current_batch)}"
        )

        if len(self.current_batch) >= self.MAX_BATCH_SIZE:
            self._insert_values(self.current_batch)
            self.insert_counter += 1

            print(
                f"Batch insert #{self.insert_counter} "
                f"completed ({len(self.current_batch)} records)"
            )

            self.current_batch = []

    def start(self, symbols):
        api_key = os.getenv("TWELVE_DATA_API_KEY")

        if not api_key:
            raise ValueError(
                "TWELVE_DATA_API_KEY is not configured."
            )

        td = TDClient(apikey=api_key)

        ws = td.websocket(
            on_event=self._on_event
        )

        print("Connecting to Twelve Data...")
        print(f"Subscribed symbols: {', '.join(symbols)}")

        ws.subscribe(symbols)
        ws.connect()

        while True:
            ws.heartbeat()
            time.sleep(10)


def create_database_connection():
    return psycopg2.connect(
        database=os.getenv("TIGER_DB_NAME"),
        host=os.getenv("TIGER_DB_HOST"),
        user=os.getenv("TIGER_DB_USER"),
        password=os.getenv("TIGER_DB_PASSWORD"),
        port=os.getenv("TIGER_DB_PORT")
    )


if __name__ == "__main__":
    conn = create_database_connection()

    symbols = [
        "BTC/USD",
        "ETH/USD"
    ]

    pipeline = WebsocketPipeline(conn)
    pipeline.start(symbols)