DECLARE @p0 uniqueidentifier
DECLARE @p1 nvarchar(100)

create table #TempvCard (
	[vID]	[uniqueidentifier] NOT NULL,
	[vFIRSTNAME] [nvarchar] (100) NULL,
	[vLASTNAME] [nvarchar] (100) NULL,
	[vFNAME]  [nvarchar] (100) NULL,
	[vCOMPANY]  [nvarchar] (300) NULL,
	[vDEPT]  [nvarchar] (300) NULL,
	[vTITLE] [nvarchar] (100) NULL,
	[vBUSPHONE] [nvarchar] (100) NULL,
	[vHOMPHONE] [nvarchar] (100) NULL,
	[vMOBPHONE] [nvarchar] (100) NULL,
	[vWORKADDR] [nvarchar] (500) NULL,
	[vWORKADDRCITY] [nvarchar] (500) NULL,
	[vWORKADDRSTATE] [nvarchar] (500) NULL,
	[vWORKADDRZIP] [nvarchar] (500) NULL,
	[vWORKURL] [nvarchar] (100) NULL,
	[vEMAIL] [nvarchar] (100) NULL
	) ON [PRIMARY];
	
create table #TempvCardFile (
	[LINES_ID] uniqueidentifier NOT NULL,
	[LINES] nvarchar(max) NULL
	) ON [PRIMARY];
	
SET @p0 = NEWID()

-- DUMP VCARD INTO TEMP TABLE FOR PROCESSING
insert into #TempvCardFile
Select @p0,line from Dbo.READ_FILE_AS_TABLE('C:\','John Q  Public.vcf');

-- PREP formatted temp table
insert into #TempvCard (vID) VALUES (@p0)

-- Cursor through the temp table to populate the formatted temp table
DECLARE @Event_ID nvarchar(500)

DECLARE my_cursor CURSOR FOR
SELECT LINES FROM #TempvCardFile

OPEN my_cursor

FETCH NEXT FROM my_cursor
INTO @Event_ID

WHILE @@FETCH_STATUS = 0
BEGIN
	IF (SELECT SUBSTRING(@Event_ID,1,1)) = 'N' 
		BEGIN
			UPDATE #TempvCard SET vFIRSTNAME = (SELECT REPLACE(value,'N;LANGUAGE=en-us:','') FROM dbo.SPLIT(REPLACE(@Event_ID,'N;LANGUAGE=en-us:',''), ';') where position=2) WHERE vID = @p0
			UPDATE #TempvCard SET vLASTNAME = (SELECT REPLACE(value,'N;LANGUAGE=en-us:','') FROM dbo.SPLIT(REPLACE(@Event_ID,'N;LANGUAGE=en-us:',''), ';') where position=1) WHERE vID = @p0
			--UPDATE #TempvCard SET vNAME = REPLACE(@Event_ID,'N;LANGUAGE=en-us:','') WHERE vID = @p0
		END
	
	IF (SELECT SUBSTRING(@Event_ID,1,2)) = 'FN' 
		BEGIN
			UPDATE #TempvCard SET vFNAME = REPLACE(@Event_ID,'FN:','') WHERE vID = @p0
		END	
		
	IF (SELECT SUBSTRING(@Event_ID,1,3)) = 'ORG' 
		BEGIN
			UPDATE #TempvCard SET vCOMPANY = (SELECT REPLACE(value,'ORG:','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ORG:',''), ';') WHERE position=1) WHERE vID = @p0
			UPDATE #TempvCard SET vDEPT = (SELECT REPLACE(value,'ORG:','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ORG:',''), ';') WHERE position=2) WHERE vID = @p0
			--UPDATE #TempvCard SET vCOMPANY = REPLACE(@Event_ID,'ORG:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,5)) = 'TITLE' 
		BEGIN
			UPDATE #TempvCard SET vTITLE = REPLACE(@Event_ID,'TITLE:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,14)) = 'TEL;WORK;VOICE' 
		BEGIN
			UPDATE #TempvCard SET vBUSPHONE = REPLACE(@Event_ID,'TEL;WORK;VOICE:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,14)) = 'TEL;HOME;VOICE' 
		BEGIN
			UPDATE #TempvCard SET vHOMPHONE = REPLACE(@Event_ID,'TEL;HOME;VOICE:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,14)) = 'TEL;CELL;VOICE' 
		BEGIN
			UPDATE #TempvCard SET vMOBPHONE = REPLACE(@Event_ID,'TEL;CELL;VOICE:','') WHERE vID = @p0
		END
		
	IF (SELECT value FROM dbo.SPLIT(@Event_ID,';') WHERE position=1) = 'ADR'
		BEGIN
			UPDATE #TempvCard SET vWORKADDR = (SELECT REPLACE(ltrim(rtrim(value)),'ADR;WORK;PREF:;;','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ADR;WORK;PREF:;;',''), ';') WHERE position=1) WHERE vID = @p0
			UPDATE #TempvCard SET vWORKADDRCITY = (SELECT REPLACE(ltrim(rtrim(value)),'ADR;WORK;PREF:;;','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ADR;WORK;PREF:;;',''), ';') WHERE position=2) WHERE vID = @p0
			UPDATE #TempvCard SET vWORKADDRSTATE = (SELECT REPLACE(ltrim(rtrim(value)),'ADR;WORK;PREF:;;','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ADR;WORK;PREF:;;',''), ';') WHERE position=3) WHERE vID = @p0
			UPDATE #TempvCard SET vWORKADDRZIP = (SELECT REPLACE(ltrim(rtrim(value)),'ADR;WORK;PREF:;;','') FROM dbo.SPLIT(REPLACE(@Event_ID,'ADR;WORK;PREF:;;',''), ';') WHERE position=4) WHERE vID = @p0
			--UPDATE #TempvCard SET vWORKADDR = REPLACE(@Event_ID,'ADR;WORK;PREF:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,3)) = 'URL' 
		BEGIN
			UPDATE #TempvCard SET vWORKURL = REPLACE(@Event_ID,'URL;WORK:','') WHERE vID = @p0
		END
		
	IF (SELECT SUBSTRING(@Event_ID,1,5)) = 'EMAIL' 
		BEGIN
			UPDATE #TempvCard SET vEMAIL = REPLACE(@Event_ID,'EMAIL;PREF;INTERNET:','')  WHERE vID = @p0
		END
	
    FETCH NEXT FROM my_cursor
    INTO @Event_ID
END

CLOSE my_cursor
DEALLOCATE my_cursor

-- add new contact info in to the real table if indicated, else just select the new row
--select * from #TempvCardFile;

select * from #TempvCard;

-- dispose of the temp tables
drop table #TempvCardFile;

drop table #TempvCard;