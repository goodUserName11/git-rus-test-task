-- Task2
SELECT 
  patient_id,
  id_calling_card,
  MAX(hosp_date_begin) AS last_rejected_date
FROM HOSP_HISTORY
WHERE hosp_state = 2
GROUP BY 
  patient_id, 
  id_calling_card
;