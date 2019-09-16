USE wac

DECLARE @FarmID NVARCHAR(20)
DECLARE @RevisionNumber NVARCHAR(3)
DECLARE @pk1 INT
DECLARE @pk2 INT
DECLARE @pk3 INT
DECLARE @doInsert NCHAR(1)
DECLARE @FileName NVARCHAR(255)
DECLARE @FilePath NVARCHAR(255)

---- Change these ----
SET @FarmID = 'ULP-003'
SET @RevisionNumber = '7'
SET @doInsert = 'N'
----------------------

SET @FileName = 'WFP2_' + @FarmID + '_rev' + @RevisionNumber + '.pdf'
SET @FilePath = @FarmID + '\Final Documentation\WFP-0, WFP-1, WFP-2, WFP-3, COS\WFP-2\' + @FileName

-- Select the record for the farmID to be used as PK_1 for the document insert --
SET @pk1 = (SELECT TOP(1) pk_farmBusiness 
			FROM dbo.farmBusiness 
			WHERE farmID = @FarmID 
			ORDER BY pk_farmBusiness)

-- Select the form_wfp2 record for the farmbusiness as PK_2 for document insert--
SET @pk2 = (SELECT TOP(1) pk_form_wfp2 
			FROM dbo.form_wfp2 
			WHERE fk_farmBusiness = @pk1 
			ORDER BY pk_form_wfp2)

-- Select the form_wfp2_version record where the version and fk_form_wfp2 match as PK_3 for document insert --
SET @pk3 = (SELECT TOP(1) pk_form_wfp2_version 
			FROM dbo.form_wfp2_version 
			WHERE version = @RevisionNumber AND fk_form_wfp2 = @pk2 
			ORDER BY pk_form_wfp2_version)

--Insert our new document into the DocumentArchive table, so its accessible in FAME
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
	(   @pk1,         -- PK_1 - int
		@pk2,         -- PK_2 - int
		@pk3,         -- PK_3 - int
		@FileName,       -- filename_actual - nvarchar(255)
		N'A_WFP2',       -- fk_participantTypeSectorFolder_code - nvarchar(12)
		GETDATE(), -- created - datetime
		N'Lorinda Backus',       -- created_by - nvarchar(36)
		NULL, -- modified - datetime
		NULL,       -- modified_by - nvarchar(36)
		@FileName,       -- filename_display - nvarchar(255)
		@FilePath        -- filepath - nvarchar(255)
	)

	--Just a debugging line to help see the newly inserted record.
	SELECT * FROM dbo.documentArchive WHERE pk_documentArchive = SCOPE_IDENTITY()

END
ELSE
BEGIN
	SELECT * FROM dbo.form_wfp2_version WHERE pk_form_wfp2_version = @pk3
	SELECT * FROM dbo.documentArchive WHERE PK_3 = @pk3 OR filename_actual = @FileName
	SELECT 'PREVIEW_ONLY' AS InsertStatus, @pk1 AS PK_1, @pk2 AS PK_2, @pk3 AS PK_3, @FileName AS filename_actual, 'A_WFP2' AS fk_participantTypeSectorFolder_code, 'Lorinda Backus' AS created_by, GETDATE() AS created, NULL AS modified_by, NULL AS modified, @FileName AS filename_display, @FilePath AS filepath
END

