--exercițiul 7 (cursor explicit parametrizat + cursor ciclu cursor cu subcerere)

--Să se realizeze un subprogram stocat independent care să genereze un raport pentru fiecare client din baza de date a magazinului.
--Pentru fiecare client se va transmite id-ul acestuia către un cursor și:
--dacă clientul are comenzi de peste 5000 de RON, statusul său va fi 'client eligibil pentru VIP';
--dacă are între 2000 și 5000 este 'client eligibil pentru premium';
--și 'client standard' în rest.
--đacă nu are comenzi, se consideră a fi 'client inactiv'.

CREATE OR REPLACE PROCEDURE analiza_clienti IS

CURSOR c_dependent(p_id_client CLIENT.CLIENT_ID%type) IS
    SELECT VALOARE_TOTALA, DATA_COMANDA
    FROM COMANDA
    WHERE CLIENT_ID=p_id_client;

    v_comanda c_dependent%ROWTYPE;
    v_total_client NUMBER(10, 2);
    v_status_client VARCHAR2(50);
BEGIN
    FOR r_client IN(
        SELECT CLIENT_ID, NUME, PRENUME
        FROM CLIENT
        ORDER BY NUME
        ) LOOP

        v_total_client :=0;

        OPEN c_dependent(r_client.CLIENT_ID);
        LOOP
            FETCH c_dependent
            INTO v_comanda;
            EXIT WHEN c_dependent%NOTFOUND;

            v_total_client := v_total_client + NVL(v_comanda.VALOARE_TOTALA,0);

        end loop;
        CLOSE c_dependent;

        IF v_total_client > 5000 THEN
            v_status_client := 'Client eligibil pentru VIP';
        ELSIF v_total_client >= 2000 THEN
            v_status_client := 'Client eligibil pentru PREMIUM';
        ELSIF v_total_client >0 THEN
            v_status_client := 'Client STANDARD';
        ELSE
            v_status_client := 'Client inactiv';
        END IF;
        DBMS_OUTPUT.PUT_LINE('Clientul ' || r_client.NUME || ' '|| r_client.PRENUME || ' are un total al comenzilor în valoare de ' || v_total_client || ' RON. Status: ' || v_status_client);
        end loop;
end;
/

BEGIN
    analiza_clienti;
end;
/




