from pathlib import Path  
import os
import duckdb

FILES_SHARE_PATH = Path("/mnt/data/job_ads.duckdb")

def query_job_listings(query: str):
    # query ska vara en komplett SELECT-sats
    with duckdb.connect(FILES_SHARE_PATH, read_only=True) as conn:
        conn.execute("SET schema 'marts'")
        return conn.execute(query).df()