DELIMITER $$

/*Operazione 5.2.1*/

DROP PROCEDURE IF EXISTS ricerca_carsharing$$
CREATE PROCEDURE ricerca_carsharing(IN casaProd VARCHAR(20),
				    IN numPosti TINYINT(2),
                                    IN dataOra1 DATETIME,
                                    IN dataOra2 DATETIME,
                                    IN codS INT)
BEGIN
	SELECT CS.Targa, CS.DataOraInizio, CS.CostoOrario, GROUP_CONCAT(O.Descrizione) AS ListaOptional
    	FROM AUTOVETTURA A INNER JOIN DOTAZIONE D ON A.Targa=D.Targa
		   INNER JOIN OPTIONAL O ON D.CodiceOpt=O.Codice
                   INNER JOIN CARSHARING CS ON A.Targa=CS.Targa
	WHERE A.Posti>=numPosti AND
		A.CasaProduttrice=casaProd AND
          	CS.CodiceServizio=codS AND
          	CS.DataOraInizio<=dataOra1 AND CS.DataOraFine>=dataOra2
	GROUP BY CS.Targa, CS.DataOraInizio;
END $$

/*Operazione 5.2.2*/

DROP PROCEDURE IF EXISTS ricerca_pool$$
CREATE PROCEDURE ricerca_pool(IN kmStradaP INT,
			      IN kmStradaA INT, 
                              IN idSP INT,
                              IN idSA INT,
                              IN codS INT,
			      IN dataOraP DATETIME)
BEGIN
	SELECT CP.CodiceServizio AS codS, CP.DataOraInizio AS inizio, CP.Targa AS auto, CP.IdentificativoPool, CP.DataArrivo, 
		   CP.PostiOccupati, CP.GradoFlessibilita, CP.PercentualeVariazioneCosto, CP.CostoAPersona 		
    	FROM CARPOOLING CP INNER JOIN AUTOVETTURA A ON A.Targa=CP.Targa
	   	INNER JOIN PERCORRE P ON A.Targa=P.Targa
		INNER JOIN TRAGITTO T ON P.CodiceTragitto=T.CodiceTragitto
	WHERE T.IdentificativoSP=idSP AND
		T.IdentificativoSA=idSA AND
          	ABS(T.KmInizioT-kmStradaP)+ABS(T.KmFineT-kmStradaA)<=15 AND 
          	dataOraP=CP.DataOraInizio  AND
          	CP.GradoFlessibilita='alto' AND
          	CP.CodiceServizio=codS AND
          	CURRENT_TIMESTAMP()<=CP.DataOraInizio-HOUR(48) AND
          	(A.Posti-CP.PostiOccupati)> (SELECT COUNT(*)
						FROM PRENOTAZIONE PREN
                                       		WHERE PREN.CodiceServizio=codS AND
							PREN.DataOraInizio=dataOraP AND
                                             		PREN.Targa=CP.Targa)
	GROUP BY auto, inizio, codS;
END $$

/*Operazione 5.2.3*/

DROP PROCEDURE IF EXISTS ricerca_sharing$$
CREATE PROCEDURE ricerca_sharing(IN dataGiorno DATE,
				 IN descrOpt VARCHAR(50), 
				 IN codS INT,
                                 IN numero INT,
                                 IN categorizzazione CHAR(4),
                                 IN suffisso CHAR(6))
BEGIN
	SELECT RS.PrezzoAlKm, (SELECT *
				FROM TRAGITTO T1
                           	WHERE T.CodiceTragitto=T1.CodiceTragitto)
    	FROM RIDESHARING RS INNER JOIN AUTOVETTURA A ON RS.Targa=A.Targa
		INNER JOIN DOTAZIONE D ON A.Targa=D.Targa
                INNER JOIN OPTIONAL O ON D.CodiceOpt=O.Codice
		INNER JOIN TRAGITTO T ON RS.CodiceTragitto=T.CodiceTragitto
                INNER JOIN COMPONES C ON T.CodiceTragitto=C.CodiceTragitto
                INNER JOIN STRADA S ON C.IdentificativoS=S.IdentificativoS
                INNER JOIN IDENTIFICA I ON I.IdentificativoS=S.IdentificativoS
                INNER JOIN IDENTIFICATORESTRADA IDS ON I.Identificatore=IDS.Identificatore
    	WHERE DATE(RS.DataOraInizio)=dataGiorno AND
		RS.CodiceServizio=codS AND
          	IDS.Numero=numero AND
          	IDS.Cat=categorizzazione AND
          	IDS.Suffisso=suffisso AND
          	O.Descrizione=descrOpt
	GROUP BY RS.Targa, RS.DataOraInizio, RS.CodiceServizio;
