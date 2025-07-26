# 📦 Olist Online Store - Data Pipeline Project


This project shows how to build a complete data pipeline using:

- **On-Premises SQL Server**
- **Azure Data Factory (ADF)**
- **Azure Synapse Analytics**
- **Azure Databricks**
- **Power BI**

  The pipeline moves and transforms sales data from the Olist Online Store dataset to create useful business insights.

**On-Prem SQL Server → Azure Data Factory → Synapse (Staging) → Databricks → Synapse (Final) → Power BI**

- Source: [Olist E-commerce Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## 🚀 Steps in the Pipeline

1. **Extract** data from on-prem SQL Server using ADF
2. **Load** it into Azure Synapse (staging layer)
3. **Transform** the data in Azure Databricks using PySpark
4. **Store** the final clean data in Synapse (final layer)
5. **Visualize** in Power BI to gain business insights

  
## 📈 Power BI Dashboard Highlights

- Monthly Sales Trends
- Top Products and Sellers
- Customer Behavior
- Payment Methods
- Review Score Analysis





## 📂 Project Files

- `SQL_Scripts/` – SQL used for extraction
- `ADF_Pipeline/` – ADF pipeline configuration (JSON)
- `Databricks_Notebooks/` – Notebooks used in transformation
- `PowerBI/` – Dashboard (.pbix file)
- `README.md` – This file

---

## ✅ What I Learned

- Moving data from on-prem to cloud using ADF
- Cleaning large datasets with Databricks
- Building dashboards for real insights in Power BI
- Using Synapse for data storage and modeling


## 🔖 Tags

`Azure` `Data Engineering` `ADF` `Synapse` `Databricks` `Power BI` `ETL` `Olist`
