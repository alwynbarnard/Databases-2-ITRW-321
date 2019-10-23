CREATE TABLE medium_dim 
(
  medium_code NUMBER(5) NOT NULL,
  medium_description VARCHAR(40),
  CONSTRAINT PK_STAR_medium_code PRIMARY KEY(medium_code)
);
CREATE TABLE avg_price_medium_fact 
(
  Medium_code NUMBER(5) NOT NULL,
  Average_Sales_Price NUMBER(10,2) NOT NULL,
  CONSTRAINT PK_medium_code PRIMARY KEY(Medium_code),
  CONSTRAINT FK_STAR_medium_code FOREIGN KEY (Medium_code) REFERENCES medium_dim(Medium_code)
);

ALTER TABLE
avg_price_medium_fact DISABLE CONSTRAINT PK_medium_code;
ALTER TABLE
  avg_price_medium_fact DISABLE CONSTRAINT FK_STAR_medium_code;

INSERT INTO avg_price_medium_fact
SELECT m.medium_code, AVG(sales_price) AS Average_Sales_Price
FROM sale_transaction_detail std,
  artwork art, art_medium m
WHERE
  m.medium_code = art.medium_code
  AND art.artwork_id = std.artwork_id
GROUP BY m.medium_code;


INSERT INTO medium_dim
SELECT DISTINCT apmf.medium_code, m.medium_description
FROM avg_price_medium_fact apmf, art_medium m
WHERE apmf.medium_code = m.medium_code;

INSERT INTO avg_price_medium_fact
SELECT m.medium_code, AVG(sales_price) AS Average_Sales_Price
FROM sale_transaction st ,sale_transaction_detail std,
  artwork art, art_medium m
WHERE m.medium_code = art. medium_code
  AND art.artwork_id = std.artwork_id
 AND std.transaction_id = st.transaction_id
AND st.sale_date > SYSDATE -1
GROUP BY m.medium_code;

SELECT t.medium_code , Average_Sales_Price
FROM avg_price_medium_fact t, medium_dim s
WHERE t.medium_code = s.medium_code;

















