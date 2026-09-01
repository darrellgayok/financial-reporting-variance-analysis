# SQL Validation and Investigation

This folder contains the SQL validation and investigation layer of the Financial Reporting & Variance Analysis project.

SQLite was used after the Excel and Power Query stage as an independent analytical layer.

The purpose was not simply to reproduce the Excel reports in SQL. The SQL stage was designed to test whether the processed financial data could independently produce the same reporting results, identify the same control issues and support deeper variance investigation.

---

## SQL Workflow

```text
Processed Financial Data
        ↓
Database Validation
        ↓
Data Quality Validation
        ↓
Financial Statement Reconstruction
        ↓
Budget vs Actual Analysis
        ↓
Branch and Department Investigation
        ↓
Account Variance Analysis
        ↓
Exception Investigation
        ↓
Management Insights
        ↓
Final Reconciliation Controls
```
The analysis was intentionally developed in this sequence so that financial interpretation only begins after the underlying reporting population has been validated.

---

## Analysis Approach
### 1. Validate the database first

Before performing financial analysis, the imported tables were checked for:
- expected table availability
- row counts
- processed transaction totals
- processed budget totals
- dimension table populations

This establishes whether the SQLite database contains the same controlled datasets produced during the Power Query stage.

### 2. Independently test data quality

The next step was to investigate the processed and clean datasets using SQL rather than relying on existing Power Query validation flags.
SQL checks were used to identify:
- duplicate transaction IDs
- missing department values
- invalid account codes
- inactive vendor activity
- repeated vendor documents
- unusual Repairs & Maintenance transactions
- missing budget coverage
This provides an independent control layer over the reporting data.

### 3. Reconstruct the financial statements

Once the data population was validated, SQL was used to rebuild the management income statement from transaction level data.

The analysis reconstructed:
```
Revenue

Less: Cost of Sales

= Gross Profit

Less: Operating Expenses

= Operating Profit
```
Annual and monthly results were then reconciled against the Excel reporting layer.

### 4. Rebuild Budget vs Actual logic

Actual and budget datasets were combined to reproduce management variance analysis.

The project applies the following reporting logic:
| Financial Area | Variance Logic |
|---|---|
| Revenue | Actual − Budget |
| Expenses | Budget − Actual |
| Profit | Actual − Budget |

This allows:
```
Positive = Favourable

Negative = Unfavourable
```
across the reporting model.

### 5. Move from totals to variance drivers
After validating the company level result, the analysis progressively drilled down through:
```
Company
   ↓
Branch
   ↓
Department
   ↓
Account
   ↓
Transaction / Exception
```
This was designed to move beyond reporting the final variance and identify where favourable and unfavourable movements originated.

### 6. Investigate exceptions separately from financial performance
Not every unusual transaction should automatically be treated as an error.
The SQL investigation therefore distinguishes between:
#### Resolved data quality issues
Examples include corrected department values, corrected account codes, standardised descriptions and duplicate removal.
#### Open management review items
Examples include inactive vendor activity, repeated vendor documents, unusual Repairs & Maintenance activity and missing source budget coverage.
This allows valid financial transactions to remain in reporting while still being surfaced for management review.

### 7. Finish with independent reconciliation
The final SQL controls compare results across multiple analytical levels.

Company, branch, department and account analyses are required to reconcile back to the same overall operating profit variance.

The final SQL validation returned:
```
14 PASS
0 REVIEW
```

---
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

---

## SQL Techniques Applied
The analysis uses practical SQL techniques including:
- Common Table Expressions
- INNER and LEFT JOINs
- conditional aggregation
- CASE expressions
- GROUP BY analysis
- COALESCE and NULL handling
- CROSS JOINs for expected reporting populations
- duplicate detection
- dimension validation
- variance ranking
- reconciliation controls
The emphasis of the SQL stage is not query complexity by itself, but using SQL to support financial control, investigation and management reporting.

### Data Inputs
SQL uses the processed datasets stored under:
```
data/processed/
```
including:
```
actual_clean.csv
actual_processed.csv
budget_clean.csv
budget_processed.csv
dim_account.csv
dim_branch.csv
dim_department.csv
dim_month.csv
dim_vendor.csv
```
The SQLite database was used locally for query development. The portfolio repository retains the source CSV files and SQL scripts so the analytical workflow remains transparent and reviewable.

---

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

---
## Project Navigation

Return to the main project documentation:

[Financial Reporting & Variance Analysis](../README.md)
