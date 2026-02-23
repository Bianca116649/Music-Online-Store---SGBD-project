--exercițiul 13

--Să se creeze un pachet care va implementa pocesarea comenzilor transmise sub formă de colecții, conținand mai multe produse. Trebuie sa se actualizeze stocurile, să se aplice reducerile și să se genereze o factură.
--Se va folosi RECORD pentru rezultat (factura);
--Va exista o funcție care să returneze FALSE dacă nu există suficient stoc pentru un produs;
--O funcție pentru a verifica dacă produsul face parte din vreo campanie activă și se va afce o reducere de 5% dacă clientul are o vechime de cel puțin doi ani;
--Se vor crea înregistrări în tabelele necesare (COMANDA, DETALII_COMANDA, LIVRARE);

CREATE OR REPLACE PACKAGE pachet_comenzi IS

    TYPE r_linie_comanda IS RECORD(
        produs_id NUMBER,
        cantitate NUMBER);

    TYPE t_lista_produse IS TABLE OF r_linie_comanda;

    TYPE r_factura IS RECORD(
        comanda_id NUMBER,
        nume_client VARCHAR2(100),
        valoare_finala NUMBER,
        awb_livrare VARCHAR2(50),
        status_mesaj VARCHAR2(200),
        succes BOOLEAN);

    FUNCTION functie_verifica_stoc(p_lista IN t_lista_produse) RETURN BOOLEAN;
    FUNCTION functie_calcul_total(p_client_id IN NUMBER, p_lista IN t_lista_produse) RETURN NUMBER;

    PROCEDURE procedura_proceseza_produsul(
        p_comanda_id IN NUMBER,
        p_linie IN r_linie_comanda
    );
    PROCEDURE procedura_proceseaza_comanda(
        p_client_id IN NUMBER,
        p_adresa_id IN NUMBER,
        p_lista_produse IN t_lista_produse,
        p_rezultat OUT r_factura
    );
END pachet_comenzi;
/

