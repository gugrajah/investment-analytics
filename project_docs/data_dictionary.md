# PIC Portfolio Analytics — Data Dictionary

This document serves as the enterprise data dictionary for the PIC Sovereign Portfolio Analytics semantic model. It defines the structure, data types, source system locations, and business ownership of all dimensions and fact tables.

---

## 1. Dimension Tables

### Dim_Date (Enterprise Calendar)
* **Business Description**: The core role-playing time-intelligence calendar. It maps daily events to fiscal cycles, public holidays, and standard calendar dates.
* **Data Owner**: Business Intelligence & Analytics Team
* **Source System**: Enterprise Data Warehouse (EDW) Master Calendar

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **DateKey** | Unique date identifier in YYYYMMDD format. | Int64 | PK |
| **Date** | Standard Gregorian calendar date. | DateTime | - |
| **Year** | Calendar year (e.g., 2025). | Int64 | - |
| **Quarter** | Calendar quarter identifier (e.g., Q1, Q2, Q3, Q4). | String | - |
| **MonthName** | Full name of the calendar month (e.g., January). | String | - |
| **MonthFiscal** | Fiscal month index matching South African government cycle (April = 1, March = 12). | Int64 | - |
| **DayOfWeek** | Name of the day of the week (e.g., Monday). | String | - |
| **IsPublicHolidayZA** | Flag indicating if the date is a South African gazetted public holiday (True/False). | Boolean | - |

---

### Dim_Division (Corporate Divisions)
* **Business Description**: Defines PIC's organizational structure, departmental divisions, cost centers, and executive heads.
* **Data Owner**: Finance Control & HR Divisions
* **Source System**: SAP S/4HANA Corporate Structures

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **DivisionKey** | Unique corporate division identifier. | Int64 | PK |
| **DivisionName** | Name of the corporate division (e.g., HR, Finance, Listed Equities, Unlisted PE, IT). | String | - |
| **ExecutiveHead** | Name of the executive head leading the division. | String | - |
| **ExecutiveHeadEmail** | Corporate email address of the Executive Head (used for RLS filter verification). | String | - |
| **CostCenterCode** | Financial code mapping division to corporate ledger cost centers. | String | - |

---

### Dim_Employee (Human Capital Profile)
* **Business Description**: Contains sensitive employee records, demographics, and compensation details. Access is restricted via Object-Level Security (OLS).
* **Data Owner**: Human Resources Division
* **Source System**: SAP SuccessFactors HR

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **EmployeeKey** | Unique employee record identifier. | Int64 | PK |
| **EmployeeID** | Official PIC employee identification number. | String | - |
| **FullName** | Complete name of the employee (First Name, Surname). | String | - |
| **Email** | Corporate email address of the employee (used for dynamic RLS lookup). | String | - |
| **Gender** | Gender classification of the employee (e.g., Male, Female, Other). | String | - |
| **EthnicGroup** | Demographic group (African, Coloured, Indian, White) used for EE reporting. *Hidden via OLS.* | String | - |
| **OccupationalLevel** | Job tier (e.g., Top Management, Senior Management, Professional, Skilled). | String | - |
| **IsHDI** | Flag indicating if the employee is classified as a Historically Disadvantaged Individual. | Boolean | - |
| **SalaryAmount** | Employee gross salary amount. *Hidden via OLS from unauthorized roles.* | Double | - |

---

### Dim_Fund (Client Mandates)
* **Business Description**: Segregates public market and private equity investments by client mandates (e.g., GEPF, UIF).
* **Data Owner**: Listed Equities & Private Equity Operations
* **Source System**: eFront Client Registry / Bloomberg AIM

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **FundKey** | Unique client fund mandate identifier. | Int64 | PK |
| **FundName** | Legal name of the client fund (e.g., GEPF, UIF, Compensation Commissioner Fund). | String | - |
| **ClientType** | Category of the client (e.g., Public Pension Fund, Social Security Fund). | String | - |
| **InvestmentMandate** | Mandatory asset class allocation mandate (e.g., Balanced, Conservative, PE). | String | - |
| **AssignedManagerEmail** | Corporate email address of the lead portfolio manager (used for RLS). | String | - |

