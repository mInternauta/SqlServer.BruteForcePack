USE [master]
GO
/****** Object:  StoredProcedure [dbo].[bruteforce_IPLoginFailed]    Script Date: 26/11/2019 10:32:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[bruteforce_IPLoginFailed]
	@qMode int = 0 
AS
BEGIN
	-------------------------------------------------------------
	-- Cria as tabelas temporárias
	--------------------------------------------------------------
 
	IF (OBJECT_ID('tempdb..#Arquivos_Log') IS NOT NULL) DROP TABLE #Arquivos_Log
	CREATE TABLE #Arquivos_Log ( 
		[idLog] INT, 
		[dtLog] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AI, 
		[tamanhoLog] INT 
	)
 
	IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
	CREATE TABLE #Login_Failed (
		[LogNumber] TINYINT,
		[LogDate] DATETIME, 
		[ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
		[Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
		[Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
		[IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
	)
 
	--------------------------------------------------------------
	-- Importa os arquivos do ERRORLOG
	--------------------------------------------------------------
 
	INSERT INTO #Arquivos_Log
	EXEC sys.sp_enumerrorlogs
 
 
	--------------------------------------------------------------
	-- Loop para procurar por falhas de login nos arquivos
	---------------------------------------
	-----------------------

	DECLARE
		@BeginDate DATETIME,
		@EndDate DATETIME

	SET @BeginDate = (DATEADD(MINUTE, -30, GETDATE()))
	SET @EndDate = (DATEADD(MINUTE, +30, GETDATE()))

	PRINT N'Pesquisando logs para: '
	PRINT @EndDate
	PRINT N'Para: '
	PRINT @BeginDate
 
	DECLARE
		@Contador INT = 0,
		@Total INT = 1
    
 
	WHILE(@Contador < @Total)
	BEGIN
    
		-- Pesquisa por senha incorreta
		INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
		EXEC master.dbo.xp_readerrorlog 0, 1, N'Password did not match that for the login provided', N'Login', @BeginDate, @EndDate, N'asc' 
 
		-- Pesquisa por tentar conectar com usuário que não existe
		INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text])     
		EXEC master.dbo.xp_readerrorlog 0, 1, N'Could not find a login matching the name provided.', N'Login', @BeginDate, @EndDate, N'asc' 
 
		-- Atualiza o número do arquivo de log
		UPDATE #Login_Failed
		SET LogNumber = @Contador
		WHERE LogNumber IS NULL
 
		SET @Contador += 1
    
	END
	
	IF @qMode = 1		
	BEGIN
		SELECT [IP], COUNT(*) AS Quantidade
			FROM #Login_Failed
			GROUP BY [IP]
			ORDER BY 2 DESC
	END

	IF @qMode = 2		
	BEGIN
		SELECT [Username], COUNT(*) AS Quantidade
			FROM #Login_Failed
			GROUP BY [Username]
			ORDER BY 2 DESC
	END

	IF @qMode = 3		
	BEGIN
		SELECT  COUNT(*) AS Quantidade
			FROM #Login_Failed
	END
		
	IF @qMode = 4		
	BEGIN
		SELECT  * FROM #Login_Failed	
	END
END
