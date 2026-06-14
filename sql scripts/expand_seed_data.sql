-- ====================================================================================
-- PIC PORTFOLIO PROJECT: EXPANDED SYNTHETIC SEED DATA
-- PURPOSE: Scale dimension tables to production-realistic volumes and improve
--          fact table distributions for meaningful report visuals.
-- TARGET:  InvestmentHouse_db (Fabric SQL Database — already provisioned)
-- PREREQUISITE: initialise_db.sql has already been executed.
-- ====================================================================================

-- ------------------------------------------------------------------------------------
-- DATABASE CONTEXT VALIDATION
-- ------------------------------------------------------------------------------------
IF DB_NAME() NOT LIKE 'InvestmentHouse_db%'
BEGIN
    DECLARE @ErrorMessage NVARCHAR(4000) = N'ERROR: This script must be executed on database "InvestmentHouse_db". Current database context is: ' + DB_NAME();
    THROW 50000, @ErrorMessage, 1;
END;

SET NOCOUNT ON;

-- ------------------------------------------------------------------------------------
-- STEP 1: CLEAR ALL EXISTING DATA (Facts first due to FK constraints, then Dims)
-- ------------------------------------------------------------------------------------
DELETE FROM dbo.Fact_HelpdeskTickets;
DELETE FROM dbo.Fact_UnlistedInvestments;
DELETE FROM dbo.Fact_PortfolioReturns;
DELETE FROM dbo.Fact_ProjectMilestones;
DELETE FROM dbo.Fact_AuditFindings;
DELETE FROM dbo.Fact_TradeSettlements;
DELETE FROM dbo.Fact_HREvents;
DELETE FROM dbo.Fact_FinancialTransactions;

DELETE FROM dbo.Dim_BEELevel;
DELETE FROM dbo.Dim_RegulatoryBody;
DELETE FROM dbo.Dim_AuditCategory;
DELETE FROM dbo.Dim_InvestmentAsset;
DELETE FROM dbo.Dim_Fund;
DELETE FROM dbo.Dim_Employee;
DELETE FROM dbo.Dim_Division;
DELETE FROM dbo.Dim_Date;

-- Reset identity seeds on fact tables
DBCC CHECKIDENT ('dbo.Fact_FinancialTransactions', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_HREvents', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_TradeSettlements', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_AuditFindings', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_ProjectMilestones', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_PortfolioReturns', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_UnlistedInvestments', RESEED, 0);
DBCC CHECKIDENT ('dbo.Fact_HelpdeskTickets', RESEED, 0);

-- ====================================================================================
-- STEP 2: SEED DIM_DATE (Calendar Years 2021–2025, SA Fiscal Year April Start)
-- ====================================================================================
DECLARE @CurrentSeedDate DATE = '2021-01-01';
WHILE @CurrentSeedDate <= '2025-12-31'
BEGIN
    INSERT INTO dbo.Dim_Date (DateKey, [Date], [Year], Quarter, MonthName, MonthFiscal, DayOfWeek, IsPublicHolidayZA)
    VALUES (
        YEAR(@CurrentSeedDate) * 10000 + MONTH(@CurrentSeedDate) * 100 + DAY(@CurrentSeedDate),
        @CurrentSeedDate,
        YEAR(@CurrentSeedDate),
        'Q' + CAST(DATEPART(QUARTER, @CurrentSeedDate) AS CHAR(1)),
        DATENAME(MONTH, @CurrentSeedDate),
        CASE WHEN MONTH(@CurrentSeedDate) >= 4 THEN MONTH(@CurrentSeedDate) - 3 
             ELSE MONTH(@CurrentSeedDate) + 9 END,
        DATENAME(WEEKDAY, @CurrentSeedDate),
        CASE
            WHEN MONTH(@CurrentSeedDate) = 1  AND DAY(@CurrentSeedDate) = 1  THEN 1  -- New Year's Day
            WHEN MONTH(@CurrentSeedDate) = 3  AND DAY(@CurrentSeedDate) = 21 THEN 1  -- Human Rights Day
            WHEN MONTH(@CurrentSeedDate) = 4  AND DAY(@CurrentSeedDate) = 27 THEN 1  -- Freedom Day
            WHEN MONTH(@CurrentSeedDate) = 5  AND DAY(@CurrentSeedDate) = 1  THEN 1  -- Workers' Day
            WHEN MONTH(@CurrentSeedDate) = 6  AND DAY(@CurrentSeedDate) = 16 THEN 1  -- Youth Day
            WHEN MONTH(@CurrentSeedDate) = 8  AND DAY(@CurrentSeedDate) = 9  THEN 1  -- National Women's Day
            WHEN MONTH(@CurrentSeedDate) = 9  AND DAY(@CurrentSeedDate) = 24 THEN 1  -- Heritage Day
            WHEN MONTH(@CurrentSeedDate) = 12 AND DAY(@CurrentSeedDate) = 16 THEN 1  -- Day of Reconciliation
            WHEN MONTH(@CurrentSeedDate) = 12 AND DAY(@CurrentSeedDate) = 25 THEN 1  -- Christmas Day
            WHEN MONTH(@CurrentSeedDate) = 12 AND DAY(@CurrentSeedDate) = 26 THEN 1  -- Day of Goodwill
            ELSE 0
        END
    );
    SET @CurrentSeedDate = DATEADD(DAY, 1, @CurrentSeedDate);
END;

