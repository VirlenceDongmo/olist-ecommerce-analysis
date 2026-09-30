"""Charge les CSV Olist de data/raw/ dans une base SQLite (data/processed/olist.db)."""

import csv
import sqlite3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW = ROOT / "data" / "raw"
DB = ROOT / "data" / "processed" / "olist.db"
SCHEMA = ROOT / "sql" / "00_schema.sql"

FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_translation",
}


def main() -> int:
    missing = [f for f in FILES if not (RAW / f).exists()]
    if missing:
        print("Fichiers manquants dans data/raw/ :")
        for f in missing:
            print(f"  - {f}")
        print("Voir data/README.md pour le téléchargement.")
        return 1

    DB.parent.mkdir(parents=True, exist_ok=True)
    if DB.exists():
        DB.unlink()
    con = sqlite3.connect(DB)
    con.executescript(SCHEMA.read_text(encoding="utf-8"))

    for filename, table in FILES.items():
        with open(RAW / filename, newline="", encoding="utf-8-sig") as fh:
            reader = csv.reader(fh)
            header = next(reader)
            placeholders = ",".join("?" * len(header))
            cols = ",".join(header)
            rows = ([v if v != "" else None for v in row] for row in reader)
            con.executemany(
                f"INSERT OR IGNORE INTO {table} ({cols}) VALUES ({placeholders})", rows
            )
        n = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"{table:32s} {n:>9,d} lignes")

    con.commit()
    con.close()
    print(f"\nBase créée : {DB}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
