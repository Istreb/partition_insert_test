USE [xxx]
GO
/****** Object:  StoredProcedure [dbo].[_xxx]    Script Date: 14.12.2016 12:52:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Каличава Константин
-- Create date: 20.01.2016
-- Description:	http://xxx/dokuwiki/doku.php?id=forbs:tests:maindata_load_partitioning
-- =============================================
ALTER PROCEDURE [dbo].[_tst_xxx]
	
AS
BEGIN
	DECLARE @NUM INT;
	DECLARE @t1 DATETIME;
	DECLARE @t2 DATETIME;
	DECLARE @chksum INT;
	DECLARE @cnt INT;

	SET NOCOUNT ON;
	SET @NUM = 1;

	WHILE @NUM <= 10
	BEGIN
		IF NOT EXISTS(SELECT top 1 * FROM [ready])
		BEGIN
			insert into [ready] (
			  [xxx1]
			  ,[xxx2]
			  ,[xxx3]
			  ,[xxx4]
			  ,[xxx5]
			  ,[xxx6]
			  ,[xxx7]
			  ,[xxx8]
			  ,[xxx9]
			  ,[xxx10]
			  ,[xxx11]
			  ,[xxx12]
			  ,[xxx13]
			  ,[xxx14]
			  ,[xxx15]
			  ,[xxx16]
			  ,[xxx17]
			  ,[xxx18]
			  ,[xxx19]
			  ,[xxx20]
			  ,[xxx21]
			  ,[xxx22]
			  ,[xxx23]
			  ,[xxx24]
			  ,[xxx25]
			  ,[xxx26]
			  ,[xxx27])
			select top 1000000
			  [xxx1]
			  ,[xxx2]
			  ,[xxx3]
			  ,[xxx4]
			  ,[xxx5]
			  ,[xxx6]
			  ,[xxx7]
			  ,[xxx8]
			  ,[xxx9]
			  ,[xxx10]
			  ,[xxx11]
			  ,[xxx12]
			  ,[xxx13]
			  ,[xxx14]
			  ,[xxx15]
			  ,[xxx16]
			  ,[xxx17]
			  ,[xxx18]
			  ,[xxx19]
			  ,[xxx20]
			  ,[xxx21]
			  ,[xxx22]
			  ,[xxx23]
			  ,[xxx24]
			  ,[xxx25]
			  ,[xxx26]
			  ,[xxx27]
			from 
				[ready_bk]
		END

		IF EXISTS (select top 1 * from [table])
		BEGIN
			truncate table [table]
		END
	
		IF @NUM<6
		BEGIN
			SET @t1 = GETDATE();
			EXEC	[dbo].[main]	'11'
			SET @t2 = GETDATE();
			SELECT @chksum = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM [table]
			SELECT @cnt = count(*) FROM [table]

			insert into main_test (num, elapsed_m, chksum, cnt)
			select 
				'maindataload original' as num, 
				DATEDIFF(second,@t1,@t2) AS elapsed_m,
				@chksum as chksum,
				@cnt as cnt
		END
		ELSE
		BEGIN
			truncate table [prds]
			SET @t1 = GETDATE();
			EXEC	[dbo].[main_wo_temp_tables]	'11'
			SET @t2 = GETDATE();
			SELECT @chksum = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM [table]
			SELECT @cnt = count(*) FROM [table]

			insert into main_test (num, elapsed_m, chksum, cnt)
			select 
				'maindataload wo_temp_tables' as num, 
				DATEDIFF(second,@t1,@t2) AS elapsed_m,
				@chksum as chksum,
				@cnt as cnt
		END
	
		IF EXISTS(SELECT top 1 * FROM [price]) or EXISTS(SELECT top 1 * FROM [abs])
		BEGIN
			truncate table [price]
			truncate table [abs]
		END

		IF EXISTS(SELECT top 1 * FROM [table])
		BEGIN
			IF @NUM<6
			BEGIN
				SET @t1 = GETDATE();
				EXEC	[dbo].[billing]
				SET @t2 = GETDATE();
				SELECT @chksum = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM [abs]
				SELECT @cnt = count(*) FROM [abs]

				insert into main_test (num, elapsed_m, chksum, cnt)
				select 
					'billing_cache_update original' as num, 
					DATEDIFF(second,@t1,@t2) AS elapsed_m,
					@chksum as chksum,
					@cnt as cnt
			END
			ELSE
			BEGIN
				delete [prds] 
				where [type]<>'BA'
				SET @t1 = GETDATE();
				EXEC	[dbo].[billing_wo_temp_tables]
				SET @t2 = GETDATE();
				SELECT @chksum = CHECKSUM_AGG(BINARY_CHECKSUM(*)) FROM [abs]
				SELECT @cnt = count(*) FROM [abs]

				insert into main_test (num, elapsed_m, chksum, cnt)
				select 
					'billing_cache_update wo_temp_tables' as num, 
					DATEDIFF(second,@t1,@t2) AS elapsed_m,
					@chksum as chksum,
					@cnt as cnt
			END
		END
		ELSE
		BEGIN
			IF @NUM<6
			BEGIN
				insert into main_test (num, elapsed_m, chksum, cnt)
				select 'billing_cache_update original' as num, 0, 0, 0
			END
			ELSE
			BEGIN
				insert into main_test (num, elapsed_m, chksum, cnt)
				select 'billing_cache_update wo_temp_tables' as num, 0, 0, 0
			END
		END
		SET @NUM = @NUM + 1;
	END
END



