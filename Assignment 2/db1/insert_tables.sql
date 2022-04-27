DELETE from author;
DELETE from paper;
DELETE from paperbyauthors;
DELETE from venue;
DELETE from citation;

--Q1, Q2
-- insert into train_info(train_no,train_name,distance,source_station_name,departure_time,day_of_departure,destination_station_name,arrival_time,day_of_arrival)
-- values (97131,'T1',12,'KURLA','12:00:00','Monday','S2','13:00:00','Monday'),
--        (2,'T2',10,'S3','14:00:00','Tuesday','S2','16:00:00','Wednesday'),
--        (3,'T2',10,'S4','14:00:00','Monday','KURLA','16:00:00','Monday'),
--        (4,'T2',10,'KURLA','14:00:00','Tuesday','S9','16:00:00','Wednesday'),
--        (5,'T2',10,'S4','14:00:00','Monday','S5','16:00:00','Monday'),
--        (6,'T2',10,'S5','14:00:00','Monday','S6','16:00:00','Monday'),
--        (7,'T2',10,'S6','14:00:00','Tuesday','S7','16:00:00','Wednesday'),
--        (14,'T3',20,'S2','01:00:00','Monday','S4','11:00:00','Monday');

--Q3
insert into author(authorid, name)
values (1, 'aditya'),
       (2, 'varma'),
       (3,'harshith');

insert into paper(paperid, title, year, venueid)
values (1, 'a1', 2000, 1),
       (2, 'v1', 2001, 2),
       (3,'h1', 2002, 2),
       (4, 'a2', 2003, 3),
       (5, 'a3', 2003, 1);

insert into paperbyauthors(paperid, authorid)
values (1, 1),
	(2, 2),
	(3, 3),
	(4, 1),
	(5, 1);

insert into venue(venueid, name, type)
values (1, 'ieicet', 'journal'),
	(2, 'tcs', 'journal'),
	(3, 'c1', 'conference');

insert into citation(paperid1, paperid2)
values (1, 2),
	(2, 3),
	(1, 3);

	
      
