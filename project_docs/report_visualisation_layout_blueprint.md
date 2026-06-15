# PIC Corporate Sovereign Portfolio Analytics — Report Visualisation Layout Blueprint

> [!NOTE]
> This blueprint bridges the gap between the [PORTFOLIO ARCHITECTURE.md](file:///c:/Users/Dell/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/project_docs/PORTFOLIO%20ARCHITECTURE.md) requirements, the [TableRelationship Matrix.md](file:///c:/Users/Dell/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/project_docs/TableRelationship%20Matrix.md) data structures, the corporate style guidelines in [pic_theme.json](file:///c:/Users/Dell/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/PBI/pic_theme.json), and the pre-designed SVG background pattern [f_pattern_canvas.svg](file:///c:/Users/Dell/My%20Drive/Jobs/Deviare%20-%20Power%20BI%20Developer/analytics%20project/PBI/f_pattern_canvas.svg).

---

## 1. Visual Standards & Styling System

The report styling system is designed to convey the dual identity of the Public Investment Corporation (PIC): a highly sophisticated sovereign asset manager and a state-owned enterprise subject to strict public accountability.

### 1.1 Color Palette
*   **Primary Corporate Navy (`#002B5C`)**: Extracted from the `pic_theme.json`. It is the dominant color for headers, page titles, text boxes, tables, and high-level card metrics. It represents institutional strength and governance.
*   **Accent Corporate Gold (`#C9A84C`)**: The secondary branding color, used for highlight markers, focus borders, primary KPIs, targets, and positive metrics.
*   **Data Palette**: Sleek, harmonious slates and greens for data comparisons:
    *   `#2F3E46` — Primary comparison series (e.g., benchmark comparison)
    *   `#52796F` / `#84A98C` / `#CAD2C5` — Green gradients for performance tiers, target levels, and positive variance
    *   `#354F52` / `#1E293B` — Alternate comparison series
*   **Status & Severity Indicators**: Standardised RAG color tokens:
    *   **Amber Warning (`#D97706`)**: Used for moderate risk, budget variance warning, and pending status.
    *   **Red Alert (`#EF4444`)**: Used for mandate breaches, failed settlements, irregular expenditure, and critical audit findings.

### 1.2 Typography Hierarchy
All text elements in the report must follow this hierarchy, using fonts specified in the theme:
*   **Page Title**: `Outfit` (Bold, 20pt, White `#FFFFFF` or Light Gold `#F4E3B1`), placed inside the navy header band.
*   **Page Subtitle / Filter Status**: `Inter` (Regular, 10pt, Light Slate `#CBD5E1`), showing active slicer selection info.
*   **Visual Title**: `Outfit` (Bold, 12pt, Navy `#002B5C`), left-aligned, no background, 10px bottom margin.
*   **KPI Callout Value**: `Outfit` (Bold, 24pt, Navy `#002B5C` or Gold `#C9A84C`), centered or left-aligned depending on layout.
*   **KPI Category Label**: `Inter` (Regular, 9pt, Slate `#64748B`), all-caps or title case, centered or left-aligned.
*   **Data Labels / Table Text**: `Segoe UI` or `Inter` (Regular, 9pt, Dark Slate `#1E293B`).

---

## 2. Canvas Grid & Coordinate System

The background template `f_pattern_canvas.svg` acts as a static layout grid. To achieve a modern, high-performance report, **all Power BI visuals must have their background, border, and shadow properties disabled (set to 100% transparent)**. This leverages the pre-rendered SVG canvas cards for a glassmorphic/flat card effect without the performance overhead of Power BI rendering shadows.

```mermaid
rect -- canvas size 1280 x 720
-------------------------------------------------------------------------------------
| HEADER BAND: X: 0, Y: 0, W: 1280, H: 80                                           |
| (Page Title, Corporate Branding & Cascade Slicers: Date, Division, Fund)           |
|-----------------------------------------------------------------------------------|
| GOLD ACCENT STRIP: Y: 80, H: 4, W: 1280                                           |
|-----------------------------------------------------------------------------------|
| KPI CARD ROW: Y: 95, H: 100                                                       |
| [Card 1: W:285]      [Card 2: W:285]      [Card 3: W:285]      [Card 4: W:285]    |
| (Navy Accent)        (Navy Accent)        (Gold Accent)        (Gold Accent)      |
|-----------------------------------------------------------------------------------|
| MIDDLE VISUALS PANELS: Y: 210, H: 240                                             |
| [Left Visual Panel: W: 600]               [Right Visual Panel: W: 600]            |
| (Navy Top Tab)                            (Navy Top Tab)                          |
|-----------------------------------------------------------------------------------|
| BOTTOM VISUAL PANEL: Y: 465, H: 220                                               |
| [Full Width Data Panel: W: 1240]                                                  |
| (Gold Top Tab)                                                                    |
-------------------------------------------------------------------------------------
```

### 2.1 Coordinate Mapping Table
When building or positioning visuals in Power BI Desktop, enter these exact values in the **Format > General > Properties > Size and Position** cards:

| Section / Container | PBI Visual Type | X (Left) | Y (Top) | Width | Height | Format / Alignment Notes |
|:---|:---|:---:|:---:|:---:|:---:|:---|
| **Header Title** | Text Box | 20 | 15 | 450 | 50 | Transparent background, font white, Outfit 20pt bold. |
| **Slicer 1 (Date)** | Slicer (Between) | 600 | 18 | 200 | 44 | White dropdown or slider style, header title off. |
| **Slicer 2 (Division)** | Slicer (Dropdown)| 815 | 18 | 180 | 44 | Cascading, multiselect with ctrl disabled, white font. |
| **Slicer 3 (Fund)** | Slicer (Dropdown)| 1010 | 18 | 180 | 44 | Cascading, multiselect, white font. |
| **Reset Filters** | Button (Bookmark) | 1210 | 18 | 50 | 44 | Icon-only, transparent, triggers "Reset Filters" bookmark. |
| **KPI Card 1 (Navy)** | Card (New) / Card | 20 | 95 | 285 | 100 | Padding Left: 20 to avoid left vertical navy border. |
| **KPI Card 2 (Navy)** | Card (New) / Card | 338 | 95 | 285 | 100 | Padding Left: 20 to avoid left vertical navy border. |
| **KPI Card 3 (Gold)** | Card (New) / Card | 657 | 95 | 285 | 100 | Padding Left: 20 to avoid left vertical gold border. |
| **KPI Card 4 (Gold)** | Card (New) / Card | 975 | 95 | 285 | 100 | Padding Left: 20 to avoid left vertical gold border. |
| **Left Trend Panel** | Chart / Tree Map | 20 | 210 | 600 | 240 | Margin Top: 15px (to clear the top navy accent tab). |
| **Right Trend Panel**| Chart / Scatter | 660 | 210 | 600 | 240 | Margin Top: 15px (to clear the top navy accent tab). |
| **Bottom Data Panel**| Table / Matrix | 20 | 465 | 1240 | 220 | Margin Top: 15px (to clear the top gold accent tab). |

---

## 3. Page-by-Page Visual Allocations

Below is the detailed visual map for each of the 10 required report pages.

### Page 1: Executive Overview
*   **Subtitle**: "Sovereign Asset Portfolio & Compliance Dashboard"
*   **KPI Card 1**: `Total_AUM_ZAR` (Formatted in Billions/Trillions: `R2.37T`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Weighted_Portfolio_Return_Percent` (Daily return performance vs benchmark e.g., `5.42%`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `BEE_Brokerage_Allocation_Percent` (Transformation progress KPI e.g., `64.2%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: `PFMA_Irregular_Expenditure_Counter` (Compliance flag e.g., `3 Violations` or `R0.00`, Outfit 24pt, bold Gold or Red depending on status)
*   **Left Chart Panel**: **AUM Growth vs. Benchmark Trend** (Line and Clustered Column Chart). Columns = AUM (ZAR); Line = Benchmark Return Index. Colors: Navy and Slate.
*   **Right Chart Panel**: **Executive Performance Matrix Slicer** (Dynamic Bar Chart linked to `Selected_Executive_Metric_Value`). Visualizes selected metric (e.g. ESG score, HR Turnover, IT Uptime) by Corporate Division.
*   **Bottom Data Panel**: **Fund Mandate & Performance Summary** (Table with Data Bars). Columns: Fund Name, Client Type, AUM, Daily Return, Standard Deviation, BEE Brokerage Share %, ESG Score. Includes gold/navy data bars for AUM.

### Page 2: Finance & Budget Control
*   **Subtitle**: "Operational Expenditure & PFMA Compliance Ledger"
*   **KPI Card 1**: **YTD Actual Opex** (ZAR amount e.g. `R245.2M`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: **YTD Budget Opex** (ZAR amount e.g. `R258.0M`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `Budget_vs_Actual_Variance_Percent` (Target indicator e.g. `-4.9%`, text color changes conditionally: green for under budget, red for over budget)
*   **KPI Card 4**: `PFMA_Irregular_Expenditure_Counter` (Cumulative statutory tracking e.g. `R0.00`, bold Gold/Red indicator)
*   **Left Chart Panel**: **Budget vs. Actual Variance Waterfall** (Waterfall Chart). Shows Budget as start, and deviations by Expense Category leading to Actual Opex.
*   **Right Chart Panel**: `Rolling_12Month_Opex` **Trend** (Area Chart). Shows 12-month rolling opex trend to identify cyclical corporate spending.
*   **Bottom Data Panel**: **Divisional Cost Center & Expense Matrix** (Matrix with Drill-down). Rows: Division Name, Expense Category. Columns: Actual YTD, Budget YTD, Variance ZAR, `Opex_YoY_Variance_Percent`. Alternating rows formatted with Light Grey (`#F8FAFC`).

### Page 3: Human Capital & Employment Equity
*   **Subtitle**: "Workforce Demographics & BEE Skills Investment"
*   **KPI Card 1**: `Active_Staff_Headcount` (Count e.g. `403 Employees`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Annualized_Turnover_Percent` (Annualised exit rate e.g. `4.2%`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `EE_Alignment_Score` (Alignment index vs national EAP targets e.g. `82.4%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: `Skills_Development_Spend_Percent` (Levy allocation tracking e.g. `3.8%`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **Employment Equity Alignment vs EAP Targets** (Clustered Column Chart). X-axis: Occupational Level (Executive, Senior, Professional, Skilled). Y-axis: Actual HDI % vs National EAP Target %. Colors: Navy and Gold.
*   **Right Chart Panel**: **Training & Skills Spend by Division** (Clustered Bar Chart). Horizontal bars showing Total Training Spend (ZAR) per Division.
*   **Bottom Data Panel**: **Staff Demographics & Compensation Matrix** (Matrix). Rows: Occupational Level, Race/Gender. Columns: Headcount, Avg Salary (ZAR, obscured under Analyst/External Manager roles via OLS), HDI Representation %, Training Hours.

### Page 4: Governance & Audit Tracker
*   **Subtitle**: "Audit Management, Regulatory Submissions & Policy Adherence"
*   **KPI Card 1**: `Open_Audit_Findings_Count` (Outstanding audit findings count e.g. `12 Open`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Average_Days_to_Resolve` (Historical resolution speed e.g. `45 Days`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `Regulatory_SLA_Compliance_Percent` (SLA adherence e.g. `98.1%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: **Closed Audit Findings YTD** (Count of resolved findings e.g. `34 Resolved`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **Open Findings by Division & Risk Rating** (Stacked Bar Chart). Y-axis: Division. X-axis: Open Findings Count. Legend: Severity/Risk Level (High = Red, Medium = Amber, Low = Blue).
*   **Right Chart Panel**: **Findings Resolution Aging Trend** (Line Chart). X-axis: Month. Y-axis: Days to Resolve trend vs Target SLA Line (30 days).
*   **Bottom Data Panel**: **Audit Findings Detailed Registry** (Table). Columns: Finding ID, Raised Date, Division, Audit Category, Severity Weight, Target Date, Resolution Status, Days Outstanding. Employs conditional formatting on Severity Weight (colored badges).

### Page 5: Investment Operations
*   **Subtitle**: "Mandate Compliance, Trading Lifecycle & Brokerage Allocation"
*   **KPI Card 1**: **Client Mandate Compliance Rate** (Compliance index e.g. `100.0%`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Trade_Settlement_Failure_Rate` (Settlement failure index e.g. `0.23%`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `BEE_Brokerage_Allocation_Percent` (BEE broker spend share e.g. `64.2%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: `Mandate_Breach_Count` (Breach events count e.g. `0 Breaches`, green for 0, red if >0)
*   **Left Chart Panel**: **Trade Settlement Status Lifecycle** (Funnel Chart). Visualizes trades moving from Execution -> Matching -> Clearing -> Settled, highlighted by settlement volume.
*   **Right Chart Panel**: **Brokerage Allocation by BEE Recognition Level** (Donut Chart or Treemap). Segments total brokerage fees paid by BEE Level (Level 1, Level 2, etc.).
*   **Bottom Data Panel**: **Trade Operations & Compliance Ledger** (Table). Columns: Execution Date, Security Name, Fund, Trade Value, Broker Name, BEE Level, Brokerage Fee, Settlement Status, Mandate Breach Flag (Red alert icon if True).

### Page 6: Transformation & ESG Dashboard
*   **Subtitle**: "B-BBEE Scorecard, ESG Integration & Developmental Impact"
*   **KPI Card 1**: `BBEE_Scorecard_Points` (B-BBEE level badge e.g. `Level 1 / 102.3 pts`, Outfit 24pt, bold Gold)
*   **KPI Card 2**: `Portfolio_Average_ESG_Score` (Portfolio-wide ESG index e.g. `7.8 / 10`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: **Carbon Intensity Index** (Weighted avg CO2 emissions e.g. `142 tCO2e/R-m`, Outfit 24pt, bold Navy)
*   **KPI Card 4**: **Developmental Jobs Created/Supported** (Count e.g. `18,450 Jobs`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **ESG Score vs. Carbon Intensity by Sector** (Scatter Chart). X-axis: ESG Score. Y-axis: Carbon Intensity. Bubble size: Market Value. Color: Sector.
*   **Right Chart Panel**: **B-BBEE Scorecard Pillar Performance** (Clustered Bar Chart). Columns: Scorecard Pillar (Ownership, Skills, Procurement, etc.). Shows Actual Points vs Target Points.
*   **Bottom Data Panel**: **Top 20 Investee Transformation Ledger** (Table). Columns: Asset Name, Sector, Market Value, BEE Recognition Level, ESG Score, Carbon Intensity, Women/HDI Board Representation %.

### Page 7: Listed Portfolio Risk Metrics
*   **Subtitle**: "Risk-Adjusted Performance & Volatility Analysis"
*   **KPI Card 1**: `Sharpe_Ratio` (Risk-adjusted return index e.g. `1.64`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Portfolio_Tracking_Error_Percent` (Annualised active risk e.g. `2.15%`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `VaR_95_1Day` (Value at Risk threshold e.g. `-1.42%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: `Information_Ratio` (Active return efficiency e.g. `0.78`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **Cumulative Fund Return vs Benchmark Index** (Line Chart). Dual lines showing selected Fund Cumulative Return % vs Benchmark Index over the calendar.
*   **Right Chart Panel**: **Listed Asset Risk-Return Profile** (Scatter Chart). X-axis: Volatility (Std Dev). Y-axis: Daily Return %. Bubble size: Market Value. Quadrant division lines added.
*   **Bottom Data Panel**: **Listed Security Volatility & Risk Analysis** (Table). Columns: Asset ISIN, Asset Name, Sector, Market Value, Return YTD, Volatility, Sharpe Ratio, Information Ratio, Beta.

### Page 8: Unlisted & Private Credit Performance
*   **Subtitle**: "Isibaya Fund & Real Estate Vintage Performance"
*   **KPI Card 1**: `Private_Equity_IRR_Approximation` (Internal Rate of Return e.g. `14.8%`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `MOIC` (Multiple on Invested Capital e.g. `1.42x`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `DPI` (Distributions to Paid-In Capital e.g. `0.65x`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: **Total Unlisted Portfolio NAV** (ZAR value e.g. `R142.6B`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **PE Cash Flow J-Curve Trend** (Line and Column Chart). Columns: Quarterly Net Cash Flows (Calls/Distributions). Line: Cumulative NAV (J-Curve).
*   **Right Chart Panel**: **IRR & MOIC Performance by Vintage Year** (Clustered Column Chart). X-axis: Vintage Year. Y-axis 1: IRR %. Y-axis 2: MOIC.
*   **Bottom Data Panel**: **Unlisted Investments Ledger** (Table/Matrix). Rows: Vintage Year, Asset Name. Columns: Committed Capital, Paid-In Capital (Drawdowns), Distributed Capital, Current Fair Value (NAV), IRR, MOIC, DPI.

### Page 9: IT & Project Delivery
*   **Subtitle**: "Operations Technology, System Availability & Project Milestone Tracking"
*   **KPI Card 1**: `System_Availability_Percent` (Core systems uptime e.g. `99.98%`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: `Project_Milestone_Adherence_Rate` (Milestone schedule SLA e.g. `91.4%`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: `Data_Quality_Index` (Cleansing completeness index e.g. `97.2%`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: `Helpdesk_SLA_Resolution_Percent` (Ticket SLA index e.g. `94.6%`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **Helpdesk Ticket Volume & SLA Resolution Trend** (Line and Column Chart). Columns: Ticket Count. Line: SLA Resolution %. X-axis: Week/Month.
*   **Right Chart Panel**: **Active Project Milestones Gantt Roadmap** (Stacked Bar Chart). Shows active IT transformation projects on Y-axis, planned duration on X-axis, color-coded by current status (Complete = Green, On Track = Navy, Delayed = Red).
*   **Bottom Data Panel**: **IT Incident & Project Operations Ledger** (Table). Columns: Project/System Name, Lead Developer, Current Milestone, Target Date, Milestone Weight, Active Ticket Count, Open Critical Tickets, SLA Met Rate, Data Quality Score.

### Page 10: Data Model & Methodology
*   **Subtitle**: "Technical Model Schema, Data Lineage & DAX Measure Catalogue"
*   **KPI Card 1**: **Active Tables Count** (Total tables in semantic model e.g. `17 Tables`, Outfit 24pt, bold Navy)
*   **KPI Card 2**: **Active Relationships Count** (Primary schema paths e.g. `22 Relationships`, Outfit 24pt, bold Navy)
*   **KPI Card 3**: **Inactive Relationships Count** (Role-playing date links e.g. `4 Relationships`, Outfit 24pt, bold Gold)
*   **KPI Card 4**: **Total Calculated Measures** (DAX measures count e.g. `34 Measures`, Outfit 24pt, bold Gold)
*   **Left Chart Panel**: **Model Table Size & Row Density** (Horizontal Bar Chart). Shows row count of each dimension and fact table to assist in performance audit.
*   **Right Chart Panel**: **Measure Usage & Visual Density Tree** (Treemap). Shows categories of measures (e.g. Risk, Finance, HC, IT) size-coded by number of visual placements.
*   **Bottom Data Panel**: **Interactive Measure Catalogue & Formula Viewer** (Table with search/filter). Columns: Measure Name, Target Table, Business Description, DAX Formula, Associated Page. Linked to a search text slicer to easily lookup DAX logic.

---

## 4. User Experience (UX) & Accessibility Directives

### 4.1 cascading Filter Pane (Header Bar)
To maximize data discovery while maintaining screen space, the horizontal header bar at `Y: 0` functions as a global slicer panel:
*   **Date Range Slicer**: Interacts with the `Dim_Date` dimension. Defaults to the last 12 months.
*   **Division Slicer**: Cascades to filter HR, Finance, and Project pages. Connected to RLS so division heads only see their own division pre-selected and locked.
*   **Fund Mandate Slicer**: Cascades to filter returns, trades, listed risk, and unlisted investments.
*   **Cascading Logic**: The Division and Fund slicers are set to "Show only relevant values" to prevent empty visual states.
*   **Reset Button**: Triggers a Power BI Bookmark that resets all slicers to their default "Select All" states and clears search inputs.

### 4.2 Tooltip Page Specifications
Hovering over any card or chart element triggers one of two standardised tooltip pages:
1.  **Metric Definition Tooltip**:
    *   Dimensions: 400px x 250px.
    *   Design: White card background, `#002B5C` border.
    *   Content: Dynamic text box showing the hover metric name, DAX formula (formatted in SQLBI style), and business definition.
2.  **Risk/SLA Threshold Tooltip**:
    *   Dimensions: 400px x 250px.
    *   Design: Visual alert card showing active metric against RAG targets.
    *   Content: A bullet chart showing the current value, target, and the historical trend line of the metric for the last 6 periods.

### 4.3 WCAG AA Accessibility Checklist
*   **Contrast Ratio**: All text and essential visuals must maintain a contrast ratio of at least **4.5:1** against the background. Since visuals use a transparent background over a `#FFFFFF` or `#F4F6F9` SVG canvas card, font colors of `#002B5C` (Navy), `#1E293B` (Dark Slate), and `#EF4444` (Red) naturally meet these requirements.
*   **Colorblind Safety**: Red (`#EF4444`) and Green (`#52796F`/`#84A98C`) are supplemented by distinct shape indicators (e.g., up/down triangles, checkmarks vs crossmarks) in tables and cards, ensuring accessibility for color-vision-deficient users.
*   **Alt-Text & Focus Order**: Add descriptive alt-text to all charts. Adjust the tab order (Selection Pane > Format > Tab Order) so screen readers navigate logically: Header Title → Slicers → KPI Cards (Left to Right) → Middle Panels (Left to Right) → Bottom Table.

---

## 5. Performance Optimization Implementation Rules

To achieve the targeted **under 3-second page load times** on standard hardware, implement the following directives in Power BI Desktop:

1.  **Disable Visual Borders and Shadows**:
    Ensure `Visual > Format > General > Effects > Border` and `Shadow` are set to **Off** for every visual. The background SVG template already pre-renders these, saving significant client-side painting CPU cycles.
2.  **Turn Off Gridlines in Charts**:
    Minimize visual noise and rendering time by turning off horizontal/vertical gridlines in line and column charts. Use subtle data labels for high-priority points instead.
3.  **Limit Visual Counts to 8 Per Page**:
    The canvas grid naturally limits visual counts (1 Header Title, 3 Dropdowns, 4 Cards, 2 Charts, 1 Table = 11 visuals maximum, including interactive controllers). Never exceed 12 active queries per page.
4.  **Use Top N Filters on Detailed Tables**:
    For detail tables (e.g., Listed Asset Portfolio Risk Analysis, Top 20 Investee transformation ledger), apply a default `Top 100` visual-level filter on Market Value to restrict initial query size, letting the user load more data as needed.
