DECLARE @ContractorOrg NVARCHAR(max), @searchTerm NVARCHAR(max), @policyStart NVARCHAR(50), @policyEnd NVARCHAR(50), @participantPK INT, @DocType NVARCHAR(20), @documentName NVARCHAR(max), @DocumentSector NVARCHAR(25), @documentUploadDate DATETIME, @documentOwner NVARCHAR(100), @documentFinalPath NVARCHAR(max), @doInsert NCHAR(1)
DECLARE @ContractorResults TABLE (pk_participantID INT NOT NULL, suggestedDocumentPrefix NVARCHAR(max) NOT NULL, ContractorFameName NVARCHAR(max) NOT NULL)

---Step 1: Change these values as necessary---
SET @searchTerm = 'Action Garage Doors'
SET @policyStart = '20190531'
SET @policyEnd = '20200531'
SET @DocType = 'CERTLIAB'
SET @documentOwner = 'Lorinda Backus'
SET @documentUploadDate = '2019-06-01'
----------------------------------------------

--Step 2: set to 'N' to preview before insert--
SET @doInsert = 'N'
-----------------------------------------------

--Step 3: set @doInsert to 'Y' when satisfied with what will be inserted into the dbo.documentArchive table--

SET @DocumentName = CONCAT(@DocType, '_', (SELECT TOP(1) suggestedDocumentPrefix FROM @ContractorResults ORDER BY suggestedDocumentPrefix), '_', @policyStart, '_', @policyEnd, '.pdf')
SET @ContractorOrg = (SELECT TOP(1) fullname_FL_dnd FROM dbo.participant WHERE fullname_FL_dnd LIKE '%' + @searchTerm + '%' ORDER BY fullname_FL_dnd)
SET @participantPK = (SELECT TOP(1) pk_participant FROM dbo.participant WHERE fullname_FL_dnd LIKE '%' + @searchTerm + '%' ORDER BY pk_participant) 
INSERT INTO @ContractorResults (pk_participantID,suggestedDocumentPrefix, ContractorFameName) VALUES (@participantPK, REPLACE(@ContractorOrg, ' ', ''), @ContractorOrg)
SELECT pk_participantID, suggestedDocumentPrefix, ContractorFameName FROM @ContractorResults
SELECT * FROM dbo.documentArchive WHERE PK_1 = @participantPK AND filename_actual LIKE @DocType + '%'

IF @DocType = 'CERTLIAB'
BEGIN
	SET @documentFinalPath = CONCAT((SELECT TOP(1) suggestedDocumentPrefix FROM @ContractorResults ORDER BY suggestedDocumentPrefix), '\General Liability\', @documentName)
	SET @DocumentSector = 'PART_OVER'
END
ELSE IF @DocType = 'WORKCOMP'
BEGIN
	SET @documentFinalPath = CONCAT((SELECT TOP(1) suggestedDocumentPrefix FROM @ContractorResults ORDER BY suggestedDocumentPrefix), '\Workers Comp\', @documentName)
	SET @DocumentSector = 'PART_OVER'
END
ELSE IF @DocType = 'IRSW9'
BEGIN
	SET @documentFinalPath = CONCAT((SELECT TOP(1) suggestedDocumentPrefix FROM @ContractorResults ORDER BY suggestedDocumentPrefix), '\W-9\', @documentName)
	SET @DocumentSector = 'PART_OVER'
END
ELSE
BEGIN
	SET @documentFinalPath = '--Invalid document type--'
	SET @DocumentSector = '--Invalid document type--'
END

IF @doInsert = 'Y'
BEGIN
	INSERT INTO dbo.documentArchive
	(
		PK_1,
		PK_2,
		PK_3,
		filename_actual,
		fk_participantTypeSectorFolder_code,
		created,
		created_by,
		modified,
		modified_by,
		filename_display,
		filepath
	)
	VALUES
	(   
		-- PK_1 - the PK value for the participant for which the document belongs
		@participantPK,
		-- Always null - PK_2 - useless for contractor docs
		NULL,				 
		-- Always null - PK_3 - uesless for contractor docs
		NULL,				 
		-- filename_actual - Display name of the document
		@documentName,       
		-- fk_participantTypeSectorFolder_code - determines in which tab the document appears, shown under the "documents" panel
		@DocumentSector,	 
		-- created - timestamp for created column when document should be marked as having been uploaded
		@documentUploadDate, 
		-- created_by - user for created_by column, determines the user which uploaded the document
		@documentOwner,		 
		-- Always null - modified - datetime
		NULL,				 
		-- Always null - modified_by - datetime
		NULL,				 
		-- filename_display - Display name of the document, must match filename_actual for some reason?
		@documentName,       
		-- filepath - relative filepath from J:\CONTRACTORS\Contractor_docs\ to the document, path should be in the form of: [<ContractorName>\<DocumentFolder>\<DocumentName>.pdf] i.e. "DavidAStanton\Workers Comp\WORKCOMP_DavidAStanton_20190531_20200531.pdf"
		@documentFinalPath	 
	)

	SELECT * FROM dbo.documentArchive WHERE pk_documentArchive = SCOPE_IDENTITY()
END
ELSE IF @doInsert = 'N'
BEGIN
	SELECT NULL AS [pk_documentArchive], @participantPK AS [PK_1], NULL AS [PK_2], NULL AS [PK_3], @documentName AS [filename_actual], @DocumentSector AS [fk_participantTypeSectorFolder_code], @documentUploadDate AS [created], @documentFinalPath AS [filepath]
END
