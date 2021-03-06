
-- CREATE A TEXT SEARCH TABLE WITH ALL TEXT TO BE SEARCHED AS ONE FIELD
USE [abp_search]

-- First time setup, need to create an empty
-- stoplist because single digits are included
-- in the default stoplist
-- DROP FULLTEXT STOPLIST EmptyStoplist;
-- CREATE FULLTEXT STOPLIST EmptyStopList;  

-- CLEAR OLD TABLE
DROP TABLE
	abp_search

-- CREATE NEW TABLE FROM LOADED CSV FILES IN abp
SELECT 
	Id_Identity,
	UPRN,
	UDPRN,
	POSTCODE,
	CASE WHEN ORGANISATION_NAME <> '' THEN ORGANISATION_NAME + ' ' ELSE '' END +
	CASE WHEN DEPARTMENT_NAME <> '' THEN DEPARTMENT_NAME + ' ' ELSE '' END +
	CASE WHEN SUB_BUILDING_NAME <> '' THEN SUB_BUILDING_NAME + ' ' ELSE '' END +
	CASE WHEN BUILDING_NAME <> '' THEN BUILDING_NAME + ' ' ELSE '' END +
	CASE WHEN BUILDING_NUMBER IS NOT NULL THEN CAST(BUILDING_NUMBER AS NVARCHAR(10)) + ' ' ELSE '' END +
	CASE WHEN DEPENDENT_THOROUGHFARE <> '' THEN DEPENDENT_THOROUGHFARE + ' ' ELSE '' END +
	CASE WHEN THOROUGHFARE <> '' THEN THOROUGHFARE + ' ' ELSE '' END +
	CASE WHEN DOUBLE_DEPENDENT_LOCALITY <> '' THEN DOUBLE_DEPENDENT_LOCALITY + ' ' ELSE '' END +
	CASE WHEN DEPENDENT_LOCALITY <> '' THEN DEPENDENT_LOCALITY + ' ' ELSE '' END +
	CASE WHEN POST_TOWN <> '' THEN POST_TOWN + ' ' ELSE '' END +
	CASE WHEN POSTCODE <> '' THEN POSTCODE + ' ' ELSE '' END +
	CASE WHEN WELSH_DEPENDENT_THOROUGHFARE <> '' THEN WELSH_DEPENDENT_THOROUGHFARE + ' ' ELSE '' END +
	CASE WHEN WELSH_THOROUGHFARE <> '' THEN WELSH_THOROUGHFARE + ' ' ELSE '' END +
	CASE WHEN WELSH_DOUBLE_DEPENDENT_LOCALITY <> '' THEN WELSH_DOUBLE_DEPENDENT_LOCALITY + ' ' ELSE '' END +
	CASE WHEN WELSH_DEPENDENT_LOCALITY <> '' THEN WELSH_DEPENDENT_LOCALITY + ' ' ELSE '' END +
	CASE WHEN WELSH_POST_TOWN <> '' THEN WELSH_POST_TOWN + ' ' ELSE '' END 
	AS SEARCH
INTO 
	abp_search
FROM
	abp.dbo.delivery_point

-- ADD THE UNIQUE KEY
ALTER TABLE abp_search
ADD CONSTRAINT PK_abp_search
-- PRIMARY KEY(Id_Identity)
	PRIMARY KEY CLUSTERED ([Id_Identity] ASC) 
	ON [PRIMARY]

-- DROP AND CREATE CATALOG
DROP FULLTEXT CATALOG 
	Address_Catalog;

CREATE FULLTEXT CATALOG 
	Address_Catalog 
AS DEFAULT; 

-- DROP FULLTEXT INDEX ON dbo.abp_search 
-- CREATE FULL TEXT INDEX
CREATE FULLTEXT INDEX ON 
	dbo.abp_search(SEARCH) 
KEY INDEX 
	PK_abp_search
WITH STOPLIST = 
	EmptyStoplist;

