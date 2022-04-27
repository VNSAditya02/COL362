--1--
WITH hop0 AS (
	SELECT train_info.destination_station_name
	FROM train_info 
	WHERE train_info.source_station_name = 'KURLA' AND train_info.train_no = 97131
),

hop1 AS (
	SELECT train_info.destination_station_name
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name
),

hop2 AS(
	SELECT train_info.destination_station_name
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name
)

SELECT destination_station_name FROM hop0
UNION
SELECT destination_station_name FROM hop1 
UNION
SELECT destination_station_name FROM hop2
ORDER BY destination_station_name
;

--2--
WITH hop0 AS (
	SELECT destination_station_name, day_of_arrival
	FROM train_info 
	WHERE source_station_name = 'KURLA' AND train_no = 97131 AND day_of_arrival = day_of_departure 
),

hop1 AS (
	SELECT train_info.destination_station_name, train_info.day_of_arrival
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = hop0.day_of_arrival
),

hop2 AS(
	SELECT train_info.destination_station_name
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = hop1.day_of_arrival
)

SELECT destination_station_name FROM hop0
UNION
SELECT destination_station_name FROM hop1 
UNION
SELECT destination_station_name FROM hop2
ORDER BY destination_station_name
;

--3--
WITH hop0 AS (
	SELECT destination_station_name, distance, day_of_arrival
	FROM train_info 
	WHERE source_station_name = 'DADAR' AND day_of_arrival = day_of_departure 
),

hop1 AS (
	SELECT train_info.destination_station_name, (train_info.distance + hop0.distance) as distance, train_info.day_of_arrival
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = hop0.day_of_arrival
),

hop2 AS(
	SELECT train_info.destination_station_name, (train_info.distance + hop1.distance) as distance, train_info.day_of_arrival
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = hop1.day_of_arrival
)

-- SELECT COUNT(*) FROM (
SELECT destination_station_name, distance, day_of_arrival FROM hop0 WHERE destination_station_name != 'DADAR'
UNION
SELECT destination_station_name, distance, day_of_arrival FROM hop1 WHERE destination_station_name != 'DADAR'
UNION
SELECT destination_station_name, distance, day_of_arrival FROM hop2 WHERE destination_station_name != 'DADAR'
ORDER BY destination_station_name, distance, day_of_arrival
-- ) AS t
;

--4--
-- TODO: CHECK TIMING CONDITION
WITH days AS(
	SELECT 'Monday' AS day, 1 AS index
	UNION
	SELECT 'Tuesday' AS day, 2 AS index
	UNION
	SELECT 'Wednesday' AS day, 3 AS index
	UNION
	SELECT 'Thursday' AS day, 4 AS index
	UNION
	SELECT 'Friday' AS day, 5 AS index
	UNION
	SELECT 'Saturday' AS day, 6 AS index
	UNION
	SELECT 'Sunday' AS day, 7 AS index
),

temp_train_info AS(
	SELECT train_no, train_name, distance, source_station_name, departure_time, day_of_departure, destination_station_name, arrival_time, day_of_arrival, index AS arrival_index
	FROM train_info JOIN days
	ON train_info.day_of_arrival = days.day
),

new_train_info AS(
	SELECT train_no, train_name, distance, source_station_name, departure_time, day_of_departure, destination_station_name, arrival_time, day_of_arrival, arrival_index, index AS departure_index
	FROM temp_train_info JOIN days
	ON temp_train_info.day_of_departure = days.day
),

hop0 AS (
	SELECT destination_station_name, arrival_time, arrival_index
	FROM new_train_info, days
	WHERE source_station_name = 'DADAR' AND (arrival_index >= departure_index)
	-- AND (new_train_info.departure_time < new_train_info.arrival_time)

),

hop1 AS (
	SELECT new_train_info.destination_station_name, new_train_info.arrival_time, new_train_info.arrival_index
	FROM hop0 JOIN new_train_info 
	ON hop0.destination_station_name = new_train_info.source_station_name AND 
	(new_train_info.arrival_index >= new_train_info.departure_index) AND
	((hop0.arrival_index < new_train_info.departure_index) OR (hop0.arrival_index = new_train_info.departure_index AND new_train_info.departure_time >= hop0.arrival_time))
	-- AND (new_train_info.departure_time < new_train_info.arrival_time)
),

hop2 AS(
	SELECT new_train_info.destination_station_name, new_train_info.arrival_index
	FROM hop1 JOIN new_train_info
	ON hop1.destination_station_name = new_train_info.source_station_name AND 
	(new_train_info.arrival_index >= new_train_info.departure_index) AND
	((hop1.arrival_index < new_train_info.departure_index) OR (hop1.arrival_index = new_train_info.departure_index AND new_train_info.departure_time >= hop1.arrival_time))
	-- AND (new_train_info.departure_time < new_train_info.arrival_time)
)

