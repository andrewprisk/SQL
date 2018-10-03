SELECT EecEmpNo, 
 COUNT(EecEmpNo) AS NumOccurrences
FROM v_EMPYMAS_REPLICA 
WHERE EecCoID<>'83UVU' and EecEmplStatus='A'
GROUP BY EecEmpNo
HAVING (COUNT(EecEmpNo) > 1)