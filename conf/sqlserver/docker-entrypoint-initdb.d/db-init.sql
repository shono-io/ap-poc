USE [master]
GO

IF DB_ID('ap') IS NOT NULL
set noexec on               -- prevent creation when already exists

/****** Object:  Database [ap] ******/
CREATE DATABASE [ap];
GO

USE [ap]
GO

CREATE TABLE [lecturers] (
    [id] integer PRIMARY KEY IDENTITY(1, 1),
    [name] nvarchar(255),
    [created_at] timestamp
)
GO

CREATE TABLE [assignments] (
    id integer PRIMARY KEY IDENTITY(1, 1),
    summary nvarchar(255),
    year integer,
    lecturer_id integer,
    created_at timestamp,
    FOREIGN KEY (lecturer_id) REFERENCES lecturers(id)
)
GO

CREATE LOGIN debezium WITH PASSWORD='Password!';
GO

EXEC sys.sp_cdc_enable_db;
GO

CREATE TABLE dbo.debezium_signal (id VARCHAR(128) PRIMARY KEY, type VARCHAR(32) NOT NULL, data VARCHAR(2048) NULL);
GO

CREATE ROLE cdc_admin;
GO

CREATE USER debezium FROM LOGIN debezium;
GO

ALTER ROLE cdc_admin ADD MEMBER debezium;
GO

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::cdc TO [cdc_admin];
GRANT SELECT ON SCHEMA::dbo TO [cdc_admin];
GRANT INSERT, UPDATE, DELETE ON dbo.debezium_signal TO [cdc_admin];
GO

EXEC sys.sp_cdc_enable_table @source_schema = N'dbo', @role_name     = N'cdc_admin', @source_name   = N'lecturers', @supports_net_changes = 0;
GO

EXEC sys.sp_cdc_enable_table @source_schema = N'dbo', @role_name     = N'cdc_admin', @source_name   = N'assignments', @supports_net_changes = 0;
GO

EXEC sys.sp_cdc_start_job;