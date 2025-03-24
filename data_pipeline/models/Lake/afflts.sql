WITH source_data AS (
        SELECT
            DLRSHP_AFFLATS.ID AS DEALERSHIP_AFFILIATES_ID,
            DLRSHP_AFFLATS.AFFILIATE_ID,
            DLRSHP_AFFLATS.DEALERSHIP_ID,
            DLRSHP_AFFLATS.EXTERNAL_ID,
            AFFLATS.DESCRIPTION,
            AFFLATS.NAME AS AFFILIATE_NAME,
            CURRENT_TIMESTAMP AS current_timestamp  -- Track when the record was last updated
        FROM {{ source('DBT_DB', 'DEALERSHIP_AFFILIATES1') }} AS DLRSHP_AFFLATS
        LEFT JOIN {{ source('DBT_DB', 'AFFILIATES1') }} AS AFFLATS
            ON DLRSHP_AFFLATS.AFFILIATE_ID = AFFLATS.ID
    )

    SELECT
        DEALERSHIP_AFFILIATES_ID,
        AFFILIATE_ID,
        DEALERSHIP_ID,
        EXTERNAL_ID,
        DESCRIPTION,
        AFFILIATE_NAME,
        current_timestamp AS EFFECTIVE_START_DATE,
        NULL AS EFFECTIVE_end_date,  -- NULL initially for active records
        1 AS current_flag  -- Indicates this record is the current one
    FROM source_data