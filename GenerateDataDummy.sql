SET @counter_hdr = 0;
SET @counter_dtl = 0;
SET @counter_date = 1;
-- Inisialisasi Date 3 years
SET @start_date = '2021-01-01';
SET @end_date = '2023-12-31';

WHILE @counter_date <= DATEDIFF(@end_date, @start_date) DO
    -- Generate next date
    SET @next_date = DATE_ADD(@start_date, INTERVAL @counter_date DAY);

    -- Skip January 1st and Saturdays and Sundays
    IF DAY(@next_date) = 1 AND MONTH(@next_date) = 1 THEN
        SET @counter_date = @counter_date + 1;
    ELSEIF WEEKDAY(@next_date) IN (5, 6) THEN
        SET @counter_date = @counter_date + 1;
    ELSE
        -- Adjust the number of records
        SET @num_records = IF(WEEKDAY(@next_date) = 1, LEAST(129, GREATEST(128, 128)), LEAST(129, GREATEST(128, 128 + FLOOR(RAND() * 2))));
        
        WHILE @num_records > 0 DO
            -- Generate CustomerID randomly who hasn't made a transaction on the same date
            SET @customerID = (
                SELECT CustomerID
                FROM Customer 
                WHERE CustomerID NOT IN (
                    SELECT DISTINCT CustomerID 
                    FROM Transaction_hdr 
                    WHERE DATE(TransactionDate) = DATE(@next_date)
                ) 
                ORDER BY RAND() 
                LIMIT 1
            );

            -- If no available customer, exit loop
            IF @customerID IS NULL THEN
                SET @num_records = 0;
            ELSE
                -- Generate SalesID randomly from Salesman table
                SET @salesID = (
                    SELECT SalesID 
                    FROM Salesman 
                    ORDER BY RAND() 
                    LIMIT 1
                );

                -- Insert data into Transaction_hdr table
                INSERT INTO Transaction_hdr (Transcation_hdrID, TransactionDate, SalesID, CustomerID, Total_price)
                VALUES (CONCAT('TH', LPAD(@counter_hdr + 1, 6, '0')), @next_date, @salesID, @customerID, 0);

                -- Get Transaction_hdrID for the inserted row
                SET @transaction_hdrID = CONCAT('TH', LPAD(@counter_hdr + 1, 6, '0'));

                -- Set the number of products for each transaction
                SET @num_products = 1 + FLOOR(RAND() * 4);

                -- Loop to insert data for each product
                FOR product_counter IN 1..@num_products DO
                    -- Generate ProductID randomly
                    SET @productID = (
                        SELECT ProductID 
                        FROM Product 
                        WHERE ProductID NOT IN (
	                        SELECT ProductID
	                        FROM Transaction_dtl
	                        WHERE Transcation_hdrID = @transaction_hdrID
	                    )
                        ORDER BY RAND() 
                        LIMIT 1
                    );

                    -- Get Product details
                    SET @product_name = (
                        SELECT Product_name 
                        FROM Product 
                        WHERE ProductID = @productID
                    );
                    SET @product_price = (
                        SELECT Price_product 
                        FROM Product 
                        WHERE ProductID = @productID
                    );
                    SET @categoryID = (
                        SELECT CategoryID 
                        FROM Product 
                        WHERE ProductID = @productID
                    );

                    SET @QtyID = (
                        SELECT QtyID 
                        FROM Product 
                        WHERE ProductID = @productID
                    );

                    SET @QtyValue = (
                        SELECT Qty_value 
                        FROM qty_product 
                        WHERE QtyID = @QtyID
                    );

                    -- Generate random quantity (maximum 20) for the product
                    SET @qty = 5 + FLOOR(RAND() * (20 - 5 + 1));

                    -- Calculate price for the product
                    SET @price = @qty * @product_price;

                    -- Insert data into Transaction_dtl table
                    INSERT INTO Transaction_dtl (Transaction_dtlID, Transcation_hdrID, ProductID, Product_name, CategoryID, QtyID, Qty_value, Qty, Price_product, Price)
                    VALUES (CONCAT('TD', LPAD(@counter_dtl + 1, 6, '0')), @transaction_hdrID, @productID, @product_name, @categoryID, @QtyID, @QtyValue, @qty, @product_price, @price);

                    -- Update Total_price in Transaction_hdr
                    UPDATE Transaction_hdr 
                    SET Total_price = Total_price + @price 
                    WHERE Transcation_hdrID = @transaction_hdrID;

                    -- Increment counter
                    SET @counter_dtl = @counter_dtl + 1;
                END FOR;

                -- Increment counter for Transaction_hdr
                SET @counter_hdr = @counter_hdr + 1;

                -- Decrement number of records
                SET @num_records = @num_records - 1;
            END IF;
        END WHILE;
    END IF;

    -- Increment date counter
    SET @counter_date = @counter_date + 1;
END WHILE;
