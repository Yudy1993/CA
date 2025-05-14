 create or replace view maximum_cost as
-- Calculating sum of won cases
with sum_won as (
	select
		sum(case_value) as total_won
	from public.cases
	where status = 'Won'
),
-- Calculating sum of lost cases
	sum_lost as (
	select
		sum(case_value) as total_lost
	from public.cases
	where status = 'Lost'
),
-- Calculating number of open cases
	count_open as (
	select
		count(*) as open_case_count
	from public.cases
	where status = 'Open'
),
-- Calculate maximum break-even on opened cases based on won and lost
max_cost as (
	select 
		total_won - total_lost as max_open_case_break_even 
	from sum_won, sum_lost
),
-- Allocate cost to open cases
max_cost_per_case as (
	select
		round(max_open_case_break_even / nullif(open_case_count, 0), 2) as max_open_case_value
	from max_cost, count_open
)
select * from max_cost_per_case;
