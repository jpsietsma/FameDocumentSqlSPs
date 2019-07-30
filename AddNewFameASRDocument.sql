DECLARE @FarmBusinessPK INT
DECLARE @FarmID NVARCHAR(20)
DECLARE @AsrYear INT
DECLARE @pk2 INT
DECLARE @FileName NVARCHAR(255)
DECLARE @FilePath NVARCHAR(255)
DECLARE @AllowInsert NCHAR(1)
DECLARE @created DATETIME
DECLARE @User NVARCHAR(100)

---- Change this
SET @FarmID = 'DEC-273'

---- Change this
SET @FileName = 'ASR_DEC-273_2019_B_20190502.pdf'

---- Optional: Change upload date, user, ASR year
SET @created = '2019-06-18 09:00:00'
SET @User = 'Tristin Tait'
SET @AsrYear = 2019

SET @AllowInsert = 'Y'



SET @FarmBusinessPK = (SELECT TOP(1)pk_farmBusiness FROM dbo.farmBusiness WHERE farmID = @FarmID ORDER BY pk_farmBusiness)
SET @pk2 = (SELECT TOP(1) pk_asrAg FROM dbo.asrAg WHERE fk_farmBusiness = @FarmBusinessPK AND year = @AsrYear ORDER BY year)
SET @FilePath = @FarmID + '\Final Documentation\ASRs\' + @FileName

----Select record from asrAg to show us which pk for record was used for the PK_2 column insert into document archive
SELECT pk_asrAg,
       date,
       interviewee,
       fk_farmBusiness,
       fk_asrType_code,
       modified_by,
       year FROM dbo.asrAg WHERE pk_asrAg = @pk2

IF @AllowInsert = 'Y'
BEGIN
	----Insert our new document into the DocumentArchive table, so its accessible in FAME
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
	(   @FarmBusinessPK,			 ---- PK_1 - int
		ISNULL(@pk2, 0),			 ---- PK_2 - int
		NULL,						 ---- PK_3 - int
		@FileName,					 ---- filename_actual - nvarchar(255)
		N'A_ASR',					 ---- fk_participantTypeSectorFolder_code - nvarchar(12)
		ISNULL(@created, GETDATE()), ---- created - datetime
		ISNULL(@User, 'Jimmy Sietsma'),			 ---- created_by - nvarchar(36)
		NULL,						 ---- modified - datetime
		NULL,						 ---- modified_by - nvarchar(36)
		@FileName,					 ---- filename_display - nvarchar(255)
		@FilePath					 ---- filepath - nvarchar(255)
	)
END

--These are just debugging lines to help see the newly inserted record.
DECLARE @newDoc INT = SCOPE_IDENTITY()
SELECT * FROM dbo.documentArchive WHERE pk_documentArchive = @newDoc