-- SELECT * FROM new_train_info
-- SELECT COUNT(*) FROM(
SELECT destination_station_name FROM hop0 WHERE destination_station_name != 'DADAR'
UNION
SELECT destination_station_name FROM hop1 WHERE destination_station_name != 'DADAR'
UNION
SELECT destination_station_name FROM hop2 WHERE destination_station_name != 'DADAR'
ORDER BY destination_station_name
-- ) AS t
;

--5--
WITH hop0 AS (
	SELECT DISTINCT train_no, source_station_name AS station0, destination_station_name
	FROM train_info 
	WHERE source_station_name = 'CST-MUMBAI'
),

hop1 AS (
	SELECT DISTINCT hop0.train_no AS train1, hop0.station0, hop0.destination_station_name AS station1, train_info.train_no, train_info.destination_station_name
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name AND hop0.destination_station_name != 'VASHI' AND train_info.destination_station_name != 'CST-MUMBAI'
),

hop2 AS(
	SELECT DISTINCT hop1.train1, hop1.station0, hop1.station1, hop1.train_no AS train2, hop1.destination_station_name AS station2, train_info.train_no, train_info.destination_station_name
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name AND hop1.destination_station_name != 'VASHI'
)

SELECT SUM(c) AS count
FROM(
	SELECT COUNT(*) AS c FROM hop0 WHERE destination_station_name = 'VASHI'
	UNION ALL
	SELECT COUNT(*) AS c FROM hop1 WHERE destination_station_name = 'VASHI'
	UNION ALL
	SELECT COUNT(*) AS c FROM hop2 WHERE destination_station_name = 'VASHI'
) AS t;

--6--
WITH hop0 AS (
	SELECT source_station_name, destination_station_name, min(distance) AS distance
	FROM train_info
	GROUP BY source_station_name, destination_station_name
),

hop1 AS (
	SELECT hop0.source_station_name, train_info.destination_station_name, min(train_info.distance + hop0.distance) as distance
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name
	GROUP BY hop0.source_station_name, train_info.destination_station_name
),

hop2 AS(
	SELECT hop1.source_station_name, train_info.destination_station_name, min(train_info.distance + hop1.distance) as distance
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name
	GROUP BY hop1.source_station_name, train_info.destination_station_name
),

hop3 AS(
	SELECT hop2.source_station_name, train_info.destination_station_name, min(train_info.distance + hop2.distance) as distance
	FROM hop2 JOIN train_info
	ON hop2.destination_station_name = train_info.source_station_name
	GROUP BY hop2.source_station_name, train_info.destination_station_name
),

hop4 AS(
	SELECT hop3.source_station_name, train_info.destination_station_name, min(train_info.distance + hop3.distance) as distance
	FROM hop3 JOIN train_info
	ON hop3.destination_station_name = train_info.source_station_name
	GROUP BY hop3.source_station_name, train_info.destination_station_name
),

hop5 AS(
	SELECT hop4.source_station_name, train_info.destination_station_name, min(train_info.distance + hop4.distance) as distance
	FROM hop4 JOIN train_info
	ON hop4.destination_station_name = train_info.source_station_name
	GROUP BY hop4.source_station_name, train_info.destination_station_name
)

SELECT t.source_station_name, t.destination_station_name, min(t.distance) AS distance FROM(
	SELECT source_station_name, destination_station_name, distance FROM hop0
	UNION ALL
	SELECT source_station_name, destination_station_name, distance FROM hop1 
	UNION ALL
	SELECT source_station_name, destination_station_name, distance FROM hop2
	UNION ALL
	SELECT source_station_name, destination_station_name, distance FROM hop3
	UNION ALL
	SELECT source_station_name, destination_station_name, distance FROM hop4
	UNION ALL
	SELECT source_station_name, destination_station_name, distance FROM hop5
) AS t
WHERE source_station_name != destination_station_name
GROUP BY source_station_name, destination_station_name
ORDER BY destination_station_name
;

--7--
WITH hop0 AS (
	SELECT DISTINCT source_station_name, destination_station_name
	FROM train_info
),

hop1 AS (
	SELECT DISTINCT hop0.source_station_name, train_info.destination_station_name
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name
),

hop2 AS(
	SELECT DISTINCT hop1.source_station_name, train_info.destination_station_name
	FROM hop1 JOIN train_info
	ON hop1.destination_station_name = train_info.source_station_name
),

