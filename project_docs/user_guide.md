# PIC Sovereign Portfolio Analytics — End-User Quick Reference Guide

Welcome to the PIC Sovereign Portfolio Analytics Dashboard. This guide provides step-by-step instructions, visual interpretation frameworks, and troubleshooting FAQs for each of the 9 core business reporting pages.

---

## Global Navigation & Cascading Filters

Every page features a standard top-bar header designed to cascade and synchronize across the report:
1. **Date Range Slicer**: Limits visual elements to the selected date boundaries. Defaults to the last 12 months.
2. **Division Dropdown**: Filters departments and cost centers. *Note: Restricted by Row-Level Security (RLS) for division heads.*
3. **Fund Dropdown**: Filters investment holdings by specific mandates (e.g., GEPF, UIF, Compensation Commissioner Fund).
4. **Reset Filters Button (Icon)**: Clears all custom slicers back to default "Select All" states.
5. **Metric Definitions Tooltip**: Hovering over complex metric titles or charts displays a pop-up showing calculation formulas and business definitions.

---

## 1. Executive Overview

### Visual Interpretation Framework
* **What it measures**: Provides a consolidated strategic performance summary of total Assets Under Management (AUM), daily returns, compliance violations, and stockbroker BEE transformation levels.
* **Key Threshold Triggers**:
  * **AUM Variance**: Highlighting benchmark deviations in basis points (bps).
  * **PFMA Violations**: A count of >0 irregular expenditure events will trigger a red warning badge.

### Frequently Asked Questions (FAQ)
* **Q: How do I change the metric shown on the division comparison chart?**
  * **A**: Use the **Dynamic Metric Slicer** on the right side of the dashboard. Toggling options (e.g., "Total AUM", "YTD Return", "PFMA Variances") updates the division chart dynamically without requiring a separate page.
* **Q: Why are there discrepancies in totals across funds?**
  * **A**: Ensure that you have not applied active filters on specific divisions that do not hold assets. Asset allocations are primarily tied to specific funds rather than administrative divisions.

---

## 2. Finance & Budget Control

### Visual Interpretation Framework
* **What it measures**: Monitors operational expenditure (Opex) against approved national treasury budgets, tracking variances and compliance with the Public Finance Management Act (PFMA).
* **Key Threshold Triggers**:
  * **Budget Overruns**: Variance % exceeding **0.0%** triggers a **Red Alert** badge. Under-budget variance is shown in **Green**.
  * **PFMA Status**: Any transaction with a `PFMA_Status_Code` of 1 (Irregular) or 2 (Fruitless/Wasteful) is counted and highlighted in **Red** under unauthorized spend.

### Frequently Asked Questions (FAQ)
* **Q: How do I drill down to individual transactions?**
  * **A**: In the bottom **Divisional Cost Center & Expense Matrix**, click the `+` icon next to a Division Name to expand by Expense Category, and right-click to drill through to the transaction ledger level.
* **Q: Why does the Cost-to-Income ratio show blank for some administrative divisions?**
  * **A**: Administrative divisions (e.g., IT, HR) do not generate investment income. The cost-to-income ratio is only evaluated for divisions managing revenue-generating assets.

---

## 3. Human Capital & Employment Equity

### Visual Interpretation Framework
* **What it measures**: Tracks organizational headcount, turnover rates, B-BBEE skills development spend, and alignment with national Employment Equity (EE) targets.
* **Key Threshold Triggers**:
  * **EE Alignment**: Under-representation vs. Department of Employment & Labour (DoEL) Economically Active Population (EAP) targets by more than **5.0%** triggers an **Amber Warning**.
  * **Annualized Turnover**: Turnover rates exceeding **8.0%** are highlighted in **Red** as a retention warning.

### Frequently Asked Questions (FAQ)
* **Q: Why can't I see the Salary Amount or Ethnic Group details?**
  * **A**: Access is restricted based on your role. Object-Level Security (OLS) hides the Salary column from Analysts, Auditors, and External Managers, and masks the Ethnic Group column to protect personal privacy under POPIA regulations.
* **Q: Why does summing headcount across months give a huge number?**
  * **A**: Headcount is a semi-additive snapshot. The dashboard uses the `Active_Staff_Headcount` measure, which automatically filters on the maximum date in the active context, preventing incorrect additive summing.

---

## 4. Governance & Audit Tracker

### Visual Interpretation Framework
* **What it measures**: Tracks open audit findings (internal and Auditor-General), resolution aging, board committee attendance, and regulatory submission cycles.
* **Key Threshold Triggers**:
  * **Open Audit Findings**: Critical findings outstanding for **>30 days** or Major findings outstanding for **>90 days** are highlighted in **Red** as SLA breaches.
  * **Regulatory Submissions**: Submissions with **<5 days** remaining until the deadline trigger an **Amber Warning** (RAG status).

### Frequently Asked Questions (FAQ)
* **Q: What is the risk severity weight?**
  * **A**: Severity weight is a scale from 1 (minor administrative issue) to 10 (critical financial risk). It is used to prioritize resources and calculate weighted days-to-resolve.
