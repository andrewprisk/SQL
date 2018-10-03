USE [msdb]
GO

SET NOCOUNT ON
GO

DECLARE @i INT
SET @i = 1

IF OBJECT_ID('tempdb..#SYSJOB_IDS','u')IS NOT NULL
	BEGIN
		DROP TABLE #SYSJOB_IDS
	END
	BEGIN
		CREATE TABLE #SYSJOB_IDS (
			[id] INT IDENTITY(1,1) NOT NULL
			,[job_ID] UNIQUEIDENTIFIER NOT NULL
			,[name] SYSNAME NOT NULL
			,[CurrOwner] SYSNAME NOT NULL
		)
	END

INSERT INTO #SYSJOB_IDS(job_ID, [name],[CurrOwner])
SELECT DISTINCT
	   a.[job_id]
	  ,a.[name]
	  ,b.[name][CurrOwner]
FROM msdb..SYSJOBS as a
JOIN master.sys.syslogins as b ON b.[sid] = a.[owner_sid]
WHERE b.[name] <> 'sa'
ORDER BY a.[name]

WHILE @i < = (SELECT MAX(id) from #SYSJOB_IDS)
	BEGIN
		DECLARE @job_id NVARCHAR(36)
			   ,@name sysname
			   ,@CurrOwner NVARCHAR(40)
		SELECT TOP 1
			   @job_id = [job_ID]
	          ,@name = RTRIM([name])
	          ,@CurrOwner = RTRIM([CurrOwner])
	    FROM #SYSJOB_IDS
		WHERE id = @i

		DECLARE @Run INT

		EXECUTE @Run = [msdb].[dbo].[sp_update_job] @job_id=@job_id , @owner_login_name=N'sa'
		IF @Run = 0
			BEGIN
				PRINT UPPER(@name) + ' owner was changed from '+ UPPER(@CurrOwner)+' to sa.'
			END
		ELSE IF @Run <> 0
			BEGIN
				PRINT 'Fail: '+ UPPER(@name) + ' owner was not changed from '+ UPPER(@CurrOwner)+'.'
			END

		SELECT @i = @i+1
	END

GO