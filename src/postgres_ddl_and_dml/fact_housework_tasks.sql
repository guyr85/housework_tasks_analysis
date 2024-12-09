CREATE TABLE IF NOT EXISTS public.fact_housework_tasks
(
    id SERIAL PRIMARY KEY,
    record_insert_time timestamp default now() NOT NULL,
    date date NOT NULL,
    person_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    task_duration_minutes INTEGER
)

