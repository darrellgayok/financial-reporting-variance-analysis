-- =====================================================
-- PART F: Annual Department Budget vs Actual Summary
-- =====================================================

WITH actual_department AS (
    SELECT
        a.DepartmentID_Processed AS DepartmentID,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN a.Amount ELSE 0
            END
        ) AS actual_revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN a.Amount ELSE 0
            END
        ) AS actual_cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN a.Amount ELSE 0
            END
        ) AS actual_operating_expenses,

        COUNT(*) AS transaction_count

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.DepartmentID_Processed
),

budget_department AS (
    SELECT
        b.DepartmentID,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS budget_revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS budget_cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS budget_operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.DepartmentID
)

SELECT
    a.DepartmentID,
    dep.DepartmentName,
    dep.DepartmentCategory,

    ROUND(a.actual_revenue, 2)
        AS actual_revenue,

    ROUND(b.budget_revenue, 2)
        AS budget_revenue,

    ROUND(
        a.actual_revenue - b.budget_revenue,
        2
    ) AS revenue_variance,

    ROUND(
        a.actual_revenue
        - a.actual_cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        b.budget_revenue
        - b.budget_cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(
        (
            a.actual_revenue
            - a.actual_cost_of_sales
        )
        -
        (
            b.budget_revenue
            - b.budget_cost_of_sales
        ),
        2
    ) AS gross_profit_variance,

    ROUND(a.actual_operating_expenses, 2)
        AS actual_operating_expenses,

    ROUND(b.budget_operating_expenses, 2)
        AS budget_operating_expenses,

    ROUND(
        b.budget_operating_expenses
        - a.actual_operating_expenses,
        2
    ) AS operating_expenses_variance,

    ROUND(
        a.actual_revenue
        - a.actual_cost_of_sales
        - a.actual_operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        b.budget_revenue
        - b.budget_cost_of_sales
        - b.budget_operating_expenses,
        2
    ) AS budget_operating_profit,

    ROUND(
        (
            a.actual_revenue
            - a.actual_cost_of_sales
            - a.actual_operating_expenses
        )
        -
        (
            b.budget_revenue
            - b.budget_cost_of_sales
            - b.budget_operating_expenses
        ),
        2
    ) AS operating_profit_variance,

    a.transaction_count

FROM actual_department AS a

JOIN budget_department AS b
    ON a.DepartmentID = b.DepartmentID

JOIN dim_department AS dep
    ON a.DepartmentID = dep.DepartmentID

ORDER BY a.DepartmentID;

-- =====================================================
-- PART G: Rank Departments by Operating Profit Variance
-- =====================================================

WITH actual_department AS (
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

budget_department AS (
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

    FROM actual_department AS a

    JOIN budget_department AS b
        ON a.DepartmentID = b.DepartmentID
)

SELECT
    v.DepartmentID,
    dep.DepartmentName,

    ROUND(
        v.operating_profit_variance,
        2
    ) AS operating_profit_variance,

    CASE
        WHEN v.operating_profit_variance > 0
        THEN 'Favourable'

        WHEN v.operating_profit_variance < 0
        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS variance_status

FROM department_variance AS v

JOIN dim_department AS dep
    ON v.DepartmentID = dep.DepartmentID

ORDER BY
    v.operating_profit_variance DESC;
	
-- =====================================================
-- PART H: Department Variance Reconciliation
-- =====================================================

WITH actual_department AS (
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

budget_department AS (
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

department_results AS (
    SELECT
        a.DepartmentID,

        a.revenue
        - a.cost_of_sales
        - a.operating_expenses
            AS actual_operating_profit,

        b.revenue
        - b.cost_of_sales
        - b.operating_expenses
            AS budget_operating_profit

    FROM actual_department AS a

    JOIN budget_department AS b
        ON a.DepartmentID = b.DepartmentID
)

SELECT
    ROUND(
        SUM(actual_operating_profit),
        2
    ) AS department_actual_operating_profit,

    ROUND(
        SUM(budget_operating_profit),
        2
    ) AS department_budget_operating_profit,

    ROUND(
        SUM(
            actual_operating_profit
            - budget_operating_profit
        ),
        2
    ) AS department_operating_profit_variance

FROM department_results;

-- =====================================================
-- PART I: Locating the Budget Exception by Department
-- =====================================================

SELECT
    b.DepartmentID,
    dep.DepartmentName,
    COUNT(*) AS missing_budget_lines

FROM budget_processed AS b

JOIN dim_department AS dep
    ON b.DepartmentID = dep.DepartmentID

WHERE b.BudgetLineStatus = 'Missing Source Line'

GROUP BY
    b.DepartmentID,
    dep.DepartmentName;
	
-- =====================================================
-- PART J: Branch and Department Variance Matrix
-- =====================================================

WITH actual_summary AS (
    SELECT
        a.BranchID,
        a.DepartmentID_Processed AS DepartmentID,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN a.Amount ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN a.Amount ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN a.Amount ELSE 0
            END
        ) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY
        a.BranchID,
        a.DepartmentID_Processed
),

budget_summary AS (
    SELECT
        b.BranchID,
        b.DepartmentID,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN b.BudgetAmount_Processed ELSE 0
            END
        ) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY
        b.BranchID,
        b.DepartmentID
)

SELECT
    a.BranchID,
    br.BranchName,

    a.DepartmentID,
    dep.DepartmentName,

    ROUND(
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
        ),
        2
    ) AS operating_profit_variance

FROM actual_summary AS a

JOIN budget_summary AS b
    ON a.BranchID = b.BranchID
   AND a.DepartmentID = b.DepartmentID

JOIN dim_branch AS br
    ON a.BranchID = br.BranchID

JOIN dim_department AS dep
    ON a.DepartmentID = dep.DepartmentID

ORDER BY
    operating_profit_variance DESC;