-- ====================================================================================
-- PUBLIC INVESTMENT CORPORATION (PIC) PORTFOLIO PROJECT SCHEMA GENERATOR
-- AUTHOR: PRINCIPAL POWER BI DEVELOPER & PORTFOLIO STRATEGIST ARCHITECTURE
-- TARGET ENGINE: AZURE SYNAPSE / FABRIC WAREHOUSE / SQL SERVER (2016+) / FABRIC SQL DB
-- DATABASE CONTEXT CHECK FOR: InvestmentHouse_db
-- ====================================================================================

-- ------------------------------------------------------------------------------------
-- DATABASE CONTEXT VALIDATION (Fabric SQL Database doesn't support 'USE')
-- ------------------------------------------------------------------------------------
IF DB_NAME() NOT LIKE 'InvestmentHouse_db%'
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000) = N'ERROR: This script must be executed on database "InvestmentHouse_db". Current database context is: ' + DB_NAME() + N'. Fabric SQL Database does not support switching databases using the T-SQL "USE" statement. Please connect directly to the "InvestmentHouse_db" database in your query editor or tool.';
    THROW 50000, @ErrorMessage, 1;
END;

-- ------------------------------------------------------------------------------------
-- CLEANUP ENVIRONMENT (DROP TABLES IF THEY EXIST TO ALLOW CLEAN RE-RUNS)
-- ------------------------------------------------------------------------------------
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Fact_HelpdeskTickets', 'U') IS NOT NULL DROP TABLE dbo.Fact_HelpdeskTickets;
IF OBJECT_ID('dbo.Fact_UnlistedInvestments', 'U') IS NOT NULL DROP TABLE dbo.Fact_UnlistedInvestments;
IF OBJECT_ID('dbo.Fact_PortfolioReturns', 'U') IS NOT NULL DROP TABLE dbo.Fact_PortfolioReturns;
IF OBJECT_ID('dbo.Fact_ProjectMilestones', 'U') IS NOT NULL DROP TABLE dbo.Fact_ProjectMilestones;
IF OBJECT_ID('dbo.Fact_AuditFindings', 'U') IS NOT NULL DROP TABLE dbo.Fact_AuditFindings;
IF OBJECT_ID('dbo.Fact_TradeSettlements', 'U') IS NOT NULL DROP TABLE dbo.Fact_TradeSettlements;
IF OBJECT_ID('dbo.Fact_HREvents', 'U') IS NOT NULL DROP TABLE dbo.Fact_HREvents;
IF OBJECT_ID('dbo.Fact_FinancialTransactions', 'U') IS NOT NULL DROP TABLE dbo.Fact_FinancialTransactions;

IF OBJECT_ID('dbo.Dim_BEELevel', 'U') IS NOT NULL DROP TABLE dbo.Dim_BEELevel;
IF OBJECT_ID('dbo.Dim_RegulatoryBody', 'U') IS NOT NULL DROP TABLE dbo.Dim_RegulatoryBody;
IF OBJECT_ID('dbo.Dim_AuditCategory', 'U') IS NOT NULL DROP TABLE dbo.Dim_AuditCategory;
IF OBJECT_ID('dbo.Dim_InvestmentAsset', 'U') IS NOT NULL DROP TABLE dbo.Dim_InvestmentAsset;
IF OBJECT_ID('dbo.Dim_Fund', 'U') IS NOT NULL DROP TABLE dbo.Dim_Fund;
IF OBJECT_ID('dbo.Dim_Employee', 'U') IS NOT NULL DROP TABLE dbo.Dim_Employee;
IF OBJECT_ID('dbo.Dim_Division', 'U') IS NOT NULL DROP TABLE dbo.Dim_Division;
IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL DROP TABLE dbo.Dim_Date;

-- ------------------------------------------------------------------------------------
-- PHASE 2: DIMENSION TABLES DEFINITIONS
-- ------------------------------------------------------------------------------------

