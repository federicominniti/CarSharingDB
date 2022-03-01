DELIMITER $$

/*Vincolo 1*/

DROP TRIGGER IF EXISTS attivita_utente1_1$$
CREATE TRIGGER attivita_utente1_1
BEFORE INSERT ON CARSHARING
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
    	SET att = (SELECT U.Attivita
			FROM UTENTE U INNER JOIN AUTOVETTURA A on U.NomeUtente=A.NomeUtente
               		WHERE A.Targa=NEW.Targa);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
END$$

/*Vincolo (1), 12*/

DROP TRIGGER IF EXISTS check_carpooling$$
CREATE TRIGGER check_carpooling
BEFORE INSERT ON CARPOOLING
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
    	SET att = (SELECT U.Attivita
			FROM UTENTE U INNER JOIN AUTOVETTURA A on U.NomeUtente=A.NomeUtente
              	 	WHERE A.Targa=NEW.Targa);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
    
    	IF (NEW.GradoFlessibilita != "alto" AND NEW.GradoFlessibilita != "medio" AND NEW.GradoFlessibilita != "basso") THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Grado di flessibilità pool non valido';
	END IF;
END$$

DROP TRIGGER IF EXISTS attivita_utente3_1$$
CREATE TRIGGER attivita_utente3_1
BEFORE INSERT ON RIDESHARING
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
    	SET att = (SELECT U.Attivita
			FROM UTENTE U INNER JOIN AUTOVETTURA A on U.NomeUtente=A.NomeUtente
               		WHERE A.Targa=NEW.Targa);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
END$$

DROP TRIGGER IF EXISTS attivita_utente1_2$$
CREATE TRIGGER attivita_utente1_2
BEFORE INSERT ON RICHIESTA
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
   	SET att = (SELECT U.Attivita
			FROM UTENTE U
              		WHERE U.NomeUtente=NEW.NomeUtenteF);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
END$$

DROP TRIGGER IF EXISTS attivita_utente2_2$$
CREATE TRIGGER attivita_utente2_2
BEFORE INSERT ON PRENOTAZIONE
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
    	SET att = (SELECT U.Attivita
			FROM UTENTE U
               		WHERE U.NomeUtente=NEW.NomeUtenteF);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
    
    	IF TIMESTAMPDIFF(HOUR, CURRENT_TIMESTAMP(), '2018-12-27 07:20:00')<=1 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Tempo per prenotare il pool scaduto';
	END IF;
END$$

DROP TRIGGER IF EXISTS attivita_utente3_2$$
CREATE TRIGGER attivita_utente3_2
BEFORE INSERT ON CHIAMATA
FOR EACH ROW
BEGIN
	DECLARE att CHAR(2);
    	SET att = (SELECT U.Attivita
			FROM UTENTE U
               		WHERE U.NomeUtente=NEW.NomeUtenteF);
	IF att = 'no' THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Untente non ancora attivato';
	END IF;
END$$

/*Vincolo 2, 3*/

DROP TRIGGER IF EXISTS check_utente$$
CREATE TRIGGER check_utente
BEFORE INSERT ON UTENTE
FOR EACH ROW
BEGIN
	DECLARE l_pwd INTEGER;
    	DECLARE l_codF INTEGER;
    	SET l_pwd = (SELECT CHAR_LENGTH(NEW.password));
	IF l_pwd<=8 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Password non sicura';
	END IF;
    
    	SET l_codF = (SELECT CHAR_LENGTH(NEW.codFiscale));
	IF l_codF != 16 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Codice fiscale non valido';
	END IF;
END$$

/*Vincolo 5*/

DROP PROCEDURE IF EXISTS aggiornaDocumento$$
CREATE PROCEDURE aggiornaDocumento(IN utente1 CHAR(15), IN NuovaDataScadenza date)
BEGIN
	DECLARE numero_documento VARCHAR(50);
    	DECLARE tipologia_documento VARCHAR(100);
    	SET numero_documento = (SELECT U.NumeroD
					FROM UTENTE U
					WHERE U.NomeUtente=utente1);
	SET tipologia_documento = (SELECT U.TipologiaD
					FROM UTENTE U
					WHERE U.NomeUtente=utente1);
	UPDATE DOCUMENTO SET ScadenzaD = NuovaDataScadenza
    	WHERE NumeroD = numero_documento
		AND TipologiaD = tipologia_documento;
END $$

/*Vincolo 6, 7, 8*/

