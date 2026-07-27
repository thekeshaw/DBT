-- Staging model for DIM_PHYSICAL_ATTRIBUTES
-- 1:1 with the source table, light cleanup only (renaming/casting).
-- TODO: replace select * with an explicit column list once youve confirmed
-- exact column names from your Snowflake table (run: DESCRIBE TABLE DIM_PHYSICAL_ATTRIBUTES;)

with source as (

    select * from {{ source("insurance_raw", "DIM_PHYSICAL_ATTRIBUTES") }}

)

select * from source