END $$

/*Operazione 5.2.4*/

DROP PROCEDURE IF EXISTS nuovo_utente$$
CREATE PROCEDURE nuovo_utente(IN _numeroD VARCHAR(50),
			      IN _tipologiaD VARCHAR(100),
    			      IN _enteRilascioD VARCHAR(100),
                              IN _scadenzaD DATE,
                              IN _nomeUtente VARCHAR (15),
			      IN _codFiscale CHAR(16),
			      IN _nome VARCHAR(100),
                              IN _cognome VARCHAR(100),
			      IN _numeroTelefono VARCHAR(50),
			      IN _password VARCHAR(50), 
			      IN _attivita CHAR(2), 
			      IN _nazionalita VARCHAR(50), 
			      IN _via VARCHAR(100),
			      IN _cap VARCHAR(20), 
			      IN _citta VARCHAR(100), 
			      IN _rispostaRecup VARCHAR(100),
			      IN _domandaRecup VARCHAR(100),
                              INOUT _targa CHAR(7),
			      IN _casaProduttrice VARCHAR(20),
			      IN _modello VARCHAR(20),
	                      IN _cilindrata SMALLINT(4),
			      IN _posti TINYINT(2),
	    		      IN _annoImmatricolazione YEAR(4),
			      IN _comfort TINYINT,
			      IN _costoUsuraKmPers FLOAT,
			      IN _capacitaSerbatoio TINYINT(2),
		     	      IN _velocitaMax TINYINT,
			      IN _CUrbano FLOAT,
			      IN _CExtraUrbano FLOAT,
			      IN _CMisto FLOAT,
			      IN _assicurazione FLOAT,
			      IN _bollo FLOAT,
			      IN _carburante1 VARCHAR(20),
			      IN _carburante2 VARCHAR(20),
                              IN _opt1 VARCHAR(20),
                              IN _opt2 VARCHAR(20),
                              IN _opt3 VARCHAR(20),
                              INOUT _dataOraInizio DATETIME,
			      IN _dataOraFine DATETIME,
	    		      IN _costoOrario FLOAT,
		              IN _kmAuto INTEGER,
			      IN _carburante TINYINT,
                              OUT codS INT)
