CREATE TABLE IF NOT EXISTS public.dim_task
(
    id integer NOT NULL,
    name text NOT NULL,
    category text,
    created_at timestamp default now() NOT NULL,
    updated_at timestamp default now() NOT NULL,
    CONSTRAINT "dim_task_pkey" PRIMARY KEY (id)
)

INSERT INTO public.dim_task (id, name, category)
VALUES (1, 'Folding Laundry', 'Household'),
       (2, 'Empty The Dishwasher', 'Household'),
       (3, 'Cooking', 'Household'),
       (4, 'Cleaning', 'Household'),
       (5, 'Clear Out The Trash', 'Household'),
       (6, 'Change Of Bed Linen', 'Household'),
       (7, 'Pick Up Mail', 'Household'),
       (8, 'Grocery Shopping/Arrangement', 'Household'),
       (9, 'Take/Return The Kindergarten Child', 'Child Care'),
       (10, 'Bath The Child', 'Child Care'),
       (11, 'Feed The Child', 'Child Care'),
       (12, 'Take Care/Play With The Child', 'Child Care'),
       (13, 'Teach The Child', 'Child Care'),
       (14, 'Accompanying The Child In Treatment', 'Child Care'),
       (15, 'Monthly Working Hours', 'Career'),
       (16, 'Study/Seminars Hours', 'Career')

