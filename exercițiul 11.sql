--exercițiul 11

--Să se implementeze un mecanism care pentru orice modificări de pe coloana cantitate trebuie să modifice stocul produselor în timp real și să se actualizeze valoarea comenzii din COMANDA,
-- ceea ce înseamnă folosirea tabelului DETALII_COMANDA în timp ce este modificat => mutating table în trigger

CREATE OR REPLACE PROCEDURE actualizare_total(p_comanda_id NUMBER) IS
v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(CANTITATE*PRET_ISTORIC), 0)
            INTO v_total
        FROM DETALII_COMANDA
            WHERE COMANDA_ID=p_comanda_id;

        UPDATE COMANDA
            SET VALOARE_TOTALA=v_total
        WHERE COMANDA_ID=p_comanda_id;
    end;
    /

CREATE OR REPLACE TRIGGER trg_stoc
    FOR INSERT OR DELETE OR UPDATE OF cantitate ON DETALII_COMANDA
    COMPOUND TRIGGER

    TYPE t_lista_id IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_comenzi_afectate t_lista_id;
    v_idx NUMBER := 0;

    BEFORE STATEMENT IS
    BEGIN
        v_comenzi_afectate.DELETE;
        v_idx :=0;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    v_x_stoc NUMBER;
        v_exista BOOLEAN := FALSE;
        v_comanda_curenta NUMBER;
        BEGIN
        v_x_stoc := NVL(:NEW.CANTITATE, 0)- NVL(:OLD.CANTITATE,0);
        IF v_x_stoc !=0 THEN
            UPDATE PRODUS
                SET STOC_CURENT=STOC_CURENT-v_x_stoc
            WHERE PRODUS_ID=NVL(:NEW.PRODUS_ID, :OLD.PRODUS_ID);
        end if;

        v_comanda_curenta := NVL(:NEW.COMANDA_ID, :OLD.COMANDA_ID);
        FOR i IN 1 .. v_comenzi_afectate.COUNT LOOP
            IF v_comenzi_afectate(i)=v_comanda_curenta THEN
                v_exista:= TRUE;
                EXIT;
            end if;
            end loop;

        IF NOT v_exista THEN
            v_idx := v_idx +1;
            v_comenzi_afectate(v_idx) := v_comanda_curenta;
        end if;
        END AFTER EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. v_comenzi_afectate.COUNT LOOP
            actualizare_total(v_comenzi_afectate(i));
            end loop;
        END AFTER STATEMENT;
    end;
/

--testare cod----------------------------------------------------------------------------------------------

DECLARE
    v_comanda_id NUMBER;
    v_produs1_id NUMBER;
    v_produs2_id NUMBER;
    v_stoc1 NUMBER;
    v_stoc2 NUMBER;
    v_total_comanda NUMBER;

    BEGIN
        v_produs1_id := PRODUS_SEQ.nextval;
        v_produs2_id := PRODUS_SEQ.nextval;

        INSERT INTO PRODUS(PRODUS_ID, DENUMIRE, PRET_LISTA, STOC_CURENT, CATEGORIE_ID)
    VALUES(v_produs1_id, 'produs 1', 100, 50, 1);
         INSERT INTO PRODUS(PRODUS_ID, DENUMIRE, PRET_LISTA, STOC_CURENT, CATEGORIE_ID)
    VALUES(v_produs2_id, 'produs 2', 200, 50, 1);

        v_comanda_id := COMANDA_SEQ.nextval;
        INSERT INTO COMANDA(comanda_id, client_id, adresa_id, data_comanda, status_comanda, valoare_totala)
    VALUES (v_comanda_id, 1, 1, SYSDATE, 'NOU',0);

        INSERT INTO DETALII_COMANDA(COMANDA_ID, PRODUS_ID, CANTITATE, PRET_ISTORIC)
    SELECT v_comanda_id, v_produs1_id,2,100
    FROM DUAL
        UNION ALL
    SELECT v_comanda_id, v_produs2_id, 1,200
        FROM DUAL;

    SELECT STOC_CURENT
        INTO v_stoc1
    FROM PRODUS
        WHERE PRODUS_ID=v_produs1_id;
        SELECT STOC_CURENT
            INTO v_stoc2
    from PRODUS
        WHERE PRODUS_ID=v_produs2_id;
        SELECT VALOARE_TOTALA
            INTO v_total_comanda FROM COMANDA
                WHERE comanda_id=v_comanda_id;

        DBMS_OUTPUT.PUT_LINE('Stoc produs 1: ' || v_stoc1);
        DBMS_OUTPUT.PUT_LINE('Stoc produs 2: ' || v_stoc2);

        IF v_total_comanda = 400 AND v_stoc1=48 THEN
            DBMS_OUTPUT.PUT_LINE('Triggerul a funcționat.');
            ELSE
            DBMS_OUTPUT.PUT_LINE('Nu a funcțioant.');
        end if;

        UPDATE DETALII_COMANDA
            SET CANTITATE=10
    WHERE COMANDA_ID=v_comanda_id AND PRODUS_ID=v_produs1_id;

        SELECT STOC_CURENT INTO v_stoc1 FROM PRODUS
            WHERE PRODUS_ID=v_produs1_id;
        SELECT VALOARE_TOTALA INTO v_total_comanda FROM COMANDA
            WHERE COMANDA_ID=v_comanda_id;

        DBMS_OUTPUT.PUT_LINE('Stoc produs 1: ' || v_stoc1);
        DBMS_OUTPUT.PUT_LINE('Total comanda: ' || v_total_comanda);
        ROLLBACK ;
end;
/

--ALTER TRIGGER trg_stoc DISABLE;