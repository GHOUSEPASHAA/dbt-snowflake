{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['row_id', 'unique_row_number'],
        merge_update_columns = ['is_current', 'record_obsolete_date'],
        schema = 'raw'
    )
}}

WITH source_cte AS (
    SELECT 
        md5(array_to_string(
            ARRAY_CONSTRUCT_COMPACT(
                u.user_id,
                CASE 
                    WHEN u.database_name LIKE 'lms%' THEN 'hstm_bi_' || SUBSTRING(u.database_name, 5, LEN(u.database_name) - 4)
                    ELSE NULL
                END
            ), '-'))::VARCHAR AS row_id,
        u.user_id,
        u.org_id,
        u.user_name AS user_name,
        u.first_name,
        u.middle_name,
        u.last_name,
        u.email,
        u.years_experience,
        u.update_datetime,
        u.update_user_id,
        u.position_status_id,
        u.time_zone_id,
        u.sex,
        u.birth_datetime,
        u.create_datetime,
        u.address_id,
        0 AS inferred_member,
        CURRENT_TIMESTAMP() AS record_creation_date,
        NULL AS record_obsolete_date,
        CURRENT_TIMESTAMP() AS dw_load_date,
        0 AS dw_data_source_ident,
        CASE 
            WHEN u.is_deleted = 1 THEN 'Y'
            ELSE 'N' 
        END AS is_deleted,
        CASE 
            WHEN u.is_deleted = 1 THEN 'N' 
            ELSE 'Y' 
        END AS is_current,
        NVL(a.address_xref_ident, -99) AS address_ident,
        NVL(TRY_CAST(d_o.org_ident AS NUMBER), -99) AS org_ident,
        CASE 
            WHEN u.database_name LIKE 'lms%' THEN 'hstm_bi_' || SUBSTRING(u.database_name, 5, LEN(u.database_name) - 4)
            ELSE NULL
        END AS database_name,
        NULL AS external_location,
        NULL AS stream_load_datetime
    FROM {{ source('MYDB', 'LCM_USER') }} u
    LEFT JOIN {{ source('MYDB', 'DWH_DIM_ORG') }} d_o
        ON u.org_id = d_o.org_id
        AND (
            CASE 
                WHEN u.database_name LIKE 'lms%' THEN 'hstm_bi_' || SUBSTRING(u.database_name, 5, LEN(u.database_name) - 4)
                ELSE NULL
            END
        ) = d_o.database_name
    LEFT JOIN {{ source('MYDB', 'ADDRESS_REF') }} a
        ON u.address_id = a.address_xref_ident
        AND (
            CASE 
                WHEN u.database_name LIKE 'lms%' THEN 'hstm_bi_' || SUBSTRING(u.database_name, 5, LEN(u.database_name) - 4)
                ELSE NULL
            END
        ) = a.database_name
),

max_org_ident AS (
    SELECT 
        database_name,
        COALESCE(MAX(user_ident), 0) AS max_org_ident
    FROM {{ source('MYDB', 'DIM_USER_ROW') }}
    GROUP BY database_name
),

new_inserted_records AS (
    SELECT 
        src.row_id,
        src.user_id,
        moi.max_org_ident + ROW_NUMBER() OVER (PARTITION BY src.database_name ORDER BY src.create_datetime) AS user_ident,
        src.inferred_member,
        src.org_ident,
        src.org_id,
        src.user_name,
        src.first_name,
        src.middle_name,
        src.last_name,
        src.email,
        src.is_deleted,
        src.update_datetime,
        src.update_user_id,
        src.record_creation_date,
        src.record_obsolete_date,
        src.dw_data_source_ident,
        src.dw_load_date,
        src.is_current,
        src.years_experience,
        src.position_status_id,
        src.time_zone_id,
        src.sex,
        src.birth_datetime,
        src.address_ident,
        src.create_datetime,
        src.database_name,
        src.external_location,
        src.stream_load_datetime
    FROM source_cte src
    INNER JOIN max_org_ident moi
        ON moi.database_name = src.database_name
    LEFT JOIN {{ source('MYDB', 'DIM_USER_ROW') }} trgt
        ON trgt.row_id = src.row_id
    WHERE trgt.row_id IS NULL
),

changed_records AS (
    SELECT 
        src.*,
        trgt.user_ident AS old_user_ident
    FROM source_cte src
    INNER JOIN {{ source('MYDB', 'DIM_USER_ROW') }} trgt
        ON src.row_id = trgt.row_id 
        AND trgt.is_current = 'Y'
    WHERE 
        COALESCE(src.inferred_member, -1) != COALESCE(trgt.inferred_member, -1) 
        OR COALESCE(src.user_name, '') != COALESCE(trgt.user_name, '') 
        OR COALESCE(src.first_name, '') != COALESCE(trgt.first_name, '') 
        OR COALESCE(src.middle_name, '') != COALESCE(trgt.middle_name, '') 
        OR COALESCE(src.last_name, '') != COALESCE(trgt.last_name, '') 
        OR COALESCE(src.email, '') != COALESCE(trgt.email, '') 
        OR COALESCE(src.update_datetime, '1900-01-01') != COALESCE(trgt.update_datetime, '1900-01-01') 
        OR COALESCE(src.update_user_id, '') != COALESCE(trgt.update_user_id, '') 
        OR COALESCE(src.years_experience, -1) != COALESCE(trgt.years_experience, -1) 
        OR COALESCE(src.position_status_id, -1) != COALESCE(trgt.position_status_id, -1) 
        OR COALESCE(src.time_zone_id, -1) != COALESCE(trgt.time_zone_id, -1) 
        OR COALESCE(src.sex, '') != COALESCE(trgt.sex, '') 
        OR COALESCE(src.birth_datetime, '1900-01-01') != COALESCE(trgt.birth_datetime, '1900-01-01') 
        OR COALESCE(src.address_ident, -1) != COALESCE(trgt.address_ident, -1) 
        OR COALESCE(src.database_name, '') != COALESCE(trgt.database_name, '')
),

