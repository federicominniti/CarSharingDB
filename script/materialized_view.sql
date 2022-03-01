DELIMITER $$

DROP TABLE IF EXISTS mv_affidabilita_utente$$
CREATE TABLE mv_affidabilita_utente(
	NomeUtente VARCHAR (15) NOT NULL, 
    	GiudizioProp FLOAT NOT NULL, 
    	GiudizioFuit FLOAT NOT NULL,
    	PRIMARY KEY(NomeUtente)
)$$


CREATE EVENT aggiorna_aff_utente
ON SCHEDULE EVERY 3 DAY
DO
/*DROP PROCEDURE IF EXISTS aggiorna_aff_utente$$
CREATE PROCEDURE aggiorna_aff_utente()*/
BEGIN
	DECLARE utente VARCHAR(15) DEFAULT '';
	DECLARE punteggioF INT DEFAULT 0;
    	DECLARE numeroF INT DEFAULT 0;
	DECLARE punteggioP INT DEFAULT 0;
    	DECLARE numeroP INT DEFAULT 0;
    	DECLARE giudizioFruitore FLOAT DEFAULT 0;
	DECLARE giudizioProponente FLOAT DEFAULT 0;
    	DECLARE p1 VARCHAR (15);
    	DECLARE f1 VARCHAR (15);
    
    	DECLARE finito INT DEFAULT 0;
    
    	DECLARE cursore_prop CURSOR FOR 
    	SELECT *
	FROM PROPONENTE P LEFT OUTER JOIN FRUITORE F ON P.NomeUtenteP=F.NomeUtenteF
	UNION 
	SELECT * 
	FROM PROPONENTE P RIGHT OUTER JOIN FRUITORE F ON P.NomeUtenteP=F.NomeUtenteF;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito=1;
    
	OPEN cursore_prop;
	scan: LOOP
		FETCH cursore_prop INTO p1, punteggioP, numeroP, f1, punteggioF, numeroF;
		IF finito = 1 THEN
			LEAVE scan;
		END IF;
        	SET utente = "not valid";
		SET giudizioProponente=-1;
		SET giudizioFruitore=-1;
		IF p1 IS NOT NULL THEN
			BEGIN
				IF numeroP = 0 THEN
					SET giudizioProponente=-2;
				END IF;
                		SET utente = p1;
                		IF numeroP > 0 THEN
					SET giudizioProponente=punteggioP/(4*numeroP);
				END IF;
			END;
		END IF;
		IF f1 IS NOT NULL THEN
			BEGIN
				IF numeroF = 0 THEN
					SET giudizioFruitore=-2;
				END IF;
                		SET utente = f1;
                		IF numeroF > 0 THEN
					SET giudizioFruitore=punteggioF/(4*numeroF);
				END IF;
			END;
		END IF;
        	IF utente != "not valid" THEN
			INSERT INTO mv_affidabilita_utente VALUES (utente, giudizioProponente, giudizioFruitore);
		END IF;
	END LOOP scan;
	CLOSE cursore_prop;
END$$

/*8.2*/

DROP TABLE IF EXISTS mv_tempi_percorrenza$$
CREATE TABLE mv_tempi_percorrenza(
	id_mv INT AUTO_INCREMENT,
	idStrada INT,
	km1 INT NOT NULL, 
    	km2 INT NOT NULL, 
    	velocitaMedia FLOAT NOT NULL,
    	tempoMedioPercorrenza FLOAT NOT NULL,
    	numeroAuto INT NOT NULL,
    	lastUpdate TIMESTAMP NOT NULL,
    	PRIMARY KEY(id_mv)
)$$

CREATE TEMPORARY TABLE IF NOT EXISTS app_tempi_percorrenza(
	id_tt INT AUTO_INCREMENT,
	idStrada INT,
	km1 INT NOT NULL, 
    	km2 INT NOT NULL, 
    	velocitaMedia FLOAT NOT NULL,
    	tempoMedioPercorrenza FLOAT NOT NULL,
    	numeroAuto INT NOT NULL DEFAULT 0,
    	lastUpdate TIMESTAMP NOT NULL,
    	PRIMARY KEY(id_tt)
)$$

DROP TABLE IF EXISTS log_tempi_percorrenza$$
CREATE TABLE log_tempi_percorrenza LIKE TRACKING$$

DROP TRIGGER IF EXISTS aggiorna_log$$
CREATE TRIGGER aggiorna_log
AFTER INSERT ON TRACKING
FOR EACH ROW 
BEGIN
	INSERT INTO log_tempi_percorrenza(Targa, IdentificativoS, Latitudine, Longitudine, TimestampT) 
    	VALUES (NEW.Targa, NEW.IdentificativoS, NEW.Latitudine, NEW.Longitudine, NEW.TimestampT);
END$$

DROP PROCEDURE IF EXISTS inserisci_parziali_mv$$
CREATE PROCEDURE inserisci_parziali_mv(IN _identificativoS INT,
					IN _min_nKm INT, 
		     		        IN _prec_nKm INT, 
                                        IN _min_timestampT TIMESTAMP,
                                        IN _prec_timestampT TIMESTAMP)
