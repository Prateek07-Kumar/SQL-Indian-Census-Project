
USE neodove;

--3. Identify the location with the maximum number of connected calls for unique leads

SELECT TOP 1
    properties,
    COUNT(DISTINCT lead_id) AS num_connected_calls
FROM call_log
JOIN organization ON call_log.org_id = organization.org_id
WHERE call_connected IN ('0', '1')
GROUP BY properties
ORDER BY num_connected_calls DESC;
