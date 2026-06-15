# PIC Portfolio Analytics — Enterprise Measure Catalogue

This document compiles the complete catalogue of calculated measures in the PIC Sovereign Portfolio Analytics semantic model. All measures are stored inside the `Dim_AuditCategory` table for organizational grouping, but they interact with tables across the star schema.

---

## Measure Catalogue Registry

| Calculated Measure Name | Target Table | Business Calculation Purpose | Target UI Page |
| :--- | :--- | :--- | :--- |
| **Total_AUM_ZAR** | Fact_PortfolioReturns | Calculates total Assets Under Management by summing the latest asset market values. | Executive Overview, Listed Risk, Unlisted PE |
| **Weighted_Portfolio_Return_Percent** | Fact_PortfolioReturns | Computes the weighted average return of the portfolio based on asset market values. | Executive Overview, Listed Risk |
| **Weighted_Benchmark_Return_Percent** | Fact_PortfolioReturns | Computes the weighted average return of the mandated benchmarks based on asset market values. | Executive Overview, Listed Risk |
| **Portfolio_vs_Benchmark_Variance_Bps** | Fact_PortfolioReturns | Calculates the active return variance in Basis Points (bps) against weighted benchmarks. | Executive Overview, Listed Risk |
| **Selected_Executive_Metric_Value** | Dim_DynamicMetricControls | Evaluates the dynamic metric slicer selection to swap card and trend visuals. | Executive Overview (Dynamic Visuals) |
| **PFMA_Irregular_Expenditure_Counter** | Fact_FinancialTransactions | Counts the number of general ledger opex transactions flagged as non-compliant under PFMA. | Executive Overview, Finance Control |
| **Total Fund AUM Share** | Dim_Fund | Computes the percentage share of AUM that a specific fund mandate represents of total AUM. | Executive Overview, Listed Risk, Unlisted PE |
| **Budget_vs_Actual_Variance_Percent** | Fact_FinancialTransactions | Calculates the percentage variance between actual opex expenditures and approved budget. | Finance & Budget Control |
| **Opex_YoY_Variance_Percent** | Fact_FinancialTransactions | Evaluates the year-on-year shift in YTD operational expenditure against the prior year YTD. | Finance & Budget Control |
| **Rolling_12Month_Opex** | Fact_FinancialTransactions | Computes trailing 12-month operational spend, ignoring calendar year-end boundaries. | Finance & Budget Control |
| **Division_Expenditure_Share_Percent** | Fact_FinancialTransactions | Calculates the division opex share relative to total corporate filtered expenditure. | Finance & Budget Control |
| **Cost_to_Income_Ratio** | Fact_FinancialTransactions / Fact_PortfolioReturns | Evaluates divisional opex against a simulated management fee income (0.15% of AUM). | Finance & Budget Control |
| **Active_Staff_Headcount** | Fact_HREvents | Tracks active employee headcount using semi-additive monthly snapshot filtering. | Human Capital & EE |
| **Annualized_Turnover_Percent** | Fact_HREvents | Computes trailing annualized workforce attrition rate (exits / average headcount). | Human Capital & EE |
| **EE_Alignment_Score** | Dim_Employee | Measures the representation percentage of Historically Disadvantaged Individuals (HDI). | Human Capital & EE |
| **Skills_Development_Spend_Percent** | Fact_HREvents / Dim_Employee | Compares total training spend against total employee salary to track B-BBEE skills targets. | Human Capital & EE |
| **Open_Audit_Findings_Count** | Fact_AuditFindings | Counts the number of unresolved audit findings (AG and internal). | Governance & Audit Tracker |
| **Average_Days_to_Resolve** | Fact_AuditFindings | Computes average days elapsed between audit findings logging and actual closure. | Governance & Audit Tracker |
| **Regulatory_SLA_Compliance_Percent** | Fact_AuditFindings | Measures the percentage of audit findings resolved within targeted timelines. | Governance & Audit Tracker |
| **Trade_Settlement_Failure_Rate** | Fact_TradeSettlements | Counts failed trade settlements as a percentage of total executed trades. | Investment Operations |
| **BEE_Brokerage_Allocation_Percent** | Fact_TradeSettlements | Evaluates the percentage of brokerage fees allocated to stockbrokers with BEE Level 1. | Investment Operations |
| **Mandate_Breach_Count** | Fact_PortfolioReturns | Counts the instances where portfolio returns deviated from benchmarks by more than 2.0%. | Investment Operations |
| **Portfolio_Average_ESG_Score** | Fact_PortfolioReturns | Calculates the weighted average ESG score (0-10) of public holdings based on asset weights. | Transformation & ESG |
| **BBEE_Scorecard_Points** | Fact_TradeSettlements | Compiles weighted procurement points based on broker BEE recognition levels. | Transformation & ESG |
| **Sharpe_Ratio** | Fact_PortfolioReturns | Calculates risk-adjusted excess returns over the risk-free rate relative to standard deviation. | Listed Risk Metrics |
| **Portfolio_Tracking_Error_Percent** | Fact_PortfolioReturns | Measures active risk (annualized standard deviation of daily excess returns vs benchmark). | Listed Risk Metrics |
| **VaR_95_1Day** | Fact_PortfolioReturns | Estimates maximum potential loss over a 1-day horizon at a 95% confidence level. | Listed Risk Metrics |
| **Information_Ratio** | Fact_PortfolioReturns | Measures active return generated per unit of active risk (Excess Return / Tracking Error). | Listed Risk Metrics |
| **Private_Equity_IRR_Approximation** | Fact_UnlistedInvestments | Computes annualized internal rate of return for non-periodic unlisted PE cash flows (XIRR). | Unlisted & Private Credit |
| **MOIC** | Fact_UnlistedInvestments | Computes the Multiple on Invested Capital (NAV + Distributions / Paid-In Capital). | Unlisted & Private Credit |
| **DPI** | Fact_UnlistedInvestments | Measures Distributed to Paid-In Capital (Distributions / Paid-In Capital). | Unlisted & Private Credit |
| **System_Availability_Percent** | Fact_HelpdeskTickets | Calculates uptime percentage for core investment systems based on priority 1 downtime. | IT & Project Delivery |
| **Project_Milestone_Adherence_Rate** | Fact_ProjectMilestones | Counts completed milestones as a percentage of total milestones logged. | IT & Project Delivery |
| **Data_Quality_Index** | Fact_FinancialTransactions / Fact_TradeSettlements / Fact_HelpdeskTickets | Computes a composite data quality score from source completeness across core fact tables. | IT & Project Delivery |
| **Helpdesk_SLA_Resolution_Percent** | Fact_HelpdeskTickets | Counts tickets resolved within SLA target times as a percentage of total tickets. | IT & Project Delivery |