---

### Dim_InvestmentAsset (Portfolio Securities)
* **Business Description**: Master reference for listed and unlisted security assets held in PIC portfolios.
* **Data Owner**: Investment Risk & ESG Committees
* **Source System**: Bloomberg Data License / eFront PE

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **AssetKey** | Unique asset record identifier. | Int64 | PK |
| **ISIN** | International Securities Identification Number for the security. | String | - |
| **AssetName** | Official trade or commercial name of the security (e.g., Sasol, Green Bond ZA203). | String | - |
| **AssetClass** | Asset class type (e.g., Equities, Fixed Income, Unlisted PE, Property). | String | - |
| **Sector** | Economic sector classification (e.g., Financials, Industrials, Technology). | String | - |
| **ESG_Score** | Environmental, Social, and Governance scorecard rating index (scale 0 - 10). | Decimal | - |
| **CarbonIntensity** | Carbon footprint index (tCO2e per R-million revenue). | Decimal | - |

---

### Dim_AuditCategory (Audit Exception Classifications)
* **Business Description**: Categorizes internal and external Auditor-General audit findings by risk level and subject area.
* **Data Owner**: Internal Audit & Risk Division
* **Source System**: TeamMate Audit Management Suite

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **AuditCategoryKey** | Unique audit category identifier. | Int64 | PK |
| **SourceType** | Origin of the audit finding (e.g., Internal Audit, Auditor-General). | String | - |
| **Classification** | Area of audit concern (e.g., Procurement, Financial Reporting, IT Governance). | String | - |
| **RiskLevel** | Risk classification representing severity (Critical, Major, Minor). | String | - |

---

### Dim_RegulatoryBody (Compliance Agencies)
* **Business Description**: Master list of statutory authorities to which PIC is accountable.
* **Data Owner**: Compliance & Risk Division
* **Source System**: GRC Regulatory Compliance Database

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **RegulatoryBodyKey** | Unique regulatory body identifier. | Int64 | PK |
| **BodyName** | Name of the regulator (e.g., FSCA, National Treasury, SARS). | String | - |
| **SubmissionCycle** | Frequency of required filings (e.g., Monthly, Quarterly, Annually). | String | - |

---

### Dim_BEELevel (B-BBEE Recognition Tiers)
* **Business Description**: Mappings for Broad-Based Black Economic Empowerment recognition levels and procurement recognition percentages.
* **Data Owner**: Transformation & Enterprise Development Unit
* **Source System**: B-BBEE Commission Gazetted Tables

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **BEELevelKey** | Unique BEE level identifier. | Int64 | PK |
| **BEELevel** | Contributor tier status (1 = Level 1 Contributor, up to 8, or 9 = Non-Compliant). | Int64 | - |
| **RecognitionPercentage** | Weighted procurement recognition percentage (e.g., Level 1 = 135%, Level 2 = 125%). | Decimal | - |

---

### Dim_DynamicMetricControls (Disconnected Slicers)
* **Business Description**: Disconnected table containing metadata rows to drive dynamic switching of executive report visuals.
* **Data Owner**: Business Intelligence & Analytics Team
* **Source System**: Built-in Semantic Model Controls

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **MetricKey** | Unique identifier for dynamic metric option. | Int64 | PK |
| **MetricName** | Display name of the metric option (e.g., Total AUM, YTD Return, PFMA Variances). | String | - |
| **MetricDisplayOrder** | Sort order index to display options in slicers. | Int64 | - |

---

## 2. Fact Tables