BEGIN
	DECLARE v_media FLOAT;
    	DECLARE tempo_medio FLOAT;
    	DECLARE denom FLOAT;
    	IF TIMESTAMPDIFF(MINUTE, _min_timestampT, _prec_timestampT) != 0 THEN
		SET denom = TIMESTAMPDIFF(MINUTE, _min_timestampT, _prec_timestampT);
	ELSE
		SET denom = 2;
	END IF;
	SET v_media=ABS(_prec_nKm-_min_nKm)/(denom);
	SET tempo_medio=denom;
	INSERT INTO app_tempi_percorrenza(idStrada, km1, km2, velocitaMedia, tempoMedioPercorrenza, numeroAuto, lastUpdate) 
    	VALUES (_identificativoS, _min_nKm, _prec_nKm, v_media, tempo_medio, 0, current_timestamp());
END$$

DROP PROCEDURE IF EXISTS inserisci_dati_mv$$
CREATE PROCEDURE inserisci_dati_mv(IN _prec_idStrada INT,
			            IN _km_partenza INT, 
				    IN _km_arrivo INT, 
				    IN _somma_v_medie DOUBLE,
                                    IN _counter INT)
BEGIN
	DECLARE v_media FLOAT;
    	DECLARE tempo_medio FLOAT;
    
	SET v_media=_somma_v_medie/_counter;
    	IF v_media = 0 THEN
		SET tempo_medio = -1;
	ELSE
		SET tempo_medio=ABS(_km_partenza-_km_arrivo)/v_media;
	END IF;
	INSERT INTO mv_tempi_percorrenza(idStrada, km1, km2, velocitaMedia, tempoMedioPercorrenza, numeroAuto, lastUpdate) 
    	VALUES (_prec_idStrada, _km_partenza, _km_arrivo, v_media, tempo_medio, _counter, current_timestamp());
END$$

DROP PROCEDURE IF EXISTS compatta_mv$$
CREATE PROCEDURE compatta_mv()
BEGIN
	DECLARE mv_idStrada INT;
    	DECLARE mv_km1 INT;
    	DECLARE mv_km2 INT;
    	DECLARE mv_velocita_media FLOAT; 
    	DECLARE mv_tempo_medio_percorrenza FLOAT;
    	DECLARE mv_numero_auto INT;
    	DECLARE mv_timestamp_aggiornamento TIMESTAMP;
    
    	DECLARE prec_mv_idStrada INT DEFAULT 0;
    	DECLARE prec_mv_km1 INT;
    	DECLARE prec_mv_km2 INT;
    
    	DECLARE km_partenza INT;
    	DECLARE km_arrivo INT;

    	DECLARE somma_v_medie FLOAT;
    	DECLARE counter INT DEFAULT 0;
    
    	DECLARE v_media FLOAT;
   	DECLARE tempo_medio FLOAT;
    
    	DECLARE finito INT DEFAULT 0;
        
	DECLARE cursoreMV CURSOR FOR
    	SELECT DD.idStrada, DD.km1, DD.km2, DD.velocitaMedia, DD.tempoMedioPercorrenza, DD.numeroAuto, DD.lastUpdate
    	FROM (SELECT idStrada, km1, km2, velocitaMedia, tempoMedioPercorrenza, numeroAuto, lastUpdate 
		FROM app_tempi_percorrenza
		UNION ALL 
          	SELECT idStrada, km1, km2, velocitaMedia, tempoMedioPercorrenza, numeroAuto, lastUpdate 
          	FROM mv_tempi_percorrenza
        )AS DD
    	ORDER BY DD.idStrada ASC, (DD.km1-DD.km2) ASC;
	
	/*SENSI DI MARCIA
    	(DD.km1-DD.km2)
    	SE <0 1->2
    	SE >0 2->1*/

    	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    	OPEN cursoreMV;
    
    	TRUNCATE mv_tempi_percorrenza; 
    
    	scan: LOOP
        /*testare perche in caso la truncate non si possa eseguire qui perche i dati non salvati nel cursore sarà necessario 
        creare una tabella di appoggio*/
	FETCH cursoreMV INTO mv_idStrada, mv_km1, mv_km2, mv_velocita_media, mv_tempo_medio_percorrenza, 
							 mv_numero_auto, mv_timestamp_aggiornamento;
        IF finito = 1 AND prec_mv_idStrada!=0 THEN 
		BEGIN
			CALL inserisci_dati_mv(prec_mv_idStrada, km_partenza, km_arrivo, somma_v_medie, counter);
			LEAVE scan;
		END;
	END IF;
	IF mv_idStrada != prec_mv_idStrada OR (prec_mv_km1<prec_mv_km2 AND mv_km1>mv_km2) THEN 
		IF prec_mv_idStrada != 0 THEN
			CALL inserisci_dati_mv(prec_mv_idStrada, km_partenza, km_arrivo, somma_v_medie, counter);
		END IF;
		IF mv_km1-mv_km2 < 0 THEN
			BEGIN
				SET km_partenza=(SELECT MAX(nKm) FROM CHILOMETRO);
				SET km_arrivo=0;
			END;
		ELSE
			BEGIN
				SET km_partenza=0;
				SET km_arrivo=(SELECT MAX(nKm) FROM CHILOMETRO);
			END;
		END IF;
		SET counter=0;
		SET somma_v_medie=0;
	END IF;
	IF mv_km1-mv_km2 < 0 THEN
		BEGIN
			IF mv_km1 < km_partenza THEN
				SET km_partenza=mv_km1;
			END IF;
        	        IF mv_km2 > km_arrivo THEN
				SET km_arrivo=mv_km2;
			END IF;
		END;
	ELSE
		BEGIN
			IF mv_km1 > km_partenza THEN
				SET km_partenza=mv_km1;
			END IF;
               		IF mv_km2 < km_arrivo THEN
				SET km_arrivo=mv_km2;
			END IF;
		END;
	END IF;
	SET somma_v_medie=somma_v_medie+mv_velocita_media;
        SET counter=counter+1;
        SET prec_mv_idStrada=mv_idStrada;
        SET prec_mv_km1=mv_km1;
        SET prec_mv_km2=mv_km2;
    END LOOP scan;