-- ====================================================================================
-- STEP 3: SEED DIM_DIVISION (Expanded from 5 to 10)
-- ====================================================================================
INSERT INTO dbo.Dim_Division VALUES
(1,  N'Listed Equities',                   N'Sipho Cele',        N'sipho.cele@pic.gov.za',        'EQ001'),
(2,  N'Private Equity',                    N'Lerato Pillay',     N'lerato.pillay@pic.gov.za',     'PE002'),
(3,  N'Human Capital',                     N'Naledi Dlamini',    N'naledi.dlamini@pic.gov.za',    'HR003'),
(4,  N'Finance',                           N'Kobus Burger',      N'kobus.burger@pic.gov.za',      'FIN04'),
(5,  N'Infrastructure & Isibaya Fund',     N'Zanele Khumalo',    N'zanele.khumalo@pic.gov.za',    'ISI05'),
(6,  N'Fixed Income & Credit',             N'Pieter van Wyk',    N'pieter.vanwyk@pic.gov.za',     'FI006'),
(7,  N'Information Technology',            N'Bongani Ndlovu',    N'bongani.ndlovu@pic.gov.za',    'IT007'),
(8,  N'Legal, Compliance & Risk',          N'Fatima Mahomed',    N'fatima.mahomed@pic.gov.za',    'LCR08'),
(9,  N'Corporate Affairs & Governance',    N'Mmapula Kekana',    N'mmapula.kekana@pic.gov.za',    'CAG09'),
(10, N'Properties & Real Estate',          N'Charl du Plessis',  N'charl.duplessis@pic.gov.za',   'PRE10');

-- ====================================================================================
-- STEP 4: SEED DIM_EMPLOYEE (~403 Employees with realistic SA demographics)
-- ====================================================================================
-- Demographic targets (aligned with PIC EE Plan & SA EAP):
--   African: ~65%  |  White: ~15%  |  Coloured: ~10%  |  Indian: ~10%
--   Female: ~48%   |  Male: ~52%
--   HDI (African + Coloured + Indian): ~85%

-- Using a name pool approach for realistic South African names
IF OBJECT_ID('tempdb..#FirstNames') IS NOT NULL DROP TABLE #FirstNames;
IF OBJECT_ID('tempdb..#Surnames') IS NOT NULL DROP TABLE #Surnames;

CREATE TABLE #FirstNames (NameID INT IDENTITY(1,1), FirstName NVARCHAR(50), Gender VARCHAR(10), EthnicGroup VARCHAR(20));
CREATE TABLE #Surnames (SurnameID INT IDENTITY(1,1), Surname NVARCHAR(50), EthnicGroup VARCHAR(20));

-- African Male First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Thabo', 'Male', 'African'), (N'Sipho', 'Male', 'African'), (N'Bongani', 'Male', 'African'),
(N'Mandla', 'Male', 'African'), (N'Tshepo', 'Male', 'African'), (N'Kabelo', 'Male', 'African'),
(N'Enoch', 'Male', 'African'), (N'Lebogang', 'Male', 'African'), (N'Sifiso', 'Male', 'African'),
(N'Thabiso', 'Male', 'African'), (N'Mpho', 'Male', 'African'), (N'Nhlanhla', 'Male', 'African'),
(N'Kagiso', 'Male', 'African'), (N'Tumelo', 'Male', 'African'), (N'Sbusiso', 'Male', 'African'),
(N'Vuyo', 'Male', 'African'), (N'Andile', 'Male', 'African'), (N'Thulani', 'Male', 'African'),
(N'Mxolisi', 'Male', 'African'), (N'Lungelo', 'Male', 'African'), (N'Katlego', 'Male', 'African'),
(N'Sizwe', 'Male', 'African'), (N'Zweli', 'Male', 'African'), (N'Phumulani', 'Male', 'African'),
(N'Xolani', 'Male', 'African'), (N'Themba', 'Male', 'African'), (N'Sandile', 'Male', 'African'),
(N'Masilo', 'Male', 'African'), (N'Mogale', 'Male', 'African'), (N'Olebogeng', 'Male', 'African');

-- African Female First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Naledi', 'Female', 'African'), (N'Zanele', 'Female', 'African'), (N'Lerato', 'Female', 'African'),
(N'Nomvula', 'Female', 'African'), (N'Thandi', 'Female', 'African'), (N'Palesa', 'Female', 'African'),
(N'Lindiwe', 'Female', 'African'), (N'Mmapula', 'Female', 'African'), (N'Nompumelelo', 'Female', 'African'),
(N'Nthabiseng', 'Female', 'African'), (N'Dineo', 'Female', 'African'), (N'Kelebogile', 'Female', 'African'),
(N'Nonhlanhla', 'Female', 'African'), (N'Bongiwe', 'Female', 'African'), (N'Refilwe', 'Female', 'African'),
(N'Boitumelo', 'Female', 'African'), (N'Tshegofatso', 'Female', 'African'), (N'Zinhle', 'Female', 'African'),
(N'Noluthando', 'Female', 'African'), (N'Ayanda', 'Female', 'African'), (N'Masego', 'Female', 'African'),
(N'Lesedi', 'Female', 'African'), (N'Nosipho', 'Female', 'African'), (N'Busisiwe', 'Female', 'African'),
(N'Pulane', 'Female', 'African'), (N'Kgomotso', 'Female', 'African'), (N'Mpumi', 'Female', 'African'),
(N'Nomasonto', 'Female', 'African'), (N'Duduetsang', 'Female', 'African'), (N'Rethabile', 'Female', 'African');

-- White Male First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Pieter', 'Male', 'White'), (N'Johan', 'Male', 'White'), (N'Hendrik', 'Male', 'White'),
(N'Charl', 'Male', 'White'), (N'Willem', 'Male', 'White'), (N'Stefan', 'Male', 'White'),
(N'David', 'Male', 'White'), (N'James', 'Male', 'White'), (N'Andrew', 'Male', 'White'),
(N'Michael', 'Male', 'White'), (N'Daniel', 'Male', 'White'), (N'Ryan', 'Male', 'White');

-- White Female First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Sarah', 'Female', 'White'), (N'Annelie', 'Female', 'White'), (N'Liesl', 'Female', 'White'),
(N'Carla', 'Female', 'White'), (N'Elana', 'Female', 'White'), (N'Janine', 'Female', 'White'),
(N'Michelle', 'Female', 'White'), (N'Karen', 'Female', 'White'), (N'Adele', 'Female', 'White'),
(N'Marlene', 'Female', 'White'), (N'Ingrid', 'Female', 'White'), (N'Carine', 'Female', 'White');

-- Coloured Male First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Ashwin', 'Male', 'Coloured'), (N'Riyaad', 'Male', 'Coloured'), (N'Gasant', 'Male', 'Coloured'),
(N'Mogamat', 'Male', 'Coloured'), (N'Farouk', 'Male', 'Coloured'), (N'Ebrahim', 'Male', 'Coloured'),
(N'Shafiek', 'Male', 'Coloured'), (N'Ricardo', 'Male', 'Coloured');

