# HR Analytics – Cloud Deployment  

This project focuses on deploying an ETL pipeline to Azure using Terraform for infrastructure as code. The pipeline incorporates a DLT script and DBT transformations, which are visualized in a Streamlit dashboard and orchestrated through Dagster.

### Steps for Cloud Deployment
1.	Provision Azure Storage Account with File Share
   - Created an Azure Storage Account and configured an Azure File Share for persistent data storage and pipeline artifacts.
2.	Set Up Azure Container Registry (ACR)
   - Deployed an Azure Container Registry to store and manage Docker images for the pipeline components.
o	Built and pushed container images to ACR.
3.	Deploy Container Instances for Dagster Orchestration
   - Launched Azure Container Instances via the Azure CLI to run the Dagster orchestration service.
   - Configured environment variables and network settings for secure communication between containers.
4.	Create an Azure Web App for the Streamlit Dashboard
   - Provisioned an Azure Web App to host the Streamlit dashboard for data visualization.
5.	Integrate Container Registry with Web App
   - Connected the Azure Web App to the Azure Container Registry to automatically deploy the latest dashboard image from Docker.
   - Enabled continuous deployment from ACR.
6.	Mount Azure File Share to the Web App
o	Configured a path mapping in the Web App to mount the Azure File Share, enabling shared data access between components.
7.	Validate and Monitor Deployment
   - Verified deployment success using terraform plan and terraform apply outputs.
   - Implemented basic monitoring through Azure Portal and logs to ensure service health.

### Cost Estimation – Cloud Deployment (Azure)
Cost estimation are based on following plan

•	The DuckDB data warehouse is updated once per day as part of the scheduled ETL workflow.

•	The deployed Streamlit dashboard remains continuously available to users for real-time access and monitoring.

##### The following is an estimated monthly cost summary for running the data pipeline on Azure
| **Resource**                                    | **Pricing Details**                                                                                            | **Estimated Monthly Cost (USD)** |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| **Container Instance – Pipeline** | 1 container group (1 vCPU, 4 GB RAM, running continuously). Price: $0.0000129 per vCPU/s + $0.0000014 per GB/s | **≈ $48,94**                     |
| **Container Instance – Dashboard**    | 1 container group (1 vCPU, 4 GB RAM, running continuous). Price: $0.0000129 per vCPU/s + $0.0000014 per GB/s                                                 | **≈ $48,94**                     |
| **Storage Account (Azure File Share)**          | 10 GB stored, <10,000 operations per month                                                                     | **$0.26**                        |
| **App Service Plan (Basic B1)**                 | 1 Core, 1.75 GB RAM, 10 GB storage ($0.018/hour × 730 hours)                                                   | **$13.14**                       |
| **Azure Container Registry (Basic B1)**       | $0.167/day × 30 days (includes 10 GB extra storage)                                                            | **$6.00**                        |
|                                                 |                                                                                                                | **Total ≈ $117.28 / month**      |


| **Resource Group**               | **Monthly Cost (USD)** |
| -------------------------------- | ---------------------- |
| Containers (2×)                  | $96.54                 |
| Storage                          | $0.26                  |
| Web App                          | $13.14                 |
| Container Registry               | $5.00                  |
| **Total Estimated Monthly Cost** | **≈ $117.28 / month**  |


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
│  └── load_job_ads.py
├─ data_transformation/        
│  ├─ models/
│  ├─ seeds/
│  ├─ snapshots/
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
