﻿CREATE PROC [labortimeguide].[usp_Volkswagen_ExtractRawToStage]

AS

BEGIN

	TRUNCATE TABLE [labortimeguide].[VOLKLTGOperationVehicles_Stage]
	TRUNCATE TABLE [labortimeguide].[VOLKLTGRelatedLaborOperations_Stage]

	DELETE FROM [labortimeguide].[VOLKLTGVehicleModels_Stage]
	DELETE FROM [labortimeguide].[VOLKLTGRelatedLabor_Stage]
	DELETE FROM [labortimeguide].[VOLKLTGOperations_Stage]
	DELETE FROM [labortimeguide].[VOLKLTGRelationshipTypes_Stage]
	DELETE FROM [labortimeguide].[VOLKLTGSections_Stage]
	DELETE FROM [labortimeguide].[VOLKLTGCategories_Stage]
	
	DBCC CHECKIDENT('labortimeguide.VOLKLTGVehicleModels_Stage', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGRelatedLabor_Stage', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGOperations_Stage', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGRelationshipTypes_Stage', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGSections_Stage', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGCategories_Stage', RESEED, 0)

	------------------------------------------------------------------------------------------------------------------------------------------

	--TRUNCATE TABLE [labortimeguide].[RawData_Volkswagen_LaborOperations]
	--TRUNCATE TABLE [labortimeguide].[RawData_Volkswagen_Vehicles]
	--TRUNCATE TABLE [labortimeguide].[RawData_Volkswagen_RelatedLabor]
	--TRUNCATE TABLE [labortimeguide].[RawData_Volkswagen_Categories]

	------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO [labortimeguide].[VOLKLTGSections_Stage] (Section,SectionDescription) -- ONE TIME INSERT
	SELECT DISTINCT
		[labortimeguide].[RawData_Volkswagen_pid_descr].[column1] AS Section,
		SUBSTRING([labortimeguide].[RawData_Volkswagen_pid_descr].[column2],2,50) AS SectionDescription
	FROM
		[labortimeguide].[RawData_Volkswagen_pid_descr]
	ORDER BY [labortimeguide].[RawData_Volkswagen_pid_descr].[column1] ASC;

	INSERT INTO [labortimeguide].[VOLKLTGCategories_Stage] (CategoryCode,CategoryCodeDescription) 
	SELECT DISTINCT
		[labortimeguide].[RawData_Volkswagen_Categories].CategoryCode AS CategoryCode,
		[labortimeguide].[RawData_Volkswagen_Categories].CategoryCodeDescription AS CategoryCodeDescription
	FROM
		[labortimeguide].[RawData_Volkswagen_Categories]
	WHERE ISNULL([labortimeguide].[RawData_Volkswagen_Categories].CategoryCode,'') <> ''
	ORDER BY [labortimeguide].[RawData_Volkswagen_Categories].CategoryCode,[labortimeguide].[RawData_Volkswagen_Categories].CategoryCodeDescription ASC;

	INSERT INTO [labortimeguide].[VOLKLTGRelationshipTypes_Stage] (RelationshipType,RelationshipTypeDescription)
	SELECT DISTINCT 
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipType AS LaborRelationshipType,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipTypeDesc AS LaborRelationshipTypeDesc
	FROM
		[labortimeguide].[RawData_Volkswagen_RelatedLabor]
	WHERE ISNULL([labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipType,'') <> ''
	ORDER BY [labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipType,[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipTypeDesc ASC;

	INSERT INTO [labortimeguide].[VOLKLTGVehicleModels_Stage] (Model,ModelYear,ModelDescription,Make)
	SELECT DISTINCT 
		[labortimeguide].[RawData_Volkswagen_Vehicles].Model AS Model,
		[labortimeguide].[RawData_Volkswagen_Vehicles].ModelYear AS ModelYear,
		[labortimeguide].[RawData_Volkswagen_Vehicles].ModelDescription AS ModelDescription,
		[labortimeguide].[RawData_Volkswagen_Vehicles].Make AS Make
	FROM
		[labortimeguide].[RawData_Volkswagen_Vehicles]
	ORDER BY [labortimeguide].[RawData_Volkswagen_Vehicles].ModelYear,[labortimeguide].[RawData_Volkswagen_Vehicles].Make,[labortimeguide].[RawData_Volkswagen_Vehicles].Model,[labortimeguide].[RawData_Volkswagen_Vehicles].ModelDescription;

	INSERT INTO [labortimeguide].[VOLKLTGRelatedLabor_Stage] (RelatedLaborOp,RelatedLaborOpDescription,TempRelationshipType,TemplaborOperationsId,TempLaborOpDescription,TempLaborAllowanceHours)
	SELECT DISTINCT
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].RelatedLaborOperationId AS RelatedLaborOperationId,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].RelatedLaborOperationDescription AS RelatedLaborOperationDescription,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborRelationshipType AS TempRelationshipType,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].laborOperationId AS TemplaborOperationsId,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborOperationDescription AS TempLaborOpDescription,
		[labortimeguide].[RawData_Volkswagen_RelatedLabor].LaborAllowanceHours AS TempLaborAllowanceHours
	FROM
		[labortimeguide].[RawData_Volkswagen_RelatedLabor]
	WHERE ISNULL([labortimeguide].[RawData_Volkswagen_RelatedLabor].RelatedLaborOperationId ,'') <> ''
	ORDER BY [labortimeguide].[RawData_Volkswagen_RelatedLabor].RelatedLaborOperationId,[labortimeguide].[RawData_Volkswagen_RelatedLabor].RelatedLaborOperationDescription ASC;

	INSERT INTO [labortimeguide].[VOLKLTGOperations_Stage] (LaborOp,LaborOpDescription,LaborAllowanceHours,categoriesId,LaborOpSection,sectionsId)
	SELECT DISTINCT
		[labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationId AS LaborOp,
		[labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationDescription AS LaborOperationDescription,
		[labortimeguide].[RawData_Volkswagen_LaborOperations].LaborAllowanceHours AS LaborAllowanceHours,
		[labortimeguide].[VOLKLTGCategories_Stage].Id AS categoriesId,
		[labortimeguide].[VOLKLTGSections_Stage].Section AS LaborOpSection,
		[labortimeguide].[VOLKLTGSections_Stage].Id AS sectionsId
	FROM
		[labortimeguide].[RawData_Volkswagen_LaborOperations]
	LEFT JOIN [labortimeguide].[RawData_Volkswagen_Categories]
		ON [labortimeguide].[RawData_Volkswagen_Categories].LaborOperationId = [labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationId
		AND [labortimeguide].[RawData_Volkswagen_Categories].LaborOperationDescription = [labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationDescription
		AND [labortimeguide].[RawData_Volkswagen_Categories].LaborAllowanceHours = [labortimeguide].[RawData_Volkswagen_LaborOperations].LaborAllowanceHours
	LEFT JOIN [labortimeguide].[VOLKLTGCategories_Stage]
		ON [labortimeguide].[VOLKLTGCategories_Stage].CategoryCode = [labortimeguide].[RawData_Volkswagen_Categories].CategoryCode
	LEFT JOIN [labortimeguide].[VOLKLTGSections_Stage]
		ON [labortimeguide].[VOLKLTGSections_Stage].Section = SUBSTRING(CAST([labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationId AS NVARCHAR(50)),1,2)
	ORDER BY [labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationId,[labortimeguide].[RawData_Volkswagen_LaborOperations].LaborOperationDescription,[labortimeguide].[RawData_Volkswagen_LaborOperations].LaborAllowanceHours ASC;

	------------------------------------------------------------------------------------------------------------------------------------------
	
	UPDATE [labortimeguide].[VOLKLTGRelatedLabor_Stage]
	SET relationshipTypesId = [labortimeguide].[VOLKLTGRelationshipTypes_Stage].Id
	FROM [labortimeguide].[VOLKLTGRelatedLabor_Stage]
	JOIN [labortimeguide].[VOLKLTGRelationshipTypes_Stage]
		ON [labortimeguide].[VOLKLTGRelationshipTypes_Stage].RelationshipType = [labortimeguide].[VOLKLTGRelatedLabor_Stage].TempRelationshipType

	------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO [labortimeguide].[VOLKLTGRelatedLaborOperations_Stage] (laborOperationsId,relatedLaborOperationsId)
	SELECT [labortimeguide].[VOLKLTGOperations_Stage].Id
		  ,[labortimeguide].[VOLKLTGRelatedLabor_Stage].Id
	FROM [labortimeguide].[VOLKLTGOperations_Stage]
	JOIN [labortimeguide].[VOLKLTGRelatedLabor_Stage]
		ON [labortimeguide].[VOLKLTGRelatedLabor_Stage].TempLaborOperationsId = [labortimeguide].[VOLKLTGOperations_Stage].LaborOp
		AND [labortimeguide].[VOLKLTGRelatedLabor_Stage].TempLaborOpDescription = [labortimeguide].[VOLKLTGOperations_Stage].LaborOpDescription
		AND [labortimeguide].[VOLKLTGRelatedLabor_Stage].TempLaborAllowanceHours = [labortimeguide].[VOLKLTGOperations_Stage].LaborAllowanceHours
	ORDER BY [labortimeguide].[VOLKLTGOperations_Stage].Id ASC,[labortimeguide].[VOLKLTGRelatedLabor_Stage].Id ASC

	------------------------------------------------------------------------------------------------------------------------------------------

	--SELECT * FROM [labortimeguide].[VOLKLTGSections_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGCategories_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGRelationshipTypes_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGVehicleModels_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGRelatedLabor_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGOperations_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGOperationVehicles_Stage]
	--SELECT * FROM [labortimeguide].[VOLKLTGRelatedLaborOperations_Stage]

	------------------------------------------------------------------------------------------------------------------------------------------

	TRUNCATE TABLE [labortimeguide].[VOLKLTGOperationVehicles]
	TRUNCATE TABLE [labortimeguide].[VOLKLTGRelatedLaborOperations]

	DELETE FROM [labortimeguide].[VOLKLTGVehicleModels]
	DELETE FROM [labortimeguide].[VOLKLTGRelatedLabor]
	DELETE FROM [labortimeguide].[VOLKLTGOperations]
	DELETE FROM [labortimeguide].[VOLKLTGRelationshipTypes]
	DELETE FROM [labortimeguide].[VOLKLTGSections]
	DELETE FROM [labortimeguide].[VOLKLTGCategories]
	
	DBCC CHECKIDENT('labortimeguide.VOLKLTGVehicleModels', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGRelatedLabor', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGOperations', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGRelationshipTypes', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGSections', RESEED, 0)
	DBCC CHECKIDENT('labortimeguide.VOLKLTGCategories', RESEED, 0)

	------------------------------------------------------------------------------------------------------------------------------------------

	INSERT INTO [labortimeguide].[VOLKLTGSections] ([Section], [SectionDescription])
	SELECT DISTINCT [Section], [SectionDescription] FROM [labortimeguide].[VOLKLTGSections_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGCategories] ([CategoryCode], [CategoryCodeDescription])
	SELECT DISTINCT [CategoryCode], [CategoryCodeDescription] FROM [labortimeguide].[VOLKLTGCategories_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGRelationshipTypes] ([RelationshipType], [RelationshipTypeDescription])
	SELECT DISTINCT [RelationshipType], [RelationshipTypeDescription] FROM [labortimeguide].[VOLKLTGRelationshipTypes_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGVehicleModels] ([Model], [ModelYear], [ModelDescription], [Make]) --
	SELECT DISTINCT [Model], [ModelYear], [ModelDescription], [Make] FROM [labortimeguide].[VOLKLTGVehicleModels_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGRelatedLabor] ([RelatedLaborOp], [RelatedLaborOpDescription], [relationshipTypesId])
	SELECT DISTINCT [RelatedLaborOp], [RelatedLaborOpDescription], [relationshipTypesId] FROM [labortimeguide].[VOLKLTGRelatedLabor_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGOperations] ([LaborOp], [LaborOpDescription], [LaborAllowanceHours], [categoriesId], [LaborOpSection], [sectionsId])
	SELECT DISTINCT [LaborOp], [LaborOpDescription], [LaborAllowanceHours], [categoriesId], [LaborOpSection], [sectionsId] FROM [labortimeguide].[VOLKLTGOperations_Stage];

	INSERT INTO [labortimeguide].[VOLKLTGRelatedLaborOperations] ([laborOperationsId], [relatedLaborOperationsId])
	SELECT DISTINCT [labortimeguide].[VOLKLTGOperations].Id
		  ,VOLKLTGRelatedLabor.Id
	FROM [labortimeguide].[VOLKLTGOperations_Stage]
	JOIN [labortimeguide].[VOLKLTGRelatedLabor_Stage]
		ON [labortimeguide].[VOLKLTGRelatedLabor_Stage].TempLaborOperationsId = [labortimeguide].[VOLKLTGOperations_Stage].LaborOp
	CROSS APPLY (SELECT TOP 1 *
					FROM [labortimeguide].[VOLKLTGRelatedLabor]
					WHERE [labortimeguide].[VOLKLTGRelatedLabor].RelatedLaborOp = [labortimeguide].[VOLKLTGRelatedLabor_Stage].RelatedLaborOp) VOLKLTGRelatedLabor
	JOIN [labortimeguide].[VOLKLTGOperations]
		ON [labortimeguide].[VOLKLTGOperations].LaborOp = [labortimeguide].[VOLKLTGOperations_Stage].LaborOp
	ORDER BY VOLKLTGOperations.Id ASC,VOLKLTGRelatedLabor.Id ASC

	SELECT DISTINCT
		[labortimeguide].[RawData_Volkswagen_Vehicles].Model AS Model,
		[labortimeguide].[RawData_Volkswagen_Vehicles].ModelYear AS ModelYear,
		[labortimeguide].[RawData_Volkswagen_Vehicles].ModelDescription AS ModelDescription,
		[labortimeguide].[RawData_Volkswagen_Vehicles].Make AS Make,
		[labortimeguide].[RawData_Volkswagen_Vehicles].LaborOperationId AS TemplaborOperationsId,
		[labortimeguide].[RawData_Volkswagen_Vehicles].LaborOperationDescription AS TempLaborOperationDescription,
		[labortimeguide].[RawData_Volkswagen_Vehicles].LaborAllowanceHours AS TempLaborAllowanceHours,
		0 AS vehicleModelsId,
		0 AS laborOperationsId
	INTO #TempVOLKLTGOperationVehicles
	FROM
		[labortimeguide].[RawData_Volkswagen_Vehicles]
	ORDER BY [labortimeguide].[RawData_Volkswagen_Vehicles].ModelYear,[labortimeguide].[RawData_Volkswagen_Vehicles].Make,[labortimeguide].[RawData_Volkswagen_Vehicles].Model,[labortimeguide].[RawData_Volkswagen_Vehicles].ModelDescription,[labortimeguide].[RawData_Volkswagen_Vehicles].LaborOperationId ASC;

	UPDATE #TempVOLKLTGOperationVehicles
	SET #TempVOLKLTGOperationVehicles.vehicleModelsId = [labortimeguide].[VOLKLTGVehicleModels].Id
		,#TempVOLKLTGOperationVehicles.laborOperationsId = [labortimeguide].[VOLKLTGOperations].Id
	FROM #TempVOLKLTGOperationVehicles
	JOIN [labortimeguide].[VOLKLTGOperations]
	ON [labortimeguide].[VOLKLTGOperations].LaborOp = #TempVOLKLTGOperationVehicles.TemplaborOperationsId
		AND [labortimeguide].[VOLKLTGOperations].LaborOpDescription = #TempVOLKLTGOperationVehicles.TempLaborOperationDescription
		AND [labortimeguide].[VOLKLTGOperations].LaborAllowanceHours = #TempVOLKLTGOperationVehicles.TempLaborAllowanceHours
	JOIN [labortimeguide].[VOLKLTGVehicleModels]
		ON [labortimeguide].[VOLKLTGVehicleModels].Make = #TempVOLKLTGOperationVehicles.Make
		AND [labortimeguide].[VOLKLTGVehicleModels].Model = #TempVOLKLTGOperationVehicles.Model
		AND [labortimeguide].[VOLKLTGVehicleModels].ModelYear = #TempVOLKLTGOperationVehicles.ModelYear
		AND ISNULL([labortimeguide].[VOLKLTGVehicleModels].ModelDescription,'') = ISNULL(#TempVOLKLTGOperationVehicles.ModelDescription,'')

	INSERT INTO [labortimeguide].[VOLKLTGOperationVehicles] (laborOperationsId,vehicleModelsId)
	SELECT DISTINCT
		#TempVOLKLTGOperationVehicles.laborOperationsId,
		#TempVOLKLTGOperationVehicles.vehicleModelsId
	FROM
		#TempVOLKLTGOperationVehicles
	ORDER BY #TempVOLKLTGOperationVehicles.laborOperationsId,#TempVOLKLTGOperationVehicles.vehicleModelsId ASC

	------------------------------------------------------------------------------------------------------------------------------------------

	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGSections]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGCategories]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGRelationshipTypes]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGVehicleModels]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGRelatedLabor]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGOperations]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGRelatedLaborOperations]
	--SELECT TOP 10 * FROM [labortimeguide].[VOLKLTGOperationVehicles]

	DROP TABLE #TempVOLKLTGOperationVehicles

END
