CREATE TABLE average_age_client_fact 
(
  Year NUMBER(4) NOT NULL,
  Month NUMBER(2) NOT NULL,
  Average_Age NUMBER(10, 2) NOT NULL,
  CONSTRAINT PK_STAR_average_age_client PRIMARY KEY(Year, Month)
);


ALTER TABLE
average_age_client_fact DISABLE CONSTRAINT PK_STAR_average_age_client;




