WITH housework_tasks AS (
	SELECT fct.date,
	 	   dim_person.name AS person,
		   dim_task.name AS task,
		   dim_task.category AS task_category,
		   COUNT(fct.id) AS number_of_tasks,
		   SUM(fct.task_duration_minutes) AS task_duration_minutes,
		   NOW() AS update_time_utc
	FROM public.fact_housework_tasks AS fct
	LEFT JOIN public.dim_person AS dim_person
		ON fct.person_id = dim_person.id
	LEFT JOIN public.dim_task AS dim_task
		ON fct.task_id = dim_task.id
	GROUP BY fct.date, dim_person.name, dim_task.name, dim_task.category
)

INSERT INTO public.agg_daily_housework_tasks (date, person, task, task_category, number_of_tasks, task_duration_minutes, update_time_utc)
SELECT date,
	   person,
	   task,
	   task_category,
	   number_of_tasks,
	   task_duration_minutes,
	   update_time_utc
FROM housework_tasks;