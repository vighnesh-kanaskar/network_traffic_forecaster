import sqlite3
from pathlib import Path
from datetime import datetime


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"

DATA_DIR.mkdir(exist_ok=True)

DB_PATH = DATA_DIR / "netra.db"


def get_connection():
    connection = sqlite3.connect(
        DB_PATH,
        check_same_thread=False
    )

    connection.row_factory = sqlite3.Row

    return connection


def initialize_database():
    connection = get_connection()

    cursor = connection.cursor()

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            current_state TEXT NOT NULL,
            predicted_state TEXT NOT NULL,
            confidence INTEGER NOT NULL,
            risk INTEGER NOT NULL,
            packets INTEGER NOT NULL,
            packets_per_second REAL NOT NULL,
            unique_ips INTEGER NOT NULL,
            flows INTEGER NOT NULL
        )
    """)

    connection.commit()
    connection.close()


def save_history(
    current_state,
    predicted_state,
    confidence,
    risk,
    packets,
    packets_per_second,
    unique_ips,
    flows
):
    connection = get_connection()

    connection.execute("""
        INSERT INTO history (
            timestamp,
            current_state,
            predicted_state,
            confidence,
            risk,
            packets,
            packets_per_second,
            unique_ips,
            flows
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        datetime.now().isoformat(),
        current_state,
        predicted_state,
        confidence,
        risk,
        packets,
        packets_per_second,
        unique_ips,
        flows
    ))

    connection.commit()
    connection.close()


def get_history(limit=100):
    connection = get_connection()

    rows = connection.execute("""
        SELECT *
        FROM history
        ORDER BY id DESC
        LIMIT ?
    """, (limit,)).fetchall()

    connection.close()

    return [dict(row) for row in rows]