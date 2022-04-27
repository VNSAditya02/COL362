DROP TABLE train_info;

CREATE table IF NOT EXISTS train_info(
    train_no bigint NOT NULL,
    train_name text,
    distance bigint,
    source_station_name text,
    day_of_departure text,
    destination_station_name text,
    day_of_arrival text,
    departure_time time,
    arrival_time time,
    CONSTRAINT trains_info_key PRIMARY KEY (train_no)
);