BEGIN
	DECLARE c1 VARCHAR(20);
	DECLARE c2 VARCHAR(20);
    	DECLARE codO1 INT;
	DECLARE codO2 INT;
    	DECLARE codO3 INT;
    
	INSERT INTO DOCUMENTO(NumeroD, TipologiaD, EnteRilascioD, ScadenzaD) 
    	VALUES (_numeroD, _tipologiaD, _enteRilascioD, _scadenzaD);
    
    	INSERT INTO UTENTE(NomeUtente, codFiscale, nome, cognome, numeroTelefono, dataIscrizione, NumeroD, 
		tipologiaD, password, Attivita, nazionalita, via, cap, citta, rispostaRecup, domandaRecup)
    	VALUES (_nomeUtente, _codFiscale, _nome, _cognome, _numeroTelefono, CURRENT_DATE(), 
		_numeroD, _tipologiaD, _password, _attivita, _nazionalita, _via, _cap, _citta, _rispostaRecup, _domandaRecup);

	INSERT INTO PROPONENTE(NomeUtenteP, PunteggioRecensioni, NumeroRecensioni) VALUES (_nomeUtente, 0, 0);

	SET c1 = (SELECT TCarburante
			FROM CARBURANTE 
             		WHERE TCarburante=_carburante1);
	IF c1 = NULL THEN
		INSERT INTO CARBURANTE(TCarburante) VALUES (_carburante1);
	END IF;
    
    	IF _carburante2 != NULL THEN
		BEGIN
			SET c2 = (SELECT TCarburante
					FROM CARBURANTE 
					WHERE TCarburante=_carburante2);
			IF c2 = NULL THEN
				INSERT INTO CARBURANTE(TCarburante) VALUES (_carburante2);
			END IF;
		END;
	END IF;
	
    	INSERT INTO AUTOVETTURA(Targa, CasaProduttrice, Modello, Cilindrata, Posti, AnnoImmatricolazione, Comfort, 
		CostoUsuraKmPers, CapacitaSerbatoio, VelocitaMax, CUrbano, CExtraUrbano, CMisto, Assicurazione, 
		Bollo, Carburante1, Carburante2, NomeUtente, NkmPercorsi, NPool)
	VALUES (_targa, _casaProduttrice, _modello, _cilindrata, _posti, _annoImmatricolazione, _comfort,
		_costoUsuraKmPers, _capacitaSerbatoio, _velocitaMax, _CUrbano, _CExtraUrbano, _CMisto, 
		_assicurazione, _bollo, _carburante1, _carburante2, _nomeUtente, 0, 0);
                                    
	INSERT INTO OPTIONAL (Descrizione) VALUES (_opt1);
	INSERT INTO OPTIONAL (Descrizione) VALUES (_opt2);
    	INSERT INTO OPTIONAL (Descrizione) VALUES (_opt3);
    
    	SET codO1 = (SELECT DISTINCT Codice
			FROM OPTIONAL
                 	WHERE Descrizione = _opt1);
	SET codO2 = (SELECT DISTINCT Codice
			FROM OPTIONAL
                 	WHERE Descrizione = _opt2);
	SET codO3 = (SELECT DISTINCT Codice
			FROM OPTIONAL
                 	WHERE Descrizione = _opt3);
    
    	INSERT INTO DOTAZIONE(CodiceOpt, Targa) VALUES (codO1, _targa);
    	INSERT INTO DOTAZIONE(CodiceOpt, Targa) VALUES (codO2, _targa);
    	INSERT INTO DOTAZIONE(CodiceOpt, Targa) VALUES (codO3, _targa);
    
    	INSERT INTO CARSHARING(CodiceServizio, DataOraInizio, Targa, DataOraFine, CostoOrario, KmAuto, Carburante)
    	VALUES (1, _dataOraInizio, _targa, _dataOraFine, _costoOrario, _kmAuto, _carburante);
    	SET codS=1;
END $$

/*Operazione 5.2.5*/

