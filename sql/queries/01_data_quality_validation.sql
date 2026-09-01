
-- =====================================================
-- PART A
-- =====================================================
SELECT
	TransactionID,
	COUNT(*) AS occurance_count
FROM actual_clean
GROUP BY TransactionID
HAVING COUNT(*) > 1;

-- =====================================================
-- PART B
-- =====================================================
SELECT COUNT(*) AS duplicated_transaction_ids
FROM (
		SELECT TransactionID
		FROM actual_clean
		GROUP BY TransactionID
		HAVING COUNT(*) > 1
);

-- =====================================================
-- PART C
-- =====================================================
SELECT
    TransactionID,
    PostingDate,
    MonthKey,
    BranchID,
    DepartmentID,
    AccountCode,
    Description,
    Amount
FROM actual_clean
WHERE TRIM(COALESCE(DepartmentID, '')) = '';

-- =====================================================
-- PART D
-- =====================================================
SELECT
	a.TransactionID,
    a.PostingDate,
    a.MonthKey,
    a.BranchID,
    a.DepartmentID,
    a.AccountCode,
    a.Description,
    a.Amount
FROM actual_clean AS a
LEFT JOIN dim_account AS d
	ON a.AccountCode = d.AccountCode
WHERE d.Accountcode IS NULL
	AND TRIM(COALESCE(a.AccountCode, '')) <> '';
	
-- =====================================================
-- PART E
-- =====================================================
SELECT
    a.TransactionID,
    a.BranchID
FROM actual_clean AS a
LEFT JOIN dim_branch AS b
    ON a.BranchID = b.BranchID
WHERE b.BranchID IS NULL;

SELECT
    a.TransactionID,
    a.MonthKeym
FROM actual_clean AS a
LEFT JOIN dim_month AS m
    ON a.MonthKey = m.MonthKey
WHERE m.MonthKey IS NULL;

-- =====================================================
-- PART F
-- =====================================================
SELECT
	a.TransactionID,
	a.MonthKey,
	a.VendorID,
	v.VendorName,
	v.VendorStatus,
	v.RiskRating,
	a.Description,
	a.Amount
FROM actual_clean AS a
INNER JOIN dim_vendor AS V
	ON a.VendorID = v.VendorID
WHERE v.VendorStatus = 'Inactive';

-- =====================================================
-- PART G
-- =====================================================
SELECT
    TransactionID,
    MonthKey,
    Description
FROM actual_clean
WHERE Description = UPPER(Description)
  AND Description <> LOWER(Description)
  AND TRIM(COALESCE(Description, '')) <> '';

-- =====================================================
-- PART H
-- =====================================================
SELECT
    TransactionID,
    PostingDate,
    MonthKey,
    BranchID,
    DepartmentID,
    AccountCode,
    Description,
    Amount
FROM actual_clean
WHERE AccountCode = 6600
  AND BranchID = 'BR03'
  AND DepartmentID = 'D02'
  AND Amount >= 20000
ORDER BY Amount DESC;

-- =====================================================
-- PART I
-- =====================================================
SELECT
    VendorID,
    DocumentNumber,
    COUNT(*) AS occurrence_count,
    ROUND(SUM(Amount), 2) AS combined_amount
FROM actual_clean
WHERE TRIM(COALESCE(VendorID, '')) <> ''
  AND TRIM(COALESCE(DocumentNumber, '')) <> ''
GROUP BY
    VendorID,
    DocumentNumber
HAVING COUNT(*) > 1;

-- =====================================================
-- PART J
-- =====================================================
SELECT
	TransactionID,
	COUNT(*) AS occurance_count
FROM actual_processed
GROUP BY TransactionID
HAVING COUNT(*) >1;

SELECT *
FROM actual_processed
WHERE TRIM(COALESCE(DepartmentID_Processed, '')) = '';

SELECT
    a.TransactionID,
    a.AccountCode_Processed
FROM actual_processed AS a
LEFT JOIN dim_account AS d
    ON a.AccountCode_Processed = d.AccountCode
