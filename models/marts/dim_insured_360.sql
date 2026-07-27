-- A single "360 view" of an insured person: profile + physical + employment +
-- insurance history + family history + medical history, one row per person.

with insured as (
    select * from {{ ref('stg_dim_insured_info') }}
),

physical as (
    select * from {{ ref('stg_dim_physical_attributes') }}
),

employment as (
    select * from {{ ref('stg_dim_employment_info') }}
),

insurance_history as (
    select * from {{ ref('stg_dim_insurance_history') }}
),

family_history as (
    select * from {{ ref('stg_dim_family_history') }}
),

medical_history as (
    select * from {{ ref('stg_dim_medical_history') }}
),

final as (

    select
        insured.insured_id,
        insured.*  exclude (insured_id),
        physical.* exclude (insured_id),
        employment.* exclude (insured_id),
        insurance_history.* exclude (insured_id),
        family_history.* exclude (insured_id),
        medical_history.* exclude (insured_id)

    from insured
    left join physical          on insured.insured_id = physical.insured_id
    left join employment        on insured.insured_id = employment.insured_id
    left join insurance_history on insured.insured_id = insurance_history.insured_id
    left join family_history    on insured.insured_id = family_history.insured_id
    left join medical_history   on insured.insured_id = medical_history.insured_id

)

select * from final
