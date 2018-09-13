SQL queries from SQLZOO

Show the name of all players who scored a goal against Germany.
SELECT DISTINCT(player) FROM goal
JOIN 
(
SELECT id, team1, team2 FROM game
WHERE (team1='GER' OR team2='GER')
)hai
ON matchid = id AND teamid !='GER'


Show teamname and the total number of goals scored.
SELECT teamname, COUNT(teamid) AS tot_goal
FROM goal
JOIN eteam ON id=teamid
GROUP BY teamid, teamname
ORDER BY teamname

why do we group by even though we count by a specific field?
Mixing of GROUP columns (MIN(),MAX(),COUNT(),...) with no GROUP columns is illegal if there is no GROUP BY clause


Show the stadium and the number of goals scored in each stadium.
SELECT stadium, SUM(num_goal) AS num_score
FROM
(
SELECT COUNT(matchid) AS num_goal, matchid
FROM goal
GROUP BY matchid
) goat
JOIN game
ON matchid=id
GROUP BY stadium
ORDER BY stadium;

For every match involving 'POL', show the matchid, date and the number of goals 
SELECT game.id, game.mdate, COUNT(*)
FROM game
JOIN goal
ON game.id = goal.matchid
WHERE (game.team1 = 'POL' OR game.team2 = 'POL')
GROUP BY game.id, game.mdate
ORDER BY game.id;


For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'
SELECT game.id, game.mdate, COUNT(*) AS num_goal
FROM game
JOIN goal
ON goal.matchid = game.id
WHERE goal.teamid = 'GER'
GROUP BY game.id, game.mdate;


List every match with the goals scored by each team as shown. This will use "CASE WHEN" which has not been explained in any previous exercises.
SELECT game.mdate, 
       game.team1, 
       SUM(CASE WHEN goal.teamid = game.team1
           THEN 1
           ELSE 0
           END) AS score1,
       game.team2,
       SUM(CASE WHEN goal.teamid = game.team2
           THEN 1
           ELSE 0
           END) AS score2
FROM game
JOIN goal
ON (game.id = goal.matchid)
GROUP BY game.id, game.mdate,  game.team1, game.team2
ORDER BY game.mdate, goal.matchid;

List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'
SELECT goal.player
FROM goal
JOIN game
ON goal.matchid = game.id
WHERE game.stadium = 'National Stadium, Warsaw';


Self join
Edinburg buses
How many stops are in the database.
SELECT COUNT(name) FROM stops;


Find the id value for the stop 'Craiglockhart'
SELECT id FROM stops WHERE name='Craiglockhart';

Give the id and the name for the stops on the '4' 'LRT' service.
SELECT id, name FROM stops
JOIN route
ON id=stop
WHERE num=4 AND company='LRT';


The query shown gives the number of routes that visit either London Road (149) or Craiglockhart (53). Run the query and notice the two services that link these stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.
SELECT company, num, COUNT(*)
FROM route WHERE stop=149 OR stop=53
GROUP BY company, num
HAVING COUNT(*) =2;


Execute the self join shown and observe that b.stop gives all the places you can get to from Craiglockhart, without changing routes. Change the query so that it shows the services from Craiglockhart to London Road.
SELECT a.company, a.num, a.stop, b.stop
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
WHERE a.stop=53 AND b.stop=149;


The query shown is similar to the previous one, however by joining two copies of the stops table we can refer to stops by name rather than by number. Change the query so that the services between 'Craiglockhart' and 'London Road' are shown. If you are tired of these places try 'Fairmilehead' against 'Tollcross'
SELECT a.company, a.num, stopa.name, stopb.name
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
  JOIN stops stopa ON (a.stop=stopa.id)
  JOIN stops stopb ON (b.stop=stopb.id)
WHERE stopa.name='Craiglockhart' AND stopb.name='London Road';


Give a list of all the services which connect stops 115 and 137 ('Haymarket' and 'Leith')
SELECT a.company, a.num
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
WHERE a.stop=115 AND b.stop=137
GROUP BY a.num, a.company;


Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'
SELECT a.company, a.num
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
  JOIN stops stopa ON (a.stop=stopa.id)
  JOIN stops stopb ON (b.stop=stopb.id)
WHERE stopa.name='Craiglockhart' AND stopb.name='Tollcross';


Give a distinct list of the stops which may be reached from 'Craiglockhart' by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. Include the company and bus no. of the relevant services.
SELECT s.name, comp, nom
FROM stops s
JOIN
(
SELECT a.company AS comp, a.num AS nom, b.stop AS stop
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
WHERE a.stop=53
GROUP BY a.num, a.company, stop
) teeth
ON teeth.stop=s.id
GROUP BY s.name, comp, nom;


Find the routes involving two buses that can go from Craiglockhart to Sighthill.
Show the bus no. and company for the first bus, the name of the stop for the transfer,
and the bus no. and company for the second bus.

SELECT DISTINCT S.num, S.company, stops.name, E.num, E.company
FROM
(SELECT a.company AS company, a.num AS num, b.stop AS stop
 FROM route a JOIN route b ON (a.company=b.company AND a.num=b.num)
 WHERE a.stop=(SELECT id FROM stops WHERE name= 'Craiglockhart')
)S
  JOIN
(SELECT a.company AS company, a.num AS num, b.stop AS stop
 FROM route a JOIN route b ON (a.company=b.company AND a.num=b.num)
 WHERE a.stop=(SELECT id FROM stops WHERE name= 'Sighthill')
)E
ON (S.stop = E.stop)
JOIN stops ON(stops.id = S.stop);
