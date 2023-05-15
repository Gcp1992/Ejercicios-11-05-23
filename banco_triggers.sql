CREATE OR REPLACE FUNCTION actualizar_saldo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_movimiento = 'Retiro' THEN
        UPDATE cuentas SET saldo = saldo - NEW.monto WHERE id = NEW.id_cliente;
    ELSE
        UPDATE cuentas SET saldo = saldo + NEW.monto WHERE id = NEW.id_cliente;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Creación trigger que se ejecuta cada vez que hago una actualización de la tabla movimientos
--Cláusula "FOR EACH ROW" indica que el trigger se ejecutará para cada fila insertada en la tabla
--actualizar_saldo(): función que se ejecuta 
CREATE OR REPLACE TRIGGER movimientos_trigger
BEFORE INSERT ON movimientos
FOR EACH ROW
EXECUTE FUNCTION actualizar_saldo();


CREATE OR REPLACE PROCEDURE insertar_movimiento_actualizar_saldo(
    IN p_cuenta_id INTEGER,
    IN p_tipo_movimiento VARCHAR(50),
    IN p_monto FLOAT
) AS $$
BEGIN
    INSERT INTO movimientos (id, tipo_movimiento, monto)
    VALUES (p_cuenta_id, p_tipo_movimiento, p_monto);
END;
$$ LANGUAGE plpgsql;



INSERT INTO movimientos (id,saldo) VALUES (1,400);
INSERT INTO movimientos (id,saldo) VALUES (2,300);
INSERT INTO movimientos (id,saldo) VALUES (3,300);
INSERT INTO movimientos (tipo_movimiento,monto,id_cliente) VALUES ('Ingreso',200,1);

truncate movimientos;

--Llamada al procedimiento:
CALL insertar_movimiento_actualizar_saldo(3, 'Retiro', 100);

SELECT * FROM cuentas order by id;
SELECT * FROM movimientos;