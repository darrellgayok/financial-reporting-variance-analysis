-- =====================================================
-- PART A: Consolidated Management Insights
-- =====================================================

WITH

-- -----------------------------------------------------
-- Company
-- -----------------------------------------------------

actual_company AS (
    SELECT
        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

budget_company AS (
    SELECT
        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

company_variance AS (
    SELECT
        a.revenue - b.revenue
            AS revenue_variance,

        (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) AS operating_profit_variance

    FROM actual_company AS a
    CROSS JOIN budget_company AS b
),

-- -----------------------------------------------------
-- Monthly
-- -----------------------------------------------------

monthly_actual AS (
    SELECT
        a.MonthKey,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.MonthKey
),

monthly_budget AS (
    SELECT
        b.MonthKey,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.MonthKey
),

monthly_variance AS (
    SELECT
        a.MonthKey,

        (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) AS operating_profit_variance

    FROM monthly_actual AS a

    JOIN monthly_budget AS b
        ON a.MonthKey = b.MonthKey
),

-- -----------------------------------------------------
-- Branch
-- -----------------------------------------------------

branch_actual AS (
    SELECT
        a.BranchID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.BranchID
),

branch_budget AS (
    SELECT
        b.BranchID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.BranchID
),

branch_variance AS (
    SELECT
        a.BranchID,
        br.BranchName,

        (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) AS operating_profit_variance

    FROM branch_actual AS a

    JOIN branch_budget AS b
        ON a.BranchID = b.BranchID

    JOIN dim_branch AS br
        ON a.BranchID = br.BranchID
),

-- -----------------------------------------------------
-- Department
-- -----------------------------------------------------

department_actual AS (
    SELECT
        a.DepartmentID_Processed AS DepartmentID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.DepartmentID_Processed
),

department_budget AS (
    SELECT
        b.DepartmentID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.DepartmentID
),

department_variance AS (
    SELECT
        a.DepartmentID,
        dep.DepartmentName,

        (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) AS operating_profit_variance

    FROM department_actual AS a

    JOIN department_budget AS b
        ON a.DepartmentID = b.DepartmentID

    JOIN dim_department AS dep
        ON a.DepartmentID = dep.DepartmentID
),

-- -----------------------------------------------------
-- Account
-- -----------------------------------------------------

actual_account AS (
    SELECT
        CAST(AccountCode_Processed AS TEXT) AS AccountCode,
        SUM(Amount) AS actual_amount

    FROM actual_processed

    GROUP BY CAST(AccountCode_Processed AS TEXT)
),

budget_account AS (
    SELECT
        CAST(AccountCode AS TEXT) AS AccountCode,
        SUM(BudgetAmount_Processed) AS budget_amount

    FROM budget_processed

    GROUP BY CAST(AccountCode AS TEXT)
),

account_variance AS (
    SELECT
        d.AccountCode,
        d.AccountName,

        CASE
            WHEN d.StatementSection = 'Revenue'
            THEN
                COALESCE(a.actual_amount, 0)
                - COALESCE(b.budget_amount, 0)

            ELSE
                COALESCE(b.budget_amount, 0)
                - COALESCE(a.actual_amount, 0)

        END AS favourable_variance

    FROM dim_account AS d

    LEFT JOIN actual_account AS a
        ON CAST(d.AccountCode AS TEXT)
         = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT)
         = b.AccountCode
),

-- -----------------------------------------------------
-- Open exceptions
-- -----------------------------------------------------

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

open_exception_counts AS (

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
),

open_exception_total AS (
    SELECT
        SUM(exception_count) AS open_exceptions

    FROM open_exception_counts
)

-- =====================================================
-- Final Management Insight Output
-- =====================================================

SELECT
    1 AS display_order,
    'Company' AS insight_area,
    'Operating Profit Variance' AS insight,
    'Company Total' AS entity,
    ROUND(operating_profit_variance, 2) AS value,

    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'
        WHEN operating_profit_variance < 0
        THEN 'Unfavourable'
        ELSE 'On Budget'
    END AS status

FROM company_variance


UNION ALL


SELECT
    2,
    'Company',
    'Revenue Variance',
    'Company Total',
    ROUND(revenue_variance, 2),

    CASE
        WHEN revenue_variance > 0
        THEN 'Favourable'
        WHEN revenue_variance < 0
        THEN 'Unfavourable'
        ELSE 'On Budget'
    END

FROM company_variance


UNION ALL


SELECT
    3,
    'Monthly',
    'Strongest Month',
    MonthKey,
    ROUND(operating_profit_variance, 2),
    'Favourable'

FROM monthly_variance

WHERE operating_profit_variance = (
    SELECT MAX(operating_profit_variance)
    FROM monthly_variance
)


UNION ALL


SELECT
    4,
    'Monthly',
    'Weakest Month',
    MonthKey,
    ROUND(operating_profit_variance, 2),
    'Unfavourable'

FROM monthly_variance

WHERE operating_profit_variance = (
    SELECT MIN(operating_profit_variance)
    FROM monthly_variance
)


UNION ALL


SELECT
    5,
    'Branch',
    'Strongest Branch',
    BranchName,
    ROUND(operating_profit_variance, 2),

    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'
        ELSE 'Unfavourable'
    END

FROM branch_variance

WHERE operating_profit_variance = (
    SELECT MAX(operating_profit_variance)
    FROM branch_variance
)


UNION ALL


SELECT
    6,
    'Branch',
    'Weakest Branch',
    BranchName,
    ROUND(operating_profit_variance, 2),

    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'
        ELSE 'Unfavourable'
    END

FROM branch_variance

WHERE operating_profit_variance = (
    SELECT MIN(operating_profit_variance)
    FROM branch_variance
)


UNION ALL


SELECT
    7,
    'Department',
    'Strongest Department',
    DepartmentName,
    ROUND(operating_profit_variance, 2),

    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'
        ELSE 'Unfavourable'
    END

FROM department_variance

WHERE operating_profit_variance = (
    SELECT MAX(operating_profit_variance)
    FROM department_variance
)


UNION ALL


SELECT
    8,
    'Department',
    'Weakest Department',
    DepartmentName,
    ROUND(operating_profit_variance, 2),

    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'
        ELSE 'Unfavourable'
    END

FROM department_variance

WHERE operating_profit_variance = (
    SELECT MIN(operating_profit_variance)
    FROM department_variance
)


UNION ALL


SELECT
    9,
    'Account',
    'Largest Favourable Account',
    AccountName,
    ROUND(favourable_variance, 2),
    'Favourable'

FROM account_variance

WHERE favourable_variance = (
    SELECT MAX(favourable_variance)
    FROM account_variance
)


UNION ALL


SELECT
    10,
    'Account',
    'Largest Unfavourable Account',
    AccountName,
    ROUND(favourable_variance, 2),
    'Unfavourable'

FROM account_variance

WHERE favourable_variance = (
    SELECT MIN(favourable_variance)
    FROM account_variance
)


UNION ALL


SELECT
    11,
    'Controls',
    'Open Exceptions',
    'Control Exceptions',
    open_exceptions,
    'Open'

FROM open_exception_total

ORDER BY display_order;

-- =====================================================
-- PART B: Final SQL Reconciliation Controls
-- =====================================================

WITH

actual_financial AS (
    SELECT
        SUM(a.Amount) AS total_amount,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

budget_financial AS (
    SELECT
        SUM(b.BudgetAmount_Processed)
            AS total_amount,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

branch_actual AS (
    SELECT
        a.BranchID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.BranchID
),

branch_budget AS (
    SELECT
        b.BranchID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.BranchID
),

branch_variance AS (
    SELECT
        SUM(
            (
                a.revenue
                - a.cost_of_sales
                - a.operating_expenses
            )
            -
            (
                b.revenue
                - b.cost_of_sales
                - b.operating_expenses
            )
        ) AS variance_total

    FROM branch_actual AS a

    JOIN branch_budget AS b
        ON a.BranchID = b.BranchID
),

department_actual AS (
    SELECT
        a.DepartmentID_Processed AS DepartmentID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0
        END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.DepartmentID_Processed
),

department_budget AS (
    SELECT
        b.DepartmentID,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0
        END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.DepartmentID
),

department_variance AS (
    SELECT
        SUM(
            (
                a.revenue
                - a.cost_of_sales
                - a.operating_expenses
            )
            -
            (
                b.revenue
                - b.cost_of_sales
                - b.operating_expenses
            )
        ) AS variance_total

    FROM department_actual AS a

    JOIN department_budget AS b
        ON a.DepartmentID = b.DepartmentID
),

actual_account AS (
    SELECT
        CAST(AccountCode_Processed AS TEXT)
            AS AccountCode,

        SUM(Amount)
            AS actual_amount

    FROM actual_processed

    GROUP BY CAST(AccountCode_Processed AS TEXT)
),

budget_account AS (
    SELECT
        CAST(AccountCode AS TEXT)
            AS AccountCode,

        SUM(BudgetAmount_Processed)
            AS budget_amount

    FROM budget_processed

    GROUP BY CAST(AccountCode AS TEXT)
),

account_variance AS (
    SELECT
        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN
                    COALESCE(a.actual_amount, 0)
                    - COALESCE(b.budget_amount, 0)

                ELSE
                    COALESCE(b.budget_amount, 0)
                    - COALESCE(a.actual_amount, 0)
            END
        ) AS variance_total

    FROM dim_account AS d

    LEFT JOIN actual_account AS a
        ON CAST(d.AccountCode AS TEXT)
         = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT)
         = b.AccountCode
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

open_exception_counts AS (

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
),

control_values AS (

    SELECT
        1 AS display_order,
        'Actual processed rows' AS control_name,
        (SELECT COUNT(*) FROM actual_processed)
            AS actual_value,
        5828 AS expected_value


    UNION ALL


    SELECT
        2,
        'Budget processed rows',
        (SELECT COUNT(*) FROM budget_processed),
        2160


    UNION ALL


    SELECT
        3,
        'Actual total amount',
        (SELECT total_amount FROM actual_financial),
        37301490


    UNION ALL


    SELECT
        4,
        'Budget total amount',
        (SELECT total_amount FROM budget_financial),
        36730500


    UNION ALL


    SELECT
        5,
        'Actual revenue',
        (SELECT revenue FROM actual_financial),
        19806040


    UNION ALL


    SELECT
        6,
        'Budget revenue',
        (SELECT revenue FROM budget_financial),
        19515100


    UNION ALL


    SELECT
        7,
        'Actual operating profit',

        (
            SELECT
                revenue
                - cost_of_sales
                - operating_expenses
            FROM actual_financial
        ),

        2310590


    UNION ALL


    SELECT
        8,
        'Budget operating profit',

        (
            SELECT
                revenue
                - cost_of_sales
                - operating_expenses
            FROM budget_financial
        ),

        2299700


    UNION ALL


    SELECT
        9,
        'Company operating profit variance',

        (
            SELECT
                (
                    a.revenue
                    - a.cost_of_sales
                    - a.operating_expenses
                )
                -
                (
                    b.revenue
                    - b.cost_of_sales
                    - b.operating_expenses
                )

            FROM actual_financial AS a
            CROSS JOIN budget_financial AS b
        ),

        10890


    UNION ALL


    SELECT
        10,
        'Branch variance reconciliation',
        (SELECT variance_total FROM branch_variance),
        10890


    UNION ALL


    SELECT
        11,
        'Department variance reconciliation',
        (SELECT variance_total FROM department_variance),
        10890


    UNION ALL


    SELECT
        12,
        'Account variance reconciliation',
        (SELECT variance_total FROM account_variance),
        10890


    UNION ALL


    SELECT
        13,
        'Missing budget source lines',

        (
            SELECT COUNT(*)
            FROM budget_processed
            WHERE BudgetLineStatus = 'Missing Source Line'
        ),

        1


    UNION ALL


    SELECT
        14,
        'Open exceptions',

        (
            SELECT SUM(exception_count)
            FROM open_exception_counts
        ),

        6
)

SELECT
    control_name,

    ROUND(actual_value, 2)
        AS actual_value,

    ROUND(expected_value, 2)
        AS expected_value,

    ROUND(
        actual_value - expected_value,
        2
    ) AS difference,

    CASE
        WHEN ABS(
            actual_value - expected_value
        ) < 0.005

        THEN 'PASS'

        ELSE 'REVIEW'
    END AS control_status

FROM control_values

ORDER BY display_order;