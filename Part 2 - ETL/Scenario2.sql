CREATE TABLE top_artist_fact 
(
  Year NUMBER(4) NOT NULL,
  Month NUMBER(2) NOT NULL,
  Artist_id NUMBER(10) NOT NULL,
  Sales_Price NUMBER(10, 2) NOT NULL,
  CONSTRAINT PK_top_artist_fact PRIMARY KEY(Year, Month, artist_id)
);

ALTER TABLE
  top_artist_fact DISABLE CONSTRAINT PK_top_artist_fact;
ALTER TABLE
total_sales_fact DISABLE CONSTRAINT FK_STAR_total_artist_id;

INSERT INTO
  top_artist_fact SELECT DISTINCT EXTRACT(YEAR FROM st.sale_date) "Year",
  EXTRACT(MONTH FROM st.sale_date) "Month", a.artist_id, MAX(std.sales_price)
FROM artist a, sale_transaction st, sale_transaction_detail std, artwork art, collection c
WHERE a.artist_id = c.artist_id
  AND c.collection_id = art.collection_id
  AND art.artwork_id = std.artwork_id
  AND std.transaction_id = st.transaction_id
GROUP BY EXTRACT(YEAR FROM st.sale_date),
  EXTRACT( MONTH FROM st.sale_date), a.artist_id, std.sales_price;

UPDATE top_artist_fact taf
SET 
taf.Year = EXTRACT(YEAR FROM SYSDATE),
  	taf.Month =  EXTRACT(MONTH FROM SYSDATE),
  	taf.sales_price  = SELECT MAX(std.sales_price) FROM sale_transaction_detail std
WHERE
  EXTRACT(YEAR FROM taf.Year) <> EXTRACT(YEAR FROM SYSDATE)
  AND EXTRACT(MONTH FROM taf.Month) <> EXTRACT( MONTH FROM SYSDATE);