---

## DAX Formats & Logic Reference

### 1. Executive Overview Measures

#### Total_AUM_ZAR
```dax
Total_AUM_ZAR =
SUM(Fact_PortfolioReturns[MarketValue])
```
* **Format**: Currency `R#,0;-"R"#,0;"R"#,0`

#### Weighted_Portfolio_Return_Percent
```dax
Weighted_Portfolio_Return_Percent =
DIVIDE(
    SUMX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn] * Fact_PortfolioReturns[MarketValue]),
    [Total_AUM_ZAR],
    0
)
```
* **Format**: Percentage `0.00%`

#### Weighted_Benchmark_Return_Percent
```dax
Weighted_Benchmark_Return_Percent = 
DIVIDE(
    SUMX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyBenchmarkReturn] * Fact_PortfolioReturns[MarketValue]),
    [Total_AUM_ZAR],
    0
)
```
* **Format**: Percentage `0.00%`

#### Portfolio_vs_Benchmark_Variance_Bps
```dax
Portfolio_vs_Benchmark_Variance_Bps = 
VAR VariancePercent = [Weighted_Portfolio_Return_Percent] - [Weighted_Benchmark_Return_Percent]
RETURN
    VariancePercent * 10000
```
* **Format**: Decimal `0`

#### Selected_Executive_Metric_Value
```dax
Selected_Executive_Metric_Value =
VAR CurrentSelection = SELECTEDVALUE(Dim_DynamicMetricControls[MetricName], "Total AUM")
RETURN
	SWITCH(
		CurrentSelection,
		"Total AUM", [Total_AUM_ZAR],
		"YTD Return", [Weighted_Portfolio_Return_Percent],
		"PFMA Variances", [PFMA_Irregular_Expenditure_Counter],
		[Total_AUM_ZAR]
	)
```
* **Format**: General Decimal / Currency depending on selection.

