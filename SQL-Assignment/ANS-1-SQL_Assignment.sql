-- 1. Find the first connected call for all the renewed organizations from the Gujarat location

SELECT call_log.org_id, organization.org_status, organization.properties, MIN(call_connected) AS first_connected_call
FROM call_log
JOIN organization ON call_log.org_id = organization.org_id  
WHERE organization.org_status = 'renewed'
GROUP BY call_log.org_id, organization.org_status, organization.properties
HAVING MIN(call_connected) IS NOT NULL;
