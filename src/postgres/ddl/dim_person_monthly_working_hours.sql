CREATE TABLE IF NOT EXISTS public.dim_person_monthly_working_hours
(
    month_id DATE NOT NULL,
    person_id INTEGER NOT NULL,
    monthly_working_hours FLOAT  NOT NULL,
    created_at timestamp default now() NOT NULL,
    updated_at timestamp default now() NOT NULL,
    CONSTRAINT "dim_person_monthly_working_hours_pkey" PRIMARY KEY (month_id, person_id)
);

INSERT INTO public.dim_person_monthly_working_hours (month_id, person_id, monthly_working_hours)
VALUES ('2024-12-01',1, 189), ('2024-12-01', 2, 66);