END$$


DROP EVENT IF EXISTS aggiorna_mv_tempi_perc$$
CREATE EVENT aggiorna_mv_tempi_perc 
ON SCHEDULE EVERY 6 MINUTE
DO 
/*DROP PROCEDURE IF EXISTS aggiorna_mv_tempi_perc$$
CREATE PROCEDURE aggiorna_mv_tempi_perc()*/
BEGIN
	DECLARE targa CHAR(7);
	DECLARE identificativoS INT; 
    	DECLARE nKm INT;
	DECLARE timestampT TIMESTAMP;	
    
	DECLARE min_nKm INT;
	DECLARE min_timestampT TIMESTAMP;	
    
    	DECLARE prec_targa CHAR(7) DEFAULT '';
	DECLARE prec_identificativoS INT DEFAULT 0; 
    	DECLARE prec_nKm INT;
	DECLARE prec_timestampT TIMESTAMP;	
    
    	DECLARE v_media FLOAT;
    	DECLARE tempo_medio FLOAT;
	
    	DECLARE finito INT DEFAULT 0;
        
	DECLARE cursoreLog CURSOR FOR
    	SELECT ltp.Targa, ltp.IdentificativoS, C.nKm, ltp.TimestampT  
    	FROM log_tempi_percorrenza ltp INNER JOIN CHILOMETRO C
		ON ltp.Latitudine=C.Latitudine AND ltp.Longitudine=C.Longitudine AND ltp.IdentificativoS=C.IdentificativoS
    	ORDER BY ltp.Targa, ltp.TimestampT, ltp.IdentificativoS, C.nKm ASC;
        
    	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
	TRUNCATE TABLE app_tempi_percorrenza;
    
    	OPEN cursoreLog;
	
    	scan: LOOP
		FETCH cursoreLog INTO targa,identificativoS,nKm,timestampT;
        	IF finito = 1 AND prec_identificativoS != 0 THEN
			BEGIN
 	 			CALL inserisci_parziali_mv(prec_identificativoS, min_nKm, prec_nKm, min_timestampT, prec_timestampT);
				LEAVE scan;
			END;
		END IF;
        	IF targa != prec_targa THEN 
			BEGIN
				IF prec_targa!='' THEN
					CALL inserisci_parziali_mv(prec_identificativoS, min_nKm, prec_nKm, min_timestampT, prec_timestampT);
				END IF;
				SET min_nKm=nKm;
				SET min_timestampT=timestampT;
			END;
		/*Se un utente decide di fare un'inversione ad U oppure in seguto ad una rotonda riprende la stessa strada ma 
        	in verso opposto l'ordinamento dei km minimo e massimo non vale più perche ritornda indietro con numero di 
        	chilometraggio della strada ovviamente inverso e quindi si devide di registrare i due tratti di strada come "spezzate"
       		Che compongono il tragitto*/
		ELSEIF !(identificativoS = prec_identificativoS 
			     AND((prec_nKm >= min_nKm AND prec_nKm <= nKm)
					 OR
                     		 (nKm <= prec_nKm AND prec_nKm<= min_nKm))
			)
			THEN
				BEGIN
	 				CALL inserisci_parziali_mv(prec_identificativoS, min_nKm, prec_nKm, min_timestampT, prec_timestampT);
					SET min_nKm=nKm;
					SET min_timestampT=timestampT;
				END;
		END IF;
        
		SET prec_targa=targa;
		SET prec_identificativoS=identificativoS; 
		SET prec_nKm=nKm;
		SET prec_timestampT=timestampT;
	END LOOP scan;
    	CLOSE cursoreLog;
    
    	DELETE FROM mv_tempi_percorrenza WHERE TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP(),lastUpdate)>=3;
    
	CALL compatta_mv();
    
    	TRUNCATE TABLE log_tempi_percorrenza;
END$$

DELIMITER ;

SET GLOBAL event_scheduler = ON;
