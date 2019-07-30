DECLARE @FarmID NVARCHAR(MAX)
DECLARE @DocumentName NVARCHAR(MAX)
DECLARE @DocumentUploader NVARCHAR(MAX)
DECLARE @FameTabSection NVARCHAR(50)
DECLARE @UploadDate DATETIME
DECLARE @DoInsert NCHAR(1)

--------- EDIT THESE VALUES AS NEEDED ---------
SET @FarmID = 'GRP-SF005'
SET @DocumentName = 'IRSW9_GRP-SF005_2019_20190528.pdf'
SET @DocumentUploader = 'Wendy Hanselman'
SET @FameTabSection = 'A_OVERFORM'
SET @UploadDate = '2019-06-11'
-----------------------------------------------

--Set this to 'N' for first run to get a preview of the information to be inserted 
SET @DoInsert = 'N'
----------------------------------------------------------------------------------

DECLARE @FinalPath NVARCHAR(MAX)
DECLARE @ResponseMessage NVARCHAR(MAX)
DECLARE @FarmBusinessPK NVARCHAR(MAX)
DECLARE @FameTabSectionDisplay NVARCHAR(MAX)
DECLARE @ExistingFile TABLE(pk_documentArchive INT NOT NULL, filename_actual NVARCHAR(MAX) NOT NULL, filepath NVARCHAR(MAX) NOT NULL, created DATETIME NOT NULL, created_by NVARCHAR(100) NOT NULL)

IF @DocumentName LIKE 'CERTLIAB%'
	SET @FinalPath = @FarmID + '\General Liability\' + @DocumentName
ELSE IF @DocumentName LIKE 'IRSW9%'
	SET @FinalPath = @FarmID + '\W-9\' + @DocumentName
ELSE IF @DocumentName LIKE 'WORKCOMP%'
	SET @FinalPath = @FarmID + '\Workers Comp\' + @DocumentName
ELSE
BEGIN
	SELECT 'Unrecognized Document Type, check the filename and try again.' AS [Error Message], (SELECT TOP(1) Item FROM dbo.SplitStrings(@DocumentName, '_') ORDER BY @@ROWCOUNT) AS [Attempted Type]
	RETURN
END

IF @FameTabSection = 'A_OVERFORM'
	SET @FameTabSectionDisplay = 'Overview Tab'
ELSE IF @FameTabSection = 'A_NMP'
	SET @FameTabSectionDisplay = 'NMP Tab'
ELSE IF @FameTabSection = 'A_ASR'
	SET @FameTabSectionDisplay = 'ASR Tab'
ELSE IF @FameTabSection = 'A_WFP2'
	SET @FameTabSectionDisplay = 'WFP-2 Tab'
ELSE IF @FameTabSection = 'A_OM'
	SET @FameTabSectionDisplay = 'O&M Tab'


SET @FarmBusinessPK = (SELECT TOP(1) pk_farmBusiness FROM dbo.farmBusiness WHERE farmID = @FarmID ORDER BY pk_farmBusiness)

IF @FarmBusinessPK IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.documentArchive WHERE filename_actual = @DocumentName)
	BEGIN
		SET @ResponseMessage = 'Document Record preview.  No record inserted.'
		IF @DoInsert = 'Y'
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
			(   @FarmBusinessPK,        -- PK_1 - int
				NULL,					-- PK_2 - int = null for this document type
				NULL,					-- PK_3 - int = null for this document type
				@DocumentName,			-- filename_actual - nvarchar(255)
				@FameTabSection,		-- fk_participantTypeSectorFolder_code - nvarchar(12)
				@UploadDate,			-- created - datetime
				@DocumentUploader,      -- created_by - nvarchar(36)
				NULL,					-- modified - datetime
				NULL,					-- modified_by - nvarchar(36)
				@DocumentName,			-- filename_display - nvarchar(255)
				@FinalPath				-- filepath - nvarchar(255)
			)

		SET @ResponseMessage = 'Document Record was successfully inserted.'
		END
		
		SELECT @ResponseMessage AS [Status Message], @FarmID AS [Farm ID], @FarmBusinessPK AS [Farm PK], SCOPE_IDENTITY() AS [New Document PK], @DocumentName AS [New Document Name], 'J:\Farms\' + @FinalPath AS [File Save Path], @DocumentUploader AS [WAC Uploader], @UploadDate AS [Upload Timestamp], @FameTabSectionDisplay AS [FAME Location], @DoInsert AS [Record Inserted?]
		
		RETURN
	END
	ELSE
	BEGIN
		--Insert matching document records from dbo.documentArchive into our table variable
		INSERT INTO @ExistingFile
		(
		    pk_documentArchive,
		    filename_actual,
		    filepath,
			created,
			created_by
		)
		SELECT pk_documentArchive, filename_actual, filepath, created, created_by FROM dbo.documentArchive WHERE filename_actual = @DocumentName

		--Output the existing file information and message
		SELECT 'Duplicate document upload attempted.  Document record already exists in FAME.' AS [Error Message], @DocumentName AS [Attempted Upload], CONVERT(NVARCHAR(10), (SELECT TOP(1) pk_documentArchive FROM @ExistingFile WHERE filename_actual = @DocumentName ORDER BY pk_documentArchive)) AS [Existing PK], (SELECT TOP(1) filepath FROM @ExistingFile WHERE filename_actual = @DocumentName ORDER BY pk_documentArchive) AS [Existing Filepath], (SELECT TOP(1) created FROM @ExistingFile WHERE filename_actual = @DocumentName ORDER BY pk_documentArchive) AS [Original Uploaded], (SELECT TOP(1) created_by FROM @ExistingFile WHERE filename_actual = @DocumentName ORDER BY pk_documentArchive) AS [Uploaded By]
		RETURN
	END
END
ELSE
BEGIN
	SELECT 'Invalid Farm ID.  Unable to locate farm record for ' + @FarmID AS [Error Message]
	RETURN
END