CREATE OR REPLACE VIEW DELIVERY_LIST
AS SELECT s.transaction_id, s.delivery_method, INITCAP(c.client_lname) AS "Last Name", 
            c.client_rsa_id, c.client_cell, c.client_street_address, c.street_nr, t.city_name, t.city_postal_code
    FROM SALE_TRANSACTION s
    INNER JOIN CLIENTS c
    ON (s.client_id = c.client_id)
    INNER JOIN CITY t
    ON (c.city_code = t.city_code);


CREATE OR REPLACE VIEW MONTHLY_SALES
AS SELECT s.transaction_id, a.artwork_id, t.sale_date, a.artwork_title, c.collection_name, 
            TO_CHAR(s.sales_price,'L99,999.00') AS "Sales Price"    
    FROM SALE_TRANSACTION_DETAIL s
    INNER JOIN SALE_TRANSACTION t
    ON (s.transaction_id = t.transaction_id)
    INNER JOIN ARTWORK a
    ON (s.artwork_id = a.artwork_id)
    INNER JOIN COLLECTION c
    ON (a.collection_id = c.collection_id)
    WHERE TO_CHAR(t.sale_date,'MM') = TO_CHAR(SYSDATE,'MM')
    ORDER BY t.sale_date ASC;


DEFINE collection_number = 1 ;   
CREATE OR REPLACE VIEW ARTWORK_IN_COLLECTION
AS SELECT INITCAP(artwork_title) AS "ARTWORK TITLE", artwork_doc AS "DATE OF CREATION", length_cm, width_cm,
            art_status AS "STATUS", TO_CHAR(art_estimated_value,'L99,999.00') AS "ESTIMATED VALUE"
    FROM ARTWORK
    WHERE COLLECTION_ID = &collection_number
    ORDER BY artwork_doc ASC;
UNDEFINE collection_number;


CREATE OR REPLACE VIEW Net_Sales
AS SELECT transaction_id, SUM(commission) AS "Total Commission", SUM(vat) AS "Total VAT" , SUM(sales_total) AS "Total Sales", 
TO_CHAR(SUM(sales_total)-SUM(commission)-SUM(vat),'L99,999.00') AS "Net sales"
FROM sale_transaction
WHERE TO_CHAR(sale_date, 'DD') = TO_CHAR(SYSDATE,'DD') 
GROUP BY transaction_id;


CREATE OR REPLACE VIEW Find_Clients
AS SELECT *
FROM CLIENTS WHERE client_lname LIKE '&client_lname%';


CREATE OR REPLACE VIEW Calculate_Artwork_Age
AS SELECT artwork_id, artwork_title, TO_CHAR(artwork_doc,'DD, "of"  MONTH, YYYY') AS "DATE OF CREATION",TO_CHAR(SYSDATE,'YYYY') - TO_CHAR(artwork_doc,'YYYY') AS "ARTWORK_AGE"
FROM ARTWORK
ORDER BY artwork_age DESC;  


CREATE OR REPLACE VIEW Display_Specific_Artwork_Sold
AS SELECT artwork_id,INITCAP(artwork_title) AS "Title"
FROM artwork a
WHERE artwork_id = (SELECT s.artwork_id
                    FROM sale_transaction_detail s
                    WHERE s.artwork_id = 2000);


CREATE OR REPLACE VIEW Display_Living_Artist
AS SELECT artist_lname, artist_dob,artist_dod
FROM artist
WHERE artist_dod IS NULL;


CREATE OR REPLACE VIEW Shipped_Artwork
AS SELECT transaction_id,sale_date
FROM sale_transaction
WHERE delivery_method = 'Ship'
OR (delivery_method = 'Ship International');


CREATE OR REPLACE VIEW ZERO_PROFIT_SALE
AS SELECT s.transaction_id, s.delivery_method, s.sales_total, d.artwork_id
    FROM SALE_TRANSACTION s
    INNER JOIN SALE_TRANSACTION_DETAIL d
    ON (s.transaction_id = d.transaction_id)
    WHERE d.sales_price = s.sales_total
    AND s.commission = 0.0;


CREATE OR REPLACE VIEW ANNUAL_SALES
AS SELECT transaction_id,sale_date, sales_total, commission, vat, client_id, delivery_method
FROM sale_transaction
WHERE EXTRACT(YEAR FROM sale_date) 
BETWEEN TRUNC(Extract(YEAR FROM SYSDATE)) AND ROUND(Extract(YEAR FROM SYSDATE));


CREATE OR REPLACE VIEW COMMISSION_GOAL
AS SELECT transaction_id,EXTRACT(MONTH FROM TO_DATE(sale_date)) AS "MONTH OF SALE", sales_total, commission, vat
FROM sale_transaction
GROUP BY EXTRACT(MONTH FROM TO_DATE(sale_date)), TO_DATE(sale_date), sale_date, sales_total, transaction_id, 
commission, vat
HAVING SUM(sales_total) >= 10000;


DEFINE artwork_value =10000;    
CREATE OR REPLACE VIEW ARTWORK_ESTIMATED_VALUE
AS SELECT INITCAP(artwork_title) AS "ARTWORK TITLE", artwork_doc AS "DATE OF CREATION", length_cm, width_cm,art_status AS "STATUS", TO_CHAR(art_estimated_value,'L99,999.00') AS "ESTIMATED VALUE"
FROM ARTWORK
WHERE art_estimated_value = &artwork_value
ORDER BY artwork_doc ASC;
UNDEFINE artwork_value;
