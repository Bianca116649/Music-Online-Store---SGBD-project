--exercitiul 9 (sa definesc exceptii si sa le afisez)

--Să se creeze un subprogram stocat independent de tip procedura care va primi parametri de intrare (emailul clientului și numele produsului)
-- și de ieșire numărul de produse eligibile pentru retur și un șir de caractere care să explice de ce sunt refuzate sau aprobate cererile de retur.
--Dacă un client a comandat același produs de mai multe ori, se va verifica fiecare produs în parte. Tranzacțiile se vor păstra într-o colecție.
--Returul se acceptă doar daca comanda are statusul 'FINALIZAT'
--Pentru produsele din categoria 'instrumente', termenul este de 2 ani
--Pentru altă categorie este de 30 de zile.
--Se vor folosi cele 5 tabele CLIENT, COMANDA, DETALII_COMANDA, PRODUS, CATEGORIE pentru rezolvare.

CREATE OR REPLACE PROCEDURE procesare_retur(
    p_email_client IN VARCHAR2,
    p_nume_produs IN VARCHAR2,
    p_nr_eligibile OUT NUMBER,
    p_raport OUT VARCHAR2
) IS
    TYPE t_detalii_comanda IS RECORD(
        data_achizitie DATE,
        status_comanda COMANDA.STATUS_COMANDA%TYPE,
        nume_categorie CATEGORIE.NUME_CATEGORIE%type);

        TYPE t_lista_comenzi IS TABLE OF t_detalii_comanda;

    v_istoric_comenzi t_lista_comenzi;
    v_zile_trecute NUMBER;
    v_limita_zile NUMBER;

    e_garantie_expirata EXCEPTION ;
    e_status_inadecvat EXCEPTION ;
    BEGIN
        p_nr_eligibile :=0;
        p_raport := '';

        SELECT c.data_comanda, c.status_comanda, cat.nume_categorie
            BULK COLLECT INTO v_istoric_comenzi
        FROM CLIENT cl
        JOIN COMANDA c ON cl.CLIENT_ID=c.CLIENT_ID
        JOIN DETALII_COMANDA dc on c.COMANDA_ID=dc.COMANDA_ID
        JOIN PRODUS p on dc.PRODUS_ID=p.PRODUS_ID
        JOIN CATEGORIE cat on p.CATEGORIE_ID=cat.CATEGORIE_ID
        WHERE UPPER(cl.EMAIL)=UPPER(p_email_client) AND UPPER(p.DENUMIRE)=UPPER(p_nume_produs);

    IF v_istoric_comenzi.COUNT =0 THEN
        RAISE NO_DATA_FOUND;
    end if;

        FOR i IN v_istoric_comenzi.FIRST .. v_istoric_comenzi.LAST LOOP
            BEGIN
            if UPPER(v_istoric_comenzi(i).nume_categorie) LIKE '%INSTRUMENTE%' THEN
                v_limita_zile := 730;
            ELSE
                v_limita_zile := 30;
            end if;

            v_zile_trecute := TRUNC(SYSDATE) - TRUNC(v_istoric_comenzi(i).data_achizitie);
            p_raport := p_raport || 'Comanda din data ' || v_istoric_comenzi(i).data_achizitie || ': ';

            IF v_zile_trecute > v_limita_zile THEN
                RAISE e_garantie_expirata;
END IF;
            IF UPPER(v_istoric_comenzi(i).status_comanda) != 'FINALIZAT' THEN
                RAISE e_status_inadecvat;
            end if;
            p_raport:= p_raport || 'Cerere aprobată.' || CHR(10);
            p_nr_eligibile := p_nr_eligibile +1;

            EXCEPTION
            WHEN e_status_inadecvat THEN
                p_raport := p_raport || 'Cerere respinsă. Comanda nu are status finalizat. Statusul actual:  '|| v_istoric_comenzi(i).status_comanda || '.' || CHR(10);
            WHEN e_garantie_expirata THEN
                p_raport := p_raport || 'Cerere respinsă. Garanția este expirată. Au trecut ' || v_zile_trecute || ' de zile.'|| CHR(10);

            END;
end loop;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_raport := 'Nu există un istoric pentru acest client sau produs.';
        p_nr_eligibile := 0;
    WHEN OTHERS THEN
        p_raport := 'Eroare ' || SQLERRM;
        p_nr_eligibile := 0;
end;
/

INSERT INTO PRODUS(produs_id, denumire, pret_lista, stoc_curent, categorie_id)
VALUES (90, 'Chitară', 2000, 10, 8);

--e_garantie_expirata

INSERT INTO COMANDA(COMANDA_ID, CLIENT_ID, ADRESA_ID, DATA_COMANDA, STATUS_COMANDA, VALOARE_TOTALA)
VALUES (90, 1, 1, SYSDATE-1000, 'FINALIZAT', 2000);
INSERT INTO DETALII_COMANDA(comanda_id, produs_id, cantitate, pret_istoric)
VALUES (90, 90, 1, 2000);

--e_status_inadecvat

INSERT INTO COMANDA(comanda_id, client_id, adresa_id, data_comanda, status_comanda, valoare_totala)
VALUES(91, 1, 1, SYSDATE-10, 'ANULAT', 2000);
INSERT INTO DETALII_COMANDA(comanda_id, produs_id, cantitate, pret_istoric)
VALUES (91, 90, 1, 2000);

--fără eroare

INSERT INTO COMANDA(COMANDA_ID, CLIENT_ID, ADRESA_ID, DATA_COMANDA, STATUS_COMANDA, VALOARE_TOTALA)
VALUES (92, 1, 1, SYSDATE-10, 'FINALIZAT', 2000);
INSERT INTO DETALII_COMANDA(COMANDA_ID, PRODUS_ID, CANTITATE, PRET_ISTORIC)
VALUES (92, 90, 1, 2000);



DECLARE
    v_nr_eligibile NUMBER ;
    v_raport VARCHAR2(4096);
    BEGIN
    procesare_retur(
    p_email_client => 'client1@gmail.com',
    p_nume_produs => 'Chitară',
    p_nr_eligibile => v_nr_eligibile,
    p_raport => v_raport
    );
    DBMS_OUTPUT.PUT_LINE('Număr produse acceptate: ' || v_nr_eligibile);
    DBMS_OUTPUT.PUT_LINE('Raport: ' || v_raport);

    procesare_retur(
    p_email_client => 'mail_inexistent@gmail.com',
    p_nume_produs => 'Produs inexistent',
    p_nr_eligibile => v_nr_eligibile,
    p_raport => v_raport
    );
    DBMS_OUTPUT.PUT_LINE('Număr produse acceptate: ' || v_nr_eligibile);
    DBMS_OUTPUT.PUT_LINE('Raport: ' || v_raport);
    ROLLBACK;
end;
/