# Power Query Transformation & Data Preparation

This folder documents the **data preparation and transformation stage** of the Financial Reporting & Variance Analysis project.

Power Query was used to clean, validate and standardise the Actual and Budget datasets before they were used for management reporting, SQL validation and Power BI analysis.

The objective was to create a controlled reporting population while preserving an audit trail of identified data-quality issues and their treatment.

---

## Transformation Workflow

The preparation process follows:

```text
Raw Source Data
      ↓
Data Type & Structure Validation
      ↓
Data Quality Checks
      ↓
Corrections & Standardisation
      ↓
Exception Handling
      ↓
Processed Reporting Tables
      ↓
Reconciliation Controls
```

Actual and Budget data were processed separately before being aggregated into a common reporting structure.

---

## Source Data

The project contains two primary financial datasets.

### Actual Transactions

Transaction-level financial activity containing fields such as:

- Transaction ID
- Posting Date
- Branch
- Department
- Account
- Vendor
- Document Number
- Description
- Amount

Initial Actual population:

```text
5,829 rows
```

### Budget

Monthly Budget data organised at:

```text
Month × Branch × Department × Account
```

Initial Budget population:

```text
2,159 rows
```

Reference tables were also used for:

- Accounts
- Branches
- Departments
- Vendors
- Months

---

## Actual Data Processing

The Actual workflow was separated into three logical layers:

```text
fact_Actual_Raw
        ↓
fact_Actual_Clean
        ↓
fact_Actual_Processed
```

### Raw

Preserves the imported source population without reporting adjustments.

### Clean

Applies structural cleaning and validation while retaining all source rows.

### Processed

Contains the final reporting population after approved corrections and duplicate treatment.

Final Actual population:

```text
5,828 rows
```

---

## Actual Data Quality Issues

Several controlled data-quality issues were introduced into the dataset to simulate realistic reporting problems.

The transformation process identified and treated:

| Issue | Treatment |
|---|---|
| Missing Department | Assigned to the appropriate department |
| Invalid Account Code | Corrected to the valid reporting account |
| Inconsistent Description | Standardised |
| Duplicate Transaction | Duplicate copy removed |
| Inactive Vendor Activity | Retained and flagged for review |
| Unusual Repairs & Maintenance | Retained and flagged for review |
| Repeated Vendor Document | Retained and flagged for review |

Examples of resolved issues include:

```text
TXN-202503-00076
Missing Department → D04

TXN-202511-00121
Missing Department → D04

TXN-202507-00106
Account 6999 → 6100

TXN-202504-00091
Description standardised

TXN-202505-00141
Duplicate copy removed
```

Resolved issues were corrected before reporting where appropriate.

Review exceptions were retained in the financial population when the underlying transaction remained valid.

---

## Audit Trail

The processed Actual dataset contains additional fields to preserve the treatment applied during data preparation:

```text
DepartmentID_Processed
AccountCode_Processed
Description_Processed
ResolutionAction
ReportingTreatment
```

This provides visibility over how source issues were handled without overwriting the original source fields.

The approach separates:

```text
Source Value
     ↓
Processed Reporting Value
     ↓
Resolution / Treatment
```

This allows reporting corrections to remain traceable.

---

## Budget Data Processing

The Budget workflow follows:

```text
fact_Budget_Raw
        ↓
fact_Budget_Clean
        ↓
fact_Budget_Processed
```

The expected reporting population was:

```text
12 Months
× 4 Branches
× 4 Departments
× 11 Budget Accounts
= 2,160 rows
```

However, the source Budget contained:

```text
2,159 rows
```

A completeness check identified one missing reporting combination:

```text
Month       2025-08
Branch      BR03
Department  D02
Account     6600
```

A zero-value Budget row was added to restore complete reporting coverage.

Final Budget population:

```text
2,160 rows
```

The added row remains identifiable as a reporting exception rather than being silently inserted.

---

## Reporting Coverage

After processing:

```text
Actual monthly reporting combinations    2,160
Budget monthly reporting combinations    2,160

Actual without Budget coverage               0
Budget without Actual coverage               0
```

This created a complete reporting structure across:

```text
Month
Branch
Department
Account
```

and allowed Actual vs Budget analysis to be performed consistently.

---

## Processed Outputs

The final processed datasets used by SQL and Power BI are stored in:

```text
data/processed/
```

Key outputs include:

```text
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

Final row counts:

| Dataset | Rows |
|---|---:|
| Actual Clean | 5,829 |
| Actual Processed | 5,828 |
| Budget Clean | 2,159 |
| Budget Processed | 2,160 |
| Account Dimension | 21 |
| Branch Dimension | 4 |
| Department Dimension | 4 |
| Vendor Dimension | 28 |
| Month Dimension | 12 |

---

## Reconciliation Controls

Power Query outputs were validated before downstream reporting.

Key controls include:

```text
Actual Clean Rows       5,829
Actual Processed Rows   5,828
Duplicate Removed           1

Budget Clean Rows       2,159
Budget Processed Rows   2,160
Coverage Row Added          1
```

The processed Actual and Budget populations were then used to construct the management reporting layer in Excel.

A reconciliation control framework was used to confirm:

- Reporting population completeness
- Actual and Budget coverage
- Monthly reconciliation
- Financial totals
- Exception treatment
- Reporting consistency

All final reporting controls passed before the datasets were used in SQL and Power BI.

---

## Exception Philosophy

Not every unusual transaction represents an error.

The transformation process therefore distinguishes between:

### Resolved Data Quality Issues

Issues that require correction or removal before reporting.

Examples:

- Missing Department
- Invalid Account
- Duplicate Transaction
- Inconsistent Description

### Open Review Exceptions

Transactions that remain valid for financial reporting but require additional review.

Examples:

- Inactive Vendor activity
- Unusual Repairs & Maintenance
- Repeated Vendor documents
- Missing Budget source coverage

This prevents valid financial activity from being removed simply because it appears unusual.

---

## Role of Power Query in the Project

Power Query serves as the controlled data preparation layer between the raw source files and the analytical tools used later in the project.

```text
Raw Data
   ↓
Power Query
Clean + Validate + Control
   ↓
Excel
Management Reporting
   ↓
SQL
Independent Validation
   ↓
Power BI
Management Analysis
```

The objective was not only to clean the data, but to create a reporting population that could be independently reconciled throughout the rest of the project.

---

## Project Navigation

Return to the main project documentation:

[Financial Reporting & Variance Analysis](../README.md)

Continue to:

[SQL Validation & Investigation](../sql/README.md)

[Power BI Management Dashboard](../powerbi/README.md)
