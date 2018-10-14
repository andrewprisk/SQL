-- Create a Holding Table to loop thru
DECLARE @Sources TABLE (Data varchar(15) PRIMARY KEY)

-- Add the data to the table
INSERT INTO @Sources
SELECT DISTINCT value FROM dbo.ft_Split(@roles,',');

-- Start the loop
WHILE EXISTS (SELECT Data FROM @Sources)
	BEGIN 
		
		-- Grab the value
		DECLARE @Source varchar(15)
			SET @Source = (SELECT TOP 1 Data FROM @Sources)

			-- DO STUFF WITH @Source


		DELETE FROM @Sources WHERE Data=@Source;
	END