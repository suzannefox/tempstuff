USE [JSON_TESTING]
GO
/****** Object:  UserDefinedFunction [dbo].[HierarchyFromJSON]    Script Date: 15-Dec-17 10:43:18 AM ******/
/****** Sourced from : https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/ ******/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[HierarchyFromJSON](@JSONData VARCHAR(MAX))
RETURNS @ReturnTable TABLE
  (
  Element_ID INT, /* internal surrogate primary key gives the order of parsing and the list order */
  SequenceNo INT NULL, /* the sequence number in a list */
  Parent_ID INT, /* if the element has a parent then it is in this column. The document is the ultimate parent, so you can get the structure from recursing from the document */
  Object_ID INT, /* each list or object has an object id. This ties all elements to a parent. Lists are treated as objects here */
  Name NVARCHAR(2000), /* the name of the object */
  StringValue NVARCHAR(MAX), /*the string representation of the value of the element. */
  ValueType VARCHAR(10) NOT NULL /* the declared type of the value represented as a string in StringValue*/
  )
AS
  BEGIN
    DECLARE @ii INT = 1, @rowcount INT = -1;
    DECLARE @null INT =
      0, @string INT = 1, @int INT = 2, @boolean INT = 3, @array INT = 4, @object INT = 5;
 
    DECLARE @TheHierarchy TABLE
      (
      element_id INT IDENTITY(1, 1) PRIMARY KEY,
      sequenceNo INT NULL,
      Depth INT, /* effectively, the recursion level. =the depth of nesting*/
      parent_ID INT,
      Object_ID INT,
      NAME NVARCHAR(2000),
      --StringValue NVARCHAR(MAX) NOT NULL, Changed 15/12/2017 -  SF
      StringValue NVARCHAR(MAX),
      ValueType VARCHAR(10) NOT NULL
      );
 
    INSERT INTO @TheHierarchy
      (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
      SELECT 1, @ii, NULL, 0, 'root', @JSONData, 'object';
 
    WHILE @rowcount <> 0
      BEGIN
        SELECT @ii = @ii + 1;
 
        INSERT INTO @TheHierarchy
          (sequenceNo, Depth, parent_ID, Object_ID, NAME, StringValue, ValueType)
          SELECT Scope_Identity(), @ii, Object_ID,
            Scope_Identity() + Row_Number() OVER (ORDER BY parent_ID), [Key], o.Value,
            CASE o.Type WHEN @string THEN 'string'
              WHEN @null THEN 'null'
              WHEN @int THEN 'int'
              WHEN @boolean THEN 'boolean'
              WHEN @int THEN 'int'
              WHEN @array THEN 'array' ELSE 'object' END
          FROM @TheHierarchy AS m
            CROSS APPLY OpenJson(StringValue) AS o
          WHERE m.ValueType IN
        ('array', 'object') AND Depth = @ii - 1;
 
        SELECT @rowcount = @@RowCount;
      END;
 
    INSERT INTO @ReturnTable
      (Element_ID, SequenceNo, Parent_ID, Object_ID, Name, StringValue, ValueType)
      SELECT element_id, element_id - sequenceNo, parent_ID,
        CASE WHEN ValueType IN ('object', 'array') THEN Object_ID ELSE NULL END,
        CASE WHEN NAME LIKE '[0-9]%' THEN NULL ELSE NAME END,
        CASE WHEN ValueType IN ('object', 'array') THEN '' ELSE StringValue END, ValueType
      FROM @TheHierarchy;
 
    RETURN;
  END;
