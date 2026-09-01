-- =====================================================
-- PART B: Confirming budget amounts by statement section, Budget statement-section validation
-- =====================================================
SELECT
    d.StatementSection,
    ROUND(SUM(b.BudgetAmount_Processed), 2) AS budget_amount
FROM budget_processed AS b

INNER JOIN dim_account AS d
    ON CAST(b.AccountCode AS TEXT)
     = CAST(d.AccountCode AS TEXT)

GROUP BY d.StatementSection

ORDER BY
    CASE d.StatementSection
        WHEN 'Revenue' THEN 1
        WHEN 'Cost of Sales' THEN 2
        WHEN 'Operating Expenses' THEN 3
        ELSE 99
    END;
	
-- =====================================================
-- PART C: Rebuilding the annual budget P&L, Annual budget P&L
-- =====================================================
WITH budget_summary AS (
    SELECT

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS operating_expenses

    FROM budget_processed AS b

    INNER JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)
)

SELECT
    ROUND(revenue, 2) AS budget_revenue,

    ROUND(cost_of_sales, 2)
        AS budget_cost_of_sales,

    ROUND(
        revenue - cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(operating_expenses, 2)
        AS budget_operating_expenses,

    ROUND(
        revenue
        - cost_of_sales
        - operating_expenses,
        2
    ) AS budget_operating_profit

FROM budget_summary;

-- =====================================================
-- PART D: Rebuilding the annual Budget vs Actual comparison, Annual Budget vs Actual
-- =====================================================
WITH actual_summary AS (
    SELECT
        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN a.Amount
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN a.Amount
                ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN a.Amount
                ELSE 0
            END
        ) AS operating_expenses

    FROM actual_processed AS a

    INNER JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

budget_summary AS (
    SELECT
        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS operating_expenses

    FROM budget_processed AS b

    INNER JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)
)