CREATE OR REPLACE PACKAGE BODY pachet_comenzi IS

    FUNCTION get_pret_cu_reducere(p_produs_id NUMBER, p_client_id NUMBER) RETURN NUMBER IS
        v_pret_lista NUMBER;
        v_data_inregistrare DATE;
        v_reducere_totala NUMBER := 0;
        v_reducere_campanie NUMBER(4,2) :=0;
    BEGIN
        SELECT pret_lista
        INTO v_pret_lista
        FROM PRODUS
        WHERE produs_id=p_produs_id;

        SELECT DATA_INREGISTRARE
            INTO v_data_inregistrare
        FROM CLIENT
            WHERE CLIENT_ID=p_client_id;

        BEGIN
            SELECT NVL(MAX(pc.reducere_speciala), 0)
            INTO v_reducere_campanie
            FROM PRODUS_CAMPANIE pc
            JOIN campanie c ON pc.CAMPANIE_ID =c.CAMPANIE_ID
            WHERE pc.produs_id =p_produs_id
            AND SYSDATE BETWEEN c.DATA_INCEPUT AND c.DATA_SFARSIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            v_reducere_campanie := 0;
        end;
        v_reducere_totala := v_reducere_campanie/100;
        IF MONTHS_BETWEEN(SYSDATE, v_data_inregistrare) >= 24 THEN
            v_reducere_totala := v_reducere_totala +0.05;
        end if;
        if v_reducere_totala > 1 THEN
            v_reducere_totala :=1;
        end if;
        RETURN v_pret_lista * (1- v_reducere_totala);

        EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END get_pret_cu_reducere;

    FUNCTION functie_verifica_stoc(p_lista IN t_lista_produse) RETURN BOOLEAN IS
        v_stoc_actual NUMBER;
    BEGIN
        IF p_lista.COUNT=0 THEN
            RETURN FALSE;
        end if;
        FOR i IN p_lista.FIRST ..p_lista.LAST LOOP
            BEGIN
                SELECT STOC_CURENT
                INTO v_stoc_actual
                FROM PRODUS
                WHERE produs_id=p_lista(i).produs_id;
                IF v_stoc_actual < p_lista(i).cantitate THEN
                    RETURN FALSE;
                end if;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
            end;
            end loop;
        RETURN TRUE;
    END functie_verifica_stoc;

    FUNCTION functie_calcul_total(p_client_id IN NUMBER, p_Lista IN t_lista_produse) RETURN NUMBER IS
        v_total NUMBER := 0;
        v_pret_calculat NUMBER;
    BEGIN
        FOR i IN p_lista.FIRST ..p_lista.LAST LOOP
            v_pret_calculat := get_pret_cu_reducere(p_lista(i).produs_id, p_client_id);
            v_total := v_total + (v_pret_calculat * p_lista(i).cantitate);
        end loop;
        RETURN v_total;
    END functie_calcul_total;

    PROCEDURE procedura_proceseza_produsul(
        p_comanda_id IN NUMBER,
        p_linie IN r_linie_comanda
    ) IS
    v_pret_final NUMBER;
    v_client_id NUMBER;
    BEGIN
        UPDATE PRODUS
        SET STOC_CURENT = STOC_CURENT-p_linie.cantitate
        WHERE PRODUS_ID=p_linie.produs_id;

        SELECT CLIENT_ID
            INTO v_client_id
        FROM COMANDA
            WHERE COMANDA_ID=p_comanda_id;

        v_pret_final := get_pret_cu_reducere(p_linie.produs_id, v_client_id);
        INSERT INTO DETALII_COMANDA(comanda_id, produs_id, cantitate, pret_istoric)
        VALUES (p_comanda_id, p_linie.produs_id, p_linie.cantitate, v_pret_final);

    END procedura_proceseza_produsul;

    PROCEDURE procedura_proceseaza_comanda(
        p_client_id IN NUMBER,
        p_adresa_id IN NUMBER,
        p_lista_produse IN t_lista_produse,
        p_rezultat OUT r_factura
    ) IS
    v_comanda_id NUMBER;
    v_livrare_id NUMBER;
    v_total_calculat NUMBER;
    v_nume_client VARCHAR2(100);
        v_awb_generat VARCHAR2(50);
    BEGIN
        IF NOT functie_verifica_stoc(p_lista_produse) THEN
            p_rezultat.succes := FALSE;
            p_rezultat.status_mesaj := 'eroare: stoc insuficient.';
            p_rezultat.valoare_finala :=0;
            RETURN;
        end if;

        v_total_calculat := functie_calcul_total(p_client_id, p_lista_produse);

        SELECT nume || ' ' || prenume
            INTO v_nume_client
        FROM client
            WHERE CLIENT_ID=p_client_id;

        SELECT COMANDA_SEQ.nextval INTO v_comanda_id FROM DUAL;
        INSERT INTO COMANDA(
            comanda_id, CLIENT_ID, adresa_id, data_comanda, status_comanda, VALOARE_TOTALA
        ) VALUES
              (v_comanda_id, p_client_id, p_adresa_id, SYSDATE, 'IN PROCESARE', v_total_calculat);


        FOR i IN p_lista_produse.FIRST ..p_lista_produse.LAST LOOP
            procedura_proceseza_produsul(v_comanda_id, p_lista_produse(i));
            end loop;
        v_awb_generat := 'AWB' || TO_CHAR(SYSDATE, 'YYYYMMDD') || v_comanda_id;
        SELECT LIVRARE_SEQ.nextval INTO v_livrare_id FROM DUAL;

        INSERT INTO LIVRARE(livrare_id, comanda_id, numar_awb, data_estimata)
        VALUES (v_livrare_id, v_comanda_id, v_awb_generat, SYSDATE+3);
        COMMIT;

        p_rezultat.comanda_id := v_comanda_id;
        p_rezultat.nume_client := v_nume_client;
        p_rezultat.valoare_finala := v_total_calculat;
        p_rezultat.awb_livrare := v_awb_generat;
        p_rezultat.status_mesaj := 'Comanda procesata cu succes.';
        p_rezultat.succes := TRUE;

        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;

                p_rezultat.succes := FALSE;
                p_rezultat.status_mesaj := 'eroare: '|| SQLERRM;
                p_rezultat.valoare_finala :=0;
        END procedura_proceseaza_comanda;

end pachet_comenzi;
    /








DECLARE
    v_lista_cumparaturi pachet_comenzi.t_lista_produse := pachet_comenzi.t_lista_produse();
    v_factura pachet_comenzi.r_factura;
BEGIN
    v_lista_cumparaturi.extend;
    v_lista_cumparaturi(1).produs_id := 3;
    v_lista_cumparaturi(1).cantitate :=2000;

    pachet_comenzi.procedura_proceseaza_comanda(
    p_client_id => 1, p_adresa_id => 1, p_lista_produse => v_lista_cumparaturi, p_rezultat => v_factura
    );

    DBMS_OUTPUT.PUT_LINE('Status: '|| v_factura.status_mesaj);
    IF v_factura.succes THEN
        DBMS_OUTPUT.PUT_LINE('ID comanda '|| v_factura.comanda_id);
        DBMS_OUTPUT.PUT_LINE('Client: '|| v_factura.nume_client);
        DBMS_OUTPUT.PUT_LINE('AWB: '|| v_factura.awb_livrare);
        DBMS_OUTPUT.PUT_LINE('Valoare totala: '|| v_factura.valoare_finala || ' RON');
    end if;
end;
/

SELECT PRODUS_ID, DENUMIRE, STOC_CURENT
FROM PRODUS
WHERE PRODUS_ID=3;





