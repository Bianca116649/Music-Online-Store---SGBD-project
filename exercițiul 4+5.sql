--exercitiul 4
--secvențe utilizate în inserările înregistrărilor în tabele

CREATE SEQUENCE DEPOZIT_SEQ START WITH 1;
CREATE SEQUENCE FURNIZOR_SEQ START WITH 1;
CREATE SEQUENCE CAMPANIE_SEQ START WITH 1;
CREATE SEQUENCE PRODUS_SEQ START WITH 1;
CREATE SEQUENCE ARTIST_SEQ START WITH 1;
CREATE SEQUENCE COMANDA_SEQ START WITH 1;
CREATE SEQUENCE CATEGORIE_SEQ START WITH 1;
CREATE SEQUENCE CLIENT_SEQ START WITH 1;
CREATE SEQUENCE RECENZIE_SEQ START WITH 1;
CREATE SEQUENCE ADRESA_SEQ START WITH 1;
CREATE SEQUENCE LIVRARE_SEQ START WITH 1;

--crearea tabelelor

CREATE TABLE DEPOZIT(
    depozit_id NUMBER DEFAULT DEPOZIT_SEQ.nextval PRIMARY KEY,
    denumire VARCHAR2(255),
    contact VARCHAR2(255)
);

CREATE TABLE FURNIZOR(
    furnizor_id NUMBER DEFAULT FURNIZOR_SEQ.nextval PRIMARY KEY,
    denumire VARCHAR2(255),
    cod_fiscal VARCHAR2(50),
    email VARCHAR2(255),
    cont_iban VARCHAR2(255)
);

CREATE TABLE CATEGORIE (
    categorie_id NUMBER DEFAULT CATEGORIE_SEQ.NEXTVAL PRIMARY KEY,
    nume_categorie VARCHAR2(255),
    descriere VARCHAR2(1000)
);

CREATE TABLE PRODUS(
    produs_id NUMBER DEFAULT PRODUS_SEQ.nextval PRIMARY KEY,
    denumire VARCHAR2(255),
    pret_lista NUMBER(10,2),
    stoc_curent INT,
    data_adaugare DATE DEFAULT SYSDATE,
    categorie_id NUMBER,
    CONSTRAINT fk_produs_categorie
        FOREIGN KEY (categorie_id)
        REFERENCES CATEGORIE(categorie_id)
);

CREATE TABLE APROVIZIONARE(
    produs_id NUMBER,
    furnizor_id NUMBER,
    depozit_id NUMBER,
    cantitate NUMBER NOT NULL,
    pret_achizitie NUMBER(12, 2) NOT NULL,
    data_aprovizionare DATE DEFAULT SYSDATE,

    PRIMARY KEY (produs_id, furnizor_id, depozit_id, data_aprovizionare),
    CONSTRAINT fk_aprovizionare_produs FOREIGN KEY (produs_id) REFERENCES PRODUS(produs_id),
    CONSTRAINT fk_aprovizionare_furnizor FOREIGN KEY (furnizor_id) REFERENCES FURNIZOR(furnizor_id),
    CONSTRAINT fk_aprovizionare_depozit FOREIGN KEY (depozit_id) REFERENCES DEPOZIT(depozit_id)
);

CREATE TABLE CAMPANIE(
    campanie_id NUMBER DEFAULT CAMPANIE_SEQ.nextval PRIMARY KEY,
    nume_campanie VARCHAR2(255),
    data_inceput DATE DEFAULT SYSDATE,
    data_sfarsit DATE DEFAULT SYSDATE,
    reducere_standard DECIMAL(4,2)
);

CREATE TABLE PRODUS_CAMPANIE(
    campanie_id NUMBER,
    produs_id NUMBER,
    reducere_speciala DECIMAL(4,2),
    PRIMARY KEY (campanie_id, produs_id),
    CONSTRAINT fk_pc_campanie FOREIGN KEY (campanie_id) REFERENCES CAMPANIE(campanie_id),
    CONSTRAINT fk_pc_produs FOREIGN KEY (produs_id) REFERENCES PRODUS(produs_id)
);