#### PFMA_Irregular_Expenditure_Counter
```dax
PFMA_Irregular_Expenditure_Counter =
CALCULATE(
    COUNTROWS(Fact_FinancialTransactions),
    Fact_FinancialTransactions[PFMA_Status_Code] > 0
)
```
* **Format**: Whole Number `#,0`

#### Total Fund AUM Share
```dax
'Total Fund AUM Share' =
VAR CurrentFundAUM = [Total_AUM_ZAR]
VAR AllFundsAUM = CALCULATE([Total_AUM_ZAR], ALL(Dim_Fund))
RETURN
    DIVIDE(
        CurrentFundAUM,
        AllFundsAUM,
        0
    )
```
* **Format**: Percentage `0.00%`

---

### 2. Finance & Budget Control Measures

#### Budget_vs_Actual_Variance_Percent
```dax
Budget_vs_Actual_Variance_Percent =
DIVIDE(
    SUM(Fact_FinancialTransactions[ActualAmount]) - SUM(Fact_FinancialTransactions[BudgetAmount]),
    SUM(Fact_FinancialTransactions[BudgetAmount]),
    0
)
```
* **Format**: Percentage `0.00%`

#### Opex_YoY_Variance_Percent
```dax
Opex_YoY_Variance_Percent = 
VAR CurrentYTD = TOTALYTD(SUM(Fact_FinancialTransactions[ActualAmount]), Dim_Date[Date])
VAR PriorYTD = TOTALYTD(SUM(Fact_FinancialTransactions[ActualAmount]), DATEADD(Dim_Date[Date], -1, YEAR))
VAR VarianceValue = CurrentYTD - PriorYTD
RETURN
    DIVIDE(
        VarianceValue, 
        PriorYTD, 
        0
    )
```
* **Format**: Percentage `0.00%`

#### Rolling_12Month_Opex
```dax
Rolling_12Month_Opex = 
VAR EndDate = MAX(Dim_Date[Date])
VAR StartDate = EDATE(EndDate, -12) + 1
VAR CalculationPeriod = 
	FILTER(
		ALL(Dim_Date[Date]),
		Dim_Date[Date] >= StartDate && 
		Dim_Date[Date] <= EndDate
	)
RETURN
	CALCULATE(
		SUM(Fact_FinancialTransactions[ActualAmount]),
		CalculationPeriod
	)
```
* **Format**: Currency `R#,0;-"R"#,0`

#### Division_Expenditure_Share_Percent
```dax
Division_Expenditure_Share_Percent = 
VAR SelectedDivisionSpend = SUM(Fact_FinancialTransactions[ActualAmount])
VAR TotalCorporateSpend = 
	CALCULATE(
		SUM(Fact_FinancialTransactions[ActualAmount]),
		ALLSELECTED(Dim_Division)
	)
RETURN
	DIVIDE(
		SelectedDivisionSpend, 
		TotalCorporateSpend, 
		0
	)
```
* **Format**: Percentage `0.00%`

