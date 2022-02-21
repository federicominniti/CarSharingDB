drop database smartmobilitydb;

SET NAMES latin1;

BEGIN;
CREATE DATABASE IF NOT EXISTS `SmartMobilityDB`;
COMMIT;

USE `SmartMobilityDB`;	

DROP TABLE IF EXISTS DOCUMENTO;																														/*OK*/
CREATE TABLE DOCUMENTO(
	NumeroD 		VARCHAR(50) NOT NULL,
    TipologiaD 		VARCHAR(100) NOT NULL,
    EnteRilascioD 	VARCHAR(100) NOT NULL, 
    ScadenzaD 		DATE NOT NULL,
	PRIMARY KEY(NumeroD, TipologiaD)
);

/*OK*/
DROP TABLE IF EXISTS UTENTE;
CREATE TABLE UTENTE(
	NomeUtente 			VARCHAR (15) NOT NULL,
    codFiscale 			CHAR(16) NOT NULL,
    nome 				VARCHAR(100) NOT NULL,
    cognome 			VARCHAR(100) NOT NULL, 
    numeroTelefono 		VARCHAR(50) NOT NULL,
    dataIscrizione 		DATE NOT NULL,
    NumeroD 			VARCHAR(50) NOT NULL,
    tipologiaD 			VARCHAR(100) NOT NULL, 
    password 			VARCHAR(50) NOT NULL, 
    Attivita 			CHAR(2) NOT NULL, 
    nazionalita 		VARCHAR(50) NOT NULL, 
    via 				VARCHAR(100) NOT NULL, 
    cap 				VARCHAR(20) NOT NULL, 
    citta 				VARCHAR(100) NOT NULL, 
    rispostaRecup 		VARCHAR(100) NOT NULL,
    domandaRecup 		VARCHAR(100) NOT NULL,
    PRIMARY KEY(NomeUtente),
    CONSTRAINT fk_documento 
		FOREIGN KEY (NumeroD, tipologiaD)
        REFERENCES DOCUMENTO(NumeroD, TipologiaD)
        ON UPDATE CASCADE
        ON DELETE NO ACTION
);
																														/*OK*/
DROP TABLE IF EXISTS PROPONENTE;
CREATE TABLE PROPONENTE(
	NomeUtenteP 		VARCHAR(15) NOT NULL,
    PunteggioRecensioni FLOAT,
	NumeroRecensioni 	INT UNSIGNED,
	PRIMARY KEY(NomeUtenteP),
	FOREIGN KEY (NomeUtenteP) REFERENCES UTENTE(NomeUtente)
);
																														/*OK*/
DROP TABLE IF EXISTS FRUITORE;
CREATE TABLE FRUITORE(
	NomeUtenteF  		VARCHAR(15) NOT NULL,
    PunteggioRecensioni FLOAT,
	NumeroRecensioni 	INT UNSIGNED,
	PRIMARY KEY(NomeUtenteF),
	FOREIGN KEY (NomeUtenteF) REFERENCES UTENTE(NomeUtente)
);
																														/*OK*/
DROP TABLE IF EXISTS CARBURANTE;
CREATE TABLE CARBURANTE(
	TCarburante				ENUM('Benzina','Gasolio','Metano','GPL', 'Elettrico'),
	PrezzoCarburante		FLOAT,
	PRIMARY KEY(TCarburante)
);
																														/*OK*/
DROP TABLE IF EXISTS AUTOVETTURA;
CREATE TABLE AUTOVETTURA(
	Targa 					CHAR(7) NOT NULL,
	CasaProduttrice 		VARCHAR(20),
	Modello 				VARCHAR(20),
	Cilindrata 				SMALLINT(4) UNSIGNED,
	Posti 					TINYINT(2) UNSIGNED,
	AnnoImmatricolazione	YEAR(4),
	Comfort					TINYINT UNSIGNED,
	CostoUsuraKmPers		FLOAT,
	CapacitaSerbatoio		TINYINT(2) UNSIGNED,
	VelocitaMax				TINYINT UNSIGNED,
	CUrbano					FLOAT,
	CExtraUrbano			FLOAT,
	CMisto					FLOAT,
	Assicurazione			FLOAT,
	Bollo					FLOAT,
	Carburante1				ENUM('Benzina','Gasolio','Metano','GPL', 'Elettrico'),
	Carburante2				ENUM('Benzina','Gasolio','Metano','GPL', 'Elettrico'),
	NomeUtente				VARCHAR(15),
	NkmPercorsi				INT UNSIGNED,
	NPool					INT UNSIGNED,
	PRIMARY KEY(Targa),
	FOREIGN KEY(NomeUtente)	REFERENCES PROPONENTE(NomeUtenteP),
	FOREIGN KEY(Carburante1) REFERENCES CARBURANTE(TCarburante),
	FOREIGN KEY(Carburante2) REFERENCES CARBURANTE(TCarburante)
);
																														/*OK*/