CREATE TABLE ARTIST(
    artist_id INT DEFAULT ARTIST_SEQ.nextval PRIMARY KEY,
    nume VARCHAR2(255),
    prenume VARCHAR2(255),
    pseudonim VARCHAR2(255),
    data_debut DATE DEFAULT SYSDATE
);

CREATE TABLE PRODUS_ARTIST(
    produs_id NUMBER,
    artist_id NUMBER,
    rol_artist VARCHAR2(20),
    PRIMARY KEY (produs_id, artist_id),
    CONSTRAINT fk_pa_produs FOREIGN KEY (produs_id) REFERENCES PRODUS(produs_id),
    CONSTRAINT fk_pa_artist FOREIGN KEY (artist_id) REFERENCES ARTIST(artist_id)
);

CREATE TABLE CLIENT(
    client_id NUMBER DEFAULT CLIENT_SEQ.nextval PRIMARY KEY,
    nume VARCHAR2(255),
    prenume VARCHAR2(255),
    email VARCHAR2(255),
    telefon VARCHAR2(20),
    data_inregistrare DATE DEFAULT SYSDATE
);

CREATE TABLE ADRESA(
    adresa_id INT DEFAULT ADRESA_SEQ.nextval PRIMARY KEY,
    client_id NUMBER NOT NULL,
    cod_postal VARCHAR2(255),
    CONSTRAINT fk_adresa_client FOREIGN KEY (client_id) REFERENCES CLIENT(client_id)
);

CREATE TABLE COMANDA(
    comanda_id INT DEFAULT COMANDA_SEQ.nextval PRIMARY KEY,
    client_id NUMBER NOT NULL,
    adresa_id NUMBER NOT NULL,
    data_comanda DATE DEFAULT SYSDATE,
    status_comanda VARCHAR2(255),
    valoare_totala DECIMAL(10,2),
    CONSTRAINT fk_client_comanda FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_adresa_comanda FOREIGN KEY (adresa_id) REFERENCES ADRESA(adresa_id)

);

CREATE TABLE LIVRARE(
    livrare_id NUMBER DEFAULT LIVRARE_SEQ.nextval PRIMARY KEY,
    comanda_id NUMBER NOT NULL,
    numar_awb VARCHAR2(50),
    data_estimata DATE,
    CONSTRAINT fk_livrare_comanda FOREIGN KEY (comanda_id) REFERENCES COMANDA(comanda_id),
    CONSTRAINT uq_livrare_comanda UNIQUE (comanda_id)
);

CREATE TABLE RECENZIE(
    recenzie_id INT DEFAULT RECENZIE_SEQ.nextval PRIMARY KEY,
    client_id NUMBER NOT NULL,
    produs_id NUMBER NOT NULL,
    rating NUMBER(1),
    comentariu VARCHAR2(255),
    data_recenzie DATE,
    CONSTRAINT ck_rating_valid CHECK ( rating >=1 AND rating <=5),
    CONSTRAINT fk_client_rec FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
    CONSTRAINT fk_produs_rec FOREIGN KEY (produs_id) REFERENCES PRODUS(produs_id)
);

CREATE TABLE DETALII_COMANDA(
    comanda_id NUMBER NOT NULL,
    produs_id NUMBER NOT NULL,
    cantitate NUMBER NOT NULL,
    pret_istoric NUMBER(10,2) NOT NULL,
    CONSTRAINT pk_d_c PRIMARY KEY (comanda_id, produs_id),
    CONSTRAINT fk_d_c_comanda FOREIGN KEY (comanda_id) REFERENCES COMANDA(comanda_id),
    CONSTRAINT fk_d_c_produs FOREIGN KEY (produs_id) REFERENCES PRODUS (produs_id),
    CONSTRAINT ck_cantitate_pozitiva CHECK ( cantitate>0 )
);


--5. Adăugare informații

INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Vinyl LP', 'Discuri de vinil 12 inch, Long PLay');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('CD Audio', 'Compact Discuri originale, ediții standard și deluxe');
INSERT INTO CATEGORIE(NUME_CATEGORIE, DESCRIERE) VALUES ('Hanorace', 'Îmbrăcăminte cu logo-uri de trupe și licență');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Postere', 'Postere de diferite dimensiuni, cu semnături originale');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Casete Audio', 'Format retro MC pentru colecționari nostalgici');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Box Sets', 'Pachete speciale cu discografie completă și bonusuri');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Accesorii Audio', 'Căști, ace de pick-up, soluții de curățat vinilul');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Instrumente', 'O mică colecție de chitare, vioare, tobe, basuri și clarinete');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Reviste & Cărți', 'Biografii artiști și reviste de specialitate muzicală');
INSERT INTO CATEGORIE(nume_categorie, descriere) VALUES ('Pick-up & Turntables', 'Echipamente hardware pentru redare viniluri');

SELECT * FROM CATEGORIE;

INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit Central București Sector 6', '0722112345');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Hub Logistic Cluj', '0732658940');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit Timișoara', '0746910000');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit Iași', '0711112222');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Music depozit Brașov', '0788885555');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Hub Craiova', '0722226665');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit central Sibiu', '0755523145');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit Str. Primăverii Sibiu', '0756245321');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit Pitești Str. Craiovei', '0752133333');
INSERT INTO DEPOZIT(denumire, contact) VALUES ('Depozit București Sector 2', '0722255551');

SELECT * FROM DEPOZIT;

DECLARE
    TYPE t_nume IS TABLE OF VARCHAR2(50);
    v_prefixe t_nume := t_nume('Music', 'Global', 'Sound', 'Vinyl', 'Art', 'Distribution', 'Master', 'Studio', 'Premium', 'Pro');
    v_sufixe t_nume := t_nume('Records', 'Group', 'Muzziker', 'Shop', 'Services', 'SRL', 'Niche', 'Bazar', 'Box', 'Living');
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO FURNIZOR(
                             denumire, cod_fiscal, email, cont_iban
        ) VALUES (
                v_prefixe(TRUNC(DBMS_RANDOM.VALUE(1,11))) || ' ' ||
                  v_sufixe(TRUNC((DBMS_RANDOM.VALUE(1,11)))) || ' ' || i,
                  'RO' || TRUNC(DBMS_RANDOM.VALUE(100000,999999)),
                  'contact' || i || '@provider' || i || '.ro',
                  'RO' || TRUNC(DBMS_RANDOM.VALUE(10,99)) || 'RZBR' || TRUNC(DBMS_RANDOM.VALUE(1000000000000000, 9999999999999999))
                );
        end loop;
    COMMIT;
end;
/

SELECT * FROM FURNIZOR;

INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Hetfield', 'James', 'Metallica', TO_DATE('1981-10-28', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Adele', 'Laurie Blue', 'Adele', TO_DATE('2006-01-01', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Cobain', 'Kurt', 'Nirvana', TO_DATE('1987-01-01', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Mercury', 'Freddie', 'Queen', TO_DATE('1970-01-01', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Swift', 'Taylor Alison', 'Taylor Swift', TO_DATE('2006-10-24', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Gilmour', 'David', 'Pink Floyd', TO_DATE('1965-01-01', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Jackson', 'Michael', 'MJ', TO_DATE('1964-09-04', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Eminem', 'Marchall', 'Slim Shady', TO_DATE('1996-06-25', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Zimmer', 'Hans', 'Hans Zimmer', TO_DATE('1980-08-18', 'YYYY-MM-DD'));
INSERT INTO ARTIST(nume, prenume, pseudonim, data_debut)  VALUES ('Grohl', 'Dave', 'Foo Fighters', TO_DATE('1994-07-13', 'YYYY-MM-DD'));

SELECT * FROM ARTIST;

INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Summer Music Fest', 10.00, SYSDATE-30, SYSDATE-15);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Black Friday', 25.00, SYSDATE-60, SYSDATE-55);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Crăciun Rock', 15.00, SYSDATE-10, SYSDATE+5);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Vinyl Week', 20.00, SYSDATE-120, SYSDATE-110);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Back to School', 5.00, SYSDATE-120, SYSDATE-110);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Valentine Special', 12.00, SYSDATE-200, SYSDATE-199);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Paște Promoțional', 10.00, SYSDATE-150, SYSDATE-145);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Lichidare Stoc Iarnă', 40.00, SYSDATE-5, SYSDATE);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Ziua Muncii', 15.00, SYSDATE, SYSDATE+2);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Instrumente Pro', 8.00, SYSDATE-20, SYSDATE+2);
INSERT INTO CAMPANIE(nume_campanie, reducere_standard, data_inceput, data_sfarsit) VALUES ('Instrumente Pro', 8.00, SYSDATE-20, SYSDATE-10);

