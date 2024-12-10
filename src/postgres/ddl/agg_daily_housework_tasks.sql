CREATE TABLE IF NOT EXISTS public.agg_daily_housework_tasks
(
    date date NOT NULL,
    -- Going to backfill the agg data, can keep the name of the person
    person TEXT NOT NULL,
    -- Going to backfill the agg data, can keep the name of the task
    task TEXT NOT NULL,
    task_category TEXT,
    -- Count the number of tasks
    number_of_tasks INTEGER,
    -- Sum the duration of the tasks
    task_duration_minutes INTEGER,
    update_time_utc timestamp default now() NOT NULL,
    CONSTRAINT "agg_daily_housework_tasks_pkey" PRIMARY KEY (date, person, task)
)

