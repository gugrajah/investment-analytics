# PIC Portfolio Analytics — Stakeholder Requirements Log

This document lists the business requirements logged by various corporate departments, mapping them to project phases, prioritization ranks, and current implementation status.

---

## Requirements Tracking Registry

| Requirement Request | Requesting Corporate Department | Priority Rank | Current Project Status | Target Release Phase |
| :--- | :--- | :--- | :--- | :--- |
| **Parliamentary Performance Report**<br>Consolidated strategic landing page displaying total AUM, performance returns against weighted benchmark, and statutory PFMA violations count. | Board & Executive Office | High | ✅ Completed | Phase 5 (Page 1) |
| **PFMA Expenditure Monitoring**<br>Track unauthorized, irregular, fruitful, and wasteful expenditure transactions at cost center level, with drill-down matrix. | Finance Control Division | High | ✅ Completed | Phase 5 (Page 2) |
| **Employment Equity Target Tracking**<br>Compare active employee headcount demographics against the Department of Employment & Labour (DoEL) regional/national EAP targets by occupational level. | Human Resources Division | Medium | ✅ Completed | Phase 5 (Page 3) |
| **Auditor-General Audit Finding Tracker**<br>Track open audit findings, resolution speed (days elapsed), risk severity weights, and regulatory filing SLA compliance. | Internal Audit & Risk Division | High | ✅ Completed | Phase 5 (Page 4) |
| **BEE stockbroker Allocation Tracking**<br>Track percentage allocation of trading brokerage fees paid to stockbrokers categorized by B-BBEE Level 1 contributor status. | Listed Equities Operations | Medium | ✅ Completed | Phase 5 (Page 5) |
| **Investee ESG Integration Rating**<br>Evaluate and display average ESG scores and carbon intensities of investee companies, weighted by portfolio asset size. | ESG & Transformation Committee | High | ✅ Completed | Phase 5 (Page 6) |
| **Risk-Adjusted Performance Analytics**<br>Display listed portfolio quantitative risk metrics: Sharpe Ratio, Tracking Error, 1-Day 95% Value at Risk (VaR), and Information Ratio. | Risk Management Division | High | ✅ Completed | Phase 5 (Page 7) |
| **Unlisted PE Hurdle Rate Performance**<br>Track Private Equity, developmental infrastructure, and credit mandates using PE metrics: IRR, MOIC, and DPI by vintage year. | Private Equity & Unlisted Assets | Medium | ✅ Completed | Phase 5 (Page 8) |
| **Core IT System Availability Tracking**<br>Monitor availability of core investment systems (e.g., Bloomberg, PAM) and track ServiceNow ticket SLA resolution rates. | IT Infrastructure & Operations | Low | ✅ Completed | Phase 5 (Page 9) |
| **Technical Metadata & Lineage Explorer**<br>Provide a technical page displaying model table sizes, relationships counts, and an interactive DAX measure catalog for system auditing. | Data Governance Committee | Low | ✅ Completed | Phase 5 (Page 10) |
| **Granular Employee Compensation Masking**<br>Implement security rules to hide individual employee salary values from Analyst, Auditor, and External Manager roles to comply with POPIA. | HR & Information Officer | High | ✅ Completed | Phase 6 (Security) |
| **Divisional Data Isolation (RLS)**<br>Configure security rules so Division Heads are restricted to viewing transaction, event, and finding data for their respective divisions only. | Compliance & Risk Division | High | ✅ Completed | Phase 6 (Security) |
| **External Manager Data Restrictions**<br>Implement security rules to restrict third-party asset managers from accessing internal corporate HR events and other fund mandates. | Legal & Compliance | High | ✅ Completed | Phase 6 (Security) |
| **Automated System Refreshes**<br>Configure programmatic dataset refreshes triggered via API request upon completion of ETL loads rather than standard scheduled cycles. | IT Data Engineering | Medium | ✅ Planned | Phase 6 Deployment |
| **Multi-Stage CI/CD Deployment**<br>Implement Dev -> Test -> Prod deployment pipeline workspaces integrated with version control (Git) branching guidelines. | Corporate IT & Release PMO | Medium | ✅ Planned | Phase 6 Deployment |
| **Tabular Model Best Practice Auditing**<br>Apply Best Practice Analyzer (BPA) rules to enforce safe DIVIDE patterns, hide foreign keys, and optimize table scans to ensure page loads under 3 seconds. | Quality Assurance (BI Lead) | High | ✅ Completed | Phase 7 Optimization |
