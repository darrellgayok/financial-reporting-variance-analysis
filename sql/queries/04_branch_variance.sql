-- =====================================================
-- PART A: Annual Branch Budget vs Actual Summary
-- =====================================================

WITH actual_branch AS (
    SELECT
        a.BranchID,

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

    INNER JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.BranchID
),

budget_branch AS (
    SELECT
        b.BranchID,

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

    INNER JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.BranchID
)

SELECT
    a.BranchID,
    br.BranchName,
    br.City,

    ROUND(a.actual_revenue, 2)
        AS actual_revenue,

    ROUND(b.budget_revenue, 2)
        AS budget_revenue,

    ROUND(
        a.actual_revenue - b.budget_revenue,
        2
    ) AS revenue_variance,

    ROUND(
        a.actual_revenue - a.actual_cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        b.budget_revenue - b.budget_cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(
        (
            a.actual_revenue - a.actual_cost_of_sales
        )
        -
        (
            b.budget_revenue - b.budget_cost_of_sales
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

    ROUND(
        (
            a.actual_revenue
            - a.actual_cost_of_sales
            - a.actual_operating_expenses
        ) * 100.0
        / NULLIF(a.actual_revenue, 0),
        2
    ) AS actual_operating_margin_pct,

    a.transaction_count

FROM actual_branch AS a

INNER JOIN budget_branch AS b
    ON a.BranchID = b.BranchID

INNER JOIN dim_branch AS br
    ON a.BranchID = br.BranchID

ORDER BY a.BranchID;

-- =====================================================
-- PART B: Rank Branches by Operating Profit Variance
-- =====================================================

WITH actual_branch AS (
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

budget_branch AS (
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

    FROM actual_branch AS a

    JOIN budget_branch AS b
        ON a.BranchID = b.BranchID
)

SELECT
    v.BranchID,
    br.BranchName,

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

FROM branch_variance AS v

JOIN dim_branch AS br
    ON v.BranchID = br.BranchID

ORDER BY
    v.operating_profit_variance DESC;
	
-- =====================================================
-- PART C: Branch Variance Reconciliation
-- =====================================================

WITH actual_branch AS (
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

budget_branch AS (
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

branch_results AS (
    SELECT
        a.BranchID,

        a.revenue
        - a.cost_of_sales
        - a.operating_expenses
            AS actual_operating_profit,

        b.revenue
        - b.cost_of_sales
        - b.operating_expenses
            AS budget_operating_profit

    FROM actual_branch AS a

    JOIN budget_branch AS b
        ON a.BranchID = b.BranchID
)

-- =====================================================
-- PART D: Identifying the Missing Budget Exception at Branch Level
-- =====================================================
SELECT
    ROUND(
        SUM(actual_operating_profit),
        2
    ) AS branch_actual_operating_profit,

    ROUND(
        SUM(budget_operating_profit),
        2
    ) AS branch_budget_operating_profit,

    ROUND(
        SUM(
            actual_operating_profit
            - budget_operating_profit
        ),
        2
    ) AS branch_operating_profit_variance

FROM branch_results;

SELECT
    b.BranchID,
    br.BranchName,
    COUNT(*) AS missing_budget_lines,
    ROUND(
        SUM(b.BudgetAmount_Processed),
        2
    ) AS processed_budget_amount

FROM budget_processed AS b

JOIN dim_branch AS br
    ON b.BranchID = br.BranchID

WHERE b.BudgetLineStatus = 'Missing Source Line'

GROUP BY
    b.BranchID,
    br.BranchName;