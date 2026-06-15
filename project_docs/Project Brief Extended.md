\#\# Persona  
Act as two experts collaborating:  
(1) A Principal Power BI Developer with 10+ years in asset management and   
    public sector BI, expert in DAX, Power Query, and Microsoft Fabric.  
(2) A portfolio strategist who coaches senior contractors on how to engineer   
    demonstration projects that convert recruiter reviews into placement offers.

\#\# Mission  
Produce a fully specced Power BI portfolio project engineered to secure a   
6-month contractor engagement at South Africa's Public Investment Corporation   
(PIC) — a sovereign asset manager overseeing \~R2.7 trillion AUM, governed   
under the PFMA, and subject to Auditor-General oversight and parliamentary   
accountability.

The portfolio must impress two audiences simultaneously:  
\- A non-technical HR recruiter: clean design, clear storytelling,   
  obvious relevance to PIC's mandate  
\- A technical hiring panel: architectural depth, DAX sophistication,   
  governance rigour, and performance discipline

\---

\#\# PHASE 1 — Report Architecture

Design a multi-page Power BI report. For each page specify:  
\- Page name and subtitle  
\- Business purpose (1 sentence)  
\- Primary KPIs displayed  
\- Recommended visual types  
\- DAX patterns used  
\- Which job description skill it demonstrates

\#\#\# Required Pages (minimum):  
1\. Executive Overview — KPI scorecard landing page  
2\. Finance & Budget Control — Opex variance, cost-to-income,   
   PFMA expenditure compliance  
3\. Human Capital & Employment Equity — Headcount, turnover,   
   EE targets vs. actuals, B-BBEE skills element  
4\. Governance & Audit Tracker — Internal audit findings, policy compliance,   
   board attendance, regulatory submissions  
5\. Investment Operations — Mandate compliance, trade settlement,   
   proxy voting, BEE brokerage, external manager reporting  
6\. Transformation & ESG Dashboard — B-BBEE scorecard, ESG integration,   
   developmental impact, HDI/gender representation  
7\. Listed Portfolio Risk Metrics — Sharpe Ratio, Tracking Error, VaR,   
   Total Return vs. benchmark  
8\. Unlisted & Private Credit Performance — IRR, MOIC, DPI by fund   
   and vintage year  
9\. IT & Project Delivery — System uptime, project milestone adherence,   
   data quality index, helpdesk SLA  
10\. Data Model & Methodology — Transparent schema view and measure   
    documentation (for technical evaluators)

\---

\#\# PHASE 2 — Data Model Specification

Design a star schema (or hybrid snowflake where justified). Specify:

\#\#\# Fact Tables (define columns, data types, grain):  
\- Fact\_FinancialTransactions  
\- Fact\_HREvents  
\- Fact\_TradeSettlements  
\- Fact\_AuditFindings  
\- Fact\_ProjectMilestones  
\- Fact\_PortfolioReturns (listed)  
\- Fact\_UnlistedInvestments  
\- Fact\_HelpdeskTickets

\#\#\# Dimension Tables:  
\- Dim\_Date (full time intelligence calendar table)  
\- Dim\_Division  
\- Dim\_Employee  
\- Dim\_Fund / Dim\_Client (GEPF, UIF, CC Fund)  
\- Dim\_InvestmentAsset  
\- Dim\_AuditCategory  
\- Dim\_RegulatoryBody  
\- Dim\_BEELevel

\#\#\# Relationships:  
\- Define all active/inactive relationships  
\- Flag any many-to-many relationships and resolution strategy  
\- Specify where bidirectional filtering is used (and justified)

\---

\#\# PHASE 3 — DAX Specification

For each report page, provide:  
\- Measure name  
\- Full DAX formula (properly formatted)  
\- Pattern used (e.g., CALCULATE \+ filter, DIVIDE for safe division,   
  time intelligence with DATEADD/SAMEPERIODLASTYEAR, RANKX, SUMX iterators)  
\- A comment explaining the business logic

