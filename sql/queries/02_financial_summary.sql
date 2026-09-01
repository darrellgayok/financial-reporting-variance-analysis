-- =====================================================
-- PART A: Confirming every processed account maps correctly
-- =====================================================
SELECT
    a.TransactionID,
    a.AccountCode_Processed
FROM actual_processed AS a
LEFT JOIN dim_account AS d
    ON CAST(a.AccountCode_Processed AS TEXT)
     = CAST(d.AccountCode AS TEXT)
WHERE d.AccountCode IS NULL;

-- =====================================================
-- PART B: Checking actual amounts by statement section
-- =====================================================
SELECT
    d.StatementSection,
    ROUND(SUM(a.Amount), 2) AS actual_amount
FROM actual_processed AS a
INNER JOIN dim_account AS d
    ON CAST(a.AccountCode_Processed AS TEXT)
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
-- PART C: Rebuilding the annual P&L
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
)

SELECT
    ROUND(revenue, 2) AS actual_revenue,
    ROUND(cost_of_sales, 2) AS actual_cost_of_sales,

    ROUND(
        revenue - cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(
        operating_expenses,
        2
    ) AS actual_operating_expenses,

    ROUND(
        revenue
        - cost_of_sales
        - operating_expenses,
        2
    ) AS actual_operating_profit

FROM actual_summary;

-- =====================================================
-- PART D: Calculating the operating margin
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
)

SELECT
    ROUND(revenue, 2) AS actual_revenue,

    ROUND(
        revenue - cost_of_sales - operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        (
            revenue
            - cost_of_sales
            - operating_expenses
        ) * 100.0 / revenue,
        2
    ) AS actual_operating_margin_pct

FROM actual_summary;

-- =====================================================
-- PART E: Producing a proper SQL income-statement layout
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
)

SELECT
    1 AS display_order,
    'Revenue' AS financial_line,
    ROUND(revenue, 2) AS amount
FROM actual_summary

UNION ALL

SELECT
    2,
    'Cost of Sales',
    ROUND(-cost_of_sales, 2)
FROM actual_summary

UNION ALL

SELECT
    3,
    'Gross Profit',
    ROUND(revenue - cost_of_sales, 2)
FROM actual_summary

UNION ALL

SELECT
    4,
    'Operating Expenses',
    ROUND(-operating_expenses, 2)
FROM actual_summary

UNION ALL

SELECT
    5,
    'Operating Profit',
    ROUND(
        revenue - cost_of_sales - operating_expenses,
        2
    )
FROM actual_summary

ORDER BY display_order;

-- =====================================================
-- PART F: Rebuilding monthly actual financial performance
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
        ) AS operating_expenses,

        COUNT(*) AS transaction_count

    FROM actual_processed AS a

    INNER JOIN dim_account AS d
        ON CAST(a.AccountCode_Processed AS TEXT)
         = CAST(d.AccountCode AS TEXT)

    GROUP BY a.MonthKey
)

SELECT
    MonthKey,

    ROUND(revenue, 2)
        AS actual_revenue,

    ROUND(cost_of_sales, 2)
        AS actual_cost_of_sales,

    ROUND(
        revenue - cost_of_sales,
        2
    ) AS actual_gross_profit,

    ROUND(operating_expenses, 2)
        AS actual_operating_expenses,

    ROUND(
        revenue
        - cost_of_sales
        - operating_expenses,
        2
    ) AS actual_operating_profit,

    ROUND(
        (
            revenue
            - cost_of_sales
            - operating_expenses
        ) * 100.0 / revenue,
        2
    ) AS actual_operating_margin_pct,

    transaction_count

FROM monthly_actual

ORDER BY MonthKey;

-- =====================================================
-- PART G: Verifying the monthly operating-profit values
-- =====================================================
| Month | Actual Operating Profit |
| ----- | ----------------------: |
| Jan   |                 RM4,610 |
| Feb   |               RM(47,690)|
| Mar   |                RM64,190 |
| Apr   |               RM141,040 |
| May   |               RM206,920 |
| Jun   |               RM282,170 |
| Jul   |               RM169,730 |
| Aug   |               RM265,110 |
| Sep   |               RM230,260 |
| Oct   |               RM366,800 |
| Nov   |               RM367,470 |
| Dec   |               RM259,980 |
SUM = RM2,310,590