SELECT
    ROUND(a.revenue, 2)
        AS actual_revenue,

    ROUND(b.revenue, 2)
        AS budget_revenue,

    ROUND(a.revenue - b.revenue, 2)
        AS revenue_variance,

    ROUND(a.cost_of_sales, 2)
        AS actual_cost_of_sales,

    ROUND(b.cost_of_sales, 2)
        AS budget_cost_of_sales,

    ROUND(b.cost_of_sales - a.cost_of_sales, 2)
        AS cost_of_sales_variance,

    ROUND(
        a.revenue - a.cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        b.revenue - b.cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(
        (a.revenue - a.cost_of_sales)
        -
        (b.revenue - b.cost_of_sales),
        2
    ) AS gross_profit_variance,

    ROUND(a.operating_expenses, 2)
        AS actual_operating_expenses,

    ROUND(b.operating_expenses, 2)
        AS budget_operating_expenses,

    ROUND(
        b.operating_expenses
        - a.operating_expenses,
        2
    ) AS operating_expenses_variance,

    ROUND(
        a.revenue
        - a.cost_of_sales
        - a.operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        b.revenue
        - b.cost_of_sales
        - b.operating_expenses,
        2
    ) AS budget_operating_profit,

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
CROSS JOIN budget_summary AS b;

-- =====================================================
-- PART E: Adding variance status, Favourable / Unfavourable logic
-- =====================================================
WITH actual_summary AS (
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

budget_summary AS (
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

variance_summary AS (

    SELECT
        1 AS display_order,
        'Revenue' AS financial_line,
        a.revenue AS actual,
        b.revenue AS budget,
        a.revenue - b.revenue AS favourable_variance
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        2,
        'Cost of Sales',
        a.cost_of_sales,
        b.cost_of_sales,
        b.cost_of_sales - a.cost_of_sales
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        3,
        'Gross Profit',
        a.revenue - a.cost_of_sales,
        b.revenue - b.cost_of_sales,
        (a.revenue - a.cost_of_sales)
        - (b.revenue - b.cost_of_sales)
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        4,
        'Operating Expenses',
        a.operating_expenses,
        b.operating_expenses,
        b.operating_expenses - a.operating_expenses
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        5,
        'Operating Profit',
        a.revenue - a.cost_of_sales - a.operating_expenses,
        b.revenue - b.cost_of_sales - b.operating_expenses,
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
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b
)

SELECT
    display_order,
    financial_line,
    ROUND(actual, 2) AS actual,
    ROUND(budget, 2) AS budget,
    ROUND(favourable_variance, 2) AS favourable_variance,

    CASE
        WHEN favourable_variance > 0
        THEN 'Favourable'

        WHEN favourable_variance < 0
        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS variance_status

FROM variance_summary

ORDER BY display_order;

-- =====================================================
-- PART F: Calculating annual variance percentages, Annual variance percentages
-- =====================================================
WITH actual_summary AS (
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

budget_summary AS (
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

variance_summary AS (

    SELECT
        1 AS display_order,
        'Revenue' AS financial_line,
        a.revenue AS actual,
        b.revenue AS budget,
        a.revenue - b.revenue AS favourable_variance
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        2,
        'Cost of Sales',
        a.cost_of_sales,
        b.cost_of_sales,
        b.cost_of_sales - a.cost_of_sales
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        3,
        'Gross Profit',
        a.revenue - a.cost_of_sales,
        b.revenue - b.cost_of_sales,
        (a.revenue - a.cost_of_sales)
        - (b.revenue - b.cost_of_sales)
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        4,
        'Operating Expenses',
        a.operating_expenses,
        b.operating_expenses,
        b.operating_expenses - a.operating_expenses
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b

    UNION ALL

    SELECT
        5,
        'Operating Profit',
        a.revenue - a.cost_of_sales - a.operating_expenses,
        b.revenue - b.cost_of_sales - b.operating_expenses,
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
    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b
)

SELECT
    display_order,
    financial_line,
    ROUND(actual, 2) AS actual,
    ROUND(budget, 2) AS budget,
    ROUND(favourable_variance, 2) AS favourable_variance,

    ROUND(
        favourable_variance * 100.0
        / NULLIF(budget, 0),
        2
    ) AS variance_pct,

    CASE
        WHEN favourable_variance > 0
        THEN 'Favourable'
        WHEN favourable_variance < 0
        THEN 'Unfavourable'
        ELSE 'On Budget'
    END AS variance_status

FROM variance_summary

ORDER BY display_order;

-- =====================================================
-- PART G: Building monthly Actual and Budget summaries, Monthly Budget vs Actual
-- =====================================================
WITH monthly_actual AS (
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
)

SELECT
    a.MonthKey,

    ROUND(a.revenue, 2)
        AS actual_revenue,

    ROUND(b.revenue, 2)
        AS budget_revenue,

    ROUND(a.revenue - b.revenue, 2)
        AS revenue_variance,

    ROUND(
        a.revenue - a.cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        b.revenue - b.cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(
        (a.revenue - a.cost_of_sales)
        -
        (b.revenue - b.cost_of_sales),
        2
    ) AS gross_profit_variance,

    ROUND(
        a.revenue
        - a.cost_of_sales
        - a.operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        b.revenue
        - b.cost_of_sales
        - b.operating_expenses,
        2
    ) AS budget_operating_profit,

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

FROM monthly_actual AS a

INNER JOIN monthly_budget AS b
    ON a.MonthKey = b.MonthKey

ORDER BY a.MonthKey;

-- =====================================================
-- PART H: Verifying monthly Operating Profit variance, 
-- =====================================================
Month  Actual OP	 Budget OP	 Variance
Jan	   4,610	     110,300	 -105,690
Feb	  -47,690	     86,600	     -134,290
Mar	  64,190	     144,700	 -80,510
Apr	  141,040	     171,500	 -30,460
May	  206,920	     191,100	  15,820
Jun	  282,170	     218,000	  64,170
Jul	  169,730	     197,000	 -27,270
Aug	  265,110	     213,800	  51,310
Sep	  230,260	     229,000	  1,260
Oct	  366,800	     238,200	  128,600
Nov	  367,470	     261,300	  106,170
Dec	  259,980	     238,200	  21,780

So, sum of monthly variance is equal to = RM10,890 favourable

-- =====================================================
-- PART I: Adding monthly variance status
-- =====================================================
WITH monthly_actual AS (
    SELECT
        a.MonthKey,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN a.Amount
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN a.Amount
                ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN a.Amount
                ELSE 0
            END
        ) AS operating_expenses

    FROM actual_processed AS a

    INNER JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.MonthKey
),

monthly_budget AS (
    SELECT
        b.MonthKey,

        SUM(
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS revenue,

        SUM(
            CASE
                WHEN d.StatementSection = 'Cost of Sales'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS cost_of_sales,

        SUM(
            CASE
                WHEN d.StatementSection = 'Operating Expenses'
                THEN b.BudgetAmount_Processed
                ELSE 0
            END
        ) AS operating_expenses

    FROM budget_processed AS b

    INNER JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.MonthKey
)

SELECT
    a.MonthKey,

    ROUND(a.revenue, 2)
        AS actual_revenue,

    ROUND(b.revenue, 2)
        AS budget_revenue,

    ROUND(
        a.revenue - b.revenue,
        2
    ) AS revenue_variance,

    ROUND(
        a.revenue - a.cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        b.revenue - b.cost_of_sales,
        2
    ) AS budget_gross_profit,

    ROUND(
        (a.revenue - a.cost_of_sales)
        -
        (b.revenue - b.cost_of_sales),
        2
    ) AS gross_profit_variance,

    ROUND(
        a.revenue
        - a.cost_of_sales
        - a.operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        b.revenue
        - b.cost_of_sales
        - b.operating_expenses,
        2
    ) AS budget_operating_profit,

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
    ) AS operating_profit_variance,

    CASE
        WHEN (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) > 0
        THEN 'Favourable'

        WHEN (
            a.revenue
            - a.cost_of_sales
            - a.operating_expenses
        )
        -
        (
            b.revenue
            - b.cost_of_sales
            - b.operating_expenses
        ) < 0
        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS operating_profit_status

FROM monthly_actual AS a

INNER JOIN monthly_budget AS b
    ON a.MonthKey = b.MonthKey

ORDER BY a.MonthKey;

-- =====================================================
-- PART J: Count monthly performance status, Monthly performance status
-- =====================================================
WITH monthly_actual AS (
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
)

SELECT
    CASE
        WHEN operating_profit_variance > 0
        THEN 'Favourable'

        WHEN operating_profit_variance < 0
        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS variance_status,

    COUNT(*) AS month_count

FROM monthly_variance

GROUP BY variance_status

ORDER BY month_count DESC;

-- =====================================================
-- PART K: Identifying strongest and weakest month, Strongest and weakest months
-- =====================================================
WITH monthly_actual AS (
    SELECT
        a.MonthKey,

        SUM(CASE
            WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0 END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0 END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0 END) AS operating_expenses

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
            THEN b.BudgetAmount_Processed ELSE 0 END) AS revenue,

        SUM(CASE
            WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0 END) AS cost_of_sales,

        SUM(CASE
            WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0 END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY b.MonthKey
)

SELECT
    a.MonthKey,

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

FROM monthly_actual AS a

JOIN monthly_budget AS b
    ON a.MonthKey = b.MonthKey

ORDER BY operating_profit_variance DESC;

-- =====================================================
-- PART L: Dectecting the unbudgeted actual through SQL
-- the missing source budget line are: 2025-08 | BR03 | D02 | 6600
-- =====================================================
SELECT
    a.MonthKey,
    a.BranchID,
    a.DepartmentID_Processed AS DepartmentID,
    a.AccountCode_Processed AS AccountCode,

    ROUND(SUM(a.Amount), 2)
        AS actual_amount,

    ROUND(
        MAX(b.BudgetAmount_Processed),
        2
    ) AS budget_amount,

    MAX(b.BudgetLineStatus)
        AS budget_line_status

FROM actual_processed AS a

INNER JOIN budget_processed AS b
    ON a.MonthKey = b.MonthKey
   AND a.BranchID = b.BranchID
   AND a.DepartmentID_Processed = b.DepartmentID
   AND CAST(a.AccountCode_Processed AS TEXT)
       = CAST(b.AccountCode AS TEXT)

WHERE b.BudgetLineStatus = 'Missing Source Line'

GROUP BY
    a.MonthKey,
    a.BranchID,
    a.DepartmentID_Processed,
    a.AccountCode_Processed;

-- =====================================================
-- PART M: Adding a budget-line interpretation
-- =====================================================
SELECT
    a.MonthKey,
    a.BranchID,
    a.DepartmentID_Processed AS DepartmentID,
    a.AccountCode_Processed AS AccountCode,

    ROUND(
        SUM(a.Amount),
        2
    ) AS actual_amount,

    ROUND(
        MAX(b.BudgetAmount_Processed),
        2
    ) AS budget_amount,

    MAX(b.BudgetLineStatus)
        AS budget_line_status,

    CASE
        WHEN MAX(b.BudgetLineStatus) = 'Missing Source Line'
             AND SUM(a.Amount) > 0
        THEN 'Unbudgeted Actual'

        ELSE 'Standard Budget vs Actual'
    END AS reporting_status

FROM actual_processed AS a

INNER JOIN budget_processed AS b
    ON a.MonthKey = b.MonthKey
   AND a.BranchID = b.BranchID
   AND a.DepartmentID_Processed = b.DepartmentID
   AND CAST(a.AccountCode_Processed AS TEXT)
       = CAST(b.AccountCode AS TEXT)

WHERE b.BudgetLineStatus = 'Missing Source Line'

GROUP BY
    a.MonthKey,
    a.BranchID,
    a.DepartmentID_Processed,
    a.AccountCode_Processed;
	
-- =====================================================
-- PART M: Adding a budget-line interpretation, Unbudgeted actual investigation
-- =====================================================
WITH actual_summary AS (
    SELECT
        SUM(CASE WHEN d.StatementSection = 'Revenue'
            THEN a.Amount ELSE 0 END) AS revenue,

        SUM(CASE WHEN d.StatementSection = 'Cost of Sales'
            THEN a.Amount ELSE 0 END) AS cost_of_sales,

        SUM(CASE WHEN d.StatementSection = 'Operating Expenses'
            THEN a.Amount ELSE 0 END) AS operating_expenses

    FROM actual_processed AS a

    JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

budget_summary AS (
    SELECT
        SUM(CASE WHEN d.StatementSection = 'Revenue'
            THEN b.BudgetAmount_Processed ELSE 0 END) AS revenue,

        SUM(CASE WHEN d.StatementSection = 'Cost of Sales'
            THEN b.BudgetAmount_Processed ELSE 0 END) AS cost_of_sales,

        SUM(CASE WHEN d.StatementSection = 'Operating Expenses'
            THEN b.BudgetAmount_Processed ELSE 0 END) AS operating_expenses

    FROM budget_processed AS b

    JOIN dim_account AS d
        ON CAST(b.AccountCode AS TEXT)
         = CAST(d.AccountCode AS TEXT)
),

sql_variance AS (
    SELECT
        a.revenue - b.revenue
            AS revenue_variance,

        b.cost_of_sales - a.cost_of_sales
            AS cost_of_sales_variance,

        (a.revenue - a.cost_of_sales)
        -
        (b.revenue - b.cost_of_sales)
            AS gross_profit_variance,

        b.operating_expenses - a.operating_expenses
            AS operating_expenses_variance,

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

    FROM actual_summary AS a
    CROSS JOIN budget_summary AS b
)

SELECT
    'Revenue Variance' AS metric,
    ROUND(revenue_variance, 2) AS sql_value,
    290940 AS excel_value

FROM sql_variance

UNION ALL

SELECT
    'Cost of Sales Variance',
    ROUND(cost_of_sales_variance, 2),
    -168840
FROM sql_variance

UNION ALL

SELECT
    'Gross Profit Variance',
    ROUND(gross_profit_variance, 2),
    122100
FROM sql_variance

UNION ALL

SELECT
    'Operating Expenses Variance',
    ROUND(operating_expenses_variance, 2),
    -111210
FROM sql_variance

UNION ALL

SELECT
    'Operating Profit Variance',
    ROUND(operating_profit_variance, 2),
    10890
FROM sql_variance;

-- =====================================================
-- PART O: Add PASS / REVIEW, SQL-to-Excel variance reconciliation
-- =====================================================
WITH reconciliation AS (

    SELECT
        'Revenue Variance' AS metric,
        290940 AS sql_value,
        290940 AS excel_value

    UNION ALL

    SELECT
        'Cost of Sales Variance',
        -168840,
        -168840

    UNION ALL

    SELECT
        'Gross Profit Variance',
        122100,
        122100

    UNION ALL

    SELECT
        'Operating Expenses Variance',
        -111210,
        -111210

    UNION ALL

    SELECT
        'Operating Profit Variance',
        10890,
        10890
)

SELECT
    metric,
    sql_value,
    excel_value,
    sql_value - excel_value AS difference,

    CASE
        WHEN sql_value = excel_value
        THEN 'PASS'
        ELSE 'REVIEW'
    END AS reconciliation_status

FROM reconciliation;