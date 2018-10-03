CREATE TABLE #Sunday
(
datSunday DATETIME
)

DECLARE @x as integer
DECLARE @num as integer 
set @x = 10
set @num = 0
DECLARE @pdatDate DATETIME
SELECT @pdatDate = convert(datetime,convert(varchar(10),getdate(),103),103)
DECLARE @pintAddDay INTEGER
SET @pintAddDay = -10

WHILE @num < @x
     BEGIN
          IF (LOWER(DATENAME(dw, @pdatDate)) = 'sunday') 
               BEGIN
                    INSERT #Sunday VALUES (@pdatDate)
                    SET @pintAddDay = 7
                    set @num = @num + 1
               END
     
          SELECT @pdatDate = DATEADD(dd,@pintAddDay,@pdatDate)
     END

SELECT * FROM #Sunday
DROP TABLE #Sunday