#### Cost_to_Income_Ratio
```dax
Cost_to_Income_Ratio =
VAR TotalIncome = SUMX(Fact_PortfolioReturns, Fact_PortfolioReturns[MarketValue] * 0.0015)
RETURN
	DIVIDE(
		SUM(Fact_FinancialTransactions[ActualAmount]),
		TotalIncome,
		0
	)
```
* **Format**: Percentage `0.00%`

---

### 3. Human Capital & Employment Equity Measures

#### Active_Staff_Headcount
```dax
Active_Staff_Headcount =
VAR MaxDateInContext = MAX(Dim_Date[Date])
RETURN
	CALCULATE(
		DISTINCTCOUNT(Fact_HREvents[EmployeeKey]),
		Fact_HREvents[EventTypeName] = "Active Snapshot",
		Dim_Date[Date] = MaxDateInContext
	)
```
* **Format**: Whole Number `#,0`

#### Annualized_Turnover_Percent
```dax
Annualized_Turnover_Percent =
VAR ExitCount = CALCULATE(COUNTROWS(Fact_HREvents), Fact_HREvents[EventTypeName] = "Exit")
VAR AvgHeadcount = AVERAGEX(VALUES(Dim_Date[DateKey]), [Active_Staff_Headcount])
RETURN
	DIVIDE(ExitCount, AvgHeadcount, 0)
```
* **Format**: Percentage `0.00%`

#### EE_Alignment_Score
```dax
EE_Alignment_Score =
VAR HDIHeadcount = CALCULATE([Active_Staff_Headcount], Dim_Employee[IsHDI] = TRUE)
VAR TotalHeadcount = [Active_Staff_Headcount]
RETURN
	DIVIDE(HDIHeadcount, TotalHeadcount, 0)
```
* **Format**: Percentage `0.00%`

#### Skills_Development_Spend_Percent
```dax
Skills_Development_Spend_Percent =
DIVIDE(
    SUM(Fact_HREvents[TrainingSpend]),
    SUM(Dim_Employee[SalaryAmount]),
    0
)
```
* **Format**: Percentage `0.00%`

---

### 4. Governance & Audit Tracker Measures

#### Open_Audit_Findings_Count
```dax
Open_Audit_Findings_Count =
CALCULATE(
    COUNTROWS(Fact_AuditFindings),
    Fact_AuditFindings[IsClosed] = FALSE
)
```
* **Format**: Whole Number `#,0`

#### Average_Days_to_Resolve
```dax
Average_Days_to_Resolve =
AVERAGEX(
    Fact_AuditFindings,
    IF(
        NOT(ISBLANK(Fact_AuditFindings[ActualResolutionDateKey])),
        DATEDIFF(
            RELATED(Dim_Date[Date]),
            LOOKUPVALUE(Dim_Date[Date], Dim_Date[DateKey], Fact_AuditFindings[ActualResolutionDateKey]),
            DAY
        )
    )
)
```
* **Format**: Decimal `0.0`

#### Regulatory_SLA_Compliance_Percent
```dax
Regulatory_SLA_Compliance_Percent = 
VAR CompliantFindings = 
    SUMX(
        Fact_AuditFindings,
        IF(
            Fact_AuditFindings[IsClosed] = TRUE,
            IF(Fact_AuditFindings[ActualResolutionDateKey] <= Fact_AuditFindings[TargetDateKey], 1, 0),
            IF(Fact_AuditFindings[TargetDateKey] >= 20251231, 1, 0)
        )
    )
RETURN 
    DIVIDE(CompliantFindings, COUNTROWS(Fact_AuditFindings), 0)
```
* **Format**: Percentage `0.00%`

---

### 5. Investment Operations Measures

#### Trade_Settlement_Failure_Rate
```dax
Trade_Settlement_Failure_Rate = 
DIVIDE(
    CALCULATE(COUNTROWS(Fact_TradeSettlements), Fact_TradeSettlements[SettlementStatus] = "Failed"),
    COUNTROWS(Fact_TradeSettlements)
)
```
* **Format**: Percentage `0.00%`

