create or replace view data_driven_pred as 
-- counting number of cases per client
with case_count as (
		select
			client_id,
			count(*) filter (where status = 'Won') as won_case,
			count(*) filter (where status = 'Lost') as lost_case,
			count(*) filter (where status = 'Open') as open_case,
			count(*) as total_case
		from public.cases
		group by client_id
),
-- calculating the win rate of cases per client
	win_probability as (
		select
			client_id,
			won_case,
			lost_case,
			open_case,
			total_case,
			case 
				when (won_case + lost_case) > 0 then round(won_case::decimal /(won_case + lost_case), 4)
				else null
			end as win_rate
		from case_count
),
-- defining weighted win rate
	weighted_cases as (
		select
			c.client_id,
	        c.creation_date,
	        c.case_value,
	        c.status,
	        wp.win_rate,
			case
				when c.status = 'Won' then 1.0
				when c.status = 'Lost' then 0.0
				when c.status = 'Open' then coalesce(wp.win_rate, 0.5)
			else 0.0
			end as status_weight
		from public.cases as c
		left join win_probability as wp
			on c.client_id = wp.client_id
),
-- multiply with the case values
	scored_cases as (
		select
			client_id,
			case_value * status_weight as weighted_value,
			date_trunc('month', creation_date) as case_month
		from weighted_cases
),
-- derriving client stats
	client_stats as (
		select
			client_id,
			sum(weighted_value) as total_weighted_value,
			min(case_month) as first_month,
			max(case_month) as last_month
		from scored_cases
		group by client_id
),
-- active months of client
	active_month as (
		select
			client_id,
			extract(month from age(last_month, first_month))
			+ extract(year from age(last_month, first_month)) * 12 + 1 as month_active
		from client_stats
),
-- calculating prediction of client
	predicted_value as (
		select
			cs.client_id,
			cs.total_weighted_value,
			am.month_active,
			round(cs.total_weighted_value / am.month_active, 2) as predicted_month_value
		from client_stats as cs
		join active_month as am on cs.client_id = am.client_id
),
-- joining with client details
	client_details as (
		select
			pv.client_id,
			cl.client_name,
			cl.market,
			pv.total_weighted_value,
			pv.month_active,
			pv.predicted_month_value
		from predicted_value as pv
		join public.clients as cl on pv.client_id = cl.client_id
		order by predicted_month_value desc
),
-- final statement for simplicity
	final as (
		select
			client_id,
			client_name,
			market,
			predicted_month_value
		from client_details
)
select * from final;
	
