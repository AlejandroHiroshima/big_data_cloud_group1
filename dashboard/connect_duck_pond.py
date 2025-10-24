# import os
# import pandas as pd
# import streamlit as st
# from dotenv import load_dotenv
# import duckdb
# from pathlib import Path


# # duck pond directory
# db_path = str(Path(__file__).parents[1] / "duck_pond/job_ads.duckdb")

# DB_PATH = os.getenv("DUCKDB_PATH")
 
# def query_job_listings(query='SELECT * FROM'):
#     with duckdb.connect(DB_PATH, read_only=True) as conn:
#         return conn.query(f"{query}").df()

# import os
# import pandas as pd
# import streamlit as st
# from dotenv import load_dotenv
# import duckdb
# from pathlib import Path

# DB_PATH = os.getenv("DUCKDB_PATH")


# @st.cache_data(show_spinner="Laddar KPI'er...")
# def query_job_listings(query):
#     conn = get_connection()
#     df = pd.read_sql(query, conn)
#     return df
from pathlib import Path  
import os
import duckdb

FILES_SHARE_PATH = Path("/mnt/data/job_ads.duckdb")

def query_job_listings(query: str):
    # query ska vara en komplett SELECT-sats
    with duckdb.connect(FILES_SHARE_PATH, read_only=True) as conn:
        conn.execute("SET schema 'marts'")
        return conn.execute(query).df()