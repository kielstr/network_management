
CREATE DATABASE network_management;

\c network_management;

CREATE TABLE queue (
  id integer,
  owner varchar(45),
  queue_id varchar(45),
  prio integer,
  rate varchar(45),
  ceiling varchar(45)
);

CREATE TABLE client (
  id integer,
  macaddr varchar(45),
  hostname varchar(45),
  ip varchar(45),
  owner varchar(45),
  rate varchar(45),
  ceiling varchar(45),
  queue_id varchar(45),
  prio integer
);

CREATE TABLE status (
  apply integer
);

INSERT INTO status VALUES (1);