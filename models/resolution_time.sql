create or replace view cltv as
-- Calcuating total won values by client
with client_won_cvalue as (
	select
		c.client_id,
		c.client_name,
		sum(cs.case_value) as total_won_v
	from public.cases as cs
	join public.clients as c
		on cs.client_id = c.client_id
	where cs.status = 'Won'
	group by c.client_id, c.client_name
),
-- Calculating the median which is less sensitive to outliers
	median_calc as (
	select
		percentile_cont(0.33) within group (order by total_won_v) as p33,
		percentile_cont(0.67) within group (order by total_won_v) as p67
	from client_won_cvalue
),
-- Define High, Medium, Low CLTV groups
	segments as (
	select
		cwv.client_id,
		cwv.total_won_v as total_value,
		case
			when cwv.total_won_v >= p67 then 'High'
			when cwv.total_won_v >= p33 then 'Medium'
		else 'Low'
		end as cltv_segment
	from client_won_cvalue cwv, median_calc mc
),
-- Final statement for simplicity
	final as (
	select 
		client_id,
		total_value,
		cltv_segment
	from segments
	order by total_value desc
)
select * from final;