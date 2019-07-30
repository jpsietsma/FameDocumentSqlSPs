DECLARE @participantPK INT, @documentName NVARCHAR(max), @DocumentSector NVARCHAR(25), @documentDate DATETIME, @documentOwner NVARCHAR(100), @documentFinalPath NVARCHAR(max), @doInsert NCHAR(1)

SET @participantPK = 6254
SET @documentName = 'WORKCOMP_DavidA.Stanton_20120605.pdf'
SET @DocumentSector = 'PART_OVER'
SET @documentFinalPath = 'DavidAStanton\Workers Comp\WORKCOMP_DavidA.Stanton_20120605.pdf'
SET @documentOwner = 'Lorinda Backus'
SET @documentDate = '2012-06-05 12:00:00.000'
SET @doInsert = 'Y'

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
	(   @participantPK,		 -- PK_1 - int
		NULL,				 -- PK_2 - int
		NULL,				 -- PK_3 - int
		@documentName,       -- filename_actual - nvarchar(255)
		@DocumentSector,	 -- fk_participantTypeSectorFolder_code - nvarchar(12)
		@documentDate,		 -- created - datetime
		@documentOwner,		 -- created_by - nvarchar(36)
		NULL,				 -- modified - datetime
		NULL,				 -- modified_by - nvarchar(36)
		@documentName,       -- filename_display - nvarchar(255)
		@documentFinalPath	 -- filepath - nvarchar(255)
	)

	SELECT * FROM dbo.documentArchive WHERE pk_documentArchive = SCOPE_IDENTITY()
END
ELSE IF @doInsert = 'N'
BEGIN
	SELECT NULL AS [pk_documentArchive], @participantPK AS [PK_1], NULL AS [PK_2], NULL AS [PK_3], @documentName AS [filename_actual], @DocumentSector AS [fk_participantTypeSectorFolder_code], @documentDate AS [created], @documentFinalPath AS [filepath]
END




SELECT * FROM dbo.documentArchive WHERE PK_1 = 6254 AND filename_actual LIKE '%WORKCOMP%'

UPDATE dbo.documentArchive SET filename_actual = 'WORKCOMP_DavidAStanton_20150531_20160531.pdf', filename_display = 'WORKCOMP_DavidAStanton_20150531_20160531.pdf', filepath = 'DavidAStanton\Workers Comp\WORKCOMP_DavidAStanton_20150531_20160531.pdf' WHERE pk_documentArchive = 7784



SELECT * FROM dbo.participant WHERE fullname_FL_dnd LIKE '%WICKHAM%'










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
(   87,         -- PK_1 - int
    NULL,         -- PK_2 - int
    NULL,         -- PK_3 - int
    N'TIER1_DEC-085_Wickham&Merrill.pdf',       -- filename_actual - nvarchar(255)
    N'A_TIER1',       -- fk_participantTypeSectorFolder_code - nvarchar(12)
    GETDATE(), -- created - datetime
    N'Jackie VanLoan',       -- created_by - nvarchar(36)
    NULL, -- modified - datetime
    NULL,       -- modified_by - nvarchar(36)
    N'TIER1_DEC-085_Wickham&Merrill.pdf',       -- filename_display - nvarchar(255)
    N'DEC-085\AEM\Tier1_DEC-085_Wickham&Merrill.pdf'        -- filepath - nvarchar(255)
    )


	SELECT * FROM dbo.documentArchive WHERE PK_1 = 12431

	SELECT * FROM dbo.documentArchive WHERE filename_actual LIKE '%TIER1%'

	UPDATE dbo.documentArchive SET PK_2 = NULL, PK_3 = NULL WHERE pk_documentArchive = 17712



	SELECT * FROM dbo.farmBusiness WHERE pk_farmBusiness = 2049



	SELECT * FROM dbo.documentArchive WHERE filename_actual LIKE 'AEM%'

	SELECT pk_farmBusiness FROM dbo.farmBusiness WHERE farmID = 'DEC-085'


	UPDATE dbo.documentArchive SET fk_participantTypeSectorFolder_code = 'A_OVERFORM' WHERE pk_documentArchive = 17714