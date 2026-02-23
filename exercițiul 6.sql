--exercitiul 6 (array si nested table si index by table)

--Cerinta: Să se implementeze un subprogram stocat independent care să proceseze și să afiseze următoarele informații:
--Să se rețină și să se afișeze valoarea ultimelor 5 comenzi plasate de client, pentru a vedea cheltuielile lui.
--Să se construiască o listă cu toate categoriile distincte de produse din care clientul a cumpărat
--Și să se calculeze frecvența de cumpărare per artist ca să se rețină relația nume artist - nr produse cumpărate ca să se identifice artistul favorit al clientului.

CREATE OR REPLACE PROCEDURE raport_client (p_client_id IN CLIENT.CLIENT_ID%type) IS

    TYPE t_istoric_valori IS VARRAY(5) OF NUMBER(10,2);
        v_ultimele_valori t_istoric_valori := t_istoric_valori();

    TYPE t_lista_categorii IS TABLE OF VARCHAR2(100);
        v_categorii_cumparate t_lista_categorii := t_lista_categorii();

    TYPE t_top_artisti IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
        v_statistica_artisti t_top_artisti;

    v_nume_client VARCHAR2(100);
    v_artist_nume VARCHAR2(100);
    v_idx VARCHAR2(100);

    BEGIN

        SELECT NUME || ' ' || PRENUME
            INTO v_nume_client
        FROM CLIENT
        WHERE CLIENT_ID=p_client_id;

        DBMS_OUTPUT.PUT_LINE('...............................................');
        DBMS_OUTPUT.PUT_LINE('Raport pentru clientul: ' || v_nume_client);
        DBMS_OUTPUT.PUT_LINE('...............................................');

        FOR r_com IN(
            SELECT valoare_totala
            FROM COMANDA
            WHERE CLIENT_ID=p_client_id
            ORDER BY DATA_COMANDA desc
            ) LOOP
            IF v_ultimele_valori.COUNT < 5 THEN
                v_ultimele_valori.EXTEND;
                v_ultimele_valori(v_ultimele_valori.LAST) := r_com.VALOARE_TOTALA;
            ELSE
                EXIT;
            end if;
        end loop;

        DBMS_OUTPUT.PUT_LINE('> Istoric ultimele ' || v_ultimele_valori.COUNT || ' comenzi (RON): ');
        IF v_ultimele_valori.COUNT > 0 THEN
            FOR i IN v_ultimele_valori.FIRST .. v_ultimele_valori.LAST LOOP
                DBMS_OUTPUT.PUT_LINE(' Comanda ' || i|| ': ' || v_ultimele_valori(i) || ' RON');
            end loop;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nu exista comenzi recente.');
        end if;

        SELECT DISTINCT cat.nume_categorie
            BULK COLLECT INTO v_categorii_cumparate
        FROM COMANDA c
        JOIN DETALII_COMANDA  dc ON c.COMANDA_ID=dc.COMANDA_ID
        JOIN PRODUS p ON dc.PRODUS_ID=p.PRODUS_ID
        JOIN CATEGORIE cat ON p.CATEGORIE_ID=cat.CATEGORIE_ID
        WHERE c.CLIENT_ID=p_client_id;

        DBMS_OUTPUT.PUT_LINE('> Diversitate achiziții: ');
        IF v_categorii_cumparate.COUNT > 0 THEN
            FOR i  IN v_categorii_cumparate.FIRST ..v_categorii_cumparate.LAST LOOP
                DBMS_OUTPUT.PUT_LINE(' -' || v_categorii_cumparate(i));
                end loop;
        ELSE
            DBMS_OUTPUT.PUT_LINE(' Nu s-a gășit nicio categorie');
        end if;

    FOR r_prod IN(
        SELECT a.pseudonim
        FROM COMANDA c
        JOIN DETALII_COMANDA dc ON c.COMANDA_ID=dc.COMANDA_ID
        JOIN PRODUS p ON dc.PRODUS_ID=p.PRODUS_ID
        JOIN PRODUS_ARTIST pa ON p.PRODUS_ID=pa.PRODUS_ID
        JOIN ARTIST a ON pa.ARTIST_ID=a.ARTIST_ID
        WHERE c.CLIENT_ID=p_client_id
        ) LOOP
            v_artist_nume := r_prod.PSEUDONIM;
            IF v_statistica_artisti.EXISTS(v_artist_nume) THEN
                v_statistica_artisti(v_artist_nume) := v_statistica_artisti(v_artist_nume)+1;
            ELSE
                v_statistica_artisti(v_artist_nume) := 1;
            end if;
        end loop;

    DBMS_OUTPUT.PUT_LINE('> Top artiști cumpărați: ');

        v_idx := v_statistica_artisti.FIRST;
        WHILE v_idx IS NOT NULL LOOP
            DBMS_OUTPUT.PUT_LINE(' Artist: ' || v_idx || '| Produse: ' || v_statistica_artisti(v_idx));
            v_idx:= v_statistica_artisti.NEXT(v_idx);
            end loop;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Clientul cu ID-ul ' || p_client_id || ' nu exista');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Eroare ' || SQLERRM);
    end;
    /

-- apelare subprogram

BEGIN
    raport_client(8);
end;
/

--id 9 pentru mai multe date