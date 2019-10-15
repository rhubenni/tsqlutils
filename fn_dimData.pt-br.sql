/* ***********************************************************************************************************
** fn_dimHora
** 
** This table-valued function returns a time dimension table with the granularity (in seconds) specified
** in the @INCREMENT parameter.
** Thus, you should be able to use it to populate time-dimension physical tables, or use the returned table
** directly in your queries dynamically using joins.
** 
** This script assumes that you're using PT-BR as language. You're free to change it.
**
** This script is licenced under GNU Lesser General Public License v3.0
** https://github.com/rhubenni/tsqlutils/blob/master/LICENSE
**
** Regards, 2019, Rhubenni Telesco
*********************************************************************************************************** */

CREATE FUNCTION fn_dimHora (@INCREMENTO INT) RETURNS @DimHora TABLE (
		 [CodiHoraMinu]			 INT NULL
		,[CodiHoraSegu]			 INT NULL
		,[NumeHora]			 INT NULL
		,[NumeMinu]			 INT NULL
		,[Hora]				 TIME NULL
		,[InteHora]			 TIME NULL
		,[InteTrinMinu]			 TIME NULL
		,[InteQuinMinu]			 TIME NULL
		,[InteDezMinu]			 TIME NULL
		,[InteCincMinu]			 TIME NULL
		,[NumePeriDia]			 INT NULL
		,[NomePeriDia]			 VARCHAR(16) NULL
		,[NumePeriRH]			 INT NULL
		,[NomePeriRH]			 VARCHAR(16) NULL
)
AS
BEGIN

	DECLARE @TEMPO_ATUAL INT = 0;
	DECLARE @HORA_ATUAL DATETIME = '00:00:00';
	DECLARE @NUME_HORA INT = NULL;

	WHILE @TEMPO_ATUAL <= 86399
		BEGIN

			SET @HORA_ATUAL = DATEADD(SECOND, @TEMPO_ATUAL, '00:00:00');
			SET @NUME_HORA = FORMAT(@HORA_ATUAL, 'HH');

			INSERT INTO @DimHora (
				 [CodiHoraMinu]
				,[CodiHoraSegu]
				,[NumeHora]
				,[NumeMinu]
				,[Hora]
				,[InteHora]
				,[InteTrinMinu]
				,[InteQuinMinu]
				,[InteDezMinu]
				,[InteCincMinu]
				,[NumePeriDia]
				,[NomePeriDia]
				,[NumePeriRH]
				,[NomePeriRH]
			) VALUES (
				 FORMAT(@HORA_ATUAL, 'HHmm')
				,FORMAT(@HORA_ATUAL, 'HHmmss')
				,@NUME_HORA
				,FORMAT(@HORA_ATUAL, 'mm')
				,@HORA_ATUAL
				,DATEADD(HOUR, DATEDIFF(HOUR, 0, @HORA_ATUAL), 0)
				,DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @HORA_ATUAL) / 30 * 30, 0)
				,DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @HORA_ATUAL) / 15 * 15, 0)
				,DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @HORA_ATUAL) / 10 * 10, 0)
				,DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @HORA_ATUAL) / 05 * 05, 0)
				,CASE
					WHEN @NUME_HORA < 06 THEN 1
					WHEN @NUME_HORA < 12 THEN 2
					WHEN @NUME_HORA < 18 THEN 3
					ELSE 4
				 END
				,CASE
					WHEN @NUME_HORA < 06 THEN 'Madrugada'
					WHEN @NUME_HORA < 12 THEN 'Manhã'
					WHEN @NUME_HORA < 18 THEN 'Tarde'
					ELSE 'Noite'
				 END
				 ,IIF(@NUME_HORA BETWEEN 05 AND 22, 1, 2)
				 ,IIF(@NUME_HORA BETWEEN 05 AND 22, 'Diurno', 'Noturno')
			)
	

			SET @TEMPO_ATUAL = @TEMPO_ATUAL + @INCREMENTO

		END
	RETURN;
END
