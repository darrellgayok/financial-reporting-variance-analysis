# Financial Reporting & Variance Analysis

A finance analytics portfolio project demonstrating an end to end management reporting workflow using **Excel, Power Query, SQL and Power BI**.

The project uses synthetic financial data from a fictional multi branch company to build controlled financial reporting, Budget vs Actual analysis, variance investigation and management insights.

## Project Status

| Stage | Scope | Status |
|---|---|---|
| Stage 1 | Excel + Power Query | ✅ Complete |
| Stage 2 | SQL Validation & Investigation | ✅ Complete |
| Stage 3 | Power BI Dashboard | 🔄 Next |
| Stage 4 | Final Portfolio Packaging | ⏳ Planned |

**Overall Progress: ~70%**

---

## Project Overview

The dataset represents **Borneo Business Solutions Sdn. Bhd.**, operating across Kuching, Sibu, Bintulu and Miri from January to December 2025.

The project focuses on:

* Financial data cleaning and validation
* Management income statement reporting
* Budget vs Actual analysis
* Financial reconciliation
* Branch, department and account analysis
* Data quality and exception investigation
* Management insight development

## Repository Structure

```text
financial-reporting-variance-analysis/
│
├── data/
│   │
│   ├── raw/
│   │   ├── actuals/
│   │   ├── budget/
│   │   ├── master-data/
│   │   └── quality/
│   │
│   └── processed/
│       ├── actual_clean.csv
│       ├── actual_processed.csv
│       ├── budget_clean.csv
│       ├── budget_processed.csv
│       ├── dim_account.csv
│       ├── dim_branch.csv
│       ├── dim_department.csv
│       ├── dim_month.csv
│       └── dim_vendor.csv
│
├── excel/
│   └── financial_reporting_variance_analysis.xlsx
│
├── power-query/
│   └── README.md
│
├── sql/
│   │
│   ├── queries/
│   │   ├── 00_database_validation.sql
│   │   ├── 01_data_quality_validation.sql
│   │   ├── 02_financial_summary.sql
│   │   ├── 03_budget_vs_actual.sql
│   │   ├── 04_branch_variance.sql
│   │   ├── 05_department_variance.sql
│   │   ├── 06_account_variance.sql
│   │   ├── 07_exception_investigation.sql
│   │   └── 08_management_insights.sql
│   │
│   └── README.md
│
├── images/
│
└── README.md
```

---

## Stage 1: Excel + Power Query

Power Query was used to consolidate, clean and validate the financial datasets before loading the processed results into an Excel management reporting workbook.

### Key Outputs

* 5,829 raw transactions
* 5,828 processed transactions
* 2,160 processed budget rows
* 19 reconciliation controls passed
* 12 monthly reporting periods reconciled
* Budget vs Actual reporting
* Branch, department and account analysis
* Exception monitoring

### Management Control Overview

![Management Control Overview](images/stage1_00_control.png)

### Budget vs Actual Performance

![Budget vs Actual Performance](images/stage1_02_budget_vs_actual.png)

---

## Stage 2: SQL Validation & Investigation

SQLite was used as an independent validation and analytical layer to reproduce the financial results from the processed datasets.

SQL analysis covered:

* Database and row validation
* Data quality checks
* Annual and monthly financial reconstruction
* Budget vs Actual analysis
* Branch and department variance analysis
* Account variance drivers
* Exception investigation
* Management insights
* Final reconciliation controls

### Key Reconciled Results

| Metric | Result |
|---|---:|
| Actual Revenue | RM19,806,040 |
| Budget Revenue | RM19,515,100 |
| Revenue Variance | RM290,940 F |
| Actual Operating Profit | RM2,310,590 |
| Budget Operating Profit | RM2,299,700 |
| Operating Profit Variance | RM10,890 F |
| Open Exceptions | 6 |
| Final SQL Controls | 14 PASS |

Company, branch, department and account analyses all reconcile to the same **RM10,890 favourable Operating Profit variance**.

See the detailed SQL documentation here:

[SQL Validation and Investigation](sql/README.md)

---

## Financial Reporting Logic

| Area | Variance Calculation |
|---|---|
| Revenue | Actual − Budget |
| Expenses | Budget − Actual |
| Profit | Actual − Budget |

**Positive = Favourable**  
**Negative = Unfavourable**

---

## Tools Used

| Tool | Application |
|---|---|
| Excel | Management reporting and reconciliation |
| Power Query | Data cleaning, transformation and validation |
| SQLite | Independent validation and financial analysis |
| DB Browser for SQLite | SQL development |
| Power BI | Interactive dashboard development |
| GitHub | Documentation and portfolio hosting |

---

## Project Roadmap
✅ Stage 1: Excel + Power Query

Completed data preparation, reconciliation, management reporting and exception controls.

✅ Stage 2: SQL

Completed independent financial validation, variance investigation and reconciliation.

🔄 Stage 3: Power BI

Next stage will build an interactive management dashboard covering financial performance, Budget vs Actual trends, variance drivers and exception monitoring.

⏳ Stage 4: Final Portfolio Packaging

Final dashboard screenshots, documentation refinement and portfolio presentation.

---

## Disclaimer
This project uses fictional company information and synthetic financial data created solely for portfolio and learning purposes.

No confidential company or client information is used.
