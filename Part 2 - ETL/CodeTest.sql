DROP TABLE artist_dim CASCADE CONSTRAINTS;
DROP TABLE total_sales_fact CASCADE CONSTRAINTS;
CREATE TABLE artist_dim (
  artist_id NUMBER(8) NOT NULL,
  artist_lname VARCHAR(35),
  artist_Inits VARCHAR(5),
  artist_cell VARCHAR(11),
  CONSTRAINT PK_STAR_artist_id PRIMARY KEY(artist_id)
);

--FACT TABLE
CREATE TABLE total_sales_fact 
(
  Year NUMBER(4) NOT NULL,
  Month NUMBER(2) NOT NULL,
  Artist_id NUMBER(10) NOT NULL,
  Total_Amount NUMBER(10, 2) NOT NULL,
  CONSTRAINT PK_STAR_total_sales_fact PRIMARY KEY(Year, Month, artist_id),
  CONSTRAINT FK_STAR_total_artist_id FOREIGN KEY (artist_id) REFERENCES artist_dim(artist_id)
);

ALTER TABLE
  total_sales_fact DISABLE CONSTRAINT PK_STAR_total_sales_fact;
ALTER TABLE
  total_sales_fact DISABLE CONSTRAINT FK_STAR_total_artist_id;
  
  
--POPULATE TOTAL SALES FACT TABLE
INSERT INTO total_sales_fact
SELECT DISTINCT EXTRACT(YEAR FROM st.sale_date) "Year",
				EXTRACT(MONTH FROM st.sale_date) "Month",
				a.artist_id,SUM(st.sales_total) "Total_Amount"
FROM
  artist a, sale_transaction st, sale_transaction_detail std,
  artwork art,collection c
WHERE
  a.artist_id = c.artist_id
  AND c.collection_id = art.collection_id
  AND art.artwork_id = std.artwork_id
  AND std.transaction_id = st.transaction_id
GROUP BY
  EXTRACT(YEAR FROM st.sale_date),EXTRACT(MONTH FROM st.sale_date),a.artist_id;


INSERT INTO artist_dim
SELECT DISTINCT tsf.artist_id, a.artist_lname, a.artist_inits, a.artist_cell
FROM total_sales_fact tsf, artist a
WHERE tsf.artist_id = a.Artist_id;

