-- CREATE DATABASE dbname;
USE abkcompa_shDev;
CREATE TABLE IF NOT EXISTS abkTable ( id smallint unsigned not null auto_increment, name varchar(20) not null, constraint pk_example primary key (id) );
INSERT INTO abkTable ( id, name ) VALUES ( null, 'Sample data' );