SELECT * FROM CAMPANIE;

DECLARE
    TYPE t_arr IS TABLE OF VARCHAR2(50);
    v_nume t_arr := t_arr('Popescu', 'Ionescu', 'Radu', 'Dumitru', 'Stan', 'Stoica', 'Matei', 'Florea', 'Olteanu', 'Gomoi');
    v_prenume t_arr := t_arr('Antonia', 'Maria', 'Elena', 'Alexandru', 'Mihai', 'Diana', 'Leonardo', 'Cristina', 'Tiberiu', 'Nick');
    v_data_reg DATE;
BEGIN
    FOR i IN 1..15 LOOP
        v_data_reg := SYSDATE-TRUNC(DBMS_RANDOM.VALUE(10, 730));

        INSERT INTO CLIENT(nume, prenume, email, telefon, data_inregistrare)
        VALUES (
                v_nume(TRUNC(DBMS_RANDOM.VALUE(1,11))),
                v_prenume(TRUNC(DBMS_RANDOM.VALUE(1,11))),
                'client' || i || '@gmail.com',
                '07' || TRUNC(DBMS_RANDOM.VALUE(10000000, 99999999)),
                v_data_reg
               );
        end loop;
    COMMIT;
end;
/

SELECT * FROM CLIENT;

INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Metallica - Master of Puppets (Vinyl)', 150.00, 20, 1);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Adele - 30 (CD)', 60.00, 50, 2);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Nirvana - Nevermind (Vinyl)', 158.00, 10, 1);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Chitară Electrică Fender Squier', 1200.00,5, 8);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Pink Floyd - The Darl Side of the Moon', 180.00, 15,1);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Set Tobe Yamaha', 3500.00,2,8);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Hanorac Metallica L', 200.00, 30,3);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('The Life of A Showgirl', 170.00, 25, 5);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Poster Queen - Wembley', 45.00, 100, 4);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Guardians of Galaxy - Box', 50.00, 25, 6);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Audio Technica AT-LP120 Pick-up', 1600.00, 8,10);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('The Eras Tour', 289.00, 15, 9);
INSERT INTO PRODUS(denumire, pret_lista, stoc_curent, categorie_id) VALUES ('Thriller 40', 168.00, 46, 1);

SELECT * FROM PRODUS;

INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (1,1, 'Trupa');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (2,2,'Solist');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (3, 3, 'Trupa');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (5,6, 'Trupa');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (7,1, 'Merch');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (8,5,'Solist & Scriitor');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (9,4, 'Producator');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (10, 5, 'Producator');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (12, 5, 'Scriitor');
INSERT INTO PRODUS_ARTIST(produs_id, artist_id, rol_artist) VALUES (13, 7,'Scriitor & Solist');

SELECT * FROM PRODUS_ARTIST;

BEGIN
    FOR i IN 1..13 LOOP
    BEGIN
        INSERT INTO PRODUS_CAMPANIE(CAMPANIE_ID, PRODUS_ID, REDUCERE_SPECIALA)
        VALUES (
                TRUNC(DBMS_RANDOM.VALUE(1,12)) ,
                TRUNC(DBMS_RANDOM.VALUE(1,13)),
                TRUNC(DBMS_RANDOM.VALUE(5,50))
                );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;
    end loop;
    COMMIT;
