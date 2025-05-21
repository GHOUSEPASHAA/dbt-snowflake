{{ config(
        materialized = 'incremental',
        incremental_strategy = 'merge',
        unique_key = ['row_id', 'update_datetime','user_ident','database_name'],
        
        schema = 'raw'
    )}}


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
        u.user_name,
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
        CURRENT_TIMESTAMP() AS dw_load_date,
        0 AS dw_data_source_ident,
        CASE 
            WHEN u.is_deleted = 1 THEN CURRENT_TIMESTAMP()
            ELSE NULL
        END AS record_obsolete_date,
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
        u.stream_load_datetime
    FROM {{ source('MYDB', 'LCM_USER') }}  u
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
    FROM {{this}}
    GROUP BY database_name
),
new_inserted_records AS (
    SELECT 
        src.row_id,
        moi.max_org_ident + ROW_NUMBER() OVER (PARTITION BY src.database_name ORDER BY src.create_datetime) AS user_ident,
        src.user_id, src.inferred_member, src.org_ident, src.org_id,
        src.user_name, src.first_name, src.middle_name, src.last_name,
        src.email, src.is_deleted, src.update_datetime, src.update_user_id,
        src.record_creation_date, src.record_obsolete_date, src.dw_data_source_ident,
        src.dw_load_date, src.is_current, src.years_experience, src.position_status_id,
        src.time_zone_id, src.sex, src.birth_datetime, src.address_ident,
        src.create_datetime, src.database_name, src.external_location, src.stream_load_datetime
    FROM source_cte src
    INNER JOIN max_org_ident moi
        ON moi.database_name = src.database_name
    LEFT JOIN {{this}} trgt
        ON trgt.row_id = src.row_id
    WHERE trgt.row_id IS NULL
),
updated_records AS (
    SELECT 
        src.row_id, trgt.user_ident,
        src.user_id, src.inferred_member, src.org_ident, src.org_id,
        src.user_name, src.first_name, src.middle_name, src.last_name,
        src.email, src.is_deleted, src.update_datetime, src.update_user_id,
        src.record_creation_date, src.record_obsolete_date, src.dw_data_source_ident,
        src.dw_load_date, src.is_current, src.years_experience, src.position_status_id,
        src.time_zone_id, src.sex, src.birth_datetime, src.address_ident,
        src.create_datetime, src.database_name, src.external_location, src.stream_load_datetime
    FROM source_cte src
    INNER JOIN {{this}} trgt
        ON src.row_id = trgt.row_id
    WHERE 
        src.inferred_member       <> trgt.inferred_member OR
        src.user_name             <> trgt.user_name OR
        src.first_name            <> trgt.first_name OR
        src.middle_name           <> trgt.middle_name OR
        src.last_name             <> trgt.last_name OR
        src.email                 <> trgt.email OR
        src.update_datetime       <> trgt.update_datetime OR
        
        src.update_user_id        <> trgt.update_user_id OR
        src.record_creation_date  <> trgt.record_creation_date OR
        src.record_obsolete_date  <> trgt.record_obsolete_date OR
       
        src.is_current            <> trgt.is_current OR
        src.years_experience      <> trgt.years_experience OR
        src.position_status_id    <> trgt.position_status_id OR
        src.time_zone_id          <> trgt.time_zone_id OR
        src.sex                   <> trgt.sex OR
        src.birth_datetime        <> trgt.birth_datetime OR
        src.address_ident         <> trgt.address_ident OR   
        src.database_name         <> trgt.database_name 
    
)





    SELECT * FROM new_inserted_records
    UNION
    SELECT * FROM updated_records


 