/*Operazione 5.2.1*/

CALL ricerca_carsharing('Merchedes-Benz', 4, '2018-11-27 09:00:00', '2018-11-27 11:00:00', 1);

/*Operazione 5.2.2*/
	
CALL ricerca_pool(5 , 6, 14, 11, 2, '2018-12-27 07:20:00');

/*Operazione 5.2.3*/

CALL ricerca_sharing('2018-11-23', 'Climatizzatore bizona', 3, 15, '-', 'bis');

/*Operazione 5.2.4*/

DELIMITER $$
DROP PROCEDURE IF EXISTS insetimento_all_in_one$$
CREATE PROCEDURE insetimento_all_in_one()
BEGIN
	DECLARE targa CHAR(7);
	DECLARE dataOraInizio DATETIME;
	DECLARE codS INTEGER;
    	SET targa = 'UP071OP';
    	SET dataOraInizio = '2018-12-30 07:00:00';

	
	CALL nuovo_utente(
     		'CI109', 'Carta Identità', 'Comune di Siracusa', '2023-12-21',
	 	'ProvaUtOp', 'PRVUTP38S25C533G', 'Mario', 'Rossi', '896-368-0788', 'yTVAAx6hD6', 'si', 'italiana', 'Via vicolo cieco', '96100', 'Siracusa', 'Cane', 'Che animale domestico hai?', 
	 	targa, 'Fiat', 'Tipo', 1500, 5, 2017, 0, 0.03, 60, 140, 6, 4.1, 5.85, 380, 200, 'Benzina', NULL, 
	 	'ABS', 'ESA', 'Dynamic Control',
	 	dataOraInizio, '2018-12-30 20:00:00', 5, 50000, 30, codS);

	SELECT codS, targa, dataOraInizio;
END$$
DELIMITER ;

CALL insetimento_all_in_one();

DELETE FROM CARSHARING WHERE CodiceServizio=1 AND
	Targa='UP071OP' AND 
	DataOraInizio='2018-12-30 07:00:00';
DELETE FROM PROPONENTE WHERE NomeUtenteP='ProvaUtOp';
DELETE FROM UTENTE WHERE NomeUtente='ProvaUtOp';
DELETE FROM DOCUMENTO WHERE NumeroD='CI109';
DELETE FROM OPTIONAL WHERE Codice=13;
DELETE FROM OPTIONAL WHERE Codice=14; 
DELETE FROM OPTIONAL WHERE Codice=15;
DELETE FROM DOTAZIONE WHERE Targa='UP071OP';
DELETE FROM AUTOVETTURA WHERE Targa='UP071OP';*/


/*Operazione 5.2.5*/

DELIMITER $$
DROP PROCEDURE IF EXISTS testMediaKmPool$$
CREATE PROCEDURE testMediaKmPool()
BEGIN 
	DECLARE media FLOAT;
    	SET media=mediaKmPool(2, 'PQ002AZ');
    	SELECT media;
END$$
DELIMITER ;

CALL testMediaKmPool();

/*Operazione 5.2.6*/

CALL nuovo_pool('2018-12-30 07:00:00', 'EE000HG', 2, '2018-12-30 20:00:00', 4, 'medio', 20.3, 10, 'N,21,22,10', 'E,022,023,010','N,11,12,15', 'E,012,013,015');
CALL popola_compones(5, 2, 10, 13);
CALL popola_compones(5, 1, 9, 5);

DELETE FROM COMPONES WHERE CodiceTragitto=5;
DELETE FROM TRAGITTO WHERE CodiceTragitto=5;
DELETE FROM CARPOOLING WHERE CodiceServizio=2 AND
	DataOraInizio='2018-12-30 07:00:00' AND 
        Targa='EE000HG';

/*Operazione 5.2.7*/

DELIMITER $$

DROP PROCEDURE IF EXISTS testMediaRecensioni$$
CREATE PROCEDURE testMediaRecensioni()
BEGIN
	DECLARE media FLOAT;
    	CALL media_recensioni('Fluminous', media);
    	SELECT media;
END$$

DELIMITER ;

CALL testMediaRecensioni();

/*Operazione 5.2.8*/

CALL find_ride_sharing2('2018-11-23 17:45:00','OttomAcracy',10,2,14,12);

CALL insert_call('Fuchsia', '2018-11-23 17:45:00', 'HG001PQ', 'N,21,22,10', 'N,51,52,16', 'E,022,023,010', 'E,055,056,016', 2,  5);

CALL modifica_stato(0, 3);


/*Ridondanza 5.3.8*/

DELIMITER $$
DROP PROCEDURE IF EXISTS testMediaKmPool2$$
CREATE PROCEDURE testMediaKmPool2()
BEGIN
	DECLARE media FLOAT;
	SET media=mediaKmPool2('PQ002AZ');
    	SELECT media;
END$$

CALL testMediaKmPool2()$$

/*Ridondanza 5.3.9*/

DROP PROCEDURE IF EXISTS testMediaRecTot2$$
CREATE PROCEDURE testMediaRecTot2()
BEGIN
	DECLARE media FLOAT;
	SET media=media_recensioni_totale('Arglebargle');
    	SELECT media;
END$$

CALL testMediaRecTot2()$$

DELIMITER ;
