SELECT
    legs_seats_prices.dep_date AS date,
    CAST(
        round(
            CAST(
                percentile_disc(0) WITHIN GROUP (
                    ORDER BY
                        legs_seats_prices.price ASC
                ) AS NUMERIC
            ),
            0
        ) AS NUMERIC
    ) AS price__min,
    CAST(
        round(
            CAST(
                percentile_disc(0.25) WITHIN GROUP (
                    ORDER BY
                        legs_seats_prices.price ASC
                ) AS NUMERIC
            ),
            0
        ) AS NUMERIC
    ) AS price__q1,
    CAST(
        round(
            CAST(
                percentile_disc(0.5) WITHIN GROUP (
                    ORDER BY
                        legs_seats_prices.price ASC
                ) AS NUMERIC
            ),
            0
        ) AS NUMERIC
    ) AS price__median,
    CAST(
        round(
            CAST(
                percentile_disc(0.75) WITHIN GROUP (
                    ORDER BY
                        legs_seats_prices.price ASC
                ) AS NUMERIC
            ),
            0
        ) AS NUMERIC
    ) AS price__q3,
    CAST(
        round(
            CAST(
                percentile_disc(1) WITHIN GROUP (
                    ORDER BY
                        legs_seats_prices.price ASC
                ) AS NUMERIC
            ),
            0
        ) AS NUMERIC
    ) AS price__max,
    count(*) AS seat_count \ nFROM (
        SELECT
            filtered_legs.dep_date AS dep_date,
            filtered_seats_prices_1.price AS price \ nFROM (
                SELECT
                    concat(
                        legs.dep_year,
                        '-',
                        lpad(CAST(legs.dep_month AS VARCHAR), 2, '0')
                    ) AS dep_month_year,
                    CASE
                        WHEN (
                            EXTRACT(
                                hour
                                FROM
                                    legs.dep_time
                            ) >= 21
                        ) THEN 'LATE NIGHT'
                        WHEN (
                            EXTRACT(
                                hour
                                FROM
                                    legs.dep_time
                            ) >= 16
                        ) THEN 'EVENING'
                        WHEN (
                            EXTRACT(
                                hour
                                FROM
                                    legs.dep_time
                            ) >= 11
                        ) THEN 'AFTERNOON'
                        WHEN (
                            EXTRACT(
                                hour
                                FROM
                                    legs.dep_time
                            ) >= 5
                        ) THEN 'MORNING'
                        ELSE 'LATE NIGHT'
                    END AS dep_time_bucket,
                    concat(
                        least(legs.origin, legs.destination),
                        greatest(legs.origin, legs.destination)
                    ) AS rt_market,
                    concat(legs.origin, legs.destination) AS ow_market,
                    CASE
                        WHEN (legs.distance_km > 4000) THEN 'long-haul'
                        WHEN (legs.distance_km > 1500) THEN 'mid-haul'
                        ELSE 'short-haul'
                    END AS flt_length,
                    CASE
                        WHEN (legs.dep_month >= 10) THEN '4'
                        WHEN (legs.dep_month >= 7) THEN '3'
                        WHEN (legs.dep_month >= 4) THEN '2'
                        ELSE '1'
                    END AS quarter,
                    concat(
                        legs.dep_year,
                        ' Q',
                        CASE
                            WHEN (legs.dep_month >= 10) THEN '4'
                            WHEN (legs.dep_month >= 7) THEN '3'
                            WHEN (legs.dep_month >= 4) THEN '2'
                            ELSE '1'
                        END
                    ) AS dep_quarter_year,
                    CAST(
                        greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                    ) AS tud,
                    CAST(
                        CASE
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 121
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 366
                            ) THEN '120+'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 61
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 120
                            ) THEN '61-120'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 31
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 60
                            ) THEN '31-60'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 21
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 30
                            ) THEN '21-30'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 14
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 20
                            ) THEN '14-20'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 9
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 13
                            ) THEN '9-13'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 4
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 8
                            ) THEN '4-8'
                            WHEN (
                                CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) >= 0
                                AND CAST(
                                    greatest(legs.dep_date - CURRENT_DATE, 0) AS INTEGER
                                ) <= 3
                            ) THEN '0-3'
                            ELSE 'N/A'
                        END AS VARCHAR
                    ) AS tud_bucket,
                    legs.created_at AS created_at,
                    legs.leg_id AS leg_id,
                    legs.flight_number AS flight_number,
                    legs.origin AS origin,
                    legs.origin_city_code AS origin_city_code,
                    legs.destination AS destination,
                    legs.destination_city_code AS destination_city_code,
                    legs.dep_datetime AS dep_datetime,
                    legs.dep_time AS dep_time,
                    legs.dep_dow AS dep_dow,
                    legs.dep_week_monday AS dep_week_monday,
                    legs.dep_week_number AS dep_week_number,
                    legs.dep_date AS dep_date,
                    legs.dep_month AS dep_month,
                    legs.dep_year AS dep_year,
                    legs.duration_min AS duration_min,
                    legs.distance_km AS distance_km,
                    legs.aircraft_subtype_id AS aircraft_subtype_id,
                    legs.processed_at AS processed_at,
                    legs.revenue AS revenue,
                    legs.currency AS currency \ nFROM legs \ nWHERE true
                    AND true
                    AND legs.dep_date >= current_date
            ) AS filtered_legs
            JOIN LATERAL (
                SELECT
                    filtered_legs.leg_id AS leg_id,
                    seat_prices.base_fare AS price \ nFROM seat_prices
                    JOIN aircraft_seats ON aircraft_seats.id = seat_prices.aircraft_seat_id \ nWHERE seat_prices.aircraft_subtype_id = filtered_legs.aircraft_subtype_id
                    AND seat_prices.leg_id = filtered_legs.leg_id
                    AND aircraft_seats.cabin_class = 'Y'
                    AND aircraft_seats.seat_zone_id IN ('4', '5')
                    AND aircraft_seats.seat_type IN ('window', 'aisle')
            ) AS filtered_seats_prices_1 ON filtered_legs.leg_id = filtered_seats_prices_1.leg_id
    ) AS legs_seats_prices
GROUP BY
    legs_seats_prices.dep_date