-- Coloured Female First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Soraya', 'Female', 'Coloured'), (N'Nabeelah', 'Female', 'Coloured'), (N'Shanaaz', 'Female', 'Coloured'),
(N'Chantal', 'Female', 'Coloured'), (N'Shireen', 'Female', 'Coloured'), (N'Rehana', 'Female', 'Coloured'),
(N'Nuraan', 'Female', 'Coloured'), (N'Mishka', 'Female', 'Coloured');

-- Indian Male First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Rajesh', 'Male', 'Indian'), (N'Pravin', 'Male', 'Indian'), (N'Sunil', 'Male', 'Indian'),
(N'Vikesh', 'Male', 'Indian'), (N'Nishant', 'Male', 'Indian'), (N'Sanjay', 'Male', 'Indian'),
(N'Yusuf', 'Male', 'Indian'), (N'Imraan', 'Male', 'Indian');

-- Indian Female First Names
INSERT INTO #FirstNames (FirstName, Gender, EthnicGroup) VALUES
(N'Farhana', 'Female', 'Indian'), (N'Priya', 'Female', 'Indian'), (N'Sunita', 'Female', 'Indian'),
(N'Nisha', 'Female', 'Indian'), (N'Anisha', 'Female', 'Indian'), (N'Fatima', 'Female', 'Indian'),
(N'Shamila', 'Female', 'Indian'), (N'Kavitha', 'Female', 'Indian');

-- Surnames by ethnic group
INSERT INTO #Surnames (Surname, EthnicGroup) VALUES
-- African Surnames
(N'Mokoena', 'African'), (N'Dlamini', 'African'), (N'Nkosi', 'African'), (N'Khumalo', 'African'),
(N'Zulu', 'African'), (N'Ndlovu', 'African'), (N'Mthembu', 'African'), (N'Naidoo', 'African'),
(N'Cele', 'African'), (N'Molefe', 'African'), (N'Langa', 'African'), (N'Radebe', 'African'),
(N'Sithole', 'African'), (N'Mahlangu', 'African'), (N'Maseko', 'African'), (N'Ngcobo', 'African'),
(N'Motaung', 'African'), (N'Shabalala', 'African'), (N'Mabaso', 'African'), (N'Tshabalala', 'African'),
(N'Mkhize', 'African'), (N'Ngwenya', 'African'), (N'Phiri', 'African'), (N'Mbatha', 'African'),
(N'Vilakazi', 'African'), (N'Nkabinde', 'African'), (N'Mokgatlhe', 'African'), (N'Tau', 'African'),
(N'Selepe', 'African'), (N'Mthethwa', 'African'), (N'Mogashoa', 'African'), (N'Letsoalo', 'African'),
(N'Tlhabi', 'African'), (N'Kekana', 'African'), (N'Mabuza', 'African'), (N'Makgoba', 'African'),
-- White Surnames
(N'van Wyk', 'White'), (N'du Plessis', 'White'), (N'Botha', 'White'), (N'Burger', 'White'),
(N'Venter', 'White'), (N'Joubert', 'White'), (N'Pretorius', 'White'), (N'van der Merwe', 'White'),
(N'Steyn', 'White'), (N'Nel', 'White'), (N'Muller', 'White'), (N'Swanepoel', 'White'),
(N'Jenkins', 'White'), (N'Thompson', 'White'), (N'Robertson', 'White'), (N'Gillespie', 'White'),
-- Coloured Surnames
(N'Abrahams', 'Coloured'), (N'Williams', 'Coloured'), (N'Jacobs', 'Coloured'), (N'Davids', 'Coloured'),
(N'Petersen', 'Coloured'), (N'Hendricks', 'Coloured'), (N'Adams', 'Coloured'), (N'Isaacs', 'Coloured'),
(N'Samuels', 'Coloured'), (N'Daniels', 'Coloured'),
-- Indian Surnames
(N'Pillay', 'Indian'), (N'Patel', 'Indian'), (N'Govender', 'Indian'), (N'Maharaj', 'Indian'),
(N'Singh', 'Indian'), (N'Naidoo', 'Indian'), (N'Reddy', 'Indian'), (N'Mahomed', 'Indian'),
(N'Moosa', 'Indian'), (N'Desai', 'Indian');

