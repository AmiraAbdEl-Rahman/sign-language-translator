import json
import os
import sqlite3
from datetime import datetime, timezone

SCHEMA = """
CREATE TABLE IF NOT EXISTS signs (
    id INTEGER PRIMARY KEY,
    label_en TEXT NOT NULL UNIQUE,
    label_ar TEXT NOT NULL,
    category TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sign_id INTEGER NOT NULL REFERENCES signs(id),
    confidence REAL NOT NULL,
    created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
"""


class Database:
    def __init__(self, path: str, vocabulary_path: str):
        self.path = path
        self.vocabulary_path = vocabulary_path
        self._init()

    def _conn(self):
        conn = sqlite3.connect(self.path)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        return conn

    def _init(self):
        with open(self.vocabulary_path, encoding="utf-8") as f:
            vocab = json.load(f)
        with self._conn() as c:
            c.executescript(SCHEMA)
            for s in vocab:
                c.execute("INSERT OR REPLACE INTO signs (id, label_en, label_ar, category) VALUES (?,?,?,?)",
                          (s["id"], s["label_en"], s["label_ar"], s["category"]))

    def get_signs(self):
        with self._conn() as c:
            return [dict(r) for r in c.execute("SELECT * FROM signs ORDER BY id")]

    def sign_id(self, label_en: str):
        with self._conn() as c:
            row = c.execute("SELECT id FROM signs WHERE label_en = ?", (label_en,)).fetchone()
            return row["id"] if row else None

    def add_history(self, label_en: str, confidence: float):
        sid = self.sign_id(label_en)
        if sid is None:
            raise KeyError(label_en)
        with self._conn() as c:
            cur = c.execute("INSERT INTO history (sign_id, confidence, created_at) VALUES (?,?,?)",
                            (sid, confidence, datetime.now(timezone.utc).isoformat()))
            return cur.lastrowid

    def get_history(self, limit: int = 100):
        with self._conn() as c:
            rows = c.execute("""SELECT h.id, s.label_en, s.label_ar, h.confidence, h.created_at
                                FROM history h JOIN signs s ON s.id = h.sign_id
                                ORDER BY h.id DESC LIMIT ?""", (limit,))
            return [dict(r) for r in rows]

    def clear_history(self):
        with self._conn() as c:
            c.execute("DELETE FROM history")