#### BEE_Brokerage_Allocation_Percent
```dax
BEE_Brokerage_Allocation_Percent =
DIVIDE(
    CALCULATE(SUM(Fact_TradeSettlements[BrokerageFee]), Dim_BEELevel[BEELevel] = 1),
    SUM(Fact_TradeSettlements[BrokerageFee]),
    0
)
```
* **Format**: Percentage `0.00%`

#### Mandate_Breach_Count
```dax
Mandate_Breach_Count =
CALCULATE(
    COUNTROWS(Fact_PortfolioReturns),
    ABS(Fact_PortfolioReturns[DailyReturn] - Fact_PortfolioReturns[DailyBenchmarkReturn]) > 0.02
)
```
* **Format**: Whole Number `#,0`

---

### 6. Transformation & ESG Measures

#### Portfolio_Average_ESG_Score
```dax
Portfolio_Average_ESG_Score =
DIVIDE(
    SUMX(Fact_PortfolioReturns, RELATED(Dim_InvestmentAsset[ESG_Score]) * Fact_PortfolioReturns[MarketValue]),
    [Total_AUM_ZAR],
    0
)
```
* **Format**: Decimal `0.0` (Scale 0-10)

#### BBEE_Scorecard_Points
```dax
BBEE_Scorecard_Points =
DIVIDE(
    SUMX(Fact_TradeSettlements, RELATED(Dim_BEELevel[RecognitionPercentage]) * Fact_TradeSettlements[TradeValue]),
    SUM(Fact_TradeSettlements[TradeValue]),
    0
)
```
* **Format**: Decimal `0.0`

---

### 7. Listed Portfolio Risk Metrics Measures

#### Sharpe_Ratio
```dax
Sharpe_Ratio =
VAR RiskFreeRate = DIVIDE(0.05, 252, 0)
VAR AvgExcessReturn = AVERAGEX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn] - RiskFreeRate)
VAR StdDevReturn = STDEVX.S(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn])
RETURN 
    DIVIDE(AvgExcessReturn, StdDevReturn, 0) * SQRT(252)
```
* **Format**: Decimal `0.00`

#### Portfolio_Tracking_Error_Percent
```dax
Portfolio_Tracking_Error_Percent =
VAR MeanExcessReturn = AVERAGEX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn] - Fact_PortfolioReturns[DailyBenchmarkReturn])
VAR ExcessReturnVarianceIter = SUMX(Fact_PortfolioReturns, POWER((Fact_PortfolioReturns[DailyReturn] - Fact_PortfolioReturns[DailyBenchmarkReturn]) - MeanExcessReturn, 2))
VAR TotalObservedDays = COUNTROWS(Fact_PortfolioReturns)
VAR DailyTrackingError = SQRT(DIVIDE(ExcessReturnVarianceIter, TotalObservedDays - 1, 0))
RETURN 
    DailyTrackingError * SQRT(252)
```
* **Format**: Percentage `0.00%`

#### VaR_95_1Day
```dax
VaR_95_1Day =
VAR MeanReturn = AVERAGEX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn])
VAR StdDevReturn = STDEVX.S(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn])
RETURN 
    -1 * (MeanReturn - 1.645 * StdDevReturn)
```
* **Format**: Percentage `0.00%`

#### Information_Ratio
```dax
Information_Ratio =
VAR ActiveReturn = AVERAGEX(Fact_PortfolioReturns, Fact_PortfolioReturns[DailyReturn] - Fact_PortfolioReturns[DailyBenchmarkReturn]) * 252
VAR TrackingError = [Portfolio_Tracking_Error_Percent]
RETURN 
    DIVIDE(ActiveReturn, TrackingError, 0)
```
* **Format**: Decimal `0.00`

---

### 8. Unlisted & Private Credit Measures

