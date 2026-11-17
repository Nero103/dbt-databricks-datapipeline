SELECT job_schedule_type AS employment_type,
    COUNT(*) AS total_postings,
    SUM(CASE WHEN has_paid_time_off = TRUE THEN 1 ELSE 0 END) AS paid_time_off_count,
    SUM(CASE WHEN has_health_insurance = TRUE THEN 1 ELSE 0 END) AS health_insurance_count,
    SUM(CASE WHEN has_dental_insurance = TRUE THEN 1 ELSE 0 END) AS dental_insurance_count,
    ROUND(SUM(CASE WHEN has_paid_time_off = TRUE THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(*), 0), 2) 
    AS paid_time_off_pct,
    ROUND(SUM(CASE WHEN has_health_insurance = TRUE THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(*), 0), 2) 
    AS health_insurance_pct,
    ROUND(SUM(CASE WHEN has_dental_insurance = TRUE THEN 1 ELSE 0 END) * 100 / NULLIF(COUNT(*), 0), 2) 
    AS dental_insurance_pct
FROM {{ ref('fct_job_postings')}}
WHERE job_schedule_type IS NOT NULL
GROUP BY job_schedule_type