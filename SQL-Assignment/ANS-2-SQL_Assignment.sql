'''

2. Find the count of organizations that had three consecutive calls (excluding Saturday and Sunday) within 0-4 days, 5-8 days, 8-15 days, 16-30 days,30+ days of organization 
a. Perform this analysis for both renewed and not renewed organizations

'''
WITH consecutive_calls AS (
    SELECT 
        org_id, 
        call_date,
        LAG(call_date, 1) OVER (PARTITION BY org_id ORDER BY call_date) AS prev_call_date,
        LAG(call_date, 2) OVER (PARTITION BY org_id ORDER BY call_date) AS prev_prev_call_date
    FROM call_log
),
time_ranges AS (
    SELECT
        org_id,
        CASE
            WHEN DATEDIFF(day, prev_prev_call_date, call_date) <= 4 THEN '0-4 days'
            WHEN DATEDIFF(day, prev_prev_call_date, call_date) BETWEEN 5 AND 8 THEN '5-8 days'
            WHEN DATEDIFF(day, prev_prev_call_date, call_date) BETWEEN 9 AND 15 THEN '9-15 days'
            WHEN DATEDIFF(day, prev_prev_call_date, call_date) BETWEEN 16 AND 30 THEN '16-30 days'
            ELSE '30+ days'
        END AS time_range
    FROM consecutive_calls
),
consecutive_calls_count AS (
    SELECT
        org_id,
        time_range,
        COUNT(*) AS consecutive_call_count
    FROM time_ranges
    WHERE 
        DATENAME(WEEKDAY, org_date) NOT IN ('Saturday', 'Sunday') AND
        DATENAME(WEEKDAY, prev_call_date) NOT IN ('Saturday', 'Sunday') AND
        DATENAME(WEEKDAY, prev_prev_call_date) NOT IN ('Saturday', 'Sunday')
    GROUP BY org_id, time_range
    HAVING COUNT(*) >= 3
)
SELECT 
    time_range,
    SUM(CASE WHEN org_status = 'renewed' THEN 1 ELSE 0 END) AS renewed_count,
    SUM(CASE WHEN org_status = 'not renewed' THEN 1 ELSE 0 END) AS not_renewed_count
FROM consecutive_calls_count
JOIN organization ON consecutive_calls_count.org_id = organization.org_id
GROUP BY time_range;