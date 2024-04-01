
use neodove;

--4. For calls not connected, identify the most common reason(s) for why the call was not connected.

SELECT 
    call_not_connected_reason,
    COUNT(*) AS reason_count
FROM call_log
WHERE call_connected = '0'
GROUP BY call_not_connected_reason
ORDER BY reason_count DESC;