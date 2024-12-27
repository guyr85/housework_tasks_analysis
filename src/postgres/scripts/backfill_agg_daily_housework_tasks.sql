CREATE OR REPLACE PROCEDURE public.backfill_agg_daily_housework_tasks()
LANGUAGE plpgsql AS $$
BEGIN
    WITH date_series AS (
    -- Generate a series of dates for the given month based on month_id
    SELECT
        person_id,
        month_id,
        generate_series(
            date_trunc('month', month_id::date),
            date_trunc('month', month_id::date) + interval '1 month' - interval '1 day',
            interval '1 day'
        )::date AS working_date
    FROM public.dim_person_monthly_working_hours
    ),
    filtered_dates AS (
        -- Exclude Fridays (5) and Saturdays (6)
        SELECT
            ds.person_id,
            ds.month_id,
            ds.working_date
        FROM date_series ds
        WHERE EXTRACT(ISODOW FROM ds.working_date) NOT IN (5, 6)
    ),
    working_days_count AS (
        -- Calculate the total number of working days in the month for each person
        SELECT
            fd.person_id,
            fd.month_id,
            COUNT(fd.working_date) AS total_working_days
        FROM filtered_dates fd
        GROUP BY fd.person_id, fd.month_id
    ),
    distributed_hours AS (
        -- Distribute the monthly working hours evenly across the working days
        SELECT
            fd.person_id,
            15 AS task_id,
            fd.month_id,
            fd.working_date,
            mwh.monthly_working_hours ,
            wd.total_working_days,
            mwh.monthly_working_hours / wd.total_working_days AS daily_working_hours
        FROM filtered_dates fd
        JOIN working_days_count wd
            ON fd.person_id = wd.person_id AND fd.month_id = wd.month_id
        JOIN public.dim_person_monthly_working_hours mwh
            ON fd.person_id = mwh.person_id AND fd.month_id = mwh.month_id
    ),
    final_working_hours_result AS (
    -- Final result with daily working hours distributed evenly
    SELECT
        distributed_hours.working_date AS date,
        dim_person.name AS person,
        dim_task.name AS task,
        dim_task.category AS task_category,
        COUNT(1) AS number_of_tasks,
        SUM(daily_working_hours) AS task_duration_hours
    FROM distributed_hours
    LEFT JOIN dim_person
        ON distributed_hours.person_id = dim_person.id
    LEFT JOIN dim_task
        ON distributed_hours.task_id = dim_task.id
    GROUP BY 1, 2, 3, 4
    ),
    stg_housework_tasks AS (
        SELECT fct.date,
               dim_person.name AS person,
               dim_task.name AS task,
               dim_task.category AS task_category,
               COUNT(1) AS number_of_tasks,
               SUM(fct.task_duration_minutes)::FLOAT / 60 AS task_duration_hours
        FROM public.fact_housework_tasks AS fct
        LEFT JOIN public.dim_person AS dim_person
            ON fct.person_id = dim_person.id
        LEFT JOIN public.dim_task AS dim_task
            ON fct.task_id = dim_task.id
        GROUP BY fct.date, dim_person.name, dim_task.name, dim_task.category
    ),
    housework_tasks AS (
        SELECT *
        FROM final_working_hours_result
        UNION ALL
        SELECT *
        FROM stg_housework_tasks
    )

    INSERT INTO public.agg_daily_housework_tasks (date, person, task, task_category, number_of_tasks, task_duration_hours)
    SELECT date,
           person,
           task,
           task_category,
           number_of_tasks,
           task_duration_hours
    FROM housework_tasks
    ON CONFLICT (date, person, task)
    DO UPDATE SET task_category = excluded.task_category,
                  number_of_tasks = excluded.number_of_tasks,
                  task_duration_hours = excluded.task_duration_hours,
                  update_time_utc = now()
    WHERE (agg_daily_housework_tasks.task_category != excluded.task_category OR
           agg_daily_housework_tasks.number_of_tasks != excluded.number_of_tasks OR
           agg_daily_housework_tasks.task_duration_hours != excluded.task_duration_hours);
END;
$$;