DROP FUNCTION IF EXISTS kmTragitto$$
CREATE FUNCTION kmTragitto(_codTragitto INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE km INT DEFAULT 0;
   	DECLARE finito1 INT DEFAULT 0;
    	DECLARE kmI INT;
    	DECLARE kmF INT;
    	DECLARE cursoreKm CURSOR FOR
    	SELECT KmInizioStrada, KmFineStrada
    	FROM COMPONES CS
    	WHERE CS.CodiceTragitto=_codTragitto;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito1=1;
    	OPEN cursoreKm;
    	scan: LOOP
		FETCH cursoreKm INTO kmI, kmF;
		IF finito1=1 THEN 
			LEAVE scan;
		END IF;
		SET km=km + (kmF-kmI);
	END LOOP scan;
	CLOSE cursoreKm;
	RETURN(km);
END$$	

DROP FUNCTION IF EXISTS kmPool$$
CREATE FUNCTION kmPool(_codServ INT,
			_dataOraI DATETIME,
			_targa CHAR(7))
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE sommaKm INT DEFAULT 0;
    	DECLARE codT INT;
    	DECLARE finito INT DEFAULT 0;
   	DECLARE cursoreTragitti CURSOR FOR
    	SELECT CodiceTragitto
    	FROM PERCORRE P
    	WHERE P.CodiceServizio=_codServ AND
		P.DataOraInizio=_dataOraI AND
          	P.Targa=_targa;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito=1;
    	OPEN cursoreTragitti;
    	scan: LOOP
		FETCH cursoreTragitti INTO codT;
		IF finito=1 THEN 
			LEAVE scan;
		END IF;
		SET sommaKm=sommaKm + kmTragitto(codT);
	END LOOP scan;
	CLOSE cursoreTragitti;
	RETURN(sommaKm);
END$$

DROP FUNCTION IF EXISTS mediaKmPool$$
CREATE FUNCTION mediaKmPool(_codServ INT,
				_targa CHAR(7))
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE dataOraIn DATETIME;
    	DECLARE finito2 INT DEFAULT 0;
    	DECLARE sommaTotKm INT DEFAULT 0;
    	DECLARE numeroPool INT DEFAULT 0;
    	DECLARE media FLOAT;
    	DECLARE cursorePool CURSOR FOR
    	SELECT DataOraInizio
    	FROM CARPOOLING CP
    	WHERE CP.CodiceServizio=_codServ AND
        	CP.Targa=_targa;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito2=1;
    	OPEN cursorePool;
    	scan: LOOP
		FETCH cursorePool INTO dataOraIn;
		IF finito2=1 THEN 
			LEAVE scan;
		END IF;
		SET sommaTotKm=sommaTotKm + kmPool(_codServ, dataOraIn, _targa);
        	SET numeroPool=numeroPool + 1;
	END LOOP scan;
	CLOSE cursorePool;
    	SET media=sommaTotKm/numeroPool;
	RETURN(media);
END$$

/*Operazione 5.2.6*/

DROP PROCEDURE IF EXISTS nuovo_pool$$
CREATE PROCEDURE  nuovo_pool(IN _dataOra DATETIME, 
				IN _targa VARCHAR(7), 
				IN _idpool VARCHAR(10), 
				IN _dataArrivo DATETIME,
				IN _postiDisponibili  TINYINT, 
				IN _flex CHAR(5), 
				IN _percvar FLOAT, 
				IN _costoapersona FLOAT, 
				IN _latPartenza CHAR(20), 
				IN _longPartenza CHAR(20), 
				IN _latArrivo CHAR(20), 
				IN _longArrivo CHAR(20))						
BEGIN

	DECLARE IDStradaP INT;
	DECLARE IDStradaA INT;
	DECLARE kmPartenza INT;
	DECLARE kmArrivo INT;
	DECLARE IDtemp INT;
	
	SELECT  S.IdentificativoS, C.nKm INTO IDStradaP, kmPartenza
	FROM STRADA S INNER JOIN CHILOMETRO C ON S.IdentificativoS = C.IdentificativoS
	WHERE C.Latitudine = _latPartenza AND C.Longitudine = _longPartenza
	LIMIT 1;
	
	SELECT S.IdentificativoS, C.nKm INTO IDStradaA, kmArrivo
	FROM STRADA S INNER JOIN CHILOMETRO C ON S.IdentificativoS = C.IdentificativoS
	WHERE C.Latitudine = _latArrivo AND C.Longitudine = _longArrivo
	LIMIT 1;
	
	INSERT INTO TRAGITTO(KmInizioT, KmFineT, IdentificativoSP, IdentificativoSA) VALUES (kmPartenza, kmArrivo, IDStradaP, IDStradaA);
	
	SET IDtemp = (SELECT LAST_INSERT_ID() FROM TRAGITTO LIMIT 1);
    
	INSERT INTO CARPOOLING(CodiceServizio, DataOraInizio, Targa, IdentificativoPool, DataArrivo, PostiOccupati, GradoFlessibilita, PercentualeVariazioneCosto, CostoAPersona)
    	VALUES (2, _dataOra, _targa, _idpool, _dataArrivo, _postiDisponibili, _flex, _percvar, _costoapersona);
    
	INSERT INTO PERCORRE(CodiceServizio,DataOraInizio, Targa, CodiceTragitto) VALUES (2, _dataOra, _targa, IDtemp);
	
END$$

DROP PROCEDURE IF EXISTS popola_compones$$
CREATE PROCEDURE popola_compones (IN _CodTragitto INT , IN _IDStrada INT , IN _kmInizio INT , IN _kmFine INT )
BEGIN 
	INSERT INTO COMPONES(CodiceTragitto, IdentificativoS,KmInizioStrada,KmFineStrada) VALUES (_CodTragitto, _IDStrada, _kmInizio, _kmFine);	
END$$

/*Operazione 5.2.7*/

DROP PROCEDURE IF EXISTS media_recensioni$$
CREATE PROCEDURE  media_recensioni( IN _nomeUtente VARCHAR(15), OUT media_valutazioni_ FLOAT)
BEGIN
	DECLARE finito 	INTEGER DEFAULT 0;
	DECLARE counter INTEGER DEFAULT 0; /*per fare la media*/
	DECLARE mP INTEGER DEFAULT 0; /*somma persona*/
	DECLARE mC INTEGER DEFAULT 0; /*somma comportamento*/
	DECLARE mS INTEGER DEFAULT 0; /*somma serieta*/
	DECLARE mPV INTEGER DEFAULT 0; /*somma piacere viaggio*/
	DECLARE a,b,c,d INTEGER; /*appoggio aree valutazione*/
	DECLARE ScorriVal CURSOR FOR
		SELECT	V.Persona, V.Comportamento, V.Serieta, V.PiacereViaggio	
		FROM VALUTAZIONE V
		WHERE ((V.NomeUtenteP = _nomeUtente AND flag=2) OR (V.NomeUtenteF = _nomeUtente AND flag=1));

	DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET finito=1; 

	OPEN ScorriVal;
	leggi: LOOP
		FETCH ScorriVal INTO a,b,c,d;
		IF finito = 1 THEN
			LEAVE leggi;
		END IF;
		SET mP = ( mP + a );
		SET mC = ( mC + b );
		SET mS = ( mS + c );
		SET mPV = ( mPV + d);
		SET counter = counter+1;
	END LOOP leggi;
	CLOSE ScorriVal;
	SET media_valutazioni_ =  ((mP+mC+mS+mPV)/(4*counter));
END$$

/*Operazione 5.2.8*/

/*---------------------------------------------------------*/
/*---------------- procedure 1, ricerca rs ----------------*/
/*---------------------------------------------------------*/

DROP PROCEDURE IF EXISTS find_ride_sharing2$$
CREATE PROCEDURE  find_ride_sharing2(IN _dataOra DATETIME, 
					IN _nomeFruitore VARCHAR(15), 
					IN _kmStradaP INT ,  
					IN _IDStradaPartenza INT, 
					IN _kmStradaA INT, 
					IN _IDStradaArrivo INT)
BEGIN
	DECLARE a INTEGER;
	DECLARE b CHAR(1);
	DECLARE c DATETIME;
	DECLARE d CHAR(7);
    	DECLARE result boolean;
	DECLARE finito INTEGER DEFAULT 0;
	DECLARE Cursore1 CURSOR FOR
		SELECT RS.CodiceTragitto, RS.CodiceServizio, RS.DataOraInizio, RS.Targa
		FROM TRAGITTO T INNER JOIN RIDESHARING RS ON T.CodiceTragitto = RS.CodiceTragitto            
		WHERE 	_dataOra <= RS.DataOraInizio;	
	DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET finito=1; 
	OPEN Cursore1;
	leggi: LOOP
		FETCH Cursore1 INTO a,b,c,d;
		IF(finito) THEN
			LEAVE leggi;
		ELSE
			CALL verificaVerso(a, _kmStradaP, _IDStradaPartenza, _kmStradaA, _IDStradaArrivo, result);
			IF(result) then 
				SELECT B as CodiceServizio,C as DataOraInizio,D as Targa;
			END IF;
		END IF;
	END LOOP leggi;
	CLOSE Cursore1;
END$$

DROP PROCEDURE IF EXISTS verificaVerso$$
CREATE PROCEDURE verificaVerso(IN codTragitto integer,
				IN _kmP INT ,  
				IN _IDSP INT, 
				IN _kmA INT, 
				IN _IDSA INT, 
				INOUT ok boolean)
BEGIN
	DECLARE finito2 INTEGER DEFAULT 0;
	DECLARE IDStrada_temp INTEGER;
	DECLARE kmInizioStrada_temp INTEGER;
	DECLARE kmFineStrada_temp INTEGER;
    	DECLARE trovatoA BOOLEAN;
	DECLARE trovatoP BOOLEAN;
    	DECLARE trovatoPartenza INTEGER DEFAULT 0;
	DECLARE trovatoArrivo INTEGER DEFAULT 0 ;	
	DECLARE Cursore2 CURSOR FOR
		SELECT CS.IdentificativoS, CS.KmInizioStrada, CS.KmFineStrada 	 
		FROM  COMPONES CS
		WHERE CS.CodiceTragitto = codTragitto;
	DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET finito2=1; 
	OPEN Cursore2;
	cercaPartenza: LOOP
		FETCH Cursore2 INTO IDStrada_temp, kmInizioStrada_temp,kmFineStrada_temp;
		IF(finito2) THEN
			LEAVE cercaPartenza;
		ELSE
			SET trovatoPartenza = trovatoPartenza+1;
                	IF(kmInizioStrada_temp>kmFineStrada_temp) THEN /*gestione dei tragitti che hanno una spezzata di strada con chilometri decrescenti*/
				IF(IDStrada_temp = _IDSP AND _kmP <= kmInizioStrada_temp AND _kmP >= kmFineStrada_temp) THEN 
						SET trovatoP = TRUE;
						LEAVE cercaPartenza;
				END IF;
			ELSE
				IF(IDStrada_temp = _IDSP AND _kmP >= kmInizioStrada_temp AND _kmP <= kmFineStrada_temp) THEN 
					SET trovatoP = TRUE;
					LEAVE cercaPartenza;
				END IF;
			END IF;
		END IF;
	END LOOP cercaPartenza;
	CLOSE Cursore2;
	SET finito2=0;
	OPEN Cursore2;
	cercaArrivo: LOOP
		FETCH Cursore2 INTO IDStrada_temp, kmInizioStrada_temp,kmFineStrada_temp;
		IF(finito2) THEN
			LEAVE cercaArrivo;
		ELSE
			SET trovatoArrivo = trovatoArrivo+1;
			IF(kmInizioStrada_temp>kmFineStrada_temp ) THEN
				IF(IDStrada_temp = _IDSA AND _kmA <= kmInizioStrada_temp AND _kmA >= kmFineStrada_temp) THEN 
					SET trovatoA = TRUE;
					LEAVE cercaArrivo;
				END IF;
			ELSE
				IF(IDStrada_temp = _IDSA AND _kmA >= kmInizioStrada_temp AND _kmA <= kmFineStrada_temp) THEN 
					SET trovatoA = TRUE;
                                	LEAVE cercaArrivo;
				END IF;
			END IF;
		END IF;
	END LOOP cercaArrivo;
	CLOSE cursore2;
	IF(trovatoA AND trovatoP AND (trovatoArrivo > trovatoPartenza)) THEN 
		SET ok = TRUE;
	END IF;
END$$				

/*per ogni codtrag vedo se transita dalle due strada date*/
 /*devo trovare 2 record, uno per la strada partenza, uno per la strada arrivo e dato che la chiave di 
compones è data  dal codTragitto_ e il nkm se ne trovo due quei due sono per forza delle due strada date in ingresso*/

/*-------------------------------------------------------------------*/
/*---------------- procedure 2, inserimento chiamata ----------------*/
/*-------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS insert_call$$
CREATE PROCEDURE insert_call(IN _nomeUtenteF VARCHAR(15),
				IN _dataOra DATETIME,
				IN _Targa VARCHAR(7),
				IN _LatP CHAR(20),
				IN _LatA CHAR(20),
				IN _LongP CHAR(20),
				IN _LongA CHAR(20),
				IN _IdSP INT,
				IN _IdSA INT)
BEGIN						
	INSERT INTO CHIAMATA(DataOraInizio, NomeUtenteF, Targa, LatitudineP, LongitudineP, IdentificativoSP, LatitudineA, LongitudineA, IdentificativoSA, Stato) 
	VALUES( _dataOra, _nomeUtenteF, _Targa, _LatP, _LongP, _IdSP, _LatA, _LongA, _IdSA, 'pending');
		
END$$
		
/*----------------------------------------------------------------*/
/*---------------- procedure 3, modifica lo stato ----------------*/
/*----------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS modifica_stato$$
CREATE PROCEDURE modifica_stato( IN _stato INT , IN _codiceChiamata INT)  /* 1 = accepted, 0 = rejected */
BEGIN
	IF(_stato=1) THEN
		UPDATE CHIAMATA C
		SET C.Stato = 'accepted' , C.TimestampRisposta = CURRENT_DATE()
		WHERE C.Codice = _codiceChiamata;		
	END IF;
	IF( _stato=0) THEN
		UPDATE CHIAMATA C
		SET C.Stato = 'rejected' , C.TimestampArrivo = NULL
		WHERE C.Codice = _codiceChiamata;
	END IF;
END$$

