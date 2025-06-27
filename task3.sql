-- Task3
CREATE TABLE HOSP_HISTORY(
  id int,
  id_calling_card int,
  patient_id int,
  hosp_date_begin date,
  hosp_date_end date,
  hosp_mo_id int,
  hosp_state int
);

INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (6, 12346, 4, '2025-01-28', '2025-01-29', 777, 2);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (7, 12346, 4, '2025-01-29', '2025-01-29', 888, 2);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (8, 12346, 4, '2025-01-29', '2025-01-30', 999, 1);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (10, 12500, 4, '2025-03-31', '2025-03-31', 777, 1);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (11, 123445, 4, '2025-06-26', '2025-06-26', 888, 2);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (12, 123445, 4, '2025-06-26', '2025-06-27', 999, 1);
INSERT INTO HOSP_HISTORY (ID, ID_CALLING_CARD, PATIENT_ID, HOSP_DATE_BEGIN, HOSP_DATE_END, HOSP_MO_ID, HOSP_STATE)
VALUES (13, 123566, 4, '2025-06-26', '2025-06-26', 777, 2);
COMMIT WORK;

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
          ORDER BY hosp_date_begin, id
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

SELECT * FROM GET_HOSP_DETAILS(4);
/*
Result:
"ID_CALLING_CARD"; "ACCEPTED_ON_TRY"; "HOSP_DATE_BEGIN"; "ACCEPTED_DATE_END"; "SECOND_HOSP_STATE"
            12346; 3                ; 2025-01-28       ; 2025-01-30         ; 2
            12500; 1                ; 2025-03-31       ; 2025-03-31         ; [Null]
           123445; 2                ; 2025-06-26       ; 2025-06-27         ; 1
           123566; [NULL]           ; 2025-06-26       ; [NULL]             ; [Null]
*/