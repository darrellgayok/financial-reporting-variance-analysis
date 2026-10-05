# Power BI Management Dashboard

This folder contains the Power BI reporting and visual analytics layer of the **Financial Reporting & Variance Analysis** project.

Power BI was introduced after the Excel, Power Query and SQL stages had already established and independently validated the reporting data.

The purpose of this stage was to transform validated financial results into an interactive management reporting experience.

---

## Reporting Approach

The dashboard follows a simple analytical flow:

```text
Performance
    ↓
Variance
    ↓
Driver
    ↓
Investigation
    ↓
Control Review
```

The report is designed around three management questions:

1. How is the business performing against budget?
2. Where are the major financial variances coming from?
3. Which reporting exceptions require attention?

---

## Data Model

The Power BI model uses two fact tables:

```text
fact_Actual
fact_Budget
```

supported by shared dimensions:

```text
dim_Month
dim_Branch
dim_Department
dim_Account
```

Vendor analysis is connected only to Actual transactions through:

```text
dim_Vendor
```

Actual and Budget are intentionally maintained as separate fact tables because they operate at different levels of detail.

```text
Actual
Transaction level

Budget
Month × Branch × Department × Account
```

There is no direct relationship between `fact_Actual` and `fact_Budget`.

---

## Report Pages

### 1. Executive Performance

Provides a high-level view of financial performance against budget.

Key elements include:

- Actual Revenue
- Actual Operating Profit
- Actual Operating Margin
- Operating Profit Variance
- Monthly Actual vs Budget trend
- Operating Profit variance bridge
- Favourable and unfavourable month summary
- Dynamic executive commentary

---

### 2. Variance Drivers

Supports drilldown into the underlying sources of financial variance.

The analytical path follows:

```text
Company
    ↓
Branch
    ↓
Department
    ↓
Account
```

Key elements include:

- Operating Profit variance by branch
- Operating Profit variance by department
- Top 10 account variance drivers
- Branch → Department → Account drilldown matrix
- Strongest and weakest branch indicators
- Strongest and weakest department indicators

---

### 3. Controls & Exceptions

Provides visibility over reporting integrity and items requiring management review.

The page distinguishes between:

**Resolved data-quality issues**

Issues corrected or removed before reporting.

**Open review exceptions**

Transactions retained in reporting because the underlying activity remains valid but requires review.

Key controls include:

- Overall Control Status
- Total, resolved and open exception counts
- Duplicate transaction removal
- Budget coverage adjustment
- Inactive vendor activity
- Unusual Repairs & Maintenance transactions
- Repeated vendor documents
- Missing budget source coverage
- Financial, variance and exception reconciliation status

---

## DAX Measure Structure

Measures are organised into dedicated display folders:

```text
01 QA
02 Financial
03 Reconciliation
04 Variance
05 Management Insights
06 Controls & Exceptions
```

Core measures include:

- Actual Revenue
- Budget Revenue
- Actual Gross Profit
- Budget Gross Profit
- Actual Operating Profit
- Budget Operating Profit
- Operating Margin
- Revenue Variance
- Cost of Sales Variance
- Operating Expense Variance
- Operating Profit Variance
- Variance percentages
- Favourable / Unfavourable status
- Reconciliation controls
- Exception counts

---

## Key Reconciled Results

| Metric | Result |
|---|---:|
| Actual Revenue | RM19,806,040 |
| Budget Revenue | RM19,515,100 |
| Actual Operating Profit | RM2,310,590 |
| Budget Operating Profit | RM2,299,700 |
| Operating Profit Variance | RM10,890 Favourable |
| Actual Operating Margin | 11.67% |
| Favourable Months | 7 |
| Unfavourable Months | 5 |
| Resolved Exceptions | 5 |
| Open Exceptions | 6 |
| Overall Control Status | PASS |

Power BI independently reproduces the key financial results previously validated through Excel and SQL.

Company, branch, department and account reporting layers reconcile to the same overall Operating Profit variance.

---

## Dashboard Design Principle

The dashboard prioritises management interpretation over visual density.

The report is structured to move from:

```text
What happened?
      ↓
Where did it happen?
      ↓
What needs attention?
```

rather than presenting several pages containing variations of the same charts.

---

## File

```text
financial_reporting_variance_analysis.pbix
```

---

## Project Navigation

Return to the main project documentation:

[Financial Reporting & Variance Analysis](../README.md)
```

This version gives the Power BI folder its own purpose: **model design, report architecture, DAX structure and reconciliation**, while leaving the overall project story to the main README.
