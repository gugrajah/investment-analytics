# PIC Sovereign Portfolio Analytics — Power BI Enterprise Showcase

A production-ready Power BI Enterprise Showcase designed for South Africa's **Public Investment Corporation (PIC)** — a sovereign asset manager overseeing ~R2.7 trillion AUM. 

This project is engineered to satisfy both HR/recruiter reviews (focusing on visual storytelling, user experience, and alignment with PIC's mandate) and technical hiring panels (demonstrating Fabric DirectLake readiness, sophisticated star-schema design, advanced statistical DAX, object-level security, and performance discipline).

---

## 🌟 Key Highlights
* **DirectLake Ready Star Schema:** 9 Dimension tables and 8 Fact tables, fully configured with structured PK/FK relationships.
* **33 Advanced DAX Measures:** Includes financial metrics (Cost-to-Income, YTD Variance), risk indicators (Sharpe Ratio, tracking error, 95% 1-day VaR), unlisted asset metrics (XIRR approximation, MOIC, DPI), and operational KPIs (SLA compliance, settlement failure rates).
* **Enterprise Security (RLS + OLS):** Dynamic row-level security (RLS) filtering by division/manager email, coupled with object-level security (OLS) protecting sensitive salary and demographic fields.
* **F-Pattern Page Layouts:** Premium corporate styling using PIC Navy (`#002B5C`) and Gold (`#C9A84C`) palette.
* **South African Compliance Focus:** Incorporated PFMA non-compliance counters, B-BBEE skills spend metrics, and Level 1–4 BEE brokerage allocations.

---

## 📂 Repository Structure

* [sql scripts/](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/sql%20scripts/)
  * [initialise_db.sql](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/sql%20scripts/initialise_db.sql) - Database schema generation script (DDL + basic seeds).
  * [expand_seed_data.sql](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/sql%20scripts/expand_seed_data.sql) - Seed script generating realistic demographic distributions and 5,000 transaction rows per fact table.
* [PBI/](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/PBI/)
  * [InvestmentHouse.pbip](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/PBI/InvestmentHouse.pbip) - The Power BI project file shell.
  * `InvestmentHouse.Report/` - Report definition folder.
  * `InvestmentHouse.SemanticModel/` - TMDL semantic model definition folder.
* [DAX/](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/DAX/) - Individual version-controlled text files for each of the 33 measures.
* [project_docs/](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/project_docs/)
  * [PORTFOLIO ARCHITECTURE.md](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/project_docs/PORTFOLIO%20ARCHITECTURE.md) - Deep architectural and design spec.
  * [Project Brief Extended.md](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/project_docs/Project%20Brief%20Extended.md) - Project goals, design constraints, and core directives.
* [dataset_gen.py](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/dataset_gen.py) - Python script used for base synthetic financial data generation.
* [implementation_plan.md](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/implementation_plan.md) - Implementation roadmap.
* [task.md](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/task.md) - Task-by-task tracker of project milestones.

---

## 📊 Star Schema Data Model

The project builds a complete Star Schema to model PIC's corporate and portfolio structures:

### Dimension Tables (9)
* **`Dim_Date`**: Full calendar table supporting South African public holidays and April fiscal year starts.
* **`Dim_Division`**: 10 distinct corporate units (e.g. Listed Equities, Fixed Income, Properties).
* **`Dim_Employee`**: 403 employees containing SA demographic fields (Gender, Ethnic Group, HDI, Salary).
* **`Dim_Fund`**: 6 primary fund mandates (e.g., GEPF, UIF, AIPF).
* **`Dim_InvestmentAsset`**: 50 assets across listed equities, corporate bonds, unlisted PE, and real estate.
* **`Dim_AuditCategory`**: 10 classifications representing Auditor-General and Internal Audit focus areas.
* **`Dim_RegulatoryBody`**: FSCA, National Treasury, SARB.
* **`Dim_BEELevel`**: Standard BBBEE Recognition percentages.
* **`Dim_DynamicMetricControls`**: Disconnected table for dynamic metric switching in the Executive Overview.

### Fact Tables (8)
* **`Fact_FinancialTransactions`**: Daily actual and budget amounts (5,000 rows, PFMA compliance codes).
* **`Fact_HREvents`**: Headcount events, exit tracking, and skills development spend.
* **`Fact_TradeSettlements`**: Listed securities trading metadata, fee allocations, and settlement failures.
* **`Fact_AuditFindings`**: Risk assessment tracker of raised vs closed audit findings.
* **`Fact_ProjectMilestones`**: IT system migration tracking (Fabric migration, SAP upgrade, Data Quality index).
* **`Fact_PortfolioReturns`**: Daily asset returns and benchmark indices.
* **`Fact_UnlistedInvestments`**: Vintage performance, capital drawdowns, and PE valuations.
* **`Fact_HelpdeskTickets`**: SLA compliance logs and support ticket queues.

---

## 🛠️ Step-by-Step Deployment Instructions

To reproduce the database environment and Power BI dataset:

### Step 1: Initialize the Database
1. Connect to your SQL Server / Fabric SQL Database instance and create a database named `InvestmentHouse_db`.
2. Execute [initialise_db.sql](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/sql%20scripts/initialise_db.sql) to build out the schemas and table relationships.

### Step 2: Seed the Data
1. Execute [expand_seed_data.sql](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/sql%20scripts/expand_seed_data.sql) in your query window.
2. This script seeds all dimensions and populates exactly 5,000 rows per fact table with realistic South African distributions (African: ~65%, HDI representation, budget variances, BEE brokerage allocations, etc.).

### Step 3: Open the Power BI Shell
1. Open [InvestmentHouse.pbip](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/PBI/InvestmentHouse.pbip) in Power BI Desktop (ensure that the latest Power BI version supporting PBIP is installed).
2. Configure your Data Source Settings to point to your deployed SQL Server instance or Fabric Warehouse endpoint.

---

## 📈 Enterprise DAX Library Highlights
All measures are version-controlled and saved inside [DAX/](file:///Users/laptop/Library/CloudStorage/GoogleDrive-gugrajah.m@gmail.com/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/DAX/). Key patterns demonstrated include:

* **Time Intelligence:** YoY Operational Budget Variance, Rolling 12-Month OPEX.
* **Portfolio Risk Statistics:** Annualized Tracking Error, Sharpe Ratio, and 95% 1-Day Value-at-Risk (VaR).
* **Private Equity Operations:** Multiple on Invested Capital (MOIC), Distributions to Paid-In Capital (DPI), and Net Asset Value (NAV) IRR approximation.
* **Governance & SLA Compliance:** SLA resolution rates, regulatory penalty/breach counters.
* **Transformation Dynamics:** Weighted ESG scores, B-BBEE scorecard points, and dynamic gender/HDI alignment metrics.
