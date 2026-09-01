-- =====================================================
-- PART I: Unusual Repairs & Maintenance
-- =====================================================

SELECT
    a.TransactionID,
    a.PostingDate,
    a.MonthKey,
    a.BranchID,
    br.BranchName,

    a.DepartmentID_Processed AS DepartmentID,
    dep.DepartmentName,

    a.AccountCode_Processed AS AccountCode,
    acc.AccountName,

    a.Description_Processed AS Description,
    a.VendorID,
    a.DocumentNumber,
    a.Amount

FROM actual_processed AS a

LEFT JOIN dim_branch AS br
    ON a.BranchID = br.BranchID

LEFT JOIN dim_department AS dep
    ON a.DepartmentID_Processed = dep.DepartmentID

LEFT JOIN dim_account AS acc
    ON CAST(a.AccountCode_Processed AS TEXT)
     = CAST(acc.AccountCode AS TEXT)

WHERE CAST(a.AccountCode_Processed AS TEXT) = '6600'
  AND a.BranchID = 'BR03'
  AND a.DepartmentID_Processed = 'D02'
  AND a.Amount >= 20000

ORDER BY a.Amount DESC;

-- =====================================================
-- PART J: Inactive Vendor Transaction
-- =====================================================

SELECT
    a.TransactionID,
    a.MonthKey,
    a.BranchID,
    a.DepartmentID_Processed AS DepartmentID,

    a.VendorID,
    v.VendorName,
    v.VendorStatus,
    v.RiskRating,

    a.DocumentNumber,
    a.Description_Processed AS Description,
    a.Amount

FROM actual_processed AS a

INNER JOIN dim_vendor AS v
    ON a.VendorID = v.VendorID

WHERE v.VendorStatus = 'Inactive';

-- =====================================================
-- PART K: Repeated Vendor Document Investigation
-- =====================================================

WITH repeated_documents AS (
    SELECT
        VendorID,
        DocumentNumber

    FROM actual_clean

    WHERE TRIM(COALESCE(VendorID, '')) <> ''
      AND TRIM(COALESCE(DocumentNumber, '')) <> ''

    GROUP BY
        VendorID,
        DocumentNumber

    HAVING COUNT(*) > 1
)

SELECT
    a.TransactionID,
    a.MonthKey,
    a.VendorID,
    a.DocumentNumber,
    a.BranchID,
    a.DepartmentID,
    a.AccountCode,
    a.Description,
    a.Amount

FROM actual_clean AS a

INNER JOIN repeated_documents AS r
    ON a.VendorID = r.VendorID
   AND a.DocumentNumber = r.DocumentNumber

ORDER BY
    a.VendorID,
    a.DocumentNumber,
    a.TransactionID;
	
-- =====================================================
-- PART L: Corrected Transaction Audit Trail
-- =====================================================

SELECT
    TransactionID,
    MonthKey,

    DepartmentID
        AS original_department,

    DepartmentID_Processed
        AS processed_department,

    AccountCode
        AS original_account,

    AccountCode_Processed
        AS processed_account,

    Description
        AS original_description,

    Description_Processed
        AS processed_description,

    ResolutionAction,
    ReportingTreatment

FROM actual_processed

WHERE
       COALESCE(DepartmentID, '')
       <> COALESCE(DepartmentID_Processed, '')

    OR CAST(COALESCE(AccountCode, '') AS TEXT)
       <> CAST(COALESCE(AccountCode_Processed, '') AS TEXT)

    OR COALESCE(Description, '')
       <> COALESCE(Description_Processed, '')

ORDER BY MonthKey;

-- =====================================================
-- PART M: Duplicate Removal Control
-- =====================================================

SELECT
    (SELECT COUNT(*) FROM actual_clean)
        AS clean_rows,

    (SELECT COUNT(*) FROM actual_processed)
        AS processed_rows,

    (
        SELECT COUNT(*) FROM actual_clean
    )
    -
    (
        SELECT COUNT(*) FROM actual_processed
    )
        AS rows_removed;
		
-- =====================================================
-- PART N: Open Exception Summary
-- =====================================================

