

----------------------------- Check if enabled -----------------------------
USE master 
GO

SELECT [name], database_id, is_cdc_enabled  
FROM sys.databases       
ORDER BY database_id  DESC
GO
----------------------------- Check if enabled -----------------------------


----------------------------- Enable for DB -----------------------------
USE [TestDB]
GO

EXEC sys.sp_cdc_enable_db 
GO 

SELECT * FROM [cdc].[captured_columns]
SELECT * FROM [cdc].[change_tables]
SELECT * FROM [cdc].[ddl_history]
SELECT * FROM [cdc].[index_columns]
SELECT * FROM [cdc].[lsn_time_mapping]
SELECT * FROM [dbo].[systranschemas]

----------------------------- Enable for DB -----------------------------

----------------------------- Check if enabled for Table -----------------------------

USE [TestDB]
GO

SELECT [name], is_tracked_by_cdc  
FROM sys.tables 
GO
  
----------------------------- Check if enabled for Table -----------------------------


----------------------------- Enable for Table -----------------------------

USE [TestDB]
GO

EXEC sys.sp_cdc_enable_table 
@source_schema = N'dbo', 
@source_name   = N'Account', 
@role_name     = NULL 
GO

SELECT * FROM [cdc].[change_tables]
SELECT * FROM [cdc].[captured_columns]
SELECT * FROM [cdc].[index_columns]
SELECT * FROM [cdc].[lsn_time_mapping]

----------------------------- Enable for Table -----------------------------

----------------------------- Enable for Selcted Table Columns -----------------------------

USE [TestDB] 
GO; 

EXEC sys.sp_cdc_enable_table 
@source_schema = N'dbo', 
@source_name   = N'Account', 
@role_name     = NULL
@captured_column_list = '[first_name],[last_name]' 
GO;

SELECT * FROM [cdc].[change_tables]
SELECT * FROM [cdc].[captured_columns]
SELECT * FROM [cdc].[index_columns]
SELECT * FROM [cdc].[lsn_time_mapping]


----------------------------- Enable for Selcted Table Columns -----------------------------



-------------------------- Insert -----------------------------

INSERT INTO [dbo].[Account]
           ([first_name]
           ,[last_name]
           ,[email]
           ,[password]
           ,[status]
           ,[date_created]
           ,[unique_identifer])
     VALUES
           ('CDC test insert'
           ,'test insert'
           ,'cdc@gmail.com'
           ,''
           ,1
           ,GETDATE()
           ,'')
GO

SELECT * FROM [dbo].[Account]
SELECT * FROM [cdc].[dbo_Account_CT]

-------------------------- Insert -----------------------------

-------------------------- Update -----------------------------

UPDATE [TestDB].[dbo].[Account] SET first_name = 'CDC test insert 2'
WHERE ID = 2007
GO

SELECT * FROM [dbo].[Account]
SELECT * FROM [cdc].[dbo_Account_CT]

-------------------------- Update -----------------------------

-------------------------- Delete -----------------------------

DELETE [TestDB].[dbo].[Account] WHERE ID = 2007
GO

SELECT * FROM [dbo].[Account]
-- TAKES FEW SECONDS TO UPDATE RUN THE SELECT AND THEN RUN THE CDC TABLE 
SELECT * FROM [cdc].[dbo_Account_CT]

-------------------------- Delete -----------------------------

-------------------------- Clean up -----------------------------

USE [TestDB]

EXEC sys.sp_cdc_change_job 
@job_type = N'cleanup', 
@retention = 2880; 
GO

-------------------------- Clean up -----------------------------

-------------------------- Retriving -----------------------------

USE [TestDB] 
GO 
DECLARE @begin_time_stamp BINARY(10);
DECLARE @end_time_stamp BINARY(10);  
SELECT	@begin_time_stamp = sys.fn_cdc_map_time_to_lsn('smallest greater than', GETDATE()-1); 
SELECT	@end_time_stamp = sys.fn_cdc_map_time_to_lsn('largest less than or equal', GETDATE()); 
SELECT * 
FROM [cdc].[fn_cdc_get_all_changes_dbo_Account](@begin_time_stamp,@end_time_stamp,'all') 
GO

-------------------------- Retriving -----------------------------


-------------------------- Disabling For Table -----------------------------

USE [TestDB]; 
GO 
EXEC sys.sp_cdc_help_change_data_capture 
GO

USE [TestDB]; 
GO
EXECUTE sys.sp_cdc_disable_table 
    @source_schema = N'dbo', 
    @source_name = N'Account',
    @capture_instance = N'dbo_Account';
GO

-------------------------- Disabling For Table -----------------------------

-------------------------- Disabling For Database -----------------------------
EXEC sys.sp_cdc_disable_db 
GO
-------------------------- Disabling For Database -----------------------------



