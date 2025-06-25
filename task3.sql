-- Task3
CREATE OR ALTER PROCEDURE GET_HOSP_DETAILS(patient_id int)
RETURNS (
  id_calling_card int,
  accepted_on_try int,
  hosp_date_begin date,
  accepted_date_end date,
  second_hosp_state int
)
AS
BEGIN
  FOR 
    WITH enumerated AS (
      SELECT
        id_calling_card,
        ROW_NUMBER() OVER (
          PARTITION BY id_calling_card
          ORDER BY hosp_date_begin
        ) AS rn,
        hosp_date_begin,
        hosp_date_end,
        hosp_state
      FROM HOSP_HISTORY
      WHERE 
        patient_id = :patient_id
    ),
    aggregated_data AS (
      SELECT 
        id_calling_card,
        MAX(
          CASE 
            WHEN hosp_state = 1 THEN rn 
          END
        ) AS accepted_on_try,
        MIN(hosp_date_begin) AS hosp_date_begin,
        MAX(
          CASE 
            WHEN hosp_state = 1 THEN hosp_date_end 
          END
        ) AS accepted_date_end,
        MAX(
          CASE 
            WHEN rn = 2 THEN hosp_state 
          END
        ) AS second_hosp_state
      FROM enumerated
      GROUP BY
        id_calling_card
    )
    SELECT 
      id_calling_card,
      accepted_on_try,
      hosp_date_begin,
      accepted_date_end,
      second_hosp_state 
    FROM aggregated_data
    INTO 
      :id_calling_card,
      :accepted_on_try,
      :hosp_date_begin,
      :accepted_date_end,
      :second_hosp_state
  DO
  BEGIN
    SUSPEND;
  END
END;