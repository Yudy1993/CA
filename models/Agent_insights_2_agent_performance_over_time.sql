create or replace view agent_performance_patterns as 
-- joining won and lost cases 
with resolved_cases as (
		select case_id, 'Won' as final_status, occured_at::timestamp as resolved_at from public.case_lost_events
		union
		select case_id, 'Lost' as final_status, occured_at::timestamp as resolved_at from public.case_won_events
),
-- getting details about the case and resolution
	case_resolution_details as (
		select
			c.case_id,
			c.assigned_to,
			c.creation_date::timestamp as created_at,
			rc.final_status,
			rc.resolved_at,
			date_trunc('week', c.creation_date::timestamp) as created_week,
			extract(week from c.creation_date::timestamp) as week_no,
			extract(epoch from (rc.resolved_at - c.creation_date::timestamp)) / 86400 as resolution_days
		from public.cases as c
		join resolved_cases as rc on c.case_id = rc.case_id
),
-- calculating weekly performance of agents
	agent_weekly_performance as (
		select
			assigned_to as agent,
			created_week,
			week_no,
			count(*) as resolved_cases,
			count(*) filter (where final_status = 'Won') as won_cases,
			count(*) filter (where final_status = 'Lost') as lost_cases,
			round(count(*) filter (where final_status = 'Won')::decimal / nullif(count(*), 0), 4) as win_rate,
			round(avg(resolution_days), 2) as avg_resolution_days
		from case_resolution_details
		group by assigned_to, created_week, week_no
		order by agent, created_week
),
-- ranked performance per week
	ranked as (
		select
			agent,
			week_no,
			resolved_cases,
			won_cases,
			lost_cases,
			win_rate,
			avg_resolution_days,
			rank() over (partition by week_no order by win_rate desc) as weekly_rank
		from agent_weekly_performance
)
select * from ranked
order by week_no, weekly_rank desc;
