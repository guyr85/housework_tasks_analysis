CREATE OR REPLACE PROCEDURE public.populate_fact_housework_tasks()
LANGUAGE plpgsql AS $$
BEGIN
    WITH housework_tasks AS (
        SELECT fct.date,
               fct.person_id,
               fct.task_id,
               SUM(fct.task_duration_minutes) AS task_duration_minutes,
               MAX(fct.record_insert_time) AS record_insert_time
        FROM public.stg_fact_housework_tasks AS fct
        GROUP BY fct.date, fct.person_id, fct.task_id
    )

    INSERT INTO public.fact_housework_tasks (date, person_id, task_id, task_duration_minutes, record_insert_time)
    SELECT date,
           person_id,
           task_id,
           task_duration_minutes,
           record_insert_time
    FROM housework_tasks
    ON CONFLICT (date, person_id, task_id)
    DO UPDATE SET task_duration_minutes = excluded.task_duration_minutes,
                  record_insert_time = excluded.record_insert_time;
END;
$$;