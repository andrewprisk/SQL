DECLARE  @ProductCode VARCHAR(256)
SET @ProductCode = 'CCCC-DDDDDDD-AAA-BBBBB'
SELECT [Part1] = LEFT(@ProductCode,CHARINDEX('-',@ProductCode) - 1),
       [Part2] = SUBSTRING(@ProductCode,CHARINDEX('-',@ProductCode) + 1,CHARINDEX('-',@ProductCode,CHARINDEX('-',@ProductCode) + 1) - (CHARINDEX('-',@ProductCode) + 1)),
       [Part3] = SUBSTRING(@ProductCode,CHARINDEX('-',@ProductCode,CHARINDEX('-',@ProductCode) + 1) + 1,DATALENGTH(@ProductCode) - CHARINDEX('-',@ProductCode,CHARINDEX('-',@ProductCode) + 1) - CHARINDEX('-',REVERSE(@ProductCode))),
       [Part4] = RIGHT(@ProductCode,CHARINDEX('-',REVERSE(@ProductCode)) - 1)
GO