DROP TRIGGER IF EXISTS check_auto$$
CREATE TRIGGER check_auto
BEFORE INSERT ON AUTOVETTURA
FOR EACH ROW
BEGIN
	DECLARE l_targa INTEGER;
	IF NEW.Comfort<0 OR NEW.Comfort>5 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Livello comfort non valido';
	END IF;
    
    	SET l_targa = (SELECT CHAR_LENGTH(NEW.Targa));
	IF l_targa != 7 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Targa non valida';
	END IF;
    
    	IF (NEW.Carburante1 != "Benzina" AND 
		NEW.Carburante1 != "Gasolio" AND
	    	NEW.Carburante1 != "Gpl" AND 
        	NEW.Carburante1 != "Metano" AND 
        	NEW.Carburante1 != "Elettrica")
       	    OR
       		(NEW.Carburante2 != "Benzina" AND 
        	NEW.Carburante2 != "Gasolio" AND
	    	NEW.Carburante2 != "Gpl" AND 
        	NEW.Carburante2 != "Metano" AND 
        	NEW.Carburante2 != "Elettrica" AND 
        	NEW.Carburante2 != NULL)
       	    THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Tipologia carburanti auto non valida';
	END IF;
END$$

/*Vincolo 9, 10*/

DROP TRIGGER IF EXISTS val_levels$$
CREATE TRIGGER val_levels
BEFORE INSERT ON VALUTAZIONE
FOR EACH ROW
BEGIN
	IF (NEW.Persona<1 OR NEW.Persona>5)
		OR
	   	(NEW.Comportamento<1 OR NEW.Comportamento>5)
       		OR
       		(NEW.Serieta<1 OR NEW.Serieta>5)
       		OR
	   	(NEW.PiacereViaggio<1 OR NEW.PiacereViaggio>5)
        THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Valutazione non valida';
	END IF;
    
    	IF (NEW.CodiceServizio<1 OR NEW.CodiceServizio>3) THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Codice servizio non valido';
	END IF;
END$$

/*Vincolo 11*/

DROP TRIGGER IF EXISTS check_torretta$$
CREATE TRIGGER check_torretta
BEFORE UPDATE ON RICHIESTA
FOR EACH ROW
BEGIN 
	DECLARE carburante_inizio TINYINT;
    	SET carburante_inizio = (SELECT Carburante 
					FROM CARSHARING C
                             		WHERE C.CodiceServizio=OLD.CodiceServizio AND
				  		C.DataOraInizio=OLD.DataOraInizio AND
                                   		C.Targa=OLD.Targa);
	IF (carburante_inizio<NEW.CarburanteFine-5) THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Impossibile restituire il veicolo, livello di benzina errato';
	END IF;
END$$

/*Vincolo 13*/

DROP TRIGGER IF EXISTS check_esito$$
CREATE TRIGGER check_esito
BEFORE UPDATE ON PRENOTAZIONE
FOR EACH ROW
BEGIN 
	IF (NEW.Esito != "pending" AND NEW.Esito != "accepted" AND NEW.Esito != "rejected") THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Esito prenotazione non valido';
	END IF;
END$$

/*Vincolo 15, 16*/

DROP TRIGGER IF EXISTS check_identifStrada$$
CREATE TRIGGER check_identifStrada
BEFORE INSERT ON IDENTIFICATORESTRADA
FOR EACH ROW
BEGIN 
	IF (NEW.Cat != "dir" AND NEW.Cat != "var" AND NEW.Cat != "racc" AND  NEW.Cat != "radd" AND NEW.Cat!= "-") THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Categorizzazione non valida';
	END IF;
    
    	IF (NEW.Suffisso != "bis" AND NEW.Suffisso != "ter" AND  NEW.Suffisso != "quater") THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Suffisso non valido';
	END IF;
END$$

/*Vincolo 18*/

DROP TRIGGER IF EXISTS check_suffisso$$
CREATE TRIGGER check_suffisso
BEFORE INSERT ON CARREGGIATA
FOR EACH ROW
BEGIN 
	IF (NEW.SensiMarcia<1 OR  NEW.SensiMarcia>2) THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Numero sensi di marcia non valido';
	END IF;
END$$

/*Vincolo 19*/

DROP TRIGGER IF EXISTS check_tipologia$$
CREATE TRIGGER check_tipologia
BEFORE INSERT ON STRADA
FOR EACH ROW
BEGIN 
	IF (NEW.Tipologia != "A" AND
		NEW.Tipologia != "SS" AND
        	NEW.Tipologia != "SR" AND
        	NEW.Tipologia != "SP" AND
        	NEW.Tipologia != "SC" AND
        	NEW.Tipologia != "SV")
      	THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Tipologia strada non valida';
	END IF;
END$$

/*Vincolo 20*/

DROP TRIGGER IF EXISTS check_extraurbana$$
CREATE TRIGGER check_extraurbana
BEFORE INSERT ON EXTRAURBANA
FOR EACH ROW
BEGIN 
	IF (NEW.Tipo != "principale" AND
		NEW.Tipo != "secondaria")
        THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Tipo strada extraurbana non valido';
	END IF;
END$$

/*Vincolo 21, 22*/

