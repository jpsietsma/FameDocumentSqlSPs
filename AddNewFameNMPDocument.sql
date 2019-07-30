DECLARE @FarmID NVARCHAR(25)
DECLARE @fileName NVARCHAR(MAX)
DECLARE @finalPath NVARCHAR(MAX)
DECLARE @Sector NVARCHAR(15)
DECLARE @User NVARCHAR(150)
DECLARE @Uploaded DATETIME
DECLARE @farmBusinessPK INT
DECLARE @DoInsert NCHAR(1)

---- Change these values ONLY!
SET @FarmID = 'SCS-SF047'
SET @User = 'Kim Holden'
SET @fileName = 'NMP_SCS-002_2019_2021_20190409.pdf'
SET @Uploaded = '2019-07-10 09:00:00'

SET @DoInsert = 'N'


SET @Sector = 'A_NMP'
SET @farmBusinessPK = ISNULL((SELECT TOP(1) pk_farmBusiness FROM dbo.farmBusiness WHERE farmID = @FarmID ORDER BY pk_farmBusiness), 0)
SET @finalPath = CONCAT(@FarmID, '\', 'Final Documentation', '\', 'Nutrient Mgmt', '\', 'NM Plans', '\', @fileName)

SELECT * FROM dbo.documentArchive WHERE filename_actual LIKE '%NMP%' AND PK_1 = @farmBusinessPK

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
	(   @farmBusinessPK,         -- PK_1 - int
		NULL,         -- PK_2 - int
		NULL,         -- PK_3 - int
		@fileName,       -- filename_actual - nvarchar(255)
		@Sector,       -- fk_participantTypeSectorFolder_code - nvarchar(12)
		ISNULL(@Uploaded, GETDATE()), -- created - datetime
		@User,       -- created_by - nvarchar(36)
		NULL, -- modified - datetime
		NULL,       -- modified_by - nvarchar(36)
		@fileName,       -- filename_display - nvarchar(255)
		@finalPath        -- filepath - nvarchar(255)
	)
END

----Show preview of inserted data
SELECT SCOPE_IDENTITY() AS [pk_documentArchive], @farmBusinessPK AS [PK_1], NULL AS [PK_2], NULL AS [PK_3], @fileName AS [filename_actual], @Sector AS [fk_participantTypeSectorFolder_code], @Uploaded AS [created], @User AS [created_by], NULL AS [modified], NULL AS [modified_by], @fileName AS [filename_display], @finalPath AS [filepath]
