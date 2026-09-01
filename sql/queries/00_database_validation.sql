-- Financial Reporting and Variance Analysis
-- Stage 2: SQL Validation and Investigation
-- 00 Database Validation

-- =====================================================
-- 1. Confirm imported tables
-- =====================================================

SELECT name AS table_name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;


-- =====================================================
-- 2. Validate table row counts
-- =====================================================

SELECT 'actual_clean' AS table_name, COUNT(*) AS row_count
FROM actual_clean

UNION ALL

SELECT 'actual_processed', COUNT(*)
FROM actual_processed

UNION ALL

SELECT 'budget_clean', COUNT(*)
FROM budget_clean

UNION ALL

SELECT 'budget_processed', COUNT(*)
FROM budget_processed

UNION ALL

SELECT 'dim_account', COUNT(*)
FROM dim_account

UNION ALL

SELECT 'dim_branch', COUNT(*)
FROM dim_branch

UNION ALL

SELECT 'dim_department', COUNT(*)
FROM dim_department

UNION ALL

SELECT 'dim_vendor', COUNT(*)
FROM dim_vendor

UNION ALL

SELECT 'dim_month', COUNT(*)
FROM dim_month;


-- =====================================================
-- 3. Reconcile processed actuals
-- =====================================================

SELECT
    COUNT(*) AS processed_transactions,
    ROUND(SUM(Amount), 2) AS total_actual_amount
FROM actual_processed;


-- =====================================================
-- 4. Reconcile clean budget
-- =====================================================

SELECT
    COUNT(*) AS budget_rows,
    ROUND(SUM(BudgetAmount), 2) AS total_budget_amount
FROM budget_clean;


-- =====================================================
-- 5. Reconcile processed budget
-- =====================================================

SELECT
    COUNT(*) AS budget_rows,
    ROUND(SUM(BudgetAmount_Processed), 2) AS total_budget_amount
FROM budget_processed;

COMPLETE
