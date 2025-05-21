WITH reviews_with_row AS (
    SELECT
        *,
        row_number() OVER (ORDER BY org_id) AS row_numm
    FROM  {{source('MYDB','DWH_DIM_ORG')}}
)

SELECT *
FROM reviews_with_row