DROP TABLE IF EXISTS OPTIONAL;
CREATE TABLE OPTIONAL(
	Codice			INT NOT NULL AUTO_INCREMENT,
	Descrizione		VARCHAR(50) NOT NULL,
	PRIMARY KEY(Codice)
);
																														/*OK*/
DROP TABLE IF EXISTS DOTAZIONE;
CREATE TABLE DOTAZIONE(
	CodiceOpt		INT NOT NULL,
	Targa			CHAR(7) NOT NULL,
	PRIMARY KEY(CodiceOpt,Targa),
	FOREIGN KEY(CodiceOpt) REFERENCES OPTIONAL(Codice),
	FOREIGN KEY(Targa) REFERENCES AUTOVETTURA(Targa)
);

DROP TABLE IF EXISTS VALUTAZIONE;
CREATE TABLE VALUTAZIONE(
	CodValutazione		INT NOT NULL AUTO_INCREMENT,
	DataOraInizioServ	TIMESTAMP NOT NULL,
	CodiceServizio		TINYINT UNSIGNED NOT NULL,
	Persona				TINYINT UNSIGNED NOT NULL,
	Comportamento		TINYINT UNSIGNED NOT NULL,
	Serieta				TINYINT UNSIGNED NOT NULL,
	PiacereViaggio		TINYINT UNSIGNED NOT NULL,
	RecensioneTesto		VARCHAR(500),
	Flag				TINYINT UNSIGNED,
	NomeUtenteP			VARCHAR(15),
	NomeUtenteF			VARCHAR(15),
	PRIMARY KEY(CodValutazione),
	FOREIGN KEY(NomeUtenteP) REFERENCES PROPONENTE(NomeUtenteP),
	FOREIGN KEY(NomeUtenteF) REFERENCES FRUITORE(NomeUtenteF)
);
																														/*OK*/
DROP TABLE IF EXISTS CARSHARING;
CREATE TABLE CARSHARING(
	CodiceServizio		CHAR(1) DEFAULT '1',
	DataOraInizio		DATETIME NOT NULL,
	Targa				CHAR(7) NOT NULL,
	DataOraFine			DATETIME,
	CostoOrario			FLOAT NOT NULL,
	KmAuto				INTEGER UNSIGNED,
	Carburante			TINYINT UNSIGNED,
	PRIMARY KEY(CodiceServizio,DataOraInizio,Targa),
	FOREIGN KEY (Targa) REFERENCES AUTOVETTURA(Targa)
);
																														/*OK*/
