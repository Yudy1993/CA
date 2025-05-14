create or replace view agen_performance as 
-- joining won and lost cases 
with resolved_cases as (
		select case_id, 'Lost' as final_status, occured_at::timestamp as resolved_at from public.case_lost_events
		union
		select case_id, 'Won' as final_status, occured_at::timestamp as resolved_at from public.case_won_events
),
-- joining agent and creation info
	case_with_resolution as (
		select
			c.case_id,
			c.assigned_to,
			c.status as inital_status,
			c.creation_date::timestamp as created_at,
			rc.final_status,
			rc.resolved_at,
			extract(epoch from (rc.resolved_at - c.creation_date::timestamp)) / 86400 as resolution_days
		from public.cases as c
		join resolved_cases as rc on c.case_id = rc.case_id
),
-- calculate agent_performance
	agent_performance as (
		select
			assigned_to as agent,
			count(*) as total_resolved_cases,
			count(*) filter (where final_status = 'Won') as won_cases,
			count(*) filter (where final_status = 'Lost') as lost_cases,
			round(count(*) filter (where final_status = 'Won')::decimal / nullif(count(*), 0), 4) as win_rate,
			round(avg(resolution_days), 2) as avg_resolution_days
		from case_with_resolution
		group by assigned_to 
),
-- final statement for simplicity
	final as (
		select
			agent,
			total_resolved_cases,
			won_cases,
			lost_cases,
			win_rate,
			avg_resolution_days
		from agent_performance
)
select * from final;
