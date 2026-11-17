WITH job_postings AS (
    SELECT job_id,
        CASE 
            WHEN job_work_from_home = TRUE THEN 'Remote_Flagged'
            ELSE 'Unspecified' -- Unspecified means NULL here
        END AS remote_status
    FROM {{ ref('fct_job_postings')}}
    {% if var('job_title', none) %}
    WHERE search_term = '{{ var("job_title") }}'
    {% endif %}
),

bridge AS (
    SELECT *
    FROM {{ ref('bridge_job_skills')}}
),

skills AS (
    SELECT *
    FROM {{ ref('dim_skill')}}
),

remote_totals AS (
    SELECT remote_status,
        COUNT(DISTINCT job_id) AS total_postings
    FROM job_postings
    GROUP BY remote_status
),

demand AS (
    SELECT display_name,
    category,
    remote_status,
    COUNT(DISTINCT job_id) AS skill_in_demand,
    ROUND(COUNT(DISTINCT job_id) * 100.0 / NULLIF(MAX(total_postings), 0), 2) AS demand_pct
    -- MAX() retrieves the group total for each remote status, avoiding aggregation errors since the value repeats across joined rows.
FROM bridge
INNER JOIN skills USING (skill_id)
INNER JOIN job_postings USING (job_id)
INNER JOIN remote_totals USING (remote_status)
GROUP BY display_name, category, remote_status
)

SELECt remote_status,
    display_name,
    category,
    Skill_in_demand,
    demand_pct,
    RANK() OVER (PARTITION BY remote_status ORDER BY skill_in_demand DESC) AS rank_skill
FROM demand
QUALIFY rank_skill <= 10
ORDER BY remote_status, rank_skill
