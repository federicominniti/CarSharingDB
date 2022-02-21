DELIMITER $$

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