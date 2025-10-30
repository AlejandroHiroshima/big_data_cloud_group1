# HR Analytics – Cloud Deployment  

This project builds upon our earlier project <a href="https://github.com/AlejandroHiroshima/Data_warehouse_grupp4_DE24" target="_blank" rel="noopener noreferrer">
  HR Analytics Proof of Concept ↗
</a>, which implemented a modern data stack for analyzing job advertisements from Arbetsförmedlingen JobTech API. 
The previous version used DLT for ingestion, DBT for data transformation, and Streamlit for dashboard visualization within a local environment and Snowflake-based data warehouse.
In this continuation, the solution is extended to a cloud-based deployment on Microsoft Azure, leveraging:
  
- Terraform for Infrastructure as Code (IaC)
- Azure Container Registry (ACR) and App Service for hosting
- Dagster for orchestration
- DuckDB as the analytical data warehouse
  
This version emphasizes scalability, automation and cost efficiency, transforming the original proof of concept into a production-ready, reproducible cloud pipeline architecture.

### Project Architecture ###
| **Layer**              | **Technology / Tools**    | **Purpose**                            |
| ---------------------- | ------------------------- | -------------------------------------- |
| **Ingestion (EL)**     | DLT, Dagster              | Extracts job ad data from JobTech API  |
| **Transformation (T)** | DBT                       | Cleans, models, and creates data marts |
| **Storage (DW)**       | DuckDB (Azure File Share) | Lightweight data warehouse             |
| **Orchestration**      | Dagster                   | Automates daily ETL jobs               |
| **Visualization**      | Streamlit                 | Dashboard for HR analytics             |
| **Infrastructure**     | Terraform                 | Provisions and manages Azure resources |

### Azure Deployment Steps ###

                                                                            
### Cost Estimation 

Cost estimation are based on following assumptions: 

•	The DuckDB data warehouse is updated once per day as part of the scheduled ETL workflow.

•	The deployed Streamlit dashboard remains continuously available to users for real-time access and monitoring.

#### Azure + DuckDB cost estimation ### 

| **Type**                | **Estimated Monthly Cost (USD)** | **Description**                                     |
| ---------------------------- | -------------------------- | --------------------------------------------- |
| **App Service (P0v3)**           | ≈ 64.97 $                |Hosts the Streamlit dashboard (24/7)                  |
| **Container Registry (Basic B1)**   | ≈ 6 $                | Stores Docker images for pipeline & dashboard |
| **Storage account - Azure File Share (10 GB)**     | ≈ 0.27 $                   | Stores DuckDB database & DBT profiles                     |
| **Container Instance (Dagster)** | ≈ 1.01 $                    | Runs ETL job once per day (~30 min) daily 
| **Total / Month**            | **≈ 72.25 $**            |                |

<sub>**Note:** The Dagster container is executed once per day (~30 minutes runtime), while the App Service runs continuously to keep the dashboard available 24/7.</sub>

#### Azure + Snowflake cost estimation

| Resource                          | Estimated Monthly Cost (USD) | Description                                 |
| --------------------------------- | ---------------------------- | ------------------------------------------- |
| **App Service (P0v3)**            | ≈ 64.97 $                     | Hosts Streamlit dashboard (24/7)        |
| **Container Registry (Basic B1)** | ≈ 6 $                    | Stores Docker images               |
| **Container Instance (Dagster)**  | ≈ 1.01 $                     | Executes ETL orchestration once per day    |
| **Snowflake Warehouse (X-Small)** | ≈ 15 $                    | Compute engine (1 credit/h × 7,5 h × $2). Runs 15 min daily    |
| **Snowflake Storage (~10 GB)**    | ≈ 0.40 $                      | Cloud storage for raw & transformed tables |
| **Azure File Share**              | —                            | Replaced by Snowflake storage.              |
| **Total / Month**                 | **≈ 87.38 $**                | ≈ +83 % vs DuckDB deployment.               |

### Pros and Cons 

| Aspect                         | **Azure + DuckDB**                       | **Azure + Snowflake**                        |
| ------------------------------ | ---------------------------------------- | -------------------------------------------- |
| **Cost**                       | ✅ Low (~72 $  /mo)                     | ❌ Higher (~ 87 $/mo) due to compute billing   |
| **Performance**                | ⚠️ Limited to single process (embedded)  | ✅ High performance with scalable compute     |
| **Concurrency**                | ⚠️ One user/process at a time for writes | ✅ Supports many concurrent queries           |
| **Management**                 | ✅ Simple (no server admin)               | ✅ Fully managed but requires tuning costs    |
| **Scalability**                | ⚠️ Constrained by VM and file size       | ✅ Elastic compute & storage scale separately |
| **Data sharing / integration** | ❌ Hard to share data externally          | ✅ Built-in data sharing & governance         |
| **Latency**                    | ✅ Low (local read access)                | ⚠️ Network latency to Snowflake region        |
| **Use case fit**               | Small team analytics / PoC / low cost    | Enterprise or multi-user production          |


### Project Structure Overview

``` 
BIG_DATA_CLOUD_GROUP1/
├─ dagster_home/
├─ dashboard/
│  ├─ connect_duck_pond.py
│  ├─ dashboard.py
│  ├─ plots.py
│  └─ run_dashboard.py
├─ data_extract_load/
│  └─ load_job_ads.py
├─ data_transformation/
│  ├─ models/
│  │  ├─ sources.yml
│  │  ├─ schema.yml
│  │  ├─ src_*.sql
│  │  ├─ dim_*.sql
│  │  ├─ fct_job_ads.sql
│  │  └─ mart_*.sql
│  ├─ dbt_project.yml
│  └─ profiles.yml
├─ duck_pond/
│  └─ job_ads.duckdb
├─ orchestration/
│  └─ definitions.py
├─ IaC_terraform/
│  ├─ providers.tf
│  ├─ resource-group.tf
│  ├─ storage-account.tf
│  ├─ random.tf
│  ├─ input-variables.tf
│  └─ outputs.tf
├─ files/
├─ logs/
├─ docker-compose.yml
├─ dockerfile.dashboard
├─ dockerfile.dwh
├─ requirements.txt
├─ requirements_mac.txt
└─ README.md

```