### Fact_FinancialTransactions (General Ledger Opex)
* **Business Description**: Contains general ledger operational expenditure transactions against approved budgets.
* **Data Owner**: Finance Control Division
* **Source System**: SAP ERP Finance (GL Module)

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **TransactionKey** | Unique ledger transaction row identifier. | Int64 | PK |
| **DateKey** | Date of financial ledger posting. | Int64 | FK |
| **DivisionKey** | Corporate division incurring the expenditure. | Int64 | FK |
| **AccountCode** | Chart of accounts general ledger account code. | Int64 | - |
| **ActualAmount** | Actual transaction value spent (ZAR). | Double | - |
| **BudgetAmount** | Approved budget allocation value for the transaction (ZAR). | Double | - |
| **PFMA_Status_Code** | Compliance status index (0 = Compliant, 1 = Irregular, 2 = Fruitless/Wasteful). | Int64 | - |
| **Last_Modified_Timestamp** | System timestamp used for incremental partitioning change detection. | DateTime | - |

---

### Fact_HREvents (Employee Lifecycles)
* **Business Description**: Captures HR lifecycle event entries (hires, promotions, exits, training spends). Restrictive RLS/OLS applied.
* **Data Owner**: Human Resources Division
* **Source System**: SAP SuccessFactors

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **HREventKey** | Unique HR event log identifier. | Int64 | PK |
| **DateKey** | Date on which the HR event occurred. | Int64 | FK |
| **EmployeeKey** | Employee associated with the HR event. | Int64 | FK |
| **DivisionKey** | Corporate division to which employee was assigned at event date. | Int64 | FK |
| **EventTypeName** | HR event classification (e.g., Active Snapshot, Hire, Promotion, Exit). | String | - |
| **TrainingSpend** | Financial expenditure incurred for training the employee (ZAR). | Double | - |

---

### Fact_TradeSettlements (Public Markets Trading)
* **Business Description**: Tracks trading lifecycle tickets, brokerage fees, and settlement status for listed portfolios.
* **Data Owner**: Listed Equities & Fixed Income Operations
* **Source System**: Bloomberg AIM Trading Engine

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **TradeKey** | Unique trade ticket transaction identifier. | Int64 | PK |
| **ExecutionDateKey** | Date on which the trade was executed. | Int64 | FK |
| **SettlementDateKey** | Date on which trade settlement occurred (role-playing link, inactive). | Int64 | FK |
| **AssetKey** | Listed security asset being traded. | Int64 | FK |
| **FundKey** | Mandate client portfolio funding the trade. | Int64 | FK |
| **BEELevelKey** | B-BBEE recognition level of the executing stockbroker. | Int64 | FK |
| **TradeValue** | Nominal value of the public market trade (ZAR). | Double | - |
| **BrokerageFee** | Broker commission fees paid (ZAR). | Double | - |
| **SettlementStatus** | Status of settlement processing (e.g., Settled, Failed, Pending). | String | - |

---

### Fact_AuditFindings (GRC Exceptions Registry)
* **Business Description**: Registers all internal audit and Auditor-General audit findings, severity weightings, and status updates.
* **Data Owner**: Internal Audit & Risk Division
* **Source System**: TeamMate Audit Suite

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **FindingKey** | Unique exception finding identifier. | Int64 | PK |
| **RaisedDateKey** | Calendar date the audit finding was officially logged. | Int64 | FK |
| **TargetDateKey** | Planned resolution deadline date (role-playing link, inactive). | Int64 | FK |
| **ActualResolutionDateKey**| Date finding was officially verified as closed (role-playing link, inactive). | Int64 | FK |
| **AuditCategoryKey** | Classification category (source, type, risk level). | Int64 | FK |
| **DivisionKey** | Corporate division responsible for implementing the resolution. | Int64 | FK |
| **SeverityWeight** | Impact weighting assigned to the finding (scale 1 - 10). | Int64 | - |
| **IsClosed** | Status flag showing if the finding is closed (True/False). | Boolean | - |

