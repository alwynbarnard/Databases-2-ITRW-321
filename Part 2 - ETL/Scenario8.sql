CREATE TABLE collection_dim 
(
  Collection_id  NUMBER(10) NOT NULL,
  Collection_name VARCHAR(30),
 CONSTRAINT PK_STAR_total_inventory PRIMARY KEY(collection_id)
);

CREATE TABLE total_inventory_fact 
(
  Year NUMBER(4) NOT NULL,
  Month NUMBER(2) NOT NULL,
  Collection_id  NUMBER(10) NOT NULL,
  Total_Inventory NUMBER(10) NOT NULL,
  CONSTRAINT PK_total_inventory PRIMARY KEY(Year, Month, collection_id),
  CONSTRAINT FK_STAR_collection_id FOREIGN KEY (Collection_id) REFERENCES collection_dim (Collection_id)
);

ALTER TABLE
  total_inventory_fact DISABLE CONSTRAINT PK_total_inventory;
ALTER TABLE
  total_inventory_fact DISABLE CONSTRAINT FK_STAR_collection_id;


INSERT INTO total_inventory_fact 
SELECT DISTINCT EXTRACT(YEAR FROM st.sale_date) "Year",
		  EXTRACT(MONTH FROM st.sale_date) "Month",
		  c.collection_id,COUNT(art.artwork_id) "Total_ Inventory"
FROM sale_transaction st, sale_transaction_detail std,
  artwork art,collection c
WHERE
  c.collection_id = art.collection_id
  AND art.artwork_id = std.artwork_id
  AND std.transaction_id = st.transaction_id
GROUP BY
  EXTRACT(YEAR FROM st.sale_date),EXTRACT(MONTH FROM st.sale_date),c.collection_id;

INSERT INTO collection_dim
SELECT DISTINCT tif. collection_id, c.Collection_name
FROM   total_inventory_fact tif, collection c
WHERE tif. collection_id = c. collection_id;

INSERT INTO total_inventory_fact
SELECT DISTINCT EXTRACT(YEAR FROM st.sale_date) "Year",
  				EXTRACT(MONTH FROM st.sale_date) "Month",
				  c.collection_id,COUNT(art.artwork_id) "Total_ Inventory "
FROM
   sale_transaction st, sale_transaction_detail std,
  artwork art,collection c
WHERE
  EXTRACT(YEAR FROM st.sale_date) = EXTRACT(YEAR FROM SYSDATE)
  AND EXTRACT(MONTH FROM st.sale_date) = EXTRACT(MONTH FROM SYSDATE)
GROUP BY EXTRACT(YEAR FROM st.sale_date),
      EXTRACT(MONTH FROM st.sale_date),  c.collection_id;

SELECT t.year, t.month, t.collection_id, t.total_inventory
FROM total_inventory_fact t, collection_dim s
WHERE t.collection_id = s.collection_id;











