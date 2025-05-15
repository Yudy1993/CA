-- Retrieving casestamps from won cases
WITH cases_timestamps_won AS (
         SELECT po.case_id,
            	po.occured_at AS open_timestamp,
            	pc.occured_at AS closed_timestamp
           FROM case_opened_events po
             JOIN case_won_events pc ON po.case_id = pc.case_id
        ), 
-- Retrieving casetampt from lost cases
	cases_timestamps_lost AS (
	SELECT po.case_id,
		po.occured_at AS open_timestamp,
		pl.occured_at AS closed_timestamp
	FROM case_opened_events po
	JOIN case_lost_events pl ON po.case_id = pl.case_id
        ), 
-- Mergning the two tables
	unioned AS (
        SELECT cases_timestamps_won.case_id,
            	cases_timestamps_won.open_timestamp,
            	cases_timestamps_won.closed_timestamp
        FROM cases_timestamps_won
        UNION ALL
	
        SELECT cases_timestamps_lost.case_id,
            	cases_timestamps_lost.open_timestamp,
            	cases_timestamps_lost.closed_timestamp
        FROM cases_timestamps_lost
        ), 
-- Resolution time calculation 	
	resolution_time_calculation AS (
        SELECT unioned.case_id,
            unioned.closed_timestamp,
            unioned.open_timestamp,
            unioned.closed_timestamp - unioned.open_timestamp AS resolution_time
        FROM unioned
        ), 
-- Splitting the days into days and hours
	day_time_split AS (
        SELECT resolution_time_calculation.case_id,
            resolution_time_calculation.resolution_time AS total_resolution_time,
            EXTRACT(day FROM resolution_time_calculation.resolution_time) AS days,
            EXTRACT(hour FROM resolution_time_calculation.resolution_time) + EXTRACT(day FROM resolution_time_calculation.resolution_time) * 24::numeric AS hours
        FROM resolution_time_calculation
        ), 
-- Final selection statement	
	final AS (
        SELECT day_time_split.case_id,
            day_time_split.total_resolution_time,
            day_time_split.days,
            day_time_split.hours
        FROM day_time_split
        )
 SELECT case_id,
    total_resolution_time,
    days,
    hours
   FROM final;
