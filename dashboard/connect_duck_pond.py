from pathlib import Path  
import os
import duckdb

DB_PATH = os.getenv("DUCKDB_PATH")

def query_job_listings(query: str):
    # query ska vara en komplett SELECT-sats
    with duckdb.connect(DB_PATH, read_only=True) as conn:
        conn.execute("SET schema 'marts'")
        return conn.execute(query).df()