# SQL Validation and Investigation

SQLite was used as an independent validation and analytical layer after the Excel and Power Query reporting workflow.

The SQL stage validates processed datasets, reconstructs financial results, performs Budget vs Actual analysis and investigates the drivers behind management reporting variances.

## Query Structure

| Script | Purpose |
|---|---|
| `00_database_validation.sql` | Validates imported tables, row counts and financial totals |
| `01_data_quality_validation.sql` | Detects duplicates, missing values, invalid accounts, vendor exceptions and missing budget coverage |
| `02_financial_summary.sql` | Reconstructs annual and monthly income statement results |
| `03_budget_vs_actual.sql` | Calculates Budget vs Actual variances and favourable / unfavourable performance |
| `04_branch_variance.sql` | Analyses financial performance by branch |
| `05_department_variance.sql` | Analyses financial performance by department and branch-department combinations |
| `06_account_variance.sql` | Identifies major account-level variance drivers |
| `07_exception_investigation.sql` | Investigates open exceptions and validates resolved data-quality issues |
| `08_management_insights.sql` | Consolidates management insights and performs final reconciliation controls |

## Key Reconciled Results

| Metric | Result |
|---|---:|
| Actual Revenue | RM19,806,040 |
| Budget Revenue | RM19,515,100 |
| Revenue Variance | RM290,940 Favourable |
| Actual Operating Profit | RM2,310,590 |
| Budget Operating Profit | RM2,299,700 |
| Operating Profit Variance | RM10,890 Favourable |
| Processed Actual Transactions | 5,828 |
| Processed Budget Rows | 2,160 |
| Open Exceptions | 6 |

All major SQL financial results reconcile to the Excel and Power Query reporting layer.
