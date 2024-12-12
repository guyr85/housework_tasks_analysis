CREATE TABLE IF NOT EXISTS public.fact_housework_tasks
(
    date date NOT NULL,
    person_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    task_duration_minutes INTEGER,
    record_insert_time timestamp default now() NOT NULL,
    CONSTRAINT "fact_housework_tasks_pkey" PRIMARY KEY (date, person_id, task_id)
);


CREATE TABLE IF NOT EXISTS public.stg_fact_housework_tasks
(
    id SERIAL PRIMARY KEY,
    date date NOT NULL,
    person_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    task_duration_minutes INTEGER,
    record_insert_time timestamp default now() NOT NULL
);