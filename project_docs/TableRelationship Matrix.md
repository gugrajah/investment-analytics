### Relationship Matrix

| From Table (Fact) | To Table (Dimension) | Fact Foreign Key | Dimension Primary Key | Cardinality | State | Cross-Filter Direction | Architectural Justification & Notes |
| :---- | :---- | :---- | :---- | :---: | :---: | :---: | :---- |
| **Fact\_FinancialTransactions** | Dim\_Date | DateKey | DateKey | \*:1 | Active | Single | Maps financial opex transactions to the primary calendar timeline. |
|  | Dim\_Division | DivisionKey | DivisionKey | \*:1 | Active | Single | Filters operational budgets and actuals by corporate divisions/cost centers. |
| **Fact\_HREvents** | Dim\_Date | DateKey | DateKey | \*:1 | Active | Single | Filters HR events and headcount snapshot dates. |
|  | Dim\_Employee | EmployeeKey | EmployeeKey | \*:1 | Active | Single | Connects HR events and training spend to individual employee attributes. |
|  | Dim\_Division | DivisionKey | DivisionKey | \*:1 | Active | Single | Maps employee snapshots and training expenditures to corporate divisions. |
| **Fact\_TradeSettlements** | Dim\_Date | ExecutionDateKey | DateKey | \*:1 | Active | Single | Maps trades to their execution date. |
|  | Dim\_Date | SettlementDateKey | DateKey | \*:1 | Inactive | Single | Role-playing date link. Kept inactive to avoid loops; activated via USERELATIONSHIP in DAX. |
|  | Dim\_InvestmentAsset | AssetKey | AssetKey | \*:1 | Active | Single | Links settlements to security metadata (ISIN, Asset Class, Sector, ESG score). |
|  | Dim\_Fund | FundKey | FundKey | \*:1 | Active | Single | Segregates public market trades by investment client mandates (e.g. GEPF, UIF). |
|  | Dim\_BEELevel | BEELevelKey | BEELevelKey | \*:1 | Active | Single | Tracks brokerage fees and allocations based on broker B-BBEE recognition tiers. |
| **Fact\_AuditFindings** | Dim\_Date | RaisedDateKey | DateKey | \*:1 | Active | Single | Maps raised audit findings along the primary calendar timeline. |
|  | Dim\_Date | TargetDateKey | DateKey | \*:1 | Inactive | Single | Role-playing date link. Used to evaluate compliance against planned deadlines in DAX. |
|  | Dim\_Date | ActualResolutionDateKey | DateKey | \*:1 | Inactive | Single | Role-playing date link. Used to compute actual days-to-resolve findings in DAX. |
|  | Dim\_AuditCategory | AuditCategoryKey | AuditCategoryKey | \*:1 | Active | Single | Categorizes audit findings by source (AG / Internal), classification, and risk level. |
|  | Dim\_Division | DivisionKey | DivisionKey | \*:1 | Active | **Both (Bi)** | **Bidirectional filter.** Explicitly configured to allow a dynamic audit exploration path. |
| **Fact\_ProjectMilestones** | Dim\_Date | PlannedDateKey | DateKey | \*:1 | Active | Single | Maps planned milestone schedules to the calendar. |
|  | Dim\_Date | ActualDateKey | DateKey | \*:1 | Inactive | Single | Role-playing date link. Kept inactive to track project milestone completion and delays. |
| **Fact\_PortfolioReturns** | Dim\_Date | DateKey | DateKey | \*:1 | Active | Single | Tracks daily investment returns and benchmark tracking along the calendar. |
|  | Dim\_InvestmentAsset | AssetKey | AssetKey | \*:1 | Active | Single | Filters portfolio daily returns by asset dimensions. |
|  | Dim\_Fund | FundKey | FundKey | \*:1 | Active | Single | Filters portfolio daily returns by client/fund mandate. |
| **Fact\_UnlistedInvestments** | Dim\_Date | DateKey | DateKey | \*:1 | Active | Single | Filters unlisted PE cash flows (drawdowns/distributions) by date. |
|  | Dim\_InvestmentAsset | AssetKey | AssetKey | \*:1 | Active | Single | Tracks unlisted investments (Isibaya Eco, real estate) vintage performance. |
|  | Dim\_Fund | FundKey | FundKey | \*:1 | Active | Single | Tracks PE/credit capital allocations by fund mandate. |
| **Fact\_HelpdeskTickets** | Dim\_Date | CreatedDateKey | DateKey | \*:1 | Active | Single | Maps ticket volumes based on creation dates. |
|  | Dim\_Date | ClosedDateKey | DateKey | \*:1 | Inactive | Single | Role-playing date link. Used to compute ticket aging and SLA resolution times. |
|  | Dim\_Employee | EmployeeKey | EmployeeKey | \*:1 | Active | Single | Connects IT tickets to employees to support dynamic RLS and department slices. |

