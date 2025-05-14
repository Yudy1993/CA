--create or replace view market_pred as 
-- calculate market cases
with market_case_count as (
		select
			market,
			count(*) filter (where status = 'Won') as won_case,
			count(*) filter (where status = 'Lost') as lost_case,
			count(*) filter (where status = 'Open') as open_case,
			count(*) as total_case
		from public.cases
		group by market
),
-- calculating market trends
	market_trends as (
		select
			market,
			won_case,
			lost_case,
			open_case,
			total_case,
			round(won_case::decimal / nullif(won_case + lost_case, 0), 4) as win_rate,
			round(lost_case::decimal / nullif(won_case + lost_case, 0), 4) as loss_rate,
			round(open_case::decimal / nullif(total_case, 0), 4) as open_rate
		from market_case_count
),
-- final statement for simplicity
	final as (
		select
			market,
			total_case,
			won_case,
			lost_case,
			open_case,
			win_rate,
			loss_rate,
			open_rate
		from market_trends
		order by total_case desc
)
select * from final;