\#\#\# Mandatory DAX Patterns to Include:  
\- YoY variance % (time intelligence)  
\- Rolling 12-month average  
\- % of total with dynamic denominator  
\- RLS-filtered measures (user-context dependent)  
\- IRR approximation using iterative DAX or placeholder with notes  
\- Tracking Error calculation (standard deviation of excess returns)  
\- Safe division pattern (DIVIDE with alternate result)  
\- SWITCH() for dynamic measure selection  
\- ALLSELECTED() for visual-level vs. report-level totals

\---

\#\# PHASE 4 — Power Query (M Language) Specification

Outline transformation logic for each major data source:  
\- Data cleansing steps (null handling, type enforcement)  
\- Custom M function for reusable transformation logic  
\- Query folding checkpoint annotation  
\- Incremental refresh policy definition   
  (RangeStart / RangeEnd parameters, partition strategy)  
\- One example of advanced M: list transformation or   
  record-level custom function

\---

\#\# PHASE 5 — Security Architecture

Specify a complete RLS \+ OLS implementation:

\#\#\# Row-Level Security:  
\- Define roles: Executive, Division Head, Analyst, Auditor, External Manager  
\- DAX filter expressions per role per table  
\- Dynamic RLS using USERNAME() / USERPRINCIPALNAME() against Dim\_Employee  
\- Test plan: how to validate RLS in Power BI Desktop and Service

\#\#\# Object-Level Security:  
\- Identify sensitive columns to restrict (e.g., individual salary,   
  personal EE data)  
\- Define which roles see which columns

\---

\#\# PHASE 6 — Deployment Pipeline Architecture

Design a three-stage pipeline:  
\- Dev → Test → Production workspace structure  
\- Dataset endorsement and certification strategy  
\- Scheduled refresh configuration (frequency per dataset)  
\- Power BI REST API use case: one example of automated admin task   
  (e.g., refresh trigger, user management)  
\- Git integration strategy: describe folder structure and   
  branching convention

\---

\#\# PHASE 7 — Performance Optimisation Checklist

Produce a checklist the candidate can apply and visibly reference:  
\- Column reduction strategy (remove unused columns at source)  
\- Cardinality reduction techniques  
\- Aggregations setup for large fact tables  
\- DAX Studio: specify which DMV queries to run to identify bottlenecks  
\- Tabular Editor: BPA (Best Practice Analyser) rules to apply  
\- Import vs. DirectQuery vs. Composite model decision matrix   
  for each fact table

\---

\#\# PHASE 8 — Documentation Package

Produce templates for:  
1\. Data Dictionary (table name, column, description, data type,   
   source, owner)  
2\. Measure Catalogue (measure name, table, formula, purpose,   
   page used on)  
3\. End-User Quick Reference Guide structure (1-page per report section)  
4\. Stakeholder Requirements Log template   
   (requirement, requestor, priority, status)

\---

\#\# Synthetic Data Generation Plan

Since real PIC data is unavailable, specify:  
\- Row volume per fact table (realistic for a \~400-person organisation   
  managing multiple funds)  
\- Value ranges and distributions for key fields   
  (e.g., budget variance ±15%, EE targets by level)  
\- Python or M script outline to generate the data  
\- Naming conventions: use realistic South African fund names,   
  division names, and regulatory references

\---

\#\# Design & UX Directives  
\- Colour palette: PIC navy (\#002B5C or similar), gold accent (\#C9A84C),   
  white canvas, grey secondary  
\- Typography: Segoe UI throughout; 14pt+ for KPI callouts  
\- Layout: F-pattern per page — KPI cards top row, trend visuals centre,   
  detail tables bottom  
\- Every page: slicers panel (date, division, fund), bookmark for   
  reset-filters, tooltip pages for metric definitions  
\- Accessibility: WCAG AA contrast ratios, colorblind-safe palette,   
  alt-text on all visuals  
\- Mobile layout: define which pages get a phone layout view

\---

\#\# Constraints  
\- Power BI Desktop (latest) \+ Power BI Service (Premium Per User assumed)  
\- Native visuals and approved AppSource visuals only  
\- No real or sensitive PIC data — synthetic only  
\- Performance target: \<3 second load per page on standard hardware  
\- All DAX must follow SQLBI formatting standards  
\- Deliverable must function as a standalone portfolio artifact:   
  self-explanatory without verbal narration  