-- Generate ~403 employees using cross-join with controlled demographic distribution
;WITH NumberedNames AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY fn.NameID, sn.SurnameID) AS EmpSeq,
        fn.FirstName,
        sn.Surname,
        fn.Gender,
        fn.EthnicGroup,
        ABS(CHECKSUM(NEWID())) AS RandSeed
    FROM #FirstNames fn
    CROSS JOIN #Surnames sn
    WHERE fn.EthnicGroup = sn.EthnicGroup  -- Match names to correct ethnic group
),
RankedEmployees AS (
    SELECT 
        EmpSeq,
        FirstName,
        Surname,
        Gender,
        EthnicGroup,
        RandSeed,
        ROW_NUMBER() OVER (ORDER BY 
            CASE EthnicGroup 
                WHEN 'African' THEN 1    -- Prioritize African to hit ~65%
                WHEN 'Coloured' THEN 2 
                WHEN 'Indian' THEN 3 
                WHEN 'White' THEN 4 
            END,
            RandSeed
        ) AS FinalRank
    FROM NumberedNames
)
INSERT INTO dbo.Dim_Employee (
    EmployeeKey, EmployeeID, FullName, Email, Gender, EthnicGroup,
    OccupationalLevel, IsHDI, SalaryAmount
)
SELECT TOP 403
    FinalRank AS EmployeeKey,
    'EMP' + RIGHT('000' + CAST(FinalRank AS VARCHAR(4)), 4) AS EmployeeID,
    FirstName + N' ' + Surname AS FullName,
    LOWER(REPLACE(REPLACE(FirstName, ' ', '.'), '''', '')) 
        + '.' + LOWER(REPLACE(REPLACE(Surname, ' ', ''), '''', '')) 
        + '@pic.gov.za' AS Email,
    Gender,
    EthnicGroup,
    CASE
        WHEN FinalRank <= 5   THEN N'Top Management'
        WHEN FinalRank <= 35  THEN N'Senior Management'
        WHEN FinalRank <= 95  THEN N'Middle Management'
        WHEN FinalRank <= 195 THEN N'Professional Specialist'
        WHEN FinalRank <= 295 THEN N'Skilled Technical'
        WHEN FinalRank <= 375 THEN N'Semi-Skilled'
        ELSE N'Unskilled'
    END AS OccupationalLevel,
    CASE WHEN EthnicGroup IN ('African', 'Coloured', 'Indian') THEN 1 ELSE 0 END AS IsHDI,
    CASE
        WHEN FinalRank <= 5   THEN ROUND(180000 + (RandSeed % 70000), 2)   -- Top Mgmt: R180k–R250k
        WHEN FinalRank <= 35  THEN ROUND(120000 + (RandSeed % 60000), 2)   -- Senior Mgmt: R120k–R180k
        WHEN FinalRank <= 95  THEN ROUND(80000  + (RandSeed % 40000), 2)   -- Middle Mgmt: R80k–R120k
        WHEN FinalRank <= 195 THEN ROUND(55000  + (RandSeed % 35000), 2)   -- Professional: R55k–R90k
        WHEN FinalRank <= 295 THEN ROUND(35000  + (RandSeed % 25000), 2)   -- Skilled: R35k–R60k
        WHEN FinalRank <= 375 THEN ROUND(20000  + (RandSeed % 15000), 2)   -- Semi-Skilled: R20k–R35k
        ELSE ROUND(12000 + (RandSeed % 10000), 2)                         -- Unskilled: R12k–R22k
    END AS SalaryAmount
FROM RankedEmployees
ORDER BY FinalRank;

DROP TABLE #FirstNames;
DROP TABLE #Surnames;

-- ====================================================================================
-- STEP 5: SEED DIM_FUND (Expanded from 3 to 6)
-- ====================================================================================
INSERT INTO dbo.Dim_Fund VALUES
(1, N'Government Employees Pension Fund (GEPF)',       'Sovereign Pension',   N'Long-term inflation-linked real growth mandate',                      N'gepf.portfolio@pic.gov.za'),
(2, N'Unemployment Insurance Fund (UIF)',               'Social Security',     N'Short-to-medium term liquidity and defensive capital preservation',   N'uif.portfolio@pic.gov.za'),
(3, N'Compensation Commissioner Fund (CC)',             'Social Security',     N'Liability-matching fixed income focus with capital guarantee',        N'cc.portfolio@pic.gov.za'),
(4, N'Associated Institutions Pension Fund (AIPF)',     'Sovereign Pension',   N'Balanced growth with moderate risk tolerance',                        N'aipf.portfolio@pic.gov.za'),
(5, N'Temporary Employees Pension Fund (TEPF)',         'Sovereign Pension',   N'Conservative balanced portfolio with liquidity requirements',         N'tepf.portfolio@pic.gov.za'),
(6, N'PIC Internal Corporate Fund',                     'Internal',            N'Operational cash management and corporate treasury',                  N'treasury@pic.gov.za');

-- ====================================================================================
-- STEP 6: SEED DIM_INVESTMENTASSET (Expanded from 5 to 50)
-- ====================================================================================
INSERT INTO dbo.Dim_InvestmentAsset VALUES
-- JSE Top 40 Listed Equities (20 assets)
( 1, 'ZAE000015889', N'Naspers Ltd',                    'Equity',          N'Technology',          68.50, 120.40),
( 2, 'ZAE000109815', N'Standard Bank Group',             'Equity',          N'Financials',          82.10, 450.90),
( 3, 'ZAE000066304', N'Anglo American plc',              'Equity',          N'Mining',              45.30, 890.20),
( 4, 'ZAE000071080', N'BHP Group',                       'Equity',          N'Mining',              51.70, 920.10),
( 5, 'ZAE000067211', N'Sasol Ltd',                       'Equity',          N'Chemicals & Energy',  32.80, 1450.60),
( 6, 'ZAE000043485', N'FirstRand Ltd',                   'Equity',          N'Financials',          79.40, 380.50),
( 7, 'ZAE000018411', N'MTN Group',                       'Equity',          N'Telecommunications',  61.20, 210.80),
( 8, 'ZAE000078580', N'Absa Group Ltd',                  'Equity',          N'Financials',          76.90, 410.30),
( 9, 'ZAE000004875', N'Shoprite Holdings',               'Equity',          N'Consumer Staples',    72.50, 180.40),
(10, 'ZAE000057428', N'Capitec Bank',                    'Equity',          N'Financials',          83.20, 290.60),
(11, 'ZAE000013181', N'Old Mutual Ltd',                  'Equity',          N'Insurance',           69.80, 350.90),
(12, 'ZAE000245711', N'Prosus NV',                       'Equity',          N'Technology',          64.10, 110.20),
(13, 'ZAE000259701', N'Vodacom Group',                   'Equity',          N'Telecommunications',  74.60, 195.40),
(14, 'ZAE000006284', N'Nedbank Group',                   'Equity',          N'Financials',          77.30, 420.80),
(15, 'ZAE000084992', N'Discovery Ltd',                   'Equity',          N'Healthcare',          71.40, 160.50),
(16, 'ZAE000132577', N'Clicks Group',                    'Equity',          N'Consumer Staples',    80.10, 140.30),
(17, 'ZAE000025745', N'Sanlam Ltd',                      'Equity',          N'Insurance',           75.50, 310.70),
(18, 'ZAE000058517', N'Woolworths Holdings',             'Equity',          N'Consumer Discretionary', 67.90, 220.40),
(19, 'ZAE000043010', N'Remgro Ltd',                      'Equity',          N'Diversified Holding', 58.60, 280.90),
(20, 'ZAE000200457', N'Sibanye Stillwater',              'Equity',          N'Mining',              38.20, 1120.50),

-- Government Bonds / Fixed Income (10 assets)
(21, 'ZAG000163442', N'RSA Government Bond R2030',       'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(22, 'ZAG000177003', N'RSA Government Bond R2035',       'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(23, 'ZAG000190105', N'RSA Government Bond R2040',       'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(24, 'ZAG000201208', N'RSA Government Bond R2048',       'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(25, 'ZAG000215301', N'RSA Inflation-Linked Bond I2025', 'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(26, 'ZAG000225404', N'RSA Inflation-Linked Bond I2038', 'Fixed Income',    N'Sovereign Debt',      95.00,   0.00),
(27, 'CORP_BOND_01', N'Eskom Corporate Bond 2028',       'Fixed Income',    N'State-Owned Entity',  28.50, 680.40),
(28, 'CORP_BOND_02', N'Transnet Corporate Bond 2030',    'Fixed Income',    N'State-Owned Entity',  35.10, 520.30),
(29, 'CORP_BOND_03', N'Standard Bank Senior Bond 2027',  'Fixed Income',    N'Corporate Credit',    82.00, 390.10),
(30, 'CORP_BOND_04', N'Nedbank Green Bond 2029',         'Fixed Income',    N'Green Finance',       88.50,  45.20),

-- Unlisted Private Equity & Infrastructure (15 assets)
(31, 'PE_ISIB_VNT1', N'Isibaya Eco Infrastructure Fund',     'Unlisted PE',  N'Renewable Energy',    88.00,  12.30),
(32, 'PE_RE_MALL01', N'Pan-African Retail Property Fund',     'Unlisted PE',  N'Real Estate',         54.20, 310.60),
(33, 'PE_INFRA_001', N'SA Toll Roads Concession',             'Unlisted PE',  N'Infrastructure',      62.40, 280.90),
(34, 'PE_INFRA_002', N'Gautrain Expansion Investment',        'Unlisted PE',  N'Infrastructure',      71.80, 145.20),
(35, 'PE_TECH_001',  N'Cape Innovation Tech Fund',            'Unlisted PE',  N'Technology',          76.30,  48.50),
(36, 'PE_AGRI_001',  N'Limpopo Agriprocessing Hub',           'Unlisted PE',  N'Agriculture',         69.50,  95.40),
(37, 'PE_HLTH_001',  N'National Healthcare PPP Fund',         'Unlisted PE',  N'Healthcare',          82.10,  35.80),
(38, 'PE_ENRG_001',  N'Karoo Solar Energy Portfolio',         'Unlisted PE',  N'Renewable Energy',    91.40,   8.20),
(39, 'PE_HOUS_001',  N'Social Housing Development Trust',     'Unlisted PE',  N'Real Estate',         73.60, 125.30),
(40, 'PE_WATER_001', N'SA Water Infrastructure Fund',         'Unlisted PE',  N'Infrastructure',      85.20,  22.10),
(41, 'PE_EDUC_001',  N'Eastern Cape Education Campus Fund',   'Unlisted PE',  N'Education',           79.80,  18.40),
(42, 'PE_PORT_001',  N'Durban Port Logistics Expansion',      'Unlisted PE',  N'Infrastructure',      66.90, 340.50),
(43, 'PE_MINE_001',  N'Junior Mining Exploration Trust',      'Unlisted PE',  N'Mining',              42.50, 780.60),
(44, 'PE_TELE_001',  N'Rural Broadband Connectivity Fund',    'Unlisted PE',  N'Telecommunications',  77.40,  55.20),
(45, 'PE_MANU_001',  N'Automotive Manufacturing SPV',         'Unlisted PE',  N'Manufacturing',       58.90, 410.80),

-- Property / REIT (5 assets)
(46, 'ZAE000250459', N'Growthpoint Properties',          'Property',        N'Real Estate',         65.40, 240.30),
(47, 'ZAE000092834', N'Redefine Properties',             'Property',        N'Real Estate',         61.80, 280.50),
(48, 'ZAE000287365', N'Vukile Property Fund',            'Property',        N'Real Estate',         59.20, 210.90),
(49, 'ZAE000156147', N'Fortress REIT Ltd',               'Property',        N'Real Estate',         56.70, 265.40),
(50, 'ZAE000198321', N'Attacq Ltd',                      'Property',        N'Real Estate',         63.10, 195.60);

-- ====================================================================================
-- STEP 7: SEED DIM_AUDITCATEGORY (Expanded from 4 to 10)
-- ====================================================================================
INSERT INTO dbo.Dim_AuditCategory VALUES
(1,  'Auditor-General',  N'Supply Chain Procurement Variance',              'High'),
(2,  'Auditor-General',  N'Material Misstatement in Asset Valuation',       'Critical'),
(3,  'Internal Audit',   N'IT User Access Certification Controls',          'Medium'),
(4,  'Internal Audit',   N'SLA Non-Adherence Breaches',                     'Low'),
(5,  'Auditor-General',  N'Unauthorized Expenditure Classification',        'Critical'),
(6,  'Auditor-General',  N'Investment Mandate Compliance Deviation',        'High'),
(7,  'Internal Audit',   N'Data Quality & Master Data Integrity',           'Medium'),
(8,  'Internal Audit',   N'Business Continuity Planning Gaps',              'High'),
(9,  'Auditor-General',  N'Fruitless & Wasteful Expenditure',               'Critical'),
(10, 'Internal Audit',   N'Conflict of Interest Declaration Monitoring',    'Medium');

-- ====================================================================================
-- STEP 8: SEED DIM_REGULATORYBODY (Keep 3, already sufficient)
-- ====================================================================================
INSERT INTO dbo.Dim_RegulatoryBody VALUES
(1, N'Financial Sector Conduct Authority (FSCA)',  'Quarterly'),
(2, N'National Treasury',                          'Monthly'),
(3, N'South African Reserve Bank (SARB)',           'Bi-Annually');

-- ====================================================================================
-- STEP 9: SEED DIM_BEELEVEL (Standard B-BBEE levels, unchanged)
-- ====================================================================================
INSERT INTO dbo.Dim_BEELevel VALUES
(1, 1, 135.00), (2, 2, 125.00), (3, 3, 110.00), (4, 4, 100.00),
(5, 5, 80.00),  (6, 6, 60.00),  (7, 7, 50.00),  (8, 8, 10.00);

-- ====================================================================================
-- STEP 10: CREATE DIM_DYNAMICMETRICCONTROLS (Disconnected slicer table)
-- This table is referenced by the SWITCH-based measure for executive dashboard
-- ====================================================================================
IF OBJECT_ID('dbo.Dim_DynamicMetricControls', 'U') IS NOT NULL 
    DROP TABLE dbo.Dim_DynamicMetricControls;

CREATE TABLE dbo.Dim_DynamicMetricControls (
    MetricKey INT PRIMARY KEY,
    MetricName NVARCHAR(50) NOT NULL,
    MetricDisplayOrder INT NOT NULL
);

INSERT INTO dbo.Dim_DynamicMetricControls VALUES
(1, N'Total AUM',       1),
(2, N'YTD Return',      2),
(3, N'PFMA Variances',  3),
(4, N'Tracking Error',  4),
(5, N'Sharpe Ratio',    5);

-- ====================================================================================
-- STEP 11: REGENERATE FACT TABLE DATA (5,000 rows each with improved distributions)
-- ====================================================================================
DECLARE @VolumeTarget INT = 5000;

-- Build deterministic seed table
IF OBJECT_ID('tempdb..#Seeds') IS NOT NULL DROP TABLE #Seeds;

CREATE TABLE #Seeds (
    RowID INT PRIMARY KEY,
    BaseDateKey INT NOT NULL,
    SettleDateKey INT NOT NULL,
    AuditTargetDateKey INT NOT NULL,
    AuditResolvedDateKey INT NULL,
    ProjectActualDateKey INT NULL,
    ClosedDateKey INT NULL,
    DivKey INT NOT NULL,
    EmpKey INT NOT NULL,
    FndKey INT NOT NULL,
    AstKey INT NOT NULL,
    AstKeyListed INT NOT NULL,       -- Constrained to listed equities (1-20)
    AstKeyUnlisted INT NOT NULL,     -- Constrained to unlisted PE (31-45)
    AudKey INT NOT NULL,
    BeeKey INT NOT NULL,
    Seed INT NOT NULL
);

;WITH TallyEngine(RowID) AS (
    SELECT TOP (@VolumeTarget) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_columns c1 CROSS JOIN sys.all_columns c2
),
RawSeeds AS (
    SELECT 
        RowID,
        -- Base date spread across 2021-01-01 to 2025-10-31 (~1765 days)
        DATEADD(DAY, RowID % 1765, CAST('2021-01-01' AS DATE)) AS BaseDate,
        (RowID % 10) + 1 AS DivKey,      -- 10 divisions
        (RowID % 403) + 1 AS EmpKey,      -- 403 employees
        (RowID % 6) + 1 AS FndKey,        -- 6 funds
        (RowID % 50) + 1 AS AstKey,       -- 50 assets (all)
        (RowID % 20) + 1 AS AstKeyListed, -- Listed equities only (1-20)
        (RowID % 15) + 31 AS AstKeyUnlisted, -- Unlisted PE only (31-45)
        (RowID % 10) + 1 AS AudKey,       -- 10 audit categories
        (RowID % 8) + 1 AS BeeKey,        -- 8 BEE levels
        ABS(CHECKSUM(NEWID())) AS Seed
    FROM TallyEngine
)
INSERT INTO #Seeds
SELECT 
    RowID,
    YEAR(BaseDate) * 10000 + MONTH(BaseDate) * 100 + DAY(BaseDate),
    -- Settlement: T+2
    YEAR(DATEADD(DAY, 2, BaseDate)) * 10000 + MONTH(DATEADD(DAY, 2, BaseDate)) * 100 + DAY(DATEADD(DAY, 2, BaseDate)),
    -- Audit target: +90 days (capped at 2025-12-31)
    CASE WHEN DATEADD(DAY, 90, BaseDate) > '2025-12-31' 
         THEN 20251231
         ELSE YEAR(DATEADD(DAY, 90, BaseDate)) * 10000 + MONTH(DATEADD(DAY, 90, BaseDate)) * 100 + DAY(DATEADD(DAY, 90, BaseDate))
    END,
    -- Audit resolution: ~60% resolved within 80 days
    CASE WHEN RowID % 5 < 3 THEN 
        CASE WHEN DATEADD(DAY, RowID % 80, BaseDate) > '2025-12-31'
             THEN 20251231
             ELSE YEAR(DATEADD(DAY, RowID % 80, BaseDate)) * 10000 + MONTH(DATEADD(DAY, RowID % 80, BaseDate)) * 100 + DAY(DATEADD(DAY, RowID % 80, BaseDate))
        END
    ELSE NULL END,
    -- Project actual date: ~80% completed
    CASE WHEN RowID % 5 <> 0 THEN 
        CASE WHEN DATEADD(DAY, (RowID % 10) + 1, BaseDate) > '2025-12-31'
             THEN 20251231
             ELSE YEAR(DATEADD(DAY, (RowID % 10) + 1, BaseDate)) * 10000 + MONTH(DATEADD(DAY, (RowID % 10) + 1, BaseDate)) * 100 + DAY(DATEADD(DAY, (RowID % 10) + 1, BaseDate))
        END
    ELSE NULL END,
    -- Closed date for helpdesk: ~93% closed same day, 7% still open
    CASE WHEN RowID % 15 <> 0 THEN 
        YEAR(BaseDate) * 10000 + MONTH(BaseDate) * 100 + DAY(BaseDate)
    ELSE NULL END,
    DivKey, EmpKey, FndKey, AstKey, AstKeyListed, AstKeyUnlisted, AudKey, BeeKey, Seed
FROM RawSeeds;

-- ------------------------------------------------------------------------------------
-- FACT 1: Fact_FinancialTransactions
-- Realistic budget variance ±15%, 3% PFMA non-compliance rate
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_FinancialTransactions (DateKey, DivisionKey, AccountCode, ActualAmount, BudgetAmount, PFMA_Status_Code)
SELECT 
    BaseDateKey, DivKey,
    520000 + (RowID % 15),
    -- Actual amounts with exponential-like distribution: R10k-R500k
    ROUND(10000 + CAST(Seed % 490000 AS DECIMAL(18,2)) + (Seed % 100) * 0.45, 2),
    -- Budget = Actual * (0.85 to 1.15) — controlled variance
    ROUND((10000 + CAST(Seed % 490000 AS DECIMAL(18,2)) + (Seed % 100) * 0.45) 
          * (0.85 + CAST(Seed % 31 AS DECIMAL(5,2)) / 100.0), 2),
    -- PFMA status: 97% compliant, 2% irregular, 1% fruitless
    CASE 
        WHEN Seed % 100 >= 99 THEN 2  -- Fruitless & Wasteful
        WHEN Seed % 100 >= 97 THEN 1  -- Irregular
        ELSE 0                         -- Fully Compliant
    END
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 2: Fact_HREvents
-- Snapshot-based with hire/exit events creating realistic turnover
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_HREvents (DateKey, EmployeeKey, DivisionKey, EventTypeName, TrainingSpend)
SELECT 
    BaseDateKey, EmpKey, DivKey,
    CASE 
        WHEN RowID % 50 = 0  THEN 'Hire'             -- 2% hire events
        WHEN RowID % 60 = 0  THEN 'Exit'             -- ~1.7% exit events
        WHEN RowID % 25 = 0  THEN 'Promotion'        -- 4% promotions
        ELSE 'Active Snapshot'                        -- ~92% active snapshots
    END,
    -- Training spend: ~15% of records have training activity
    CASE WHEN RowID % 7 = 0 THEN ROUND(1500.00 + CAST(Seed % 15000 AS DECIMAL(18,2)), 2) 
         ELSE 0.00 END
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 3: Fact_TradeSettlements
-- Trade execution with realistic brokerage fees and settlement failure rates
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_TradeSettlements (ExecutionDateKey, SettlementDateKey, AssetKey, FundKey, BEELevelKey, TradeValue, BrokerageFee, SettlementStatus)
SELECT 
    BaseDateKey, SettleDateKey,
    AstKeyListed,  -- Only listed assets trade on exchange
    FndKey, BeeKey,
    -- Trade values: R50k to R50M (heavy-tailed distribution)
    ROUND(50000 + CAST(Seed % 50000000 AS DECIMAL(18,2)), 2),
    -- Brokerage: 12-18 bps
    ROUND((50000 + CAST(Seed % 50000000 AS DECIMAL(18,2))) * (0.0012 + (Seed % 7) * 0.00001), 2),
    -- Settlement failure: ~0.8% failure rate (realistic for SA market)
    CASE WHEN RowID % 125 = 0 THEN 'Failed' ELSE 'Settled' END
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 4: Fact_AuditFindings
-- Aging distribution: mix of quickly resolved and long-outstanding findings
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_AuditFindings (RaisedDateKey, TargetDateKey, ActualResolutionDateKey, AuditCategoryKey, DivisionKey, SeverityWeight, IsClosed)
SELECT 
    BaseDateKey, AuditTargetDateKey, AuditResolvedDateKey,
    AudKey, DivKey,
    -- Severity: 1-5, weighted toward lower severity
    CASE 
        WHEN Seed % 100 < 5  THEN 5  -- 5% Critical
        WHEN Seed % 100 < 15 THEN 4  -- 10% High
        WHEN Seed % 100 < 40 THEN 3  -- 25% Medium
        WHEN Seed % 100 < 70 THEN 2  -- 30% Low
        ELSE 1                        -- 30% Informational
    END,
    CASE WHEN AuditResolvedDateKey IS NOT NULL THEN 1 ELSE 0 END
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 5: Fact_ProjectMilestones
-- IT project tracking with realistic project names
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_ProjectMilestones (PlannedDateKey, ActualDateKey, ProjectKey, MilestoneName, Weight, [Status])
SELECT 
    BaseDateKey, ProjectActualDateKey,
    (RowID % 12) + 101,  -- 12 distinct projects
    CASE (RowID % 12)
        WHEN 0  THEN N'Microsoft Fabric Platform Migration'
        WHEN 1  THEN N'Bloomberg Terminal Integration'
        WHEN 2  THEN N'ERP System Upgrade (SAP S/4HANA)'
        WHEN 3  THEN N'Data Quality Framework Implementation'
        WHEN 4  THEN N'Power BI Enterprise Analytics Rollout'
        WHEN 5  THEN N'Cybersecurity Maturity Assessment'
        WHEN 6  THEN N'PAM System Modernization'
        WHEN 7  THEN N'Cloud Disaster Recovery Setup'
        WHEN 8  THEN N'Employee Self-Service Portal'
        WHEN 9  THEN N'Regulatory Reporting Automation'
        WHEN 10 THEN N'Network Infrastructure Refresh'
        ELSE N'Document Management System Migration'
    END + N' - Phase ' + CAST((RowID % 4) + 1 AS NVARCHAR(2)),
    ROUND(25.00, 2),
    CASE 
        WHEN ProjectActualDateKey IS NULL THEN 'Delayed'
        WHEN RowID % 20 = 0 THEN 'In Progress'
        ELSE 'Completed'
    END
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 6: Fact_PortfolioReturns
-- Daily returns with realistic basis point distributions for listed assets
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_PortfolioReturns (DateKey, AssetKey, FundKey, DailyReturn, DailyBenchmarkReturn, MarketValue)
SELECT 
    BaseDateKey, AstKeyListed, FndKey,
    -- Daily returns: -2% to +2% with slight positive bias (mean ~+0.03%)
    CAST(((Seed % 400) - 197) AS DECIMAL(18,6)) / 10000.000000,
    -- Benchmark: similar range but independent
    CAST(((ABS(CHECKSUM(NEWID())) % 380) - 188) AS DECIMAL(18,6)) / 10000.000000,
    -- Market values: R10M to R1B per position
    ROUND(10000000.00 + CAST(Seed % 990000000 AS DECIMAL(18,2)), 2)
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 7: Fact_UnlistedInvestments
-- PE cash flows: drawdowns, distributions, and valuations for unlisted assets
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_UnlistedInvestments (DateKey, AssetKey, FundKey, TransactionType, CashFlowAmount, NetAssetValue)
SELECT 
    BaseDateKey, AstKeyUnlisted, FndKey,
    CASE 
        WHEN RowID % 3 = 0 THEN 'Drawdown'       -- Capital calls (negative cash flow)
        WHEN RowID % 3 = 1 THEN 'Distribution'    -- Returns to investors
        ELSE 'Valuation'                           -- NAV snapshots
    END,
    -- Cash flows: R100k to R25M
    CASE 
        WHEN RowID % 3 = 0 THEN -1 * ROUND(100000 + CAST(Seed % 25000000 AS DECIMAL(18,2)), 2)  -- Drawdowns negative
        WHEN RowID % 3 = 1 THEN ROUND(100000 + CAST(Seed % 20000000 AS DECIMAL(18,2)), 2)       -- Distributions positive
        ELSE 0  -- Valuations have no cash flow
    END,
    -- NAV: R50M to R500M
    ROUND(50000000 + CAST(Seed % 450000000 AS DECIMAL(18,2)), 2)
FROM #Seeds;

-- ------------------------------------------------------------------------------------
-- FACT 8: Fact_HelpdeskTickets
-- IT support tickets with SLA tracking
-- ------------------------------------------------------------------------------------
INSERT INTO dbo.Fact_HelpdeskTickets (CreatedDateKey, ClosedDateKey, EmployeeKey, PriorityCode, ResolutionDurationMinutes, SLA_Met)
SELECT 
    BaseDateKey,
    ClosedDateKey,
    EmpKey,
    -- Priority: 1=Critical(5%), 2=High(15%), 3=Medium(50%), 4=Low(30%)
    CASE 
        WHEN Seed % 100 < 5  THEN 1
        WHEN Seed % 100 < 20 THEN 2
        WHEN Seed % 100 < 70 THEN 3
        ELSE 4
    END,
    -- Resolution duration: 15 min to 8 hours (480 min), NULL if still open
    CASE WHEN ClosedDateKey IS NOT NULL 
         THEN 15 + (Seed % 466) 
         ELSE NULL END,
    -- SLA met: depends on priority and resolution time
    CASE 
        WHEN ClosedDateKey IS NULL THEN 0  -- Open tickets = SLA not met
        WHEN (15 + (Seed % 466)) < 240 THEN 1  -- Resolved under 4 hours = SLA met
        ELSE 0
    END
FROM #Seeds;

-- Clean up
IF OBJECT_ID('tempdb..#Seeds') IS NOT NULL DROP TABLE #Seeds;

-- ====================================================================================
-- STEP 12: VALIDATION CHECKPOINT
-- ====================================================================================
SELECT '=== DIMENSION TABLE COUNTS ===' AS [Section], '' AS [Table], 0 AS [Rows]
UNION ALL SELECT '', 'Dim_Date', COUNT(*) FROM dbo.Dim_Date
UNION ALL SELECT '', 'Dim_Division', COUNT(*) FROM dbo.Dim_Division
UNION ALL SELECT '', 'Dim_Employee', COUNT(*) FROM dbo.Dim_Employee
UNION ALL SELECT '', 'Dim_Fund', COUNT(*) FROM dbo.Dim_Fund
UNION ALL SELECT '', 'Dim_InvestmentAsset', COUNT(*) FROM dbo.Dim_InvestmentAsset
UNION ALL SELECT '', 'Dim_AuditCategory', COUNT(*) FROM dbo.Dim_AuditCategory
UNION ALL SELECT '', 'Dim_RegulatoryBody', COUNT(*) FROM dbo.Dim_RegulatoryBody
UNION ALL SELECT '', 'Dim_BEELevel', COUNT(*) FROM dbo.Dim_BEELevel
UNION ALL SELECT '', 'Dim_DynamicMetricControls', COUNT(*) FROM dbo.Dim_DynamicMetricControls
UNION ALL SELECT '=== FACT TABLE COUNTS ===', '', 0
UNION ALL SELECT '', 'Fact_FinancialTransactions', COUNT(*) FROM dbo.Fact_FinancialTransactions
UNION ALL SELECT '', 'Fact_HREvents', COUNT(*) FROM dbo.Fact_HREvents
UNION ALL SELECT '', 'Fact_TradeSettlements', COUNT(*) FROM dbo.Fact_TradeSettlements
UNION ALL SELECT '', 'Fact_AuditFindings', COUNT(*) FROM dbo.Fact_AuditFindings
UNION ALL SELECT '', 'Fact_ProjectMilestones', COUNT(*) FROM dbo.Fact_ProjectMilestones
UNION ALL SELECT '', 'Fact_PortfolioReturns', COUNT(*) FROM dbo.Fact_PortfolioReturns
UNION ALL SELECT '', 'Fact_UnlistedInvestments', COUNT(*) FROM dbo.Fact_UnlistedInvestments
UNION ALL SELECT '', 'Fact_HelpdeskTickets', COUNT(*) FROM dbo.Fact_HelpdeskTickets;

-- Demographic distribution check for EE reporting
SELECT 
    'Employee Demographics' AS [Report],
    EthnicGroup,
    Gender,
    COUNT(*) AS [Count],
    CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.Dim_Employee), 1) AS DECIMAL(5,1)) AS [Percent]
FROM dbo.Dim_Employee
GROUP BY EthnicGroup, Gender
ORDER BY EthnicGroup, Gender;

-- Occupational level distribution
SELECT 
    'Occupational Levels' AS [Report],
    OccupationalLevel,
    COUNT(*) AS [Count],
    SUM(CASE WHEN IsHDI = 1 THEN 1 ELSE 0 END) AS [HDI_Count],
    CAST(ROUND(SUM(CASE WHEN IsHDI = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS DECIMAL(5,1)) AS [HDI_Percent]
FROM dbo.Dim_Employee
GROUP BY OccupationalLevel
ORDER BY 
    CASE OccupationalLevel 
        WHEN 'Top Management' THEN 1
        WHEN 'Senior Management' THEN 2
        WHEN 'Middle Management' THEN 3
        WHEN 'Professional Specialist' THEN 4
        WHEN 'Skilled Technical' THEN 5
        WHEN 'Semi-Skilled' THEN 6
        WHEN 'Unskilled' THEN 7
    END;

PRINT 'Expanded seed data generation complete.';
