DELETE from train_info;

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
insert into train_info(train_no,train_name,distance,source_station_name,departure_time,day_of_departure,destination_station_name,arrival_time,day_of_arrival)
values (97131,'T1',12,'DADAR','12:00:00','Monday','S2','13:00:00','Monday'),
       (2,'T2',11,'S3','14:00:00','Tuesday','S2','16:00:00','Wednesday'),
       (3,'T2',13,'S4','14:00:00','Monday','DADAR','16:00:00','Monday'),
       (4,'T2',14,'DADAR','14:00:00','Wednesday','S9','16:00:00','Wednesday'),
       (5,'T2',15,'S4','14:00:00','Monday','S5','16:00:00','Monday'),
       (6,'T2',16,'S5','14:00:00','Monday','S6','16:00:00','Monday'),
       (7,'T2',17,'S6','14:00:00','Tuesday','S7','16:00:00','Wednesday'),
       (8,'T2',15,'S4','14:00:00','Monday','S2','16:00:00','Monday'),
       (14,'T3',20,'S2','01:00:00','Monday','S4','11:00:00','Monday');
