
use neodove;

select * from organization;

select * from call_log;

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Find the first connected call for all the renewed organizations from the Gujarat location

SELECT call_log.org_id, organization.org_status, organization.properties, MIN(call_connected) AS first_connected_call
FROM call_log
JOIN organization ON call_log.org_id = organization.org_id  
WHERE organization.org_status = 'renewed'
GROUP BY call_log.org_id, organization.org_status, organization.properties
HAVING MIN(call_connected) IS NOT NULL;

------------------------------------------------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------------------------------------------


--3. Identify the location with the maximum number of connected calls for unique leads

SELECT TOP 1
    properties,
    COUNT(DISTINCT lead_id) AS num_connected_calls
FROM call_log
JOIN organization ON call_log.org_id = organization.org_id
WHERE call_connected IN ('0', '1')
GROUP BY properties
ORDER BY num_connected_calls DESC;

-------------------------------------------------------------------------------------------------------------------------------

--4. For calls not connected, identify the most common reason(s) for why the call was not connected.

SELECT 
    call_not_connected_reason,
    COUNT(*) AS reason_count
FROM call_log
WHERE call_connected = '0'
GROUP BY call_not_connected_reason
ORDER BY reason_count DESC;

------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. Create a summary for your analysis to summarize your findings and inference for the above queries.

'''

Here is a summary of the analysis based on the provided queries:

1. First Connected Call for Renewed Organizations in Gujarat:

# We identified the first connected call for all renewed organizations located in Gujarat.
# This analysis provides insight into the initial engagement of renewed organizations in Gujarat, potentially highlighting successful lead conversion or early interactions.

2. Count of Organizations with Three Consecutive Calls:

# We analyzed the count of organizations that had three consecutive calls within various time ranges after organization creation, excluding Saturdays and Sundays.
# This analysis offers insights into the engagement and consistency of communication with organizations shortly after their creation, segmented by time ranges.

3. Location with Maximum Number of Connected Calls for Unique Leads:

# We determined the location with the highest number of connected calls for unique leads.
# This finding indicates the geographic area where there is the most successful lead conversion or effective communication.

4. Most Common Reasons for Calls Not Connected:

# We identified the most common reasons why calls were not connected.
# This information highlights potential barriers or challenges in establishing communication and provides insights for improving call connectivity.

'''
