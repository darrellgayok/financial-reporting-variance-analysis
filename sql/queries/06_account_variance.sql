-- =====================================================
-- PART A: Annual Account Budget vs Actual
-- =====================================================

WITH actual_account AS (
    SELECT
        CAST(a.AccountCode_Processed AS TEXT) AS AccountCode,
        SUM(a.Amount) AS actual_amount,
        COUNT(*) AS transaction_count

    FROM actual_processed AS a

    GROUP BY CAST(a.AccountCode_Processed AS TEXT)
),

budget_account AS (
    SELECT
        CAST(b.AccountCode AS TEXT) AS AccountCode,
        SUM(b.BudgetAmount_Processed) AS budget_amount

    FROM budget_processed AS b

    GROUP BY CAST(b.AccountCode AS TEXT)
)

SELECT
    d.AccountCode,
    d.AccountName,
    d.StatementSection,
    d.AccountGroup,

    ROUND(
        COALESCE(a.actual_amount, 0),
        2
    ) AS actual_amount,

    ROUND(
        COALESCE(b.budget_amount, 0),
        2
    ) AS budget_amount,

    ROUND(
        COALESCE(a.actual_amount, 0)
        - COALESCE(b.budget_amount, 0),
        2
    ) AS raw_difference,

    ROUND(
        CASE
            WHEN d.StatementSection = 'Revenue'
            THEN
                COALESCE(a.actual_amount, 0)
                - COALESCE(b.budget_amount, 0)

            ELSE
                COALESCE(b.budget_amount, 0)
                - COALESCE(a.actual_amount, 0)
        END,
        2
    ) AS favourable_variance,

    ROUND(
        (
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN
                    COALESCE(a.actual_amount, 0)
                    - COALESCE(b.budget_amount, 0)

                ELSE
                    COALESCE(b.budget_amount, 0)
                    - COALESCE(a.actual_amount, 0)
            END
        ) * 100.0
        / NULLIF(COALESCE(b.budget_amount, 0), 0),
        2
    ) AS variance_pct,

    CASE
        WHEN
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN
                    COALESCE(a.actual_amount, 0)
                    - COALESCE(b.budget_amount, 0)

                ELSE
                    COALESCE(b.budget_amount, 0)
                    - COALESCE(a.actual_amount, 0)
            END > 0

        THEN 'Favourable'

        WHEN
            CASE
                WHEN d.StatementSection = 'Revenue'
                THEN
                    COALESCE(a.actual_amount, 0)
                    - COALESCE(b.budget_amount, 0)

                ELSE
                    COALESCE(b.budget_amount, 0)
                    - COALESCE(a.actual_amount, 0)
            END < 0

        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS variance_status,

    COALESCE(a.transaction_count, 0)
        AS transaction_count

FROM dim_account AS d

LEFT JOIN actual_account AS a
    ON CAST(d.AccountCode AS TEXT) = a.AccountCode

LEFT JOIN budget_account AS b
    ON CAST(d.AccountCode AS TEXT) = b.AccountCode

ORDER BY d.DisplayOrder;

-- =====================================================
-- PART C: Top Account Variance Drivers
-- =====================================================

WITH actual_account AS (
    SELECT
        CAST(a.AccountCode_Processed AS TEXT) AS AccountCode,
        SUM(a.Amount) AS actual_amount

    FROM actual_processed AS a

    GROUP BY CAST(a.AccountCode_Processed AS TEXT)
),

budget_account AS (
    SELECT
        CAST(b.AccountCode AS TEXT) AS AccountCode,
        SUM(b.BudgetAmount_Processed) AS budget_amount

    FROM budget_processed AS b

    GROUP BY CAST(b.AccountCode AS TEXT)
),

account_variance AS (
    SELECT
        d.AccountCode,
        d.AccountName,
        d.StatementSection,

        COALESCE(a.actual_amount, 0)
            AS actual_amount,

        COALESCE(b.budget_amount, 0)
            AS budget_amount,

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
        ON CAST(d.AccountCode AS TEXT) = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT) = b.AccountCode
)

SELECT
    AccountCode,
    AccountName,
    StatementSection,

    ROUND(actual_amount, 2)
        AS actual_amount,

    ROUND(budget_amount, 2)
        AS budget_amount,

    ROUND(favourable_variance, 2)
        AS favourable_variance,

    CASE
        WHEN favourable_variance > 0
        THEN 'Favourable'

        WHEN favourable_variance < 0
        THEN 'Unfavourable'

        ELSE 'On Budget'
    END AS variance_status,

    ROUND(
        ABS(favourable_variance),
        2
    ) AS variance_magnitude

FROM account_variance

ORDER BY
    ABS(favourable_variance) DESC

LIMIT 10;

-- =====================================================
-- PART D: Largest Favourable Account Variances
-- =====================================================

WITH actual_account AS (
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
        d.StatementSection,

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
        ON CAST(d.AccountCode AS TEXT) = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT) = b.AccountCode
)

SELECT
    AccountCode,
    AccountName,
    StatementSection,

    ROUND(
        favourable_variance,
        2
    ) AS favourable_variance

FROM account_variance

WHERE favourable_variance > 0

ORDER BY favourable_variance DESC;

-- =====================================================
-- PART E: Largest Unfavourable Account Variances
-- =====================================================

WITH actual_account AS (
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
        d.StatementSection,

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
        ON CAST(d.AccountCode AS TEXT) = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT) = b.AccountCode
)

SELECT
    AccountCode,
    AccountName,
    StatementSection,

    ROUND(
        favourable_variance,
        2
    ) AS favourable_variance

FROM account_variance

WHERE favourable_variance < 0

ORDER BY favourable_variance ASC;

-- =====================================================
-- PART F: Account Variance Reconciliation
-- =====================================================

WITH actual_account AS (
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
        ON CAST(d.AccountCode AS TEXT) = a.AccountCode

    LEFT JOIN budget_account AS b
        ON CAST(d.AccountCode AS TEXT) = b.AccountCode
)

SELECT
    ROUND(
        SUM(favourable_variance),
        2
    ) AS account_variance_total,

    10890 AS company_variance,

    ROUND(
        SUM(favourable_variance) - 10890,
        2
    ) AS difference,

    CASE
        WHEN ROUND(
            SUM(favourable_variance) - 10890,
            2
        ) = 0

        THEN 'PASS'

        ELSE 'REVIEW'
    END AS reconciliation_status

FROM account_variance;