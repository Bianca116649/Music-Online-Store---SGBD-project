--exercițiul 12

--Să se facă un mecanism de securitate la nivel de schemă cu un trigger de tip LDD
--Dacă se încearcă ștergerea unui obiect, trebuie să verifice dacă nu există dependețe, adică ceva care să depindă de el. Dacă există, se va bloca ștergerea și se va afișa lista în consolă.
--Dacă se încearcă crearea unui tabel, sistemul va trebui să valideze numele tabelului: să fie scris cu majuscule și sa aibă mai mult de trei litere.
--Se va afișa totul: utilizatorul, tipul de eveniment, obiectul și rezultatul.
--Se vor semnala și erorile

CREATE OR REPLACE PROCEDURE p_analiza_ldd(
    p_nume_obiect IN VARCHAR2,
    p_tip_obiect IN VARCHAR2,
    p_eveniment IN VARCHAR2,
    p_user IN VARCHAR2
) IS
CURSOR c_dependente IS
SELECT name, type
FROM USER_DEPENDENCIES
WHERE REFERENCED_NAME=UPPER(p_nume_obiect)
AND REFERENCED_TYPE=UPPER(p_tip_obiect);

    v_dependente_count NUMBER := 0;
    v_eroare VARCHAR2(4000);

    BEGIN
        DBMS_OUTPUT.PUT_LINE('Utilizator: ' || p_user);
        DBMS_OUTPUT.PUT_LINE(p_eveniment || ' ' || p_tip_obiect || ' ' || p_nume_obiect);


        IF p_eveniment = 'DROP' THEN
            v_eroare := 'Nu se poate șterge obiectul, este folosit de: ';

            FOR r_dep IN c_dependente LOOP
                v_dependente_count := v_dependente_count+1;
                v_eroare := v_eroare || ' ' || r_dep.type || ' ' || r_dep.name;
                DBMS_OUTPUT.PUT_LINE('Atenție: ' || r_dep.type || ' ' || r_dep.name || ' depind de obiectul pe care doriți să-l ștergeți.');
                end loop;

            IF v_dependente_count >0 THEN
                DBMS_OUTPUT.PUT_LINE('Acțiune blocată din cauza dependențelor.');
                RAISE_APPLICATION_ERROR(-20005, v_eroare);
            ELSE
                DBMS_OUTPUT.PUT_LINE('Ștergerea este permisă.');

            end if;
        end if;

        IF p_eveniment = 'CREATE' AND p_tip_obiect='TABLE' THEN
            IF p_nume_obiect != UPPER(p_nume_obiect) THEN
                RAISE_APPLICATION_ERROR(-20006, 'Numele obiectului trebuie scris cu majuscule.');

            end if;

        IF LENGTH(p_nume_obiect) < 3 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Numele este prea scurt.');
        end if;
            DBMS_OUTPUT.PUT_LINE('Creare permisă.');
        end if;
    end;
    /

CREATE OR REPLACE TRIGGER trg_analiza
    BEFORE DDL ON SCHEMA
    BEGIN
        p_analiza_ldd(
        p_nume_obiect => SYS.DICTIONARY_OBJ_NAME,
        p_tip_obiect => SYS.DICTIONARY_OBJ_TYPE,
        p_eveniment => SYS.SYSEVENT,
        p_user => SYS.LOGIN_USER
        );
    end;
/

CREATE TABLE "tabel_fara_majuscule" (id number);
CREATE TABLE TABEL_CU_MAJUSCULE( id number);
CREATE OR REPLACE PROCEDURE P_DEPENDENTA IS
BEGIN
    INSERT INTO TABEL_CU_MAJUSCULE VALUES(1);
end;
    /
DROP TABLE TABEL_CU_MAJUSCULE;

--ALTER TRIGGER trg_analiza DISABLE;
--DROP PROCEDURE P_DEPENDENTA;
--DROP TABLE TABEL_CU_MAJUSCULE;