DROP TRIGGER IF EXISTS check_flagValutazione$$
CREATE TRIGGER check_flagValutazione
BEFORE INSERT ON VALUTAZIONE
FOR EACH ROW
BEGIN 
	DECLARE l_recTesto INTEGER;
	IF (NEW.Flag < 1 OR NEW.Flag > 2) THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Flag valutazion non valido non valido';
	END IF;
    
    	SET l_recTesto = (SELECT CHAR_LENGTH(NEW.RecensioneTesto));
	IF l_recTesto<10 OR l_recTesto>500 THEN
		SIGNAL SQLSTATE '45000'
        	SET MESSAGE_TEXT = 'Recensione testuale troppo corta/lunga';
	END IF;
END$$

/*Vincolo 23*/

DROP TRIGGER IF EXISTS controlla_lat$$
CREATE TRIGGER controlla_lat 
BEFORE INSERT ON CHILOMETRO
FOR EACH ROW 
BEGIN 
	IF (NEW.latitudine REGEXP '(N|S),([0-8][0-9]|90),([0-8][0-9]|90),([0-8][0-9]|90)' ) = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'dominio ingresso errato!';
	END IF; 
END$$

DROP TRIGGER IF EXISTS controlla_long$$
CREATE TRIGGER controlla_long 
BEFORE INSERT ON CHILOMETRO
FOR EACH ROW 
BEGIN 
	IF(NEW.longitudine REGEXP '(O|E),(0[0-9][0-9]|1[0-7][0-9]|180),(0[0-9][0-9]|1[0-7][0-9]|180),(0[0-9][0-9]|1[0-7][0-9]|180)') = 0 THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'dominio ingresso errato!';
	END IF;
END$$

/*Vincolo 26*/

DROP TRIGGER IF EXISTS aggiungiVariazioneOkPool$$
CREATE TRIGGER aggiungiVariazioneOkPool 
AFTER UPDATE ON PRENOTAZIONE
FOR EACH ROW 
BEGIN
	IF NEW.Esito = 'accettata' AND NEW.ConfermaUtente='si' THEN
		INSERT INTO PERCORRE(CodiceServizio, DataOraInizio, Targa, CodiceTragitto) 
		VALUES(2, NEW.DataOraInizio, NEW.Targa, NEW.CodiceTragitto);
	END IF;
END$$

/*Vincolo 6*/

DROP EVENT IF EXISTS calcolo_confort$$
CREATE EVENT calcolo_confort
ON SCHEDULE EVERY 6 HOUR
DO
BEGIN 
	DECLARE punteggio_posti INTEGER DEFAULT 0;
	DECLARE punteggio_vmax 	INTEGER DEFAULT 0;
	DECLARE Noptional INTEGER DEFAULT 0;
    	DECLARE AppTarga CHAR(7);
    	DECLARE AppPosti INT;
    	DECLARE AppVelocitaMax TINYINT;
	DECLARE val FLOAT;
   	DECLARE finito INT DEFAULT 0;
    
    	DECLARE cursore CURSOR FOR
    	SELECT Targa, Posti, VelocitaMax
    	FROM AUTOVETTURA
    	WHERE Comfort = 0;
    
    	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito=1;
    
    	scan: LOOP
		FETCH cursore INTO AppTarga, AppPosti, AppVelocitaMax;
        	IF finito = 1 THEN 
			LEAVE scan;
		END IF;
        
		SELECT COUNT(*) INTO Noptional 
		FROM DOTAZIONE D INNER JOIN AUTOVETTURA A ON A.Targa = D.Targa
		WHERE D.Targa = AppTarga
		GROUP BY D.Targa;
			
		CASE AppPosti
			WHEN 1 THEN SET punteggio_posti = 1;
			WHEN 2 THEN SET punteggio_posti = 2;
			WHEN 4 THEN SET punteggio_posti = 3;
			WHEN 5 THEN SET punteggio_posti = 4;
			ELSE SET punteggio_posti=5;
		END CASE;
		
		CASE AppVelocitaMax
			WHEN AppVelocitaMax < 100 
				THEN SET punteggio_vmax=1;
			WHEN AppVelocitaMax >=100 AND AppVelocitaMax <=130 
				THEN SET punteggio_vmax = 2;
			WHEN AppVelocitaMax >130 AND AppVelocitaMax <=150
				THEN SET punteggio_vmax = 3;
			WHEN AppVelocitaMax >150 AND AppVelocitaMax <=180
				THEN SET punteggio_vmax= 4;
			ELSE SET punteggio_vmax = 5;
		END CASE;
		
		UPDATE AUTOVETTURA SET Comfort = (5* Noptional + punteggio_posti + punteggio_vmax)/(2 + Noptional)
		WHERE Targa = AppTarga;
	END LOOP scan;
    CLOSE cursore;
END $$