end;
/

SELECT * FROM PRODUS_CAMPANIE;

DECLARE
    v_produs_id NUMBER;
    v_pret_lista NUMBER;
    v_pret_achizitie NUMBER;
    v_depozit_id NUMBER;
BEGIN
    FOR i IN 1..15 LOOP
        BEGIN
            SELECT produs_id, pret_lista
            INTO v_produs_id, v_pret_lista
            FROM(
                SELECT produs_id, pret_lista
                FROM PRODUS
                ORDER BY DBMS_RANDOM.VALUE()
                )
                WHERE ROWNUM=1;

            SELECT depozit_id
                INTO v_depozit_id
            FROM(
                SELECT depozit_id FROM DEPOZIT ORDER BY DBMS_RANDOM.VALUE()
                )
            WHERE ROWNUM=1;

            v_pret_achizitie := v_pret_lista * DBMS_RANDOM.VALUE(0.40, 0.70);
            v_pret_achizitie := ROUND(v_pret_achizitie,2);

            INSERT INTO APROVIZIONARE(produs_id, furnizor_id, depozit_id, cantitate, pret_achizitie, data_aprovizionare)
            VALUES(
                   v_produs_id,
                   TRUNC(DBMS_RANDOM.VALUE(1,11)),
                   v_depozit_id,
                   TRUNC(DBMS_RANDOM.VALUE(10,500)),
                   v_pret_achizitie,
                   SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1,365))
                  );
            EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
            WHEN NO_DATA_FOUND THEN NULL;
        end;
        end loop;
    COMMIT;
end;
/

SELECT * FROM APROVIZIONARE;

BEGIN
    FOR i IN 1..15 LOOP
        INSERT INTO ADRESA(client_id, cod_postal)
        VALUES (
                i, 'CP-' ||TRUNC(DBMS_RANDOM.VALUE(10000, 99999))
               );
        end loop;
    COMMIT;
end;
/

SELECT * FROM ADRESA;

DECLARE
    v_client_id NUMBER;
    v_adresa_id NUMBER;
    v_status VARCHAR2(20);
    v_data_comanda DATE;
    v_rand_chance NUMBER;
    BEGIN
    FOR i IN 1..15 LOOP
        BEGIN
            SELECT client_id, adresa_id
                INTO v_client_id, v_adresa_id
            FROM(
                SELECT client_id, adresa_id
                FROM ADRESA
                ORDER BY DBMS_RANDOM.VALUE()
                )
            WHERE ROWNUM=1;
        v_data_comanda := SYSDATE - DBMS_RANDOM.VALUE(0,60);
        v_rand_chance := DBMS_RANDOM.VALUE(0,1);
        IF v_rand_chance < 0.10 THEN
            v_status := 'ANULATA';
        ELSIF v_data_comanda > (SYSDATE -7) THEN
            v_status := 'IN PROCESARE';
        ELSE
            v_status := 'FINALIZAT';
        end if;
        INSERT INTO COMANDA(client_id, adresa_id, status_comanda, valoare_totala, data_comanda)
            VALUES (
                    v_client_id,
                    v_adresa_id,
                    v_status,
                    TRUNC(DBMS_RANDOM.VALUE(100,2000)),
                    v_data_comanda
                   );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN NULL;
                WHEN OTHERS THEN NULL;
        end;
        end loop;
    COMMIT;
end;
/

SELECT * FROM COMANDA;