hop3 AS(
	SELECT DISTINCT hop2.source_station_name, train_info.destination_station_name
	FROM hop2 JOIN train_info
	ON hop2.destination_station_name = train_info.source_station_name
)

-- SELECT COUNT(*) FROM(
	SELECT DISTINCT source_station_name, destination_station_name FROM(
	SELECT source_station_name, destination_station_name FROM hop0 WHERE source_station_name != destination_station_name
	UNION
	SELECT source_station_name, destination_station_name FROM hop1 WHERE source_station_name != destination_station_name
	UNION
	SELECT source_station_name, destination_station_name FROM hop2 WHERE source_station_name != destination_station_name
	UNION
	SELECT source_station_name, destination_station_name FROM hop3 WHERE source_station_name != destination_station_name

	ORDER BY source_station_name, destination_station_name
	) AS t
-- ) AS p
;

--8--
WITH RECURSIVE paths (source_station_name, destination_station_name, day_of_arrival, path) AS (
        SELECT source_station_name, destination_station_name, day_of_arrival, ARRAY[source_station_name, destination_station_name]
        FROM train_info
        WHERE source_station_name = 'SHIVAJINAGAR' AND day_of_arrival = day_of_departure
    UNION
        SELECT paths.source_station_name, train_info.destination_station_name, paths.day_of_arrival, paths.path || ARRAY[train_info.destination_station_name]
        FROM paths
        JOIN train_info
        ON paths.destination_station_name = train_info.source_station_name AND train_info.destination_station_name != ALL(paths.path)
        AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = paths.day_of_arrival
)

SELECT DISTINCT destination_station_name , day_of_arrival AS day
FROM paths WHERE destination_station_name != 'SHIVAJINAGAR'
ORDER BY destination_station_name;

--9--
WITH RECURSIVE paths (source_station_name, destination_station_name, distance, day_of_arrival, path) AS (
        SELECT source_station_name, destination_station_name, distance, day_of_arrival, ARRAY[source_station_name, destination_station_name]
        FROM train_info
        WHERE source_station_name = 'LONAVLA' AND day_of_arrival = day_of_departure
    UNION
        SELECT paths.source_station_name, train_info.destination_station_name, paths.distance + train_info.distance, paths.day_of_arrival, paths.path || ARRAY[train_info.destination_station_name]
        FROM paths
        JOIN train_info
        ON paths.destination_station_name = train_info.source_station_name AND train_info.destination_station_name != ALL(paths.path)
        AND train_info.day_of_arrival = train_info.day_of_departure AND train_info.day_of_arrival = paths.day_of_arrival
)

SELECT destination_station_name, distance, day_of_arrival AS day
FROM paths 
WHERE destination_station_name != 'LONAVLA'
AND (destination_station_name, distance) IN
	(
		SELECT destination_station_name, min(distance) AS distance
		FROM paths WHERE destination_station_name != 'LONAVLA'
		GROUP BY destination_station_name, day_of_arrival
	)
ORDER BY distance, destination_station_name
;

--10--
WITH RECURSIVE paths (source_station_name, destination_station_name, path) AS (
        SELECT source_station_name, destination_station_name, ARRAY[destination_station_name]
        FROM train_info
    UNION
        SELECT paths.source_station_name, train_info.destination_station_name, paths.path || ARRAY[train_info.destination_station_name]
        FROM paths
        JOIN train_info
        ON paths.destination_station_name = train_info.source_station_name
         AND train_info.destination_station_name != ALL(paths.path)
)

SELECT source_station_name, cardinality(path) AS distance
FROM paths 
WHERE source_station_name = destination_station_name
AND cardinality(path) = 
(SELECT max(length) FROM (SELECT cardinality(path) AS length FROM paths WHERE source_station_name = destination_station_name) AS t)
ORDER BY source_station_name
;

--11--
WITH hop0 AS (
	SELECT source_station_name, destination_station_name
	FROM train_info 
),

hop1 AS (
	SELECT hop0.source_station_name, train_info.destination_station_name
	FROM hop0 JOIN train_info 
	ON hop0.destination_station_name = train_info.source_station_name AND hop0.source_station_name != train_info.destination_station_name
)

SELECT t1.source_station_name
FROM
	(SELECT t.source_station_name, count(t.destination_station_name) FROM
		(SELECT DISTINCT source_station_name, destination_station_name FROM hop0
		UNION
		SELECT DISTINCT source_station_name, destination_station_name FROM hop1) AS t
	GROUP BY t.source_station_name) AS t1