#### Private_Equity_IRR_Approximation
```dax
Private_Equity_IRR_Approximation =
VAR CashFlowTable = 
    SELECTCOLUMNS(
        Fact_UnlistedInvestments, 
        "CF_Date", RELATED(Dim_Date[Date]), 
        "CF_Amount", Fact_UnlistedInvestments[CashFlowAmount]
    )
RETURN 
    XIRR(CashFlowTable, [CF_Amount], [CF_Date])
```
* **Format**: Percentage `0.00%`

#### MOIC
```dax
MOIC =
VAR TotalDistributions = CALCULATE(SUM(Fact_UnlistedInvestments[CashFlowAmount]), Fact_UnlistedInvestments[TransactionType] = "Distribution")
VAR TotalDrawdowns = -1 * CALCULATE(SUM(Fact_UnlistedInvestments[CashFlowAmount]), Fact_UnlistedInvestments[TransactionType] = "Drawdown")
VAR CurrentNAV = CALCULATE(SUM(Fact_UnlistedInvestments[NetAssetValue]), Fact_UnlistedInvestments[TransactionType] = "Valuation")
RETURN 
    DIVIDE(TotalDistributions + CurrentNAV, TotalDrawdowns, 0)
```
* **Format**: Decimal `0.00x`

#### DPI
```dax
DPI =
VAR TotalDistributions = CALCULATE(SUM(Fact_UnlistedInvestments[CashFlowAmount]), Fact_UnlistedInvestments[TransactionType] = "Distribution")
VAR TotalDrawdowns = -1 * CALCULATE(SUM(Fact_UnlistedInvestments[CashFlowAmount]), Fact_UnlistedInvestments[TransactionType] = "Drawdown")
RETURN 
    DIVIDE(TotalDistributions, TotalDrawdowns, 0)
```
* **Format**: Decimal `0.00x`

---

### 9. IT & Project Delivery Measures

#### System_Availability_Percent
```dax
System_Availability_Percent =
VAR TotalDowntimeMinutes = CALCULATE(SUM(Fact_HelpdeskTickets[ResolutionDurationMinutes]), Fact_HelpdeskTickets[PriorityCode] = 1)
VAR TotalMinutesInPeriod = COUNTROWS(Dim_Date) * 1440
RETURN 
    1 - DIVIDE(TotalDowntimeMinutes, TotalMinutesInPeriod, 0)
```
* **Format**: Percentage `0.00%`

#### Project_Milestone_Adherence_Rate
```dax
Project_Milestone_Adherence_Rate = 
DIVIDE(
    CALCULATE(COUNTROWS(Fact_ProjectMilestones), Fact_ProjectMilestones[Status] = "Completed"), 
    COUNTROWS(Fact_ProjectMilestones), 
    0
)
```
* **Format**: Percentage `0.00%`

#### Data_Quality_Index
```dax
Data_Quality_Index = 
VAR FinancialCompliance = DIVIDE(CALCULATE(COUNTROWS(Fact_FinancialTransactions), Fact_FinancialTransactions[PFMA_Status_Code] = 0), COUNTROWS(Fact_FinancialTransactions), 0)
VAR TradeSettlementRate = 1 - [Trade_Settlement_Failure_Rate]
VAR SLACompliance = [Helpdesk_SLA_Resolution_Percent]
RETURN 
    DIVIDE(FinancialCompliance + TradeSettlementRate + SLACompliance, 3, 0)
```
* **Format**: Percentage `0.00%`

#### Helpdesk_SLA_Resolution_Percent
```dax
Helpdesk_SLA_Resolution_Percent =
DIVIDE(
    CALCULATE(COUNTROWS(Fact_HelpdeskTickets), Fact_HelpdeskTickets[SLA_Met] = TRUE), 
    COUNTROWS(Fact_HelpdeskTickets), 
    0
)
```
* **Format**: Percentage `0.00%`