DECLARE
    v_produs_id NUMBER;
    v_pret_produs NUMBER;
    v_nr_produse_in_comanda NUMBER;
    BEGIN
    FOR r_comanda IN(
        SELECT comanda_id
        FROM COMANDA
        ) LOOP
        v_nr_produse_in_comanda := TRUNC(DBMS_RANDOM.VALUE(1,15));
        FOR i IN 1..v_nr_produse_in_comanda LOOP
            BEGIN
                SELECT produs_id, pret_lista
                INTO v_produs_id, v_pret_produs
                FROM(
                    SELECT produs_id, pret_lista
                    FROM PRODUS
                    ORDER BY DBMS_RANDOM.VALUE()
                    )
                    WHERE ROWNUM=1;
                INSERT INTO DETALII_COMANDA(comanda_id, produs_id, cantitate, pret_istoric)
                VALUES (
                        r_comanda.comanda_id,
                        v_produs_id,
                        TRUNC(DBMS_RANDOM.VALUE(1,3)),
                        v_pret_produs
                       );
                EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;
            end;
            end loop;
        end loop;
    COMMIT;
end;
/

SELECT * FROM DETALII_COMANDA;

UPDATE COMANDA c
SET valoare_totala =(
    SELECT NVL(SUM(d.cantitate * d.pret_istoric), 0)
    FROM DETALII_COMANDA d
    WHERE d.comanda_id=c.comanda_id
    )
WHERE EXISTS(
    SELECT 1 FROM DETALII_COMANDA d
    WHERE d.comanda_id=c.comanda_id
);
COMMIT ;

BEGIN
    FOR r_comanda IN(
        SELECT comanda_id, data_comanda
        FROM COMANDA
        WHERE status_comanda IN ('FINALIZAT', 'IN PROCESARE')
        ) LOOP
        BEGIN
            INSERT INTO LIVRARE(comanda_id, numar_awb, data_estimata)
            VALUES (
                    r_comanda.comanda_id,
                    'AWB' || TRUNC(DBMS_RANDOM.VALUE(1000000, 9999999)),
                    r_comanda.data_comanda + TRUNC(DBMS_RANDOM.VALUE(2,6))
                   );
            EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN NULL;
        end;
        end loop;
    COMMIT;
end;
/

select * from LIVRARE;

DECLARE
    v_rating NUMBER;
    v_comentariu VARCHAR2(255);
    v_data_recenzie DATE;
BEGIN
    FOR r_achizitie IN(
        SELECT c.client_id, d.produs_id, c.data_comanda
        FROM COMANDA c
        JOIN DETALII_COMANDA d on c.comanda_id = d.comanda_id
        WHERE c.status_comanda='FINALIZAT'
        ) LOOP
            IF DBMS_RANDOM.VALUE() < 0.40 THEN
                BEGIN
                    IF DBMS_RANDOM.VALUE() < 0.15 THEN
                        v_rating := TRUNC(DBMS_RANDOM.VALUE(1,3));
                    ELSE
                        v_rating := TRUNC(DBMS_RANDOM.VALUE(3,6));
                    end if;
                    CASE v_rating
                        WHEN 5 THEN v_comentariu := 'Produs excelent! Exact ca în descriere. Recomand.';
                        WHEN 4 THEN v_comentariu := 'Bun, dar livrarea a cam durat.';
                        WHEN 3 THEN v_comentariu := 'Raport calitate-preț ok, aveam mai multe așteptări.';
                        WHEN 2 THEN v_comentariu := 'Produsul nu are o calitate pre bună. ';
                        WHEN 1 THEN v_comentariu := 'Produsul a ajuns deteriorat. L-am returnat. Nu recomand.';
                        END CASE;
                    v_data_recenzie := r_achizitie.data_comanda + TRUNC(DBMS_RANDOM.VALUE(3,10));
                    IF v_data_recenzie > SYSDATE THEN
                        v_data_recenzie := SYSDATE;
                    end if;
                    INSERT INTO RECENZIE(client_id, produs_id, rating, comentariu, data_recenzie)
                    VALUES (
                            r_achizitie.client_id,
                            r_achizitie.produs_id,
                            v_rating,
                            v_comentariu,
                            v_data_recenzie
                           );
                    EXCEPTION
                        WHEN OTHERS THEN NULL;
                end;
            end if;
        end loop;
    COMMIT;
end;
/

SELECT * FROM RECENZIE;