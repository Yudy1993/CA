create or replace view monthly_pred as
with won_case as (
	select *
	from public.cases
	where status = 'Won' 
),
-- count cases and get average value per client
	client_stat as (
	select
		client_id,
		count(*) as total_cases,
		round(avg(case_value), 2) as avg_case_value
	from won_case
	group by client_id
),
-- calculating monthly case count per client
	monthly_case_count as (
	select
		client_id,
		date_trunc('month', creation_date) as month,
		count(*) as cases_in_month
	from won_case
	group by client_id, month
),
-- calculating avg case per client
	avg_monthly_case as (
    select
        client_id,
        round(avg(cases_in_month), 2) as avg_monthly_case_count
    from monthly_case_count
    group by client_id
),
-- predict by average case value and count
	prediction as (
	select
		cs.client_id,
		cs.avg_case_value,
		amc.avg_monthly_case_count,
		round(cs.avg_case_value * amc.avg_monthly_case_count, 2) as pred_month_case_value
	from client_stat as cs
	join avg_monthly_case as amc
		on cs.client_id = amc.client_id
),
-- add client and market
	joined as (
	select
		p.client_id,
		cl.client_name,
		cl.market,
		p.avg_monthly_case_count,
		p.pred_month_case_value
	from prediction as p
	join clients as cl on p.client_id = cl.client_id
	order by p.pred_month_case_value desc
),
-- final statement for simplicity
	final as (
	select
		client_id,
		client_name,
		market,
		avg_monthly_case_count,
		pred_month_case_value
	from joined
)
select * from final;
	
