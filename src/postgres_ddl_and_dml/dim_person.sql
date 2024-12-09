CREATE TABLE IF NOT EXISTS public.dim_person
(
    id integer NOT NULL,
    name text  NOT NULL,
    created_at timestamp default now() NOT NULL,
    updated_at timestamp default now() NOT NULL,
    CONSTRAINT "dim_person_pkey" PRIMARY KEY (id)
);

INSERT INTO public.dim_person (id, name) VALUES (1, 'Guy'), (2, 'Adi');