DROP TABLE IF EXISTS RICHIESTA;
CREATE TABLE RICHIESTA(
	CodiceRichiesta INT NOT NULL AUTO_INCREMENT,
	CodiceServizio	CHAR(1) DEFAULT '1',
	DataOraInizio	DATETIME NOT NULL,
	Targa			CHAR(7) NOT NULL,
	NomeUtenteF		VARCHAR(15) NOT NULL,
	DataOraFine		DATETIME,
	Esito			CHAR(15) NOT NULL,
	CarburanteFine	TINYINT UNSIGNED,
    PRIMARY KEY (CodiceRichiesta),
    CONSTRAINT fk_richiesta
		FOREIGN KEY (CodiceServizio,DataOraInizio,Targa)
        REFERENCES CARSHARING(CodiceServizio,DataOraInizio,Targa)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
																														/*OK*/
DROP TABLE IF EXISTS VEICOLICOINVOLTI;
CREATE TABLE VEICOLICOINVOLTI(
	TargaVeicolo 	CHAR(7) NOT NULL, 
    CasaAutVeicolo 	CHAR(50), 
    ModelloVeicolo 	CHAR(50),
    PRIMARY KEY (TargaVeicolo)
);
																														/*OK*/
DROP TABLE IF EXISTS SINISTRO;
CREATE TABLE SINISTRO(
	CodiceSinistro 	INT NOT NULL AUTO_INCREMENT, 
    CodiceServizio 	CHAR(1) DEFAULT '1', 
    DataOraInizio 	DATETIME NOT NULL, 
    Targa 			CHAR(7) NOT NULL, 
    TargaVeicoloS 	CHAR(7) NOT NULL, 
    NomeUtenteF 	VARCHAR(15) NOT NULL, 
    Dinamica 		CHAR(100), 
    TimeStamp1 		TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (CodiceSinistro),
    CONSTRAINT fk_sinistro
		FOREIGN KEY (CodiceServizio,DataOraInizio,Targa)
        REFERENCES CARSHARING(CodiceServizio,DataOraInizio,Targa)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
	FOREIGN KEY (TargaVeicoloS) REFERENCES VEICOLICOINVOLTI(TargaVeicolo)
);
																														/*OK*/
DROP TABLE IF EXISTS CARPOOLING;
CREATE TABLE CARPOOLING(
	CodiceServizio 				CHAR(1) DEFAULT '2', 
    DataOraInizio 				DATETIME NOT NULL, 
    Targa 						CHAR(7) NOT NULL, 
    IdentificativoPool 			VARCHAR(10), 
    DataArrivo		 			DATE NOT NULL, 
    PostiOccupati				TINYINT UNSIGNED NOT NULL, 
    GradoFlessibilita 			CHAR(5) NOT NULL, 
    PercentualeVariazioneCosto 	FLOAT NOT NULL, 
    CostoAPersona 				FLOAT NOT NULL,
    PRIMARY KEY (CodiceServizio, DataOraInizio, Targa),
    FOREIGN KEY (Targa) REFERENCES AUTOVETTURA(Targa)
);
																														/*OK*/
DROP TABLE IF EXISTS STRADA;
CREATE TABLE STRADA(
	IdentificativoS		INT NOT NULL AUTO_INCREMENT, 
	Nome 				CHAR(100) NOT NULL, 
	Tipologia 			CHAR(2),
	PRIMARY KEY(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS CHILOMETRO;
CREATE TABLE CHILOMETRO(
	IdentificativoS 	INT NOT NULL, 
	Latitudine 			CHAR(20) NOT NULL, 
	Longitudine 		CHAR(20) NOT NULL, 
	LimiteVelocita 		INT NOT NULL, 
	nKm 				INT NOT NULL,
	PRIMARY KEY (IdentificativoS, Latitudine, Longitudine),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS TRAGITTO;
CREATE TABLE TRAGITTO(
	CodiceTragitto 		INT NOT NULL AUTO_INCREMENT, 
	KmInizioT 			INT NOT NULL, 
	KmFineT 			INT NOT NULL, 
	IdentificativoSP 	INT NOT NULL, 
	IdentificativoSA 	INT NOT NULL,
	PRIMARY KEY (CodiceTragitto),
	FOREIGN KEY (IdentificativoSP) REFERENCES STRADA(IdentificativoS),
	FOREIGN KEY (IdentificativoSA) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS PERCORRE;
CREATE TABLE PERCORRE(
	CodicePercorrenzaPool 	INT NOT NULL AUTO_INCREMENT, 
	CodiceServizio 			CHAR(1) DEFAULT '2' , 
	DataOraInizio			DATETIME NOT NULL, 
	Targa					CHAR(7) NOT NULL, 
	CodiceTragitto			INT NOT NULL,
	PRIMARY KEY (CodicePercorrenzaPool),
	CONSTRAINT fk_percorre
			FOREIGN KEY (CodiceServizio,DataOraInizio,Targa)
			REFERENCES CARPOOLING(CodiceServizio,DataOraInizio,Targa)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	FOREIGN KEY (CodiceTragitto) REFERENCES TRAGITTO(CodiceTragitto)
);
																														/*OK*/
DROP TABLE IF EXISTS PRENOTAZIONE;
CREATE TABLE PRENOTAZIONE(
	CodicePrenotazionePool	INT NOT NULL AUTO_INCREMENT, 
	CodiceServizio			CHAR(1) DEFAULT '2', 
	DataOraInizio			DATETIME NOT NULL, 
	Targa					CHAR(7) NOT NULL,
	NomeUtenteF				CHAR(15) NOT NULL, 
	CodiceTragitto			INT,
	Esito					CHAR(20), 
	ConfermaUtente			CHAR(20),
	PRIMARY KEY (CodicePrenotazionePool),
	FOREIGN KEY (CodiceTragitto) REFERENCES TRAGITTO(CodiceTragitto),
	FOREIGN KEY (NomeUtenteF) REFERENCES FRUITORE(NomeUtenteF),
	CONSTRAINT fk_prenotazione
			FOREIGN KEY (CodiceServizio,DataOraInizio,Targa)
			REFERENCES CARPOOLING(CodiceServizio,DataOraInizio,Targa)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION
);
																														/*OK*/
DROP TABLE IF EXISTS RIDESHARING;
CREATE TABLE RIDESHARING(
	CodiceServizio 	CHAR(1) DEFAULT '3', 
	DataOraInizio 	DATETIME NOT NULL, 
	Targa 			CHAR(7) NOT NULL, 
	PrezzoAlKm 		FLOAT NOT NULL,
	CodiceTragitto 	INT NOT NULL,
	PRIMARY KEY (CodiceServizio, DataOraInizio, Targa),
	FOREIGN KEY (CodiceTragitto) REFERENCES TRAGITTO(CodiceTragitto)
);
																														/*OK*/
DROP TABLE IF EXISTS CHIAMATA;
CREATE TABLE CHIAMATA(
	Codice 				INT NOT NULL AUTO_INCREMENT, 
	CodiceServizio 		CHAR(1) DEFAULT '3', 
	DataOraInizio 		DATETIME NOT NULL, 
	NomeUtenteF 		CHAR(15) NOT NULL, 
	Targa 				CHAR(7) NOT NULL, 
	LatitudineP 		CHAR(20) NOT NULL, 
	LongitudineP 		CHAR(20) NOT NULL, 
	IdentificativoSP 	INT NOT NULL, 
	LatitudineA 		CHAR(20) NOT NULL, 
	LongitudineA 		CHAR(20) NOT NULL, 
	IdentificativoSA 	INT NOT NULL, 
	TimestampChiamata 	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	Stato 				CHAR(20) DEFAULT 'pending', 
	TimestampRisposta 	DATETIME, 
	TimestampArrivo 	DATETIME,
	PRIMARY KEY (Codice),
	CONSTRAINT fk_ridesh
			FOREIGN KEY (CodiceServizio,DataOraInizio,Targa)
			REFERENCES RIDESHARING(CodiceServizio,DataOraInizio,Targa)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	CONSTRAINT fk_km
			FOREIGN KEY (IdentificativoSP,LatitudineP,LongitudineP)
			REFERENCES CHILOMETRO(IdentificativoS,Latitudine,Longitudine)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	CONSTRAINT fk_km1
			FOREIGN KEY (IdentificativoSA,LatitudineA,LongitudineA)
			REFERENCES CHILOMETRO(IdentificativoS,Latitudine,Longitudine)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	FOREIGN KEY (NomeUtenteF) REFERENCES FRUITORE(NomeUtenteF)
);
																														/*OK*/
DROP TABLE IF EXISTS COMPONES;
CREATE TABLE COMPONES(
	CodiceTragitto 	INT NOT NULL, 
	IdentificativoS INT NOT NULL, 
	KmInizioStrada 	INT NOT NULL, 
	KmFineStrada 	INT NOT NULL,
	PRIMARY KEY (CodiceTragitto, IdentificativoS),
	FOREIGN KEY (CodiceTragitto) REFERENCES TRAGITTO(CodiceTragitto),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS IDENTIFICATORESTRADA;
CREATE TABLE IDENTIFICATORESTRADA(
	Identificatore 	INT NOT NULL AUTO_INCREMENT, 
	Numero			INT NOT NULL, 
	Cat				CHAR(4), 
	Suffisso		CHAR(6),
	PRIMARY KEY (Identificatore)
);
																														/*OK*/
DROP TABLE IF EXISTS IDENTIFICA;
CREATE TABLE IDENTIFICA(
	Identificatore	INT NOT NULL,
	IdentificativoS INT NOT NULL,
	PRIMARY KEY (Identificatore,IdentificativoS),
	FOREIGN KEY (Identificatore) REFERENCES IDENTIFICATORESTRADA(Identificatore),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS CARREGGIATA;
CREATE TABLE CARREGGIATA(
	CodiceCarr		INT NOT NULL AUTO_INCREMENT, 
	NCarreggiata	INT NOT NULL, 
	NCorsie			INT NOT NULL, 
	SensiMarcia		INT NOT NULL,
	PRIMARY KEY(CodiceCarr)
);
																														/*OK*/
DROP TABLE IF EXISTS POSSIEDE;
CREATE TABLE POSSIEDE(
	IdentificativoS	INT NOT NULL, 
	CodiceCarr 		INT NOT NULL,
	PRIMARY KEY (IdentificativoS,CodiceCarr),
	FOREIGN KEY (CodiceCarr) REFERENCES CARREGGIATA(CodiceCarr),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS AUTOSTRADA;
CREATE TABLE AUTOSTRADA(
	IdentificativoS	INT NOT NULL,
	PRIMARY KEY (IdentificativoS),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS PEDAGGIO;
CREATE TABLE PEDAGGIO(
	IdentificativoS	INT NOT NULL, 
	KmInizio		INT NOT NULL,
	Costoxkm		FLOAT NOT NULL,
	PRIMARY KEY (IdentificativoS,KmInizio),
	FOREIGN KEY (IdentificativoS) REFERENCES AUTOSTRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS URBANA;
CREATE TABLE URBANA(
	IdentificativoS	INT NOT NULL,
	PRIMARY KEY (IdentificativoS),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS EXTRAURBANA;
CREATE TABLE EXTRAURBANA(
	IdentificativoS	INT NOT NULL, 
	Tipo			CHAR(12) NOT NULL, 
	kmCorsia		INT NOT NULL,
	PRIMARY KEY (IdentificativoS),
	FOREIGN KEY (IdentificativoS) REFERENCES STRADA(IdentificativoS)
);
																														/*OK*/
DROP TABLE IF EXISTS INCROCIO;
CREATE TABLE INCROCIO(
	CodiceIncrocio	INT NOT NULL AUTO_INCREMENT, 
	Identificativo1	INT NOT NULL, 
	Latitudine1		CHAR(20) NOT NULL,
	Longitudine1	CHAR(20) NOT NULL, 
	Identificativo2	INT NOT NULL, 
	Latitudine2		CHAR(20) NOT NULL, 
	Longitudine2	CHAR(20) NOT NULL,
	PRIMARY KEY (CodiceIncrocio),
	CONSTRAINT fk_kmI1
			FOREIGN KEY (Identificativo1,Latitudine1,Longitudine1)
			REFERENCES CHILOMETRO(IdentificativoS,Latitudine,Longitudine)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	CONSTRAINT fk_kmI2
			FOREIGN KEY (Identificativo2,Latitudine2,Longitudine2)
			REFERENCES CHILOMETRO(IdentificativoS,Latitudine,Longitudine)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION
);

DROP TABLE IF EXISTS TRACKING;
CREATE TABLE TRACKING(
	IdTrack			INT NOT NULL AUTO_INCREMENT,
	Targa			CHAR(7) NOT NULL,
	IdentificativoS	INT NOT NULL, 
	Latitudine		CHAR(20) NOT NULL, 
	Longitudine		CHAR(20) NOT NULL,
	TimestampT		TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (IdTrack),
	CONSTRAINT fk_kmTrk
			FOREIGN KEY (IdentificativoS,Latitudine,Longitudine)
			REFERENCES CHILOMETRO(IdentificativoS,Latitudine,Longitudine)
			ON UPDATE NO ACTION
			ON DELETE NO ACTION,
	FOREIGN KEY (Targa) REFERENCES AUTOVETTURA(Targa)
);

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
    
    IF (NEW.GradoFlessibilita != "alto" AND NEW.GradoFlessibilita != "medio" AND NEW.GradoFlessibilita != "basso")
       THEN
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
    
    IF (NEW.CodiceServizio<1 OR NEW.CodiceServizio>3)
       THEN
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
	IF (carburante_inizio<NEW.CarburanteFine-5)
       THEN
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
	IF (NEW.Esito != "pending" AND NEW.Esito != "accepted" AND NEW.Esito != "rejected")
       THEN
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
	IF (NEW.Cat != "dir" AND NEW.Cat != "var" AND NEW.Cat != "racc" AND  NEW.Cat != "radd" AND NEW.Cat!= "-")
       THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Categorizzazione non valida';
	END IF;
    
    IF (NEW.Suffisso != "bis" AND NEW.Suffisso != "ter" AND  NEW.Suffisso != "quater")
       THEN
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
	IF (NEW.SensiMarcia<1 OR  NEW.SensiMarcia>2)
       THEN
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
	IF (NEW.Flag < 1 OR NEW.Flag > 2)
       THEN
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
		IF 	(NEW.longitudine REGEXP	'(O|E),(0[0-9][0-9]|1[0-7][0-9]|180),(0[0-9][0-9]|1[0-7][0-9]|180),(0[0-9][0-9]|1[0-7][0-9]|180)') = 0 THEN 
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
			ELSE	SET punteggio_posti=5;
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
          dataOraP=CP.DataOraInizio AND
          CP.GradoFlessibilita='alto' AND
          CP.CodiceServizio=codS AND
          CURRENT_TIMESTAMP()<=CP.DataOraInizio-HOUR(48) AND
          (A.Posti-CP.PostiOccupati)> (SELECT COUNT(*)
									   FROM PRENOTAZIONE PREN
                                       WHERE PREN.CodiceServizio=codS AND
											 PREN.DataOraInizio=dataOraP AND
                                             PREN.Targa=CP.Targa)
	GROUP BY auto, inizio,codS ;
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
	SELECT RS.PrezzoAlKm, T.*
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
								 IN _velocitaMax TINYINT UNSIGNED,
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
	
    INSERT INTO AUTOVETTURA(Targa, CasaProduttrice,	Modello, Cilindrata, Posti, AnnoImmatricolazione, Comfort, 
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
CREATE PROCEDURE  nuovo_pool(	IN _dataOra DATETIME, 
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
								IN _longArrivo CHAR(20)
							)						
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
CREATE PROCEDURE  find_ride_sharing2( 	IN _dataOra DATETIME, 
										IN _nomeFruitore VARCHAR(15), 
										IN _kmStradaP INT ,  
										IN _IDStradaPartenza INT, 
										IN _kmStradaA INT, 
										IN _IDStradaArrivo INT
									)
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
			if(result) then SELECT B as CodiceServizio,C as DataOraInizio,D as Targa;
				END IF;
		END IF;
	END LOOP leggi;
	CLOSE Cursore1;
END$$

DROP PROCEDURE IF EXISTS verificaVerso$$
CREATE PROCEDURE verificaVerso( 
								IN codTragitto integer,
								IN _kmP INT ,  
								IN _IDSP INT, 
								IN _kmA INT, 
								IN _IDSA INT, 
								INOUT ok boolean
								)
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
							IF(IDStrada_temp = _IDSP AND _kmP <= kmInizioStrada_temp AND _kmP >= kmFineStrada_temp)
								THEN SET 	trovatoP = TRUE;
									LEAVE cercaPartenza;
							END IF;
					ELSE
							IF(IDStrada_temp = _IDSP AND _kmP >= kmInizioStrada_temp AND _kmP <= kmFineStrada_temp)
								THEN SET trovatoP = TRUE;
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
						IF(IDStrada_temp = _IDSA AND _kmA <= kmInizioStrada_temp AND _kmA >= kmFineStrada_temp)
							THEN SET 	trovatoA = TRUE;
								LEAVE cercaArrivo;
						END IF;
				ELSE
						IF(IDStrada_temp = _IDSA AND _kmA >= kmInizioStrada_temp AND _kmA <= kmFineStrada_temp)
							THEN SET 	trovatoA = TRUE;
                                LEAVE cercaArrivo;
						END IF;
				END IF;
			END IF;
		END LOOP cercaArrivo;
		CLOSE cursore2;
		IF(trovatoA AND trovatoP AND (trovatoArrivo > trovatoPartenza))
			THEN SET ok = TRUE;
		END IF;
END$$				

/*per ogni codtrag vedo se transita dalle due strada date*/
 /*devo trovare 2 record, uno per la strada partenza, uno per la strada arrivo e dato che la chiave di 
compones è data  dal codTragitto_ e il nkm se ne trovo due quei due sono per forza delle due strada date in ingresso*/

/*-------------------------------------------------------------------*/
/*---------------- procedure 2, inserimento chiamata ----------------*/
/*-------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS insert_call$$
CREATE PROCEDURE insert_call	(
											IN _nomeUtenteF VARCHAR(15),
											IN _dataOra DATETIME,
											IN _Targa VARCHAR(7),
											IN _LatP CHAR(20),
											IN _LatA CHAR(20),
											IN _LongP CHAR(20),
											IN _LongA CHAR(20),
											IN _IdSP INT,
											IN _IdSA INT
								)
BEGIN						
		INSERT INTO 
        CHIAMATA(DataOraInizio, NomeUtenteF, Targa, LatitudineP, LongitudineP, IdentificativoSP, LatitudineA, LongitudineA, IdentificativoSA, Stato) 
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





/*5.3.8*/

DROP FUNCTION IF EXISTS mediaKmPool2$$
CREATE FUNCTION mediaKmPool2(_targa CHAR(7))
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE media FLOAT;
    SET media = (SELECT NkmPercorsi/NPool
				 FROM AUTOVETTURA A
				 WHERE A.Targa=_targa);
	RETURN(media);
END$$

DROP TRIGGER IF EXISTS aggiornaNPool$$
CREATE TRIGGER aggiornaNPool
AFTER INSERT ON CARPOOLING 
FOR EACH ROW
BEGIN
	UPDATE AUTOVETTURA SET NPool=NPool+1 WHERE Targa=NEW.Targa;
END$$

DROP TRIGGER IF EXISTS aggiornaKmPool$$
CREATE TRIGGER aggiornaKmPool
AFTER INSERT ON PERCORRE 
FOR EACH ROW
BEGIN
	DECLARE nKm INT;
    SET nKm=kmTragitto(NEW.CodiceTragitto);
    UPDATE AUTOVETTURA SET NkmPercorsi=NkmPercorsi+nKm WHERE Targa=NEW.Targa;
END$$

/*5.3.9*/

DROP FUNCTION IF EXISTS media_recensioni_totale$$
CREATE FUNCTION media_recensioni_totale(_utente VARCHAR (15))
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE appPunteggio INT DEFAULT 0;
    DECLARE appNRecensioni INT DEFAULT 0;
    DECLARE nRecensioni INT DEFAULT 0;
	DECLARE media FLOAT DEFAULT 0;
    
	SELECT PunteggioRecensioni, NumeroRecensioni INTO appPunteggio, appNRecensioni
	FROM PROPONENTE P
	WHERE P.NomeUtenteP=_utente;
    
    SET nRecensioni = nRecensioni + appNRecensioni;
    SET media = media + appPunteggio;
    
    SET appNRecensioni=0;
    SET appPunteggio=0;
    
    SELECT PunteggioRecensioni, NumeroRecensioni INTO appPunteggio, appNRecensioni
	FROM FRUITORE F
	WHERE F.NomeUtenteF=_utente;
    
    SET nRecensioni = nRecensioni + appNRecensioni;
    SET media = media + appPunteggio;
    
    IF nRecensioni != 0 THEN
		SET media = media/(nRecensioni*4);
	ELSE
		SET media = -1;
    END IF;
    
    RETURN(media);
END$$

DROP TRIGGER IF EXISTS aggiorna_punteggi_utenti$$
CREATE TRIGGER aggiorna_punteggi_utenti
AFTER INSERT ON VALUTAZIONE 
FOR EACH ROW
BEGIN
    IF NEW.Flag = 1 THEN
		UPDATE FRUITORE SET PunteggioRecensioni=PunteggioRecensioni+NEW.Persona+NEW.Comportamento+NEW.Serieta+NEW.PiacereViaggio,
							NumeroRecensioni = NumeroRecensioni + 1
        WHERE NomeUtenteF=NEW.NomeUtenteF;
	ELSE
		UPDATE PROPONENTE SET PunteggioRecensioni=PunteggioRecensioni+NEW.Persona+NEW.Comportamento+NEW.Serieta+NEW.PiacereViaggio,
							  NumeroRecensioni = NumeroRecensioni + 1
        WHERE NomeUtenteP=NEW.NomeUtenteP;
	END IF;
END$$



/*8.1*/

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
		SET denom = 1;
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
