CREATE OR REPLACE PROCEDURE public.truncate_stg_fact_housework_tasks()
LANGUAGE plpgsql AS $$
BEGIN
    TRUNCATE TABLE public.stg_fact_housework_tasks;
END;
$$;