CREATE TABLE dbo.Dim_Date (
    DateKey INT PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Year] INT NOT NULL,
    Quarter CHAR(2) NOT NULL,
    MonthName NVARCHAR(20) NOT NULL,
    MonthFiscal INT NOT NULL,
    DayOfWeek NVARCHAR(15) NOT NULL,
    IsPublicHolidayZA BIT NOT NULL
);

CREATE TABLE dbo.Dim_Division (
    DivisionKey INT PRIMARY KEY,
    DivisionName NVARCHAR(100) NOT NULL,
    ExecutiveHead NVARCHAR(100) NOT NULL,
    ExecutiveHeadEmail NVARCHAR(150) NOT NULL,
    CostCenterCode VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.Dim_Employee (
    EmployeeKey INT PRIMARY KEY,
    EmployeeID VARCHAR(20) NOT NULL,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    EthnicGroup VARCHAR(20) NOT NULL,
    OccupationalLevel NVARCHAR(50) NOT NULL,
    IsHDI BIT NOT NULL,
    SalaryAmount DECIMAL(18,2) NOT NULL -- Sensitive field protected via OLS later
);

CREATE TABLE dbo.Dim_Fund (
    FundKey INT PRIMARY KEY,
    FundName NVARCHAR(150) NOT NULL,
    ClientType VARCHAR(50) NOT NULL,
    InvestmentMandate NVARCHAR(250) NOT NULL,
    AssignedManagerEmail NVARCHAR(150) NOT NULL
);

CREATE TABLE dbo.Dim_InvestmentAsset (
    AssetKey INT PRIMARY KEY,
    ISIN VARCHAR(12) NOT NULL,
    AssetName NVARCHAR(150) NOT NULL,
    AssetClass VARCHAR(50) NOT NULL,
    Sector NVARCHAR(100) NOT NULL,
    ESG_Score DECIMAL(5,2) NOT NULL,
    CarbonIntensity DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Dim_AuditCategory (
    AuditCategoryKey INT PRIMARY KEY,
    SourceType VARCHAR(20) NOT NULL, -- AG / Internal Audit
    Classification NVARCHAR(150) NOT NULL,
    RiskLevel VARCHAR(10) NOT NULL
);

CREATE TABLE dbo.Dim_RegulatoryBody (
    RegulatoryBodyKey INT PRIMARY KEY,
    BodyName NVARCHAR(100) NOT NULL,
    SubmissionCycle VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Dim_BEELevel (
    BEELevelKey INT PRIMARY KEY,
    BEELevel INT NOT NULL,
    RecognitionPercentage DECIMAL(5,2) NOT NULL
);

-- ------------------------------------------------------------------------------------
-- PHASE 2: FACT TABLES DEFINITIONS (WITH FOREIGN KEY ENFORCEMENTS)
-- ------------------------------------------------------------------------------------

CREATE TABLE dbo.Fact_FinancialTransactions (
    TransactionKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    DivisionKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Division(DivisionKey),
    AccountCode INT NOT NULL,
    ActualAmount DECIMAL(18,2) NOT NULL,
    BudgetAmount DECIMAL(18,2) NOT NULL,
    PFMA_Status_Code INT NOT NULL, -- 0=Compliant, 1=Irregular, 2=Fruitless/Wasteful
    Last_Modified_Timestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE dbo.Fact_HREvents (
    HREventKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    EmployeeKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Employee(EmployeeKey),
    DivisionKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Division(DivisionKey),
    EventTypeName VARCHAR(30) NOT NULL, -- "Active Snapshot", "Hire", "Exit"
    TrainingSpend DECIMAL(18,2) NOT NULL
);

CREATE TABLE dbo.Fact_TradeSettlements (
    TradeKey INT IDENTITY(1,1) PRIMARY KEY,
    ExecutionDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    SettlementDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey), -- Inactive role-playing link
    AssetKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_InvestmentAsset(AssetKey),
    FundKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Fund(FundKey),
    BEELevelKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_BEELevel(BEELevelKey),
    TradeValue DECIMAL(18,2) NOT NULL,
    BrokerageFee DECIMAL(18,2) NOT NULL,
    SettlementStatus VARCHAR(20) NOT NULL -- "Settled", "Failed"
);

CREATE TABLE dbo.Fact_AuditFindings (
    FindingKey INT IDENTITY(1,1) PRIMARY KEY,
    RaisedDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    TargetDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    ActualResolutionDateKey INT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    AuditCategoryKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_AuditCategory(AuditCategoryKey),
    DivisionKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Division(DivisionKey),
    SeverityWeight INT NOT NULL,
    IsClosed BIT NOT NULL
);

CREATE TABLE dbo.Fact_ProjectMilestones (
    MilestoneKey INT IDENTITY(1,1) PRIMARY KEY,
    PlannedDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    ActualDateKey INT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    ProjectKey INT NOT NULL,
    MilestoneName NVARCHAR(100) NOT NULL,
    Weight DECIMAL(5,2) NOT NULL,
    [Status] VARCHAR(20) NOT NULL
);

CREATE TABLE dbo.Fact_PortfolioReturns (
    ReturnKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    AssetKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_InvestmentAsset(AssetKey),
    FundKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Fund(FundKey),
    DailyReturn DECIMAL(18,6) NOT NULL,
    DailyBenchmarkReturn DECIMAL(18,6) NOT NULL,
    MarketValue DECIMAL(18,2) NOT NULL
);

CREATE TABLE dbo.Fact_UnlistedInvestments (
    UnlistedTransactionKey INT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    AssetKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_InvestmentAsset(AssetKey),
    FundKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Fund(FundKey),
    TransactionType VARCHAR(30) NOT NULL, -- "Drawdown", "Distribution", "Valuation"
    CashFlowAmount DECIMAL(18,2) NOT NULL,
    NetAssetValue DECIMAL(18,2) NOT NULL
);

CREATE TABLE dbo.Fact_HelpdeskTickets (
    TicketKey INT IDENTITY(1,1) PRIMARY KEY,
    CreatedDateKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    ClosedDateKey INT NULL FOREIGN KEY REFERENCES dbo.Dim_Date(DateKey),
    EmployeeKey INT NOT NULL FOREIGN KEY REFERENCES dbo.Dim_Employee(EmployeeKey),
    PriorityCode INT NOT NULL,
    ResolutionDurationMinutes INT NULL,
    SLA_Met BIT NOT NULL
);

-- ------------------------------------------------------------------------------------
-- SEED DATA FILLING ENGINE (POPULATING SEED DIMENSIONS)
-- ------------------------------------------------------------------------------------

-- Seed Static Calendar Dim_Date (Years 2023 - 2025)
DECLARE @CurrentSeedDate DATE = '2023-01-01';
WHILE @CurrentSeedDate <= '2025-12-31'
BEGIN
    INSERT INTO dbo.Dim_Date (DateKey, [Date], [Year], Quarter, MonthName, MonthFiscal, DayOfWeek, IsPublicHolidayZA)
    VALUES (
        YEAR(@CurrentSeedDate) * 10000 + MONTH(@CurrentSeedDate) * 100 + DAY(@CurrentSeedDate),
        @CurrentSeedDate,
        YEAR(@CurrentSeedDate),
        'Q' + CAST(DATEPART(QUARTER, @CurrentSeedDate) AS CHAR(1)),
        DATENAME(MONTH, @CurrentSeedDate),
        CASE WHEN MONTH(@CurrentSeedDate) >= 4 THEN MONTH(@CurrentSeedDate) - 3 ELSE MONTH(@CurrentSeedDate) + 9 END, -- SA Fiscal Year starts April
        DATENAME(WEEKDAY, @CurrentSeedDate),
        CASE WHEN MONTH(@CurrentSeedDate) = 1 AND DAY(@CurrentSeedDate) = 1 THEN 1 -- New Years
             WHEN MONTH(@CurrentSeedDate) = 4 AND DAY(@CurrentSeedDate) = 27 THEN 1 -- Freedom Day
             WHEN MONTH(@CurrentSeedDate) = 12 AND DAY(@CurrentSeedDate) = 25 THEN 1 -- Xmas
             ELSE 0 END
    );
    SET @CurrentSeedDate = DATEADD(DAY, 1, @CurrentSeedDate);
END;

-- Seed Dim_Division
INSERT INTO dbo.Dim_Division VALUES 
(1, N'Listed Equities', N'Sipho Cele', N'sipho.cele@pic.gov.za', 'EQ001'),
(2, N'Private Equity', N'Lerato Pillay', N'lerato.pillay@pic.gov.za', 'PE002'),
(3, N'Human Capital', N'Naledi Dlamini', N'naledi.dlamini@pic.gov.za', 'HR003'),
(4, N'Finance', N'Kobus Burger', N'kobus.burger@pic.gov.za', 'FIN004'),
(5, N'Infrastructure & Isibaya Fund', N'Zanele Khumalo', N'zanele.khumalo@pic.gov.za', 'ISI05');

-- Seed Dim_Employee
INSERT INTO dbo.Dim_Employee VALUES 
(1, 'EMP001', N'Thabo Mokoena', N'thabo.mokoena@pic.gov.za', 'Male', 'African', N'Senior Management', 1, 145000.00),
(2, 'EMP002', N'Sarah Jenkins', N'sarah.jenkins@pic.gov.za', 'Female', 'White', N'Middle Management', 0, 98000.00),
(3, 'EMP003', N'Farhana Patel', N'farhana.patel@pic.gov.za', 'Female', 'Indian', N'Professional Specialist', 1, 85000.00),
(4, 'EMP004', N'John Louw', N'john.louw@pic.gov.za', 'Male', 'Coloured', N'Skilled Technical', 1, 55000.00),
(5, 'EMP005', N'Enoch Mbatha', N'enoch.mbatha@pic.gov.za', 'Male', 'African', N'Professional Specialist', 1, 88000.00);

-- Seed Dim_Fund
INSERT INTO dbo.Dim_Fund VALUES 
(1, N'Government Employees Pension Fund (GEPF)', 'Sovereign Pension', N'Long-term inflation-linked real growth mandate', N'gepf.portfolio@pic.gov.za'),
(2, N'Unemployment Insurance Fund (UIF)', 'Social Security', N'Short-to-medium term liquidity and defensive preservation', N'uif.portfolio@pic.gov.za'),
(3, N'Compensation Commissioner Fund', 'Social Security', N'Liability-matching fixed income focus', N'cc.portfolio@pic.gov.za');

-- Seed Dim_InvestmentAsset
INSERT INTO dbo.Dim_InvestmentAsset VALUES 
(1, 'ZAE000015889', N'Naspers Ltd', 'Equity', N'Technology', 68.50, 120.40),
(2, 'ZAE000109815', N'Standard Bank Group', 'Equity', N'Financials', 82.10, 450.90),
(3, 'ZAG000163442', N'RSA Government Bond R2030', 'Fixed Income', N'Sovereign Debt', 95.00, 0.00),
(4, 'PE_ISIB_VNT1', N'Isibaya Eco Infrastructure Fund', 'Unlisted Asset', N'Renewable Energy', 88.00, 12.30),
(5, 'PE_RE_MALL01', N'Pan-African Retail Property Fund', 'Unlisted Asset', N'Real Estate', 54.20, 310.60);

-- Seed Dim_AuditCategory
INSERT INTO dbo.Dim_AuditCategory VALUES 
(1, 'Auditor-General', N'Supply Chain Procurement Variance', 'High'),
(2, 'Auditor-General', N'Material Misstatement in Asset Valuation', 'Critical'),
(3, 'Internal Audit', N'IT User Access Certification Controls', 'Medium'),
(4, 'Internal Audit', N'SLA Non-Adherence Breaches', 'Low');

-- Seed Dim_RegulatoryBody
INSERT INTO dbo.Dim_RegulatoryBody VALUES 
(1, N'Financial Sector Conduct Authority (FSCA)', 'Quarterly'),
(2, N'National Treasury', 'Monthly'),
(3, N'South African Reserve Bank (SARB)', 'Bi-Annually');

-- Seed Dim_BEELevel
INSERT INTO dbo.Dim_BEELevel VALUES 
(1, 1, 135.00), (2, 2, 125.00), (3, 3, 110.00), (4, 4, 100.00), (5, 5, 80.00);

-- ------------------------------------------------------------------------------------
-- ADVANCED COMPREHENSIVE SET-BASED SYNTHETIC TRANSACTION INGESTION CORE
-- Generates exactly 5,000 distinct tracking rows per operational Fact table.
-- ------------------------------------------------------------------------------------
DECLARE @VolumeTarget INT = 5000;

-- Create a temporary table to store the precomputed deterministic seeds
IF OBJECT_ID('tempdb..#DeterministicSeeds') IS NOT NULL 
    DROP TABLE #DeterministicSeeds;

CREATE TABLE #DeterministicSeeds (
    RowID INT PRIMARY KEY,
    CalculatedDateKey INT NOT NULL,
    SettlementDateKey INT NOT NULL,
    AuditTargetDateKey INT NOT NULL,
    AuditResolutionDateKey INT NULL,
    ProjectActualDateKey INT NULL,
    DivKey INT NOT NULL,
    EmpKey INT NOT NULL,
    FndKey INT NOT NULL,
    AstKey INT NOT NULL,
    AudKey INT NOT NULL,
    BeeKey INT NOT NULL,
    CryptoSeed INT NOT NULL
);

-- Populate the temporary table
WITH TallyEngine(RowID) AS (
    SELECT TOP (@VolumeTarget) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_columns c1 CROSS JOIN sys.all_columns c2
),
RawSeeds AS (
    SELECT 
        RowID,
        -- Generate base date between 2023-01-01 and late 2025 (RowID % 1000)
        DATEADD(day, RowID % 1000, CAST('2023-01-01' AS DATE)) AS BaseDate,
        (RowID % 5) + 1 AS DivKey,
        (RowID % 5) + 1 AS EmpKey,
        (RowID % 3) + 1 AS FndKey,
        (RowID % 5) + 1 AS AstKey,
        (RowID % 4) + 1 AS AudKey,
        (RowID % 5) + 1 AS BeeKey,
        ABS(CHECKSUM(NEWID())) AS CryptoSeed
    FROM TallyEngine
)
INSERT INTO #DeterministicSeeds (
    RowID, CalculatedDateKey, SettlementDateKey, AuditTargetDateKey, 
    AuditResolutionDateKey, ProjectActualDateKey, DivKey, EmpKey, 
    FndKey, AstKey, AudKey, BeeKey, CryptoSeed
)
SELECT 
    RowID,
    -- Convert BaseDate to YYYYMMDD
    YEAR(BaseDate) * 10000 + MONTH(BaseDate) * 100 + DAY(BaseDate) AS CalculatedDateKey,
    
    -- SettlementDateKey: T+2 days
    YEAR(DATEADD(day, 2, BaseDate)) * 10000 + MONTH(DATEADD(day, 2, BaseDate)) * 100 + DAY(DATEADD(day, 2, BaseDate)) AS SettlementDateKey,
    
    -- AuditTargetDateKey: +90 days
    YEAR(DATEADD(day, 90, BaseDate)) * 10000 + MONTH(DATEADD(day, 90, BaseDate)) * 100 + DAY(DATEADD(day, 90, BaseDate)) AS AuditTargetDateKey,
    
    -- AuditResolutionDateKey: if RowID % 3 = 0, resolution is within 80 days
    CASE WHEN RowID % 3 = 0 THEN 
        YEAR(DATEADD(day, RowID % 80, BaseDate)) * 10000 + MONTH(DATEADD(day, RowID % 80, BaseDate)) * 100 + DAY(DATEADD(day, RowID % 80, BaseDate)) 
    ELSE NULL END AS AuditResolutionDateKey,
    
    -- ProjectActualDateKey: if RowID % 5 <> 0, actual is within 5 days
    CASE WHEN RowID % 5 <> 0 THEN 
        YEAR(DATEADD(day, RowID % 5, BaseDate)) * 10000 + MONTH(DATEADD(day, RowID % 5, BaseDate)) * 100 + DAY(DATEADD(day, RowID % 5, BaseDate)) 
    ELSE NULL END AS ProjectActualDateKey,
    
    DivKey, EmpKey, FndKey, AstKey, AudKey, BeeKey, CryptoSeed
FROM RawSeeds;

-- 1. Ingest Fact_FinancialTransactions
INSERT INTO dbo.Fact_FinancialTransactions (DateKey, DivisionKey, AccountCode, ActualAmount, BudgetAmount, PFMA_Status_Code)
SELECT 
    CalculatedDateKey, DivKey, 520000 + (RowID % 15),
    ROUND((CryptoSeed % 150000) + 10000.45, 2) AS Actual,
    ROUND(((CryptoSeed % 150000) + 10000.45) * (0.88 + ((CryptoSeed % 25) * 0.01)), 2) AS Budget,
    CASE WHEN (CryptoSeed % 100) >= 97 THEN (CryptoSeed % 2) + 1 ELSE 0 END -- 3% Compliance Non-Conformance Rates
FROM #DeterministicSeeds;

-- 2. Ingest Fact_HREvents
INSERT INTO dbo.Fact_HREvents (DateKey, EmployeeKey, DivisionKey, EventTypeName, TrainingSpend)
SELECT 
    CalculatedDateKey, EmpKey, DivKey,
    CASE WHEN RowID % 20 = 0 THEN 'Hire' WHEN RowID % 45 = 0 THEN 'Exit' ELSE 'Active Snapshot' END,
    CASE WHEN RowID % 7 = 0 THEN ROUND((CryptoSeed % 12000) + 1500.00, 2) ELSE 0.00 END
FROM #DeterministicSeeds;

-- 3. Ingest Fact_TradeSettlements
INSERT INTO dbo.Fact_TradeSettlements (ExecutionDateKey, SettlementDateKey, AssetKey, FundKey, BEELevelKey, TradeValue, BrokerageFee, SettlementStatus)
SELECT 
    CalculatedDateKey, 
    SettlementDateKey, 
    AstKey, FndKey, BeeKey,
    ROUND((CryptoSeed % 5000000) + 50000.00, 2),
    ROUND(((CryptoSeed % 5000000) + 50000.00) * 0.0015, 2), -- 15 bps brokerage execution fees
    CASE WHEN RowID % 120 = 0 THEN 'Failed' ELSE 'Settled' END
FROM #DeterministicSeeds;

-- 4. Ingest Fact_AuditFindings
INSERT INTO dbo.Fact_AuditFindings (RaisedDateKey, TargetDateKey, ActualResolutionDateKey, AuditCategoryKey, DivisionKey, SeverityWeight, IsClosed)
SELECT 
    CalculatedDateKey, AuditTargetDateKey, ActualResolutionDateKey,
    AudKey, DivKey,
    (RowID % 5) + 1,
    CASE WHEN RowID % 3 = 0 THEN 1 ELSE 0 END
FROM #DeterministicSeeds;

-- 5. Ingest Fact_ProjectMilestones
INSERT INTO dbo.Fact_ProjectMilestones (PlannedDateKey, ActualDateKey, ProjectKey, MilestoneName, Weight, [Status])
SELECT 
    CalculatedDateKey,
    ProjectActualDateKey,
    (RowID % 8) + 101,
    N'Project Deliverable Stage Framework ' + CAST((RowID % 4) AS NVARCHAR(5)),
    ROUND(25.00, 2),
    CASE WHEN RowID % 5 = 0 THEN 'Delayed' ELSE 'Completed' END
FROM #DeterministicSeeds;

-- 6. Ingest Fact_PortfolioReturns
INSERT INTO dbo.Fact_PortfolioReturns (DateKey, AssetKey, FundKey, DailyReturn, DailyBenchmarkReturn, MarketValue)
SELECT 
    CalculatedDateKey, AstKey, FndKey,
    CAST(((CryptoSeed % 200) - 95) AS DECIMAL(18,6)) / 10000.000000, -- Dynamic basis points generation
    CAST(((CryptoSeed % 180) - 90) AS DECIMAL(18,6)) / 10000.000000,
    ROUND((CryptoSeed % 100000000) + 10000000.00, 2)
FROM #DeterministicSeeds;

-- 7. Ingest Fact_UnlistedInvestments
INSERT INTO dbo.Fact_UnlistedInvestments (DateKey, AssetKey, FundKey, TransactionType, CashFlowAmount, NetAssetValue)
SELECT 
    CalculatedDateKey, AstKey, FndKey,
    CASE WHEN RowID % 3 = 0 THEN 'Drawdown' WHEN RowID % 3 = 1 THEN 'Distribution' ELSE 'Valuation' END,
    ROUND(CAST((CryptoSeed % 25000000) AS DECIMAL(18,2)), 2),
    ROUND(CAST((CryptoSeed % 400000000) + 50000000 AS DECIMAL(18,2)), 2)
FROM #DeterministicSeeds;

-- 8. Ingest Fact_HelpdeskTickets
INSERT INTO dbo.Fact_HelpdeskTickets (CreatedDateKey, ClosedDateKey, EmployeeKey, PriorityCode, ResolutionDurationMinutes, SLA_Met)
SELECT 
    CalculatedDateKey,
    CASE WHEN RowID % 15 <> 0 THEN CalculatedDateKey ELSE NULL END,
    EmpKey, (RowID % 4) + 1,
    CASE WHEN RowID % 15 <> 0 THEN (CryptoSeed % 480) + 15 ELSE NULL END,
    CASE WHEN (RowID % 15 <> 0) AND ((CryptoSeed % 480) < 240) THEN 1 ELSE 0 END
FROM #DeterministicSeeds;

-- Clean up temporary table
IF OBJECT_ID('tempdb..#DeterministicSeeds') IS NOT NULL 
    DROP TABLE #DeterministicSeeds;

-- ------------------------------------------------------------------------------------
-- PHASE 7: DIAGNOSTIC VALIDATION CHECKPOINT
-- Confirming that all 16 tables exist and contain appropriate records.
-- ------------------------------------------------------------------------------------
SELECT 'Dim_Date' AS [Table], COUNT(*) AS [Rows] FROM dbo.Dim_Date UNION ALL
SELECT 'Dim_Division', COUNT(*) FROM dbo.Dim_Division UNION ALL
SELECT 'Dim_Employee', COUNT(*) FROM dbo.Dim_Employee UNION ALL
SELECT 'Dim_Fund', COUNT(*) FROM dbo.Dim_Fund UNION ALL
SELECT 'Dim_InvestmentAsset', COUNT(*) FROM dbo.Dim_InvestmentAsset UNION ALL
SELECT 'Dim_AuditCategory', COUNT(*) FROM dbo.Dim_AuditCategory UNION ALL
SELECT 'Dim_RegulatoryBody', COUNT(*) FROM dbo.Dim_RegulatoryBody UNION ALL
SELECT 'Dim_BEELevel', COUNT(*) FROM dbo.Dim_BEELevel UNION ALL
SELECT 'Fact_FinancialTransactions', COUNT(*) FROM dbo.Fact_FinancialTransactions UNION ALL
SELECT 'Fact_HREvents', COUNT(*) FROM dbo.Fact_HREvents UNION ALL
SELECT 'Fact_TradeSettlements', COUNT(*) FROM dbo.Fact_TradeSettlements UNION ALL
SELECT 'Fact_AuditFindings', COUNT(*) FROM dbo.Fact_AuditFindings UNION ALL
SELECT 'Fact_ProjectMilestones', COUNT(*) FROM dbo.Fact_ProjectMilestones UNION ALL
SELECT 'Fact_PortfolioReturns', COUNT(*) FROM dbo.Fact_PortfolioReturns UNION ALL
SELECT 'Fact_UnlistedInvestments', COUNT(*) FROM dbo.Fact_UnlistedInvestments UNION ALL
SELECT 'Fact_HelpdeskTickets', COUNT(*) FROM dbo.Fact_HelpdeskTickets;