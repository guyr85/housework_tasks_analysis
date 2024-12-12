CREATE VIEW tb_agg_daily_housework_tasks_vw AS
    SELECT date,
	       person,
	       task,
	       task_category,
	       number_of_tasks,
	       task_duration_minutes,
	       update_time_utc
    FROM public.agg_daily_housework_tasks;