-- =====================================================
-- PART H: Verifying monthly transaction counts
-- =====================================================
SELECT
    MonthKey,
    COUNT(*) AS transaction_count
FROM actual_processed
GROUP BY MonthKey
ORDER BY MonthKey;

SELECT
    SUM(transaction_count) AS total_transactions
FROM (
    SELECT
        MonthKey,
        COUNT(*) AS transaction_count
    FROM actual_processed
    GROUP BY MonthKey
);

-- =====================================================
-- PART I: Analysing actual performance by account
-- =====================================================
SELECT
    d.AccountCode,
    d.AccountName,
    d.StatementSection,
    d.AccountGroup,
    ROUND(SUM(a.Amount), 2) AS actual_amount,
    COUNT(*) AS transaction_count
FROM actual_processed AS a

INNER JOIN dim_account AS d
    ON CAST(a.AccountCode_Processed AS TEXT)
     = CAST(d.AccountCode AS TEXT)

GROUP BY
    d.AccountCode,
    d.AccountName,
    d.StatementSection,
    d.AccountGroup,
    d.DisplayOrder

ORDER BY
    d.DisplayOrder;
	
-- =====================================================
-- PART J: Creating an SQL-to-Excel reconciliation check
-- =====================================================
WITH sql_actual AS (
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
)

SELECT
    'Actual Revenue' AS metric,
    ROUND(revenue, 2) AS sql_value,
    19806040 AS excel_value,
    ROUND(revenue - 19806040, 2) AS difference

FROM sql_actual

UNION ALL

SELECT
    'Actual Cost of Sales',
    ROUND(cost_of_sales, 2),
    10813140,
    ROUND(cost_of_sales - 10813140, 2)

FROM sql_actual

UNION ALL

SELECT
    'Actual Gross Profit',
    ROUND(revenue - cost_of_sales, 2),
    8992900,
    ROUND(
        revenue - cost_of_sales - 8992900,
        2
    )

FROM sql_actual

UNION ALL

SELECT
    'Actual Operating Expenses',
    ROUND(operating_expenses, 2),
    6682310,
    ROUND(operating_expenses - 6682310, 2)

FROM sql_actual

UNION ALL

SELECT
    'Actual Operating Profit',
    ROUND(
        revenue
        - cost_of_sales
        - operating_expenses,
        2
    ),
    2310590,
    ROUND(
        revenue
        - cost_of_sales
        - operating_expenses
        - 2310590,
        2
    )

FROM sql_actual;

-- =====================================================
-- PART K: Adding a reconciliation status
-- =====================================================
WITH sql_actual AS (
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

reconciliation AS (

    SELECT
        'Actual Revenue' AS metric,
        revenue AS sql_value,
        19806040 AS excel_value
    FROM sql_actual

    UNION ALL

    SELECT
        'Actual Cost of Sales',
        cost_of_sales,
        10813140
    FROM sql_actual

    UNION ALL

    SELECT
        'Actual Gross Profit',
        revenue - cost_of_sales,
        8992900
    FROM sql_actual

    UNION ALL

    SELECT
        'Actual Operating Expenses',
        operating_expenses,
        6682310
    FROM sql_actual

    UNION ALL

    SELECT
        'Actual Operating Profit',
        revenue - cost_of_sales - operating_expenses,
        2310590
    FROM sql_actual
)

SELECT
    metric,
    ROUND(sql_value, 2) AS sql_value,
    ROUND(excel_value, 2) AS excel_value,
    ROUND(sql_value - excel_value, 2) AS difference,

    CASE
        WHEN ROUND(sql_value - excel_value, 2) = 0
        THEN 'PASS'
        ELSE 'REVIEW'
    END AS reconciliation_status

FROM reconciliation;

COMPLETE