WHERE t1.count + 1 = (
	SELECT count(t.station) 
	FROM 
		(SELECT DISTINCT source_station_name AS station FROM train_info
		UNION
		SELECT DISTINCT destination_station_name AS station FROM train_info
		) AS t
	)
ORDER BY t1.source_station_name 
;

--12--
SELECT teams.name AS teamnames
FROM(
	SELECT DISTINCT g2.hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'Arsenal'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
) AS t JOIN teams
ON t.hometeamid = teams.teamid
ORDER BY teams.name;

--13--
WITH common AS(
	SELECT DISTINCT g2.hometeamid, g2.year
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'Arsenal'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
),

min_year AS(
	SELECT min(t.year)
	FROM common AS t
),

total_goals AS(
	SELECT t1.hometeamid AS teamid, (t1.sum + t2.sum) AS goals
	FROM(
		SELECT games.hometeamid, sum(games.homegoals)
		FROM games
		GROUP BY games.hometeamid
	) AS t1
	JOIN(
		SELECT games.awayteamid, sum(games.awaygoals)
		FROM games
		GROUP BY games.awayteamid
	) AS t2
	ON t1.hometeamid = t2.awayteamid

)

SELECT teams.name AS teamnames, t.goals, t.year FROM(
	SELECT DISTINCT common.hometeamid, total_goals.goals, common.year
	FROM common
	JOIN total_goals
	ON common.hometeamid = total_goals.teamid 
	AND total_goals.goals = (SELECT max(goals) FROM total_goals JOIN common ON total_goals.teamid = common.hometeamid)
) AS t JOIN teams 
ON t.hometeamid = teams.teamid
AND t.year = (
			SELECT min(t.year)
			FROM(
				SELECT DISTINCT common.hometeamid, total_goals.goals, common.year
				FROM common
				JOIN total_goals
				ON common.hometeamid = total_goals.teamid 
				AND total_goals.goals = (SELECT max(goals) FROM total_goals JOIN common ON total_goals.teamid = common.hometeamid)
			) AS t
);

--14--
WITH common AS(
	SELECT DISTINCT g2.hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'Leicester'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
)

SELECT DISTINCT teams.name AS teamnames, t.goals AS goaldiff
FROM teams JOIN
	(SELECT games.hometeamid, (games.homegoals - games.awaygoals) as goals
	FROM games
	JOIN common
	ON games.hometeamid = common.hometeamid AND games.year = 2015 AND games.homegoals - games.awaygoals > 3
) AS t ON teams.teamid = t.hometeamid
ORDER BY t.goals, teams.name
;

--15--
WITH common AS(
	SELECT DISTINCT g2.hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'Valencia'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
)

SELECT players.name AS playernames, t1.sum AS goals
FROM players JOIN
	(SELECT appearances.playerid, sum(appearances.goals)
	FROM appearances JOIN
		(SELECT DISTINCT games.gameid
		FROM games JOIN common
		ON games.hometeamid = common.hometeamid
	) AS t ON appearances.gameid = t.gameid
	GROUP BY appearances.playerid
) as t1
ON t1.playerid = players.playerid AND t1.sum = 
	(SELECT max(t1.sum) 
	FROM 
		(SELECT sum(appearances.goals)
		FROM appearances JOIN
			(SELECT games.gameid
			FROM games JOIN common
			ON games.hometeamid = common.hometeamid
		) AS t ON appearances.gameid = t.gameid
		GROUP BY appearances.playerid) 
	AS t1)
ORDER BY playernames
;

--16--
WITH common AS(
	SELECT DISTINCT g2.hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'Everton'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
)


SELECT players.name AS playernames, t1.sum AS assistscount
FROM players JOIN
	(SELECT appearances.playerid, sum(appearances.assists)
	FROM appearances JOIN
		(SELECT DISTINCT games.gameid
		FROM games JOIN common
		ON games.hometeamid = common.hometeamid
	) AS t ON appearances.gameid = t.gameid
	GROUP BY appearances.playerid
) as t1
ON t1.playerid = players.playerid AND t1.sum = 
	(SELECT max(t1.sum) 
	FROM 
		(SELECT sum(appearances.assists)
		FROM appearances JOIN
			(SELECT games.gameid
			FROM games JOIN common
			ON games.hometeamid = common.hometeamid
		) AS t ON appearances.gameid = t.gameid
		GROUP BY appearances.playerid) 
	AS t1)
ORDER BY playernames
;

--17--
WITH common AS(
	SELECT DISTINCT g2.awayteamid as hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.awayteamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'AC Milan'
		)
		AND g1.hometeamid = g2.hometeamid
		AND g2.awayteamid != g1.awayteamid
		-- AND g2.year = 2016
	)
)

