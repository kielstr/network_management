
CREATE TABLE `queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(45) NOT NULL UNIQUE,
  `queue_id` varchar(45) NOT NULL UNIQUE,
  `prio` int(11) DEFAULT 1,
  `rate` varchar(45) DEFAULT "2mbit",
  `ceiling` varchar(45) DEFAULT "2mbit",
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;


CREATE TABLE `client` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `macaddr` varchar(45) NOT NULL UNIQUE,
  `hostname` varchar(45) NOT NULL UNIQUE,
  `ip` varchar(45) DEFAULT NULL UNIQUE,
  `owner` varchar(45) NOT NULL,
  `rate` varchar(45) DEFAULT "2mbit",
  `ceiling` varchar(45) DEFAULT "2mbit",
  `queue_id` varchar(45),
  `prio` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `status` (
  `apply` int(1) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

INSERT INTO status VALUES (1);