* **Q: How do I filter by Auditor-General findings only?**
  * **A**: Use the **Audit Source** category selector in the slicer panel to toggle between "Auditor-General" and "Internal Audit".

---

## 5. Investment Operations

### Visual Interpretation Framework
* **What it measures**: Monitors trade settlement lifecycles, settlement failure rates, mandate compliance, and brokerage commission allocations.
* **Key Threshold Triggers**:
  * **Settlement Failure**: Trade settlement failure rates exceeding **0.50%** trigger a **Red Warning**.
  * **Mandate Breaches**: Any mandate breach count **>0** is highlighted in **Red** and triggers an email alert sequence.

### Frequently Asked Questions (FAQ)
* **Q: How is the settlement lag evaluated?**
  * **A**: Hovering over the trade table activates a tooltip that calculates the date difference between `ExecutionDateKey` and `SettlementDateKey` utilizing the `USERELATIONSHIP` DAX pattern.
* **Q: What determines a mandate breach?**
  * **A**: A mandate breach is flagged when a fund's daily return deviates from its benchmark return by more than 200 basis points (2.0%).

---

## 6. Transformation & ESG Dashboard

### Visual Interpretation Framework
* **What it measures**: Evaluates the ESG integration profiles of investee companies and compiles the PIC's scorecard points across key B-BBEE pillars.
* **Key Threshold Triggers**:
  * **ESG Rating**: Average ESG ratings below **6.0 / 10** trigger a **Red Alert** badge, indicating low sustainability integration.
  * **Carbon Intensity**: Assets with carbon intensity exceeding **250 tCO2e/R-m** trigger an **Amber Warning** on carbon footprint maps.

### Frequently Asked Questions (FAQ)
* **Q: How is the overall portfolio ESG score calculated?**
  * **A**: It is a weighted average calculation. The ESG score of each investee company is multiplied by its market value weighting in the portfolio, ensuring that larger investments have a proportionate impact on the score.
* **Q: What does the BEE Recognition Level represent in the table?**
  * **A**: It represents the verified procurement recognition percentage of the investee company (Level 1 contributor = 135% recognition).

---

## 7. Listed Portfolio Risk Metrics

### Visual Interpretation Framework
* **What it measures**: Delivers quantitative risk metrics including Sharpe Ratio, Tracking Error, Value at Risk (VaR), and Information Ratio for public equity and bond portfolios.
* **Key Threshold Triggers**:
  * **Tracking Error**: An annualized tracking error exceeding **2.5%** triggers a **Red Warning**, indicating significant active risk.
  * **Sharpe Ratio**: A Sharpe ratio below **1.0** indicates inefficient risk-adjusted performance and is highlighted in **Amber**.

### Frequently Asked Questions (FAQ)
* **Q: What does a 95% 1-Day VaR of -1.42% mean?**
  * **A**: It means there is a 95% confidence that the portfolio will not lose more than 1.42% of its market value in a single trading day under normal market conditions.
* **Q: Why is the benchmark comparison line chart blank for unlisted assets?**
  * **A**: The listed risk page is designed specifically for public market securities. Unlisted assets do not have daily public market benchmark indices and are monitored on Page 8.

---

## 8. Unlisted & Private Credit Performance

### Visual Interpretation Framework
* **What it measures**: Tracks long-horizon private equity investments, infrastructure deals, and private credit allocations by fund and vintage year.
* **Key Threshold Triggers**:
  * **IRR Target**: Annualized IRR below **8.0%** (mandated hurdle rate) is highlighted in **Amber**.
  * **DPI Target**: A Distributed to Paid-in Capital (DPI) ratio of **<0.5x** for vintage years older than 5 years triggers a **Red Warning**, indicating slow cash distributions.

### Frequently Asked Questions (FAQ)
* **Q: Why is the IRR blank or negative for recent investment vintages?**
  * **A**: This is due to the **J-Curve effect**. In the early years of a private equity investment (usually vintages <3 years), capital is called (drawdown) and fees are paid, but distributions have not yet commenced, resulting in negative or uncomputable IRR.
* **Q: What is the difference between MOIC and DPI?**
  * **A**: MOIC measures *total value* (cash distributed plus remaining net asset value) relative to paid-in capital, while DPI measures *cash returned* (actual distributions) relative to paid-in capital.

---

## 9. IT & Project Delivery

### Visual Interpretation Framework
* **What it measures**: Monitors core IT investment system uptimes (e.g., Bloomberg, PAM), ServiceNow ticket resolution SLA compliance, PMO project milestones, and corporate data quality.
* **Key Threshold Triggers**:
  * **System Uptime**: Core system availability dropping below **99.95%** triggers a **Red Warning** card.
  * **Data Quality Index**: A composite index score below **95.0%** triggers an **Amber Warning**, signaling completeness issues.

### Frequently Asked Questions (FAQ)
* **Q: How is the System Availability calculated?**
  * **A**: It subtracts elapsed downtime minutes of Priority 1 (critical) ServiceNow tickets from total minutes in the calendar period, giving a continuous availability index.
* **Q: What is the Data Quality Index composed of?**
  * **A**: It is a composite score evaluating financial transaction completeness (correct PFMA codes), trade settlement status validation, and helpdesk SLA logging accuracy.
