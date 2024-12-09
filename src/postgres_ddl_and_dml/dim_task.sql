CREATE TABLE IF NOT EXISTS public.dim_task
(
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp default now() NOT NULL,
    updated_at timestamp default now() NOT NULL,
    CONSTRAINT "dim_task_pkey" PRIMARY KEY (id)
)

INSERT INTO public.dim_task (id, name) VALUES (1, 'Laundry '), (2, 'Washing Dishes');