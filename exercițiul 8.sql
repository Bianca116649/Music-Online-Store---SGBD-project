--exercitiul 8 (de tratat exceptiile sa se vada)

--Se cere realizarea unui subprogram stocat independent de tip funcție pentru a verifica dacă este sau nu profitabilă achiziția unui produs livrat de un anume
-- furnizor (denumirile amandurora fiind date ca și parametri).
--se va calcula un verdict pe baza unor reguli:
--"Convenabil" dacă profitul este strict pozitiv și s-au vandut peste 3 bucăți din produs;
--"Riscant" dacă profitul este strict pozitiv, dar s-au vandut sub 3 bucăți;
--"Neconvenabil" altfel.

CREATE OR REPLACE FUNCTION analiza_produs(
    p_nume_produs IN VARCHAR2,
    p_nume_furnizor IN VARCHAR2
) RETURN VARCHAR2 IS

v_id_produs PRODUS.PRODUS_ID%type;
v_pret_lista PRODUS.PRET_LISTA%type;
v_pret_achizitie APROVIZIONARE.PRET_ACHIZITIE%type;
    v_cantitate_vanduta NUMBER := 0;
    v_profit NUMBER(10,2);
    v_decizie_fin VARCHAR2(100);

BEGIN
    SELECT p.produs_id, p.pret_lista, a.pret_achizitie
    INTO v_id_produs, v_pret_lista, v_pret_achizitie
    FROM PRODUS p
    JOIN APROVIZIONARE a ON p.PRODUS_ID=a.PRODUS_ID
    JOIN FURNIZOR f ON a.FURNIZOR_ID=f.FURNIZOR_ID

    WHERE UPPER(p.DENUMIRE) = UPPER(p_nume_produs)
    AND UPPER(f.DENUMIRE)=upper(p_nume_furnizor);

    SELECT NVL(SUM(dc.cantitate), 0)
        INTO v_cantitate_vanduta
    FROM DETALII_COMANDA dc
    JOIN COMANDA c ON dc.COMANDA_ID=c.COMANDA_ID
    WHERE dc.PRODUS_ID = v_id_produs
    AND c.DATA_COMANDA >= ADD_MONTHS(SYSDATE, -6);

    v_profit := v_pret_lista - v_pret_achizitie;

    IF v_profit > 0 AND v_cantitate_vanduta > 3 THEN
        v_decizie_fin := 'Convenabil';
    ELSIF v_profit > 0 AND v_cantitate_vanduta <= 3 THEN
        v_decizie_fin := 'Riscant';
        ELSE
        v_decizie_fin := 'Neconvenabil';
    end if;

    RETURN 'Verdictul analizei produsului ' || p_nume_produs || ' este ' || v_decizie_fin ||
           ', deoarece: ' || v_profit || 'RON profit și ' || v_cantitate_vanduta || ' bucăți vandute în total';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Nu există date de aprovizionare pentru produsul ' || p_nume_produs || ' de la furnizorul ' || p_nume_furnizor;
        WHEN TOO_MANY_ROWS THEN
            RETURN 'Există mai multe intrări pentru acest produs de la acest furnizor. Este necesară analiză manuală.';
        WHEN OTHERS THEN
            RETURN SQLCODE || ' - ' || SQLERRM;
end;
/

-- apelare subprogram cu evidențierea erorilor

DECLARE
    v_rezultat VARCHAR2(1000);
    v_id_produs_1 NUMBER;
    v_id_produs_2 NUMBER;
    v_id_furnizor NUMBER;
    v_id_comanda NUMBER;
    v_nume_prod VARCHAR2(50) := 'Death or Glory (Vinyl)';
    v_nume_furnizor VARCHAR2(50) := 'Discogs';

BEGIN
    DBMS_OUTPUT.PUT_LINE('Testare');
    v_id_furnizor := FURNIZOR_SEQ.nextval;
    INSERT INTO FURNIZOR(furnizor_id, denumire, email)
        VALUES (v_id_furnizor, v_nume_furnizor, 'contact@discogs.com');

    v_id_produs_1 := PRODUS_SEQ.nextval;
    INSERT INTO PRODUS(produs_id, denumire, pret_lista, stoc_curent, categorie_id)
        VALUES (v_id_produs_1, v_nume_prod, 150,10,1);

    INSERT INTO APROVIZIONARE(produs_id, furnizor_id, depozit_id, cantitate, pret_achizitie, DATA_APROVIZIONARE)
    VALUES (v_id_produs_1, v_id_furnizor, 1,50, 100, SYSDATE-10);

    v_id_comanda :=COMANDA_SEQ.nextval;
    INSERT INTO COMANDA(comanda_id, client_id, adresa_id, data_comanda, status_comanda, valoare_totala)
        values (v_id_comanda, 1, 1,SYSDATE-2, 'FINALIZAT', 750);

    INSERT INTO DETALII_COMANDA(comanda_id, produs_id, cantitate, pret_istoric)
        VALUES (v_id_comanda, v_id_produs_1, 5, 150);

    DBMS_OUTPUT.PUT_LINE('Test 1');
    DBMS_OUTPUT.PUT_LINE(analiza_produs(v_nume_prod, v_nume_furnizor ));

    DBMS_OUTPUT.PUT_LINE('Testare pentru NO_DATA_FOUND');
    DBMS_OUTPUT.PUT_LINE(analiza_produs('nume', v_nume_furnizor));


    v_id_produs_2 := PRODUS_SEQ.nextval;
    INSERT INTO PRODUS(produs_id, denumire, pret_lista, stoc_curent, categorie_id)
        VALUES (v_id_produs_2, v_nume_prod, 200,5,1);

    INSERT INTO APROVIZIONARE(produs_id, furnizor_id, depozit_id, cantitate, pret_achizitie, DATA_APROVIZIONARE)
    VALUES (v_id_produs_2, v_id_furnizor, 1,80, 20, SYSDATE-5);

    DBMS_OUTPUT.PUT_LINE('Testare pentru TOO_MANY ROWS');
    DBMS_OUTPUT.PUT_LINE(analiza_produs(v_nume_prod, v_nume_furnizor));

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Rollback executat.');
end;
/