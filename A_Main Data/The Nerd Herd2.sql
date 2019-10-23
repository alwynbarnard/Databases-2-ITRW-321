CREATE TABLE ALL_SALES(
    Transaction_ID NUMBER(8) NOT NULL,
    Total_Commission NUMBER(8) NOT NULL,
    Total_VAT NUMBER(8) NOT NULL,
    Total_Sales NUMBER(8) NOT NULL,
    Net_Sales NUMBER(8) NOT NULL
);

INSERT ALL
    INTO all_sales VALUES(Transaction_ID, Commission, VAT, Total_Sales, Net_Sales)
    SELECT transaction_id, commission, vat, sales_total, SUM(sales_total)-SUM(commission)-SUM(vat)
    FROM sale_transaction
    WHERE EXTRACT(YEAR FROM sale_date) = EXTRACT(YEAR FROM SYSDATE) 
    group by transaction_id, commission, vat, sales_total;
    
    --Create TOTAL_SALES_FACT Fact table
CREATE TABLE TOTAL_SALES_FACT(
    Year NUMBER(4) NOT NULL,
    Month NUMBER(2) NOT NULL,
    Artist_ID_FACT NUMBER(8) NOT NULL,
    Total_Amount NUMBER(8) NOT NULL,
    CONSTRAINT year_pk_fact PRIMARY KEY (Year),
    CONSTRAINT month_pk_fact PRIMARY KEY (Month),
    CONSTRAINT artist_pk PRIMARY KEY (Artist_ID_FACT),
    CONSTRAINT artist_id_fact FOREIGN KEY (Artist_ID_FACT) REFERENCES ARTIST_DIM(Artist_ID_DIM)
);

--Populate Total_sales_fact fact table
INSERT INTO total_sales_fact
    SELECT EXTRACT(YEAR FROM st.sales_date) AS 'Year',  EXTRACT (MONTH FROM st.sales_date) As 'Month', c.artist_id, SUM(st.sales_total) AS 'Total_Amount'
    FROM sales_transaction st
    JOIN sales_transaction_detail std
    USING (transaction_id)
    JOIN artwork a
    USING (artwork_id)
    JOIN collection c
    USING (collection_id)
    GROUP BY EXTRACT(YEAR FROM st.sales_date),  EXTRACT (MONTH FROM st.sales_date)	,c.artist_id);
