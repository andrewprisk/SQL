DECLARE @x XML
SET @x = '<Root><note1>test</note1><note2>test</note2></Root>'

DECLARE @t XML
SELECT @t = (SELECT TOP 3 name FROM sys.tables FOR XML AUTO)

SET @x.modify('insert sql:variable("@t") as first into (/Root)[1] ')
SELECT @x