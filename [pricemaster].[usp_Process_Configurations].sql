CREATE PROCEDURE [pricemaster].[usp_Process_Configurations] (@OEM NVARCHAR(100) = NULL,@ConnectionType NVARCHAR(100) = NULL,@SourceFileName NVARCHAR(100) = NULL) 

AS
BEGIN

	DECLARE 
	 @SQL NVARCHAR(MAX)
	,@nl CHAR(2) = CHAR(13) + CHAR(10)

	SELECT @SQL ='
			SELECT
			 [OEM]
			,[NCICCode]
			,[SourceFileName]
			,[FeedType]
			,[Frequency]
			,[TargetFolder]
			,[BaseURL]
			,[HostName]
			,[UserName]
			,[Port]
			,[SecretName]
			,[FileFormat]
			,[Password]
			,[CompressionType]
			,[CopyBehavior]
			,[ConnectionType]
			,[SourceFolder]
			,[ColumnDelimiter]
			,[RowDelimiter]
			,[EscapeCharacter]
			,[QuoteCharacter]
			,[FirstRowAsHeader]
		FROM [pricemaster].[Configurations]
		INNER JOIN [pricemaster].[OEMs]
			ON [pricemaster].[OEMs].Id = [pricemaster].[Configurations].OEMsId
		WHERE [pricemaster].[Configurations].[Active] = 1 ' + @nl

	IF @ConnectionType IS NOT NULL
	SELECT @SQL += '	AND [pricemaster].[Configurations].[ConnectionType] = ''' + @ConnectionType + ''''

	IF @OEM IS NOT NULL
	SELECT @SQL += '	AND [pricemaster].[OEMs].[OEM] = ''' + @OEM + ''''

	IF @SourceFileName IS NOT NULL
	SELECT @SQL += '	AND [pricemaster].[Configurations].[SourceFileName] = ''' + @SourceFileName + ''''

	EXEC sp_executesql @SQL

END