SELECT players.name AS playernames, t1.sum AS shotscount
FROM players JOIN
	(SELECT appearances.playerid, sum(appearances.shots)
	FROM appearances JOIN
		(SELECT DISTINCT games.gameid
		FROM games JOIN common
		ON games.awayteamid = common.hometeamid AND games.year = 2016
	) AS t ON appearances.gameid = t.gameid
	GROUP BY appearances.playerid
) as t1
ON t1.playerid = players.playerid AND t1.sum = 
	(SELECT max(t1.sum) 
	FROM 
		(SELECT sum(appearances.shots)
		FROM appearances JOIN
			(SELECT games.gameid
			FROM games JOIN common
			ON games.awayteamid = common.hometeamid AND games.year = 2016
		) AS t ON appearances.gameid = t.gameid
		GROUP BY appearances.playerid) 
	AS t1)
ORDER BY playernames
;

--18--
WITH common AS(
	SELECT DISTINCT g2.hometeamid
	FROM games AS g1 JOIN games AS g2
	ON (
		g1.hometeamid = (
			SELECT teamid
			FROM teams
			WHERE teams.name = 'AC Milan'
		)
		AND g1.awayteamid = g2.awayteamid
		AND g2.hometeamid != g1.hometeamid
	)
)

SELECT teams.name AS teamname, 2020 AS year
FROM teams JOIN
	(SELECT DISTINCT games.awayteamid, sum(games.awaygoals) AS goals
	FROM games JOIN common
	ON games.hometeamid = common.hometeamid AND games.year = 2020
	GROUP BY games.awayteamid
) AS t
ON teams.teamid = t.awayteamid AND goals = 0
ORDER BY teams.name LIMIT 5
;

--19--

--20--
WITH RECURSIVE paths (hometeamid, awayteamid, path) AS (
        SELECT hometeamid, awayteamid, ARRAY[hometeamid, awayteamid]
        FROM games
        WHERE hometeamid = (SELECT teamid FROM teams WHERE name = 'Manchester United')
    UNION
        SELECT paths.hometeamid, games.awayteamid, paths.path || ARRAY[games.awayteamid]
        FROM paths
        JOIN games
        ON paths.awayteamid = games.hometeamid AND games.awayteamid != ALL(paths.path)
)


SELECT max(array_length(path, 1))
FROM
	(SELECT path 
	FROM paths 
	WHERE hometeamid = (SELECT teamid FROM teams WHERE name = 'Manchester United') AND
	awayteamid = (SELECT teamid FROM teams WHERE name = 'Manchester City')
	) AS t
;

--21--
WITH RECURSIVE paths (hometeamid, awayteamid, path) AS (
        SELECT hometeamid, awayteamid, ARRAY[hometeamid, awayteamid]
        FROM games
    UNION
        SELECT paths.hometeamid, games.awayteamid, paths.path || ARRAY[games.awayteamid]
        FROM paths
        JOIN games
        ON paths.awayteamid = games.hometeamid AND games.awayteamid != ALL(paths.path)
)
SELECT count(path) 
FROM paths 
WHERE hometeamid = (SELECT teamid FROM teams WHERE name = 'Manchester United') AND
awayteamid = (SELECT teamid FROM teams WHERE name = 'Manchester City')
;

--22--
WITH RECURSIVE paths (leagueid, hometeamid, awayteamid, path) AS (
        SELECT leagueid, hometeamid, awayteamid, ARRAY[hometeamid, awayteamid]
        FROM games
    UNION
        SELECT paths.leagueid, paths.hometeamid, games.awayteamid, paths.path || ARRAY[games.awayteamid]
        FROM paths
        JOIN games
        ON paths.awayteamid = games.hometeamid AND games.awayteamid != ALL(paths.path) AND games.leagueid = paths.leagueid
)

SELECT DISTINCT leagues.name AS leaguename, teamAname, teamBname, count FROM leagues JOIN
    (SELECT leagueid, teamAname, teams.name AS teamBname, count FROM teams JOIN
        (SELECT leagueid, teams.name AS teamAname, awayteamid, count FROM teams JOIN
        (SELECT leagueid, hometeamid, awayteamid, array_length(path, 1) AS count
                    FROM paths
                    WHERE (leagueid, array_length(path, 1)) IN
                        (SELECT leagueid, max(array_length(path, 1))
                        FROM paths
                        GROUP BY leagueid)
        ) AS t1
        ON teams.teamid = t1.awayteamid
    ) AS t2
    ON teams.teamid = t2.awayteamid 
) AS t3
ON leagues.leagueid = t3.leagueid
ORDER BY count DESC, teamAname, teamBname
;