expired_records AS (
    SELECT 
        trgt.row_id,
        trgt.unique_row_number,
        trgt.user_ident,
        trgt.user_id,
        trgt.inferred_member,
        trgt.org_ident,
        trgt.org_id,
        trgt.user_name,
        trgt.first_name,
        trgt.middle_name,
        trgt.last_name,
        trgt.email,
        trgt.is_deleted,
        trgt.update_datetime,
        trgt.update_user_id,
        trgt.record_creation_date,
        CURRENT_TIMESTAMP() AS record_obsolete_date,
        trgt.dw_data_source_ident,
        trgt.dw_load_date,
        'N' AS is_current,
        trgt.years_experience,
        trgt.position_status_id,
        trgt.time_zone_id,
        trgt.sex,
        trgt.birth_datetime,
        trgt.address_ident,
        trgt.create_datetime,
        trgt.database_name,
        trgt.external_location,
        trgt.stream_load_datetime
    FROM {{ source('MYDB', 'DIM_USER_ROW') }} trgt
    WHERE EXISTS (
        SELECT 1
        FROM changed_records chg
        WHERE chg.row_id = trgt.row_id
        AND trgt.is_current = 'Y'
    )
),

new_changed_records AS (
    SELECT 
        chg.row_id,
        chg.old_user_ident AS user_ident,
        chg.user_id,
        chg.inferred_member,
        chg.org_ident,
        chg.org_id,
        chg.user_name,
        chg.first_name,
        chg.middle_name,
        chg.last_name,
        chg.email,
        chg.is_deleted,
        chg.update_datetime,
        chg.update_user_id,
        CURRENT_TIMESTAMP() AS record_creation_date,
        NULL AS record_obsolete_date,
        chg.dw_data_source_ident,
        CURRENT_TIMESTAMP() AS dw_load_date,
        'Y' AS is_current,
        chg.years_experience,
        chg.position_status_id,
        chg.time_zone_id,
        chg.sex,
        chg.birth_datetime,
        chg.address_ident,
        chg.create_datetime,
        chg.database_name,
        chg.external_location,
        chg.stream_load_datetime
    FROM changed_records chg
    INNER JOIN max_org_ident moi
        ON moi.database_name = chg.database_name
),

combined_records AS (
    SELECT 
        row_id,
        user_ident,
        user_id,
        inferred_member,
        org_ident,
        org_id,
        user_name,
        first_name,
        middle_name,
        last_name,
        email,
        is_deleted,
        update_datetime,
        update_user_id,
        record_creation_date,
        record_obsolete_date,
        dw_data_source_ident,
        dw_load_date,
        is_current,
        years_experience,
        position_status_id,
        time_zone_id,
        sex,
        birth_datetime,
        address_ident,
        create_datetime,
        database_name,
        external_location,
        stream_load_datetime
    FROM new_inserted_records
    UNION ALL
    SELECT 
        row_id,
        user_ident,
        user_id,
        inferred_member,
        org_ident,
        org_id,
        user_name,
        first_name,
        middle_name,
        last_name,
        email,
        is_deleted,
        update_datetime,
        update_user_id,
        record_creation_date,
        record_obsolete_date,
        dw_data_source_ident,
        dw_load_date,
        is_current,
        years_experience,
        position_status_id,
        time_zone_id,
        sex,
        birth_datetime,
        address_ident,
        create_datetime,
        database_name,
        external_location,
        stream_load_datetime
    FROM new_changed_records
),

final_records AS (
    SELECT 
        row_id,
        ROW_NUMBER() OVER (ORDER BY create_datetime, user_id) 
            + COALESCE((SELECT MAX(unique_row_number) FROM {{ this }}), 0) AS unique_row_number,
        user_ident,
        user_id,
        inferred_member,
        org_ident,
        org_id,
        user_name,
        first_name,
        middle_name,
        last_name,
        email,
        is_deleted,
        update_datetime,
        update_user_id,
        record_creation_date,
        record_obsolete_date,
        dw_data_source_ident,
        dw_load_date,
        is_current,
        years_experience,
        position_status_id,
        time_zone_id,
        sex,
        birth_datetime,
        address_ident,
        create_datetime,
        database_name,
        external_location,
        stream_load_datetime
    FROM combined_records
)

SELECT * FROM final_records
{% if is_incremental() %}
UNION ALL
SELECT * FROM expired_records
{% endif %}