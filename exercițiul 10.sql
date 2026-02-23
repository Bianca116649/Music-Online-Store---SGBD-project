--exercițiul 10

--Să se creeze un mecanism prin care se poate face o verificare globală a comenzilor active, după orice INSERT, UPDATE, DELETE asupra tabelului DETALII_COMANDA
--Se va crea un program stocat care va verifica daca o comandă depășește 5000 de RON și o va semnala corespunzător, schimband statusul în verificare_comandă.

CREATE OR REPLACE PROCEDURE marcheaza_comenzi IS
v_rows_updated NUMBER;
    BEGIN
        UPDATE COMANDA
            SET STATUS_COMANDA='VERIFICARE_COMANDA'
        WHERE VALOARE_TOTALA > 5000
        AND STATUS_COMANDA NOT IN ('FINALIZAT', 'ANULAT', 'VERIFICARE_COMANDA');
        v_rows_updated := SQL%ROWCOUNT;
        IF v_rows_updated > 0 THEN
            DBMS_OUTPUT.PUT_LINE('S-au identificat ' || v_rows_updated || ' comenzi cu o valoarea semnificativă. Status actualizat');
        end if;
    end;
/

--trigger LMD la nivel de comandă

CREATE OR REPLACE TRIGGER trg_monitorizare_comenzi
    AFTER INSERT OR UPDATE OR DELETE ON DETALII_COMANDA
    BEGIN
        marcheaza_comenzi();
    end;
/

--testare cod

DECLARE
    v_comanda_id NUMBER;
    v_produs_id NUMBER;
    v_status_initial VARCHAR2(50);
    v_status_final VARCHAR2(50);
    BEGIN
    v_produs_id := PRODUS_SEQ.nextval;
    INSERT INTO PRODUS(produs_id, denumire, pret_lista, stoc_curent, categorie_id)
    VALUES (v_produs_id, 'Chitară electrică', 6000,10, 8);

    v_comanda_id := COMANDA_SEQ.nextval;
    INSERT INTO COMANDA(comanda_id, client_id, adresa_id, data_comanda, status_comanda,VALOARE_TOTALA)
    VALUES (v_comanda_id, 1,1,sysdate, 'NOU',0);

    SELECT STATUS_COMANDA
        INTO v_status_initial
    FROM COMANDA
        WHERE COMANDA_ID=v_comanda_id;
    DBMS_OUTPUT.PUT_LINE('1. Status inițial: ' || v_status_initial);

    DBMS_OUTPUT.PUT_LINE('2. Se actualizează DETALII_COMANDA cu insert-ul.');

    INSERT INTO DETALII_COMANDA(COMANDA_ID, PRODUS_ID, CANTITATE, PRET_ISTORIC)
    VALUES(v_comanda_id, v_produs_id, 1, 6000);

    UPDATE COMANDA
        SET VALOARE_TOTALA = 6000
    WHERE COMANDA_ID=v_comanda_id;

    UPDATE DETALII_COMANDA
        SET CANTITATE=1
    WHERE COMANDA_ID=v_comanda_id;

    SELECT STATUS_COMANDA
        INTO v_status_final FROM COMANDA
            WHERE COMANDA_ID=v_comanda_id;

    DBMS_OUTPUT.PUT_LINE('3. Status final ' || v_status_final);

    IF v_status_final = 'VERIFICARE_COMANDA' THEN
        DBMS_OUTPUT.PUT_LINE('Trigger-ul a detectat și a modificat statusul.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Statusul nu s-a schimbat');
    end if;
    ROLLBACK;
end;
/


--ALTER TRIGGER trg_monitorizare_comenzi DISABLE;