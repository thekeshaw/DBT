-- One row per application: the underwriting response, joined to product info
-- and a summary of how many medical keywords were flagged on that application.

with applications as (
    select * from {{ ref('stg_fct_application_response') }}
),

products as (
    select * from {{ ref('stg_dim_product_info') }}
),

medical_keywords as (
    select * from {{ ref('stg_fct_medical_keywords') }}
),

keyword_summary as (

    select
        application_id,
        count(*) as medical_keyword_count

    from medical_keywords
    group by application_id

),

final as (

    select
        applications.application_id,
        applications.insured_id,
        applications.product_id,
        applications.* exclude (application_id, insured_id, product_id),
        products.*     exclude (product_id),
        coalesce(keyword_summary.medical_keyword_count, 0) as medical_keyword_count

    from applications
    left join products         on applications.product_id = products.product_id
    left join keyword_summary  on applications.application_id = keyword_summary.application_id

)

select * from final
