CREATE OR REPLACE PROCEDURE insertar_movimiento_actualizar_saldo(
    --Clausula IN se usa para definir los parámetros de un procedimiento
    IN p_cuenta_id INTEGER,
    IN p_tipo_movimiento VARCHAR(50),
    IN p_monto FLOAT
) AS $$
BEGIN
    -- Iniciar transacción
    BEGIN
        
		--Evaluamos si se trata de un retiro lo que introduzco como parámetro en el CALL
		IF p_tipo_movimiento = 'Retiro' THEN
		--Primero vemos si hay saldo en esa cuenta
			IF (SELECT saldo FROM cuentas WHERE id = p_cuenta_id) < p_monto THEN
				--Deshago la transacción:
				rollback;
				--Lanzo excepción:
				RAISE SQLSTATE '22012';
			END IF;
		--Si hay saldo, actualizamos/insertamos el movimiento:
		INSERT INTO movimientos (tipo_movimiento, monto) VALUES (p_tipo_movimiento, p_monto);
		UPDATE cuentas SET saldo = saldo - p_monto WHERE id = p_cuenta_id;
		
		--Si no se trata de un retiro, se trata de un ingreso, insertas y actualizas
		ELSE
		INSERT INTO movimientos (tipo_movimiento, monto) VALUES (p_tipo_movimiento, p_monto);
		UPDATE cuentas SET saldo = saldo + p_monto WHERE id = p_cuenta_id;
		

        END IF;
	END;
	
END;
$$ LANGUAGE plpgsql;

--Llamada al procedimiento:
CALL insertar_movimiento_actualizar_saldo(1, 'Ingreso', 200);

INSERT INTO cuentas (saldo) VALUES (300);

SELECT * FROM cuentas;
SELECT * FROM movimientos;