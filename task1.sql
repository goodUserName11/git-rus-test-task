-- Task1 
UPDATE PATIENT AS p
SET p."count" = (
  SELECT
  CASE
    WHEN count(*) = 1 THEN 0
    WHEN count(*) = 2 THEN 1
    ELSE 2
  END AS "count"
  FROM PATIENT AS p2
  WHERE 
    p2.name = p.name
    AND p2.surname = p.surname
)
;