---

### Fact_ProjectMilestones (Enterprise IT Portfolio)
* **Business Description**: Monitors status, planned dates, and actual dates of IT project portfolio milestones.
* **Data Owner**: IT Division / Corporate PMO
* **Source System**: Jira Portfolio PPM Tool

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **MilestoneKey** | Unique project milestone record identifier. | Int64 | PK |
| **PlannedDateKey** | Date milestone was planned to complete. | Int64 | FK |
| **ActualDateKey** | Date milestone was actually completed (role-playing, inactive). | Int64 | FK |
| **ProjectKey** | Code mapping to the parent enterprise IT project. | Int64 | - |
| **MilestoneName** | Short descriptive name of the project milestone. | String | - |
| **Weight** | Priority weight (modeled as currency, representing significance). | Decimal | - |
| **Status** | Status of milestone (e.g., Completed, In Progress, Delayed). | String | - |

---

### Fact_PortfolioReturns (Listed Performance)
* **Business Description**: High-frequency daily performance return rates and valuations for listed equity and bond assets.
* **Data Owner**: Investment Risk & Analytics Team
* **Source System**: Bloomberg Valuation Engine / PAM

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **ReturnKey** | Unique daily holding return identifier. | Int64 | PK |
| **DateKey** | Valuation date of the return entry. | Int64 | FK |
| **AssetKey** | Investment asset security evaluated. | Int64 | FK |
| **FundKey** | Mandate client portfolio holding the asset. | Int64 | FK |
| **DailyReturn** | Daily return rate achieved by the asset (expressed as decimal). | Double | - |
| **DailyBenchmarkReturn** | Daily return rate of the mandated index benchmark. | Double | - |
| **MarketValue** | Total market value valuation of the asset holding (ZAR). | Double | - |

---

### Fact_UnlistedInvestments (Private Equity Ledger)
* **Business Description**: Captures capital calls, distributions, and valuation snapshots for private equity and credit deals.
* **Data Owner**: Private Equity & Unlisted Investments Division (Isibaya)
* **Source System**: eFront PE Ledger

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **UnlistedTransactionKey** | Unique cash flow transaction record identifier. | Int64 | PK |
| **DateKey** | Date of cash flow posting or valuation snapshot. | Int64 | FK |
| **AssetKey** | Unlisted PE/Infrastructure asset code. | Int64 | FK |
| **FundKey** | Mandate client portfolio funding the PE asset. | Int64 | FK |
| **TransactionType** | Transaction classification (e.g., Drawdown, Distribution, Valuation). | String | - |
| **CashFlowAmount** | Net capital cash flow (negative for drawdowns, positive for distributions). | Double | - |
| **NetAssetValue** | Estimated net asset value valuation snapshot (ZAR). | Double | - |

---

### Fact_HelpdeskTickets (IT Operations ITSM)
* **Business Description**: Tracks support ticket lifecycle records, resolution times, priority, and SLA compliance.
* **Data Owner**: IT Infrastructure & Operations Division
* **Source System**: ServiceNow ITSM

| Column Technical Name | Business Description Summary | Native Data Type | Key Type |
| :--- | :--- | :--- | :--- |
| **TicketKey** | Unique support ticket record identifier. | Int64 | PK |
| **CreatedDateKey** | Date the support ticket was logged. | Int64 | FK |
| **ClosedDateKey** | Date the support ticket was closed (role-playing, inactive). | Int64 | FK |
| **EmployeeKey** | Employee who logged the support ticket. | Int64 | FK |
| **PriorityCode** | Severity classification (1 = Critical Incident, 2 = High, 3 = Medium, 4 = Low). | Int64 | - |
| **ResolutionDurationMinutes**| Elapsed time to resolve and close the ticket (in minutes). | Int64 | - |
| **SLA_Met** | Flag representing if SLA timeline targets were met (True/False). | Boolean | - |
