DECLARE @FarmBusiness INT;
DECLARE @FarmID NVARCHAR(15);
DECLARE @Wfp3FormPk INT;
DECLARE @FileName NVARCHAR(255);


	--Change this
	SET @FileName = 'FPD_DEC-002_bmp_15NMCP16.pdf'
	SET @FarmID = (SELECT Item FROM dbo.SplitStrings(@FileName, '_') ORDER BY Item OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY)

	SELECT @FarmID AS FarmID
	

	SELECT pk_documentArchive,
           PK_1,
           PK_2,
           PK_3,
           filename_actual,
           fk_participantTypeSectorFolder_code,
           filepath FROM dbo.documentArchive 
	WHERE filename_actual LIKE 'FPD[_]%'
	ORDER BY filename_actual

	SELECT * FROM dbo.form_wfp3 WHERE pk_form_wfp3 = 2859


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
(   @FarmBusiness,         
    0,        
    NULL,         
    @FileName,       -- filename_actual - nvarchar(255)
    N'A_FORMWAC',       -- fk_participantTypeSectorFolder_code - nvarchar(12)
    GETDATE(), -- created - datetime
    N'Wendy Hanselman',       -- created_by - nvarchar(36)
    NULL, -- modified - datetime
    NULL,       -- modified_by - nvarchar(36)
    @FileName,       -- filename_display - nvarchar(255)
    CONCAT(@FarmID, '\Final Documentation\Nutrient Mgmt\NM Credits\', @FileName)        -- filepath - nvarchar(255)
    )
