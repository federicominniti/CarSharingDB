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
    PostiOccupati	 			TINYINT UNSIGNED NOT NULL, 
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