WHERE d.AccountCode IS NULL;

-- =====================================================
-- PART K
-- =====================================================
SELECT
	MonthKey,
	BranchID,
	DepartmentID,
	AccountCode,
	COUNT(*) AS budget_key_count
FROM budget_clean
GROUP BY
	Monthkey,
	BranchID,
	DepartmentID,
	AccountCode
HAVING COUNT(*) >1;

-- =====================================================
-- PART L
-- =====================================================
SELECT COUNT(*) AS budget_scope_combinations
FROM (
		SELECT DISTINCT
			DepartmentID,
			AccountCode
		FROM budget_clean
);

WITH budget_scope AS (
    SELECT DISTINCT
        DepartmentID,
        AccountCode
    FROM budget_clean
),

expected_budget AS (
    SELECT
        m.MonthKey,
        b.BranchID,
        s.DepartmentID,
        s.AccountCode
    FROM dim_month AS m
    CROSS JOIN dim_branch AS b
    CROSS JOIN budget_scope AS s
)

SELECT
    e.MonthKey,
    e.BranchID,
    e.DepartmentID,
    e.AccountCode
FROM expected_budget AS e

LEFT JOIN budget_clean AS bc
    ON e.MonthKey = bc.MonthKey
   AND e.BranchID = bc.BranchID
   AND e.DepartmentID = bc.DepartmentID
   AND e.AccountCode = bc.AccountCode

WHERE bc.BudgetID IS NULL;

-- =====================================================
-- PART M
-- =====================================================
WITH budget_scope AS (
    SELECT DISTINCT
        DepartmentID,
        AccountCode
    FROM budget_clean
),

expected_budget AS (
    SELECT
        m.MonthKey,
        b.BranchID,
        s.DepartmentID,
        s.AccountCode
    FROM dim_month AS m
    CROSS JOIN dim_branch AS b
    CROSS JOIN budget_scope AS s
)

SELECT
    e.MonthKey,
    e.BranchID,
    e.DepartmentID,
    e.AccountCode
FROM expected_budget AS e

LEFT JOIN budget_processed AS bp
    ON e.MonthKey = bp.MonthKey
   AND e.BranchID = bp.BranchID
   AND e.DepartmentID = bp.DepartmentID
   AND e.AccountCode = bp.AccountCode

WHERE bp.BudgetID_Processed IS NULL;

-- =====================================================
-- PART N
-- =====================================================
SELECT
    'Duplicate transaction rows' AS validation_check,
    COUNT(*) AS exception_count
FROM actual_clean AS a
WHERE a.TransactionID IN (
    SELECT TransactionID
    FROM actual_clean
    GROUP BY TransactionID
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'Missing departments',
    COUNT(*)
FROM actual_clean
WHERE TRIM(COALESCE(DepartmentID, '')) = ''

UNION ALL

SELECT
    'Invalid account codes',
    COUNT(*)
FROM actual_clean AS a
LEFT JOIN dim_account AS d
    ON a.AccountCode = d.AccountCode
WHERE d.AccountCode IS NULL
  AND TRIM(COALESCE(a.AccountCode, '')) <> ''

UNION ALL

SELECT
    'Inactive vendor transactions',
    COUNT(*)
FROM actual_clean AS a
INNER JOIN dim_vendor AS v
    ON a.VendorID = v.VendorID
WHERE v.VendorStatus = 'Inactive'

UNION ALL

SELECT
    'Uppercase descriptions',
    COUNT(*)
FROM actual_clean
WHERE Description = UPPER(Description)
  AND Description <> LOWER(Description)
  AND TRIM(COALESCE(Description, '')) <> ''

UNION ALL

SELECT
    'Unusual repairs transactions',
    COUNT(*)
FROM actual_clean
WHERE AccountCode = 6600
  AND BranchID = 'BR03'
  AND DepartmentID = 'D02'
  AND Amount >= 20000;
  
COMPLETE 