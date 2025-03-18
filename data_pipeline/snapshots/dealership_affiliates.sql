{% snapshot dealership_affiliates_scd_snapshot %}
    {{
        config(
            target_schema='DBT_SCHEMA',  -- Replace with your target schema
            target_database='DBT_DB',  -- Replace with your target database
            unique_key='DEALERSHIP_AFFILIATES_ID',  -- The unique key for the records
            strategy='timestamp',  -- We use 'timestamp' strategy for detecting changes
            updated_at='current_timestamp',  -- The column that tracks changes, we will use CURRENT_TIMESTAMP here
            check_cols=['AFFILIATE_ID', 'DEALERSHIP_ID', 'EXTERNAL_ID', 'DESCRIPTION', 'AFFILIATE_NAME']  -- List of columns to check for changes
        )
    }}
    
    WITH source_data AS (
        SELECT
            DLRSHP_AFFLATS.ID AS DEALERSHIP_AFFILIATES_ID,
            DLRSHP_AFFLATS.AFFILIATE_ID,
            DLRSHP_AFFLATS.DEALERSHIP_ID,
            DLRSHP_AFFLATS.EXTERNAL_ID,
            AFFLATS.DESCRIPTION,
            AFFLATS.NAME AS AFFILIATE_NAME,
            CURRENT_TIMESTAMP AS current_timestamp  -- Track when the record was last updated
        FROM {{ source('DEV_LAKE_LENS', 'CAPS_DEALERSHIP_AFFILIATES') }} AS DLRSHP_AFFLATS
        LEFT JOIN {{ source('DEV_LAKE_LENS', 'CAPS_AFFILIATES') }} AS AFFLATS
            ON DLRSHP_AFFLATS.AFFILIATE_ID = AFFLATS.ID
    )

    SELECT
        DEALERSHIP_AFFILIATES_ID,
        AFFILIATE_ID,
        DEALERSHIP_ID,
        EXTERNAL_ID,
        DESCRIPTION,
        AFFILIATE_NAME,
        current_timestamp AS start_date,
        NULL AS end_date,  -- NULL initially for active records
        1 AS current_flag  -- Indicates this record is the current one
    FROM source_data

{% endsnapshot %}