WITH repeated_documents AS (
    SELECT
        VendorID,
        DocumentNumber

    FROM actual_clean

    WHERE TRIM(COALESCE(VendorID, '')) <> ''
      AND TRIM(COALESCE(DocumentNumber, '')) <> ''

    GROUP BY
        VendorID,
        DocumentNumber

    HAVING COUNT(*) > 1
),

exception_counts AS (

    SELECT
        'Inactive Vendor' AS exception_type,
        COUNT(*) AS exception_count

    FROM actual_processed AS a

    INNER JOIN dim_vendor AS v
        ON a.VendorID = v.VendorID

    WHERE v.VendorStatus = 'Inactive'


    UNION ALL


    SELECT
        'Unusual Repairs and Maintenance',
        COUNT(*)

    FROM actual_processed

    WHERE CAST(AccountCode_Processed AS TEXT) = '6600'
      AND BranchID = 'BR03'
      AND DepartmentID_Processed = 'D02'
      AND Amount >= 20000


    UNION ALL


    SELECT
        'Repeated Vendor Document',
        COUNT(*)

    FROM actual_clean AS a

    INNER JOIN repeated_documents AS r
        ON a.VendorID = r.VendorID
       AND a.DocumentNumber = r.DocumentNumber


    UNION ALL


    SELECT
        'Missing Budget Source Line',
        COUNT(*)

    FROM budget_processed

    WHERE BudgetLineStatus = 'Missing Source Line'
)

SELECT
    exception_type,
    exception_count,

    (
        SELECT SUM(exception_count)
        FROM exception_counts
    ) AS total_open_exceptions

FROM exception_counts;

-- =====================================================
-- PART O: Exception Reconciliation
-- =====================================================

WITH corrected_transactions AS (
    SELECT COUNT(*) AS corrected_count

    FROM actual_processed

    WHERE
           COALESCE(DepartmentID, '')
           <> COALESCE(DepartmentID_Processed, '')

        OR CAST(COALESCE(AccountCode, '') AS TEXT)
           <> CAST(COALESCE(AccountCode_Processed, '') AS TEXT)

        OR COALESCE(Description, '')
           <> COALESCE(Description_Processed, '')
),

duplicate_removal AS (
    SELECT
        (
            (SELECT COUNT(*) FROM actual_clean)
            -
            (SELECT COUNT(*) FROM actual_processed)
        ) AS removed_count
),

repeated_documents AS (
    SELECT
        VendorID,
        DocumentNumber

    FROM actual_clean

    WHERE TRIM(COALESCE(VendorID, '')) <> ''
      AND TRIM(COALESCE(DocumentNumber, '')) <> ''

    GROUP BY
        VendorID,
        DocumentNumber

    HAVING COUNT(*) > 1
),

open_exceptions AS (

    SELECT COUNT(*) AS exception_count
    FROM actual_processed AS a
    JOIN dim_vendor AS v
        ON a.VendorID = v.VendorID
    WHERE v.VendorStatus = 'Inactive'

    UNION ALL

    SELECT COUNT(*)
    FROM actual_processed
    WHERE CAST(AccountCode_Processed AS TEXT) = '6600'
      AND BranchID = 'BR03'
      AND DepartmentID_Processed = 'D02'
      AND Amount >= 20000

    UNION ALL

    SELECT COUNT(*)
    FROM actual_clean AS a
    JOIN repeated_documents AS r
        ON a.VendorID = r.VendorID
       AND a.DocumentNumber = r.DocumentNumber

    UNION ALL

    SELECT COUNT(*)
    FROM budget_processed
    WHERE BudgetLineStatus = 'Missing Source Line'
)

SELECT
    c.corrected_count
        + d.removed_count
        AS resolved_exceptions,

    (
        SELECT SUM(exception_count)
        FROM open_exceptions
    ) AS open_exceptions,

    (
        c.corrected_count
        + d.removed_count
        +
        (
            SELECT SUM(exception_count)
            FROM open_exceptions
        )
    ) AS total_exceptions

FROM corrected_transactions AS c

CROSS JOIN duplicate_removal AS d;