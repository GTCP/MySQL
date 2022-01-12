--Restricciones

-- a. Se debe consistir que la fecha de inicio de la publicación de 
--la edición sea anterior a la fecha de fin de la publicación 
--del mismo si esta última no es nula.
ALTER TABLE GR15_Evento_Edicion DROP CONSTRAINT IF EXISTS CHK_GR15_fechas;
ALTER TABLE GR15_Evento_Edicion ADD CONSTRAINT CHK_GR15_fechas
CHECK ((fecha_inicio_pub < fecha_fin_pub) OR (fecha_fin_pub IS NULL));

--ACTIVA Restriccion a
-- INSERT INTO GR15_Evento_Edicion (id_evento, nro_edicion, fecha_inicio_pub, fecha_fin_pub, presupuesto, fecha_edicion)
--                 VALUES (1, 2, '2020-1-1', '2019-1-1', 1000, NULL);

--b. Cada categoría no debe superar las 50 subcategorías.
--AGREGAR SUBCATEGORIAS A id_categoria=21
CREATE OR REPLACE FUNCTION TRFN_GR15_MaxCategorias
() RETURNS trigger AS $$
BEGIN
	if (
	exists (
			SELECT 1
	FROM GR15_Subcategoria S
	GROUP BY (S.id_categoria)
	HAVING COUNT(*) > 49
			)
		)then
			raise exception 'No puede haber categorias con mas de 50 Subcategorias.';
end
if;
				return new;
END $$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS TR_GR15_Subcategorias_MaxCategorias
ON GR15_Subcategoria;
CREATE TRIGGER TR_GR15_Subcategorias_MaxCategorias
BEFORE
INSERT OR
UPDATE ON GR15_Subcategoria
FOR EACH STATEMENT
EXECUTE PROCEDURE TRFN_GR15_MaxCategorias
();

-- --Activa restriccion b

-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,24, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,25, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,26, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,27, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,28, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,29, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,30, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,31, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,32, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,33, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,34, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,35, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,36, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,37, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,38, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,39, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,40, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,41, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,42, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,43, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,44, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,45, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,46, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,47, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,48, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,49, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,50, 'Sub Categoria 1-24');
-- INSERT INTO GR15_Subcategoria (id_categoria, id_subcategoria, nombre_subcategoria)
--         VALUES (1,51, 'Sub Categoria 1-24');

--c. La suma de los aportes que recibe una edición de un Evento de sus 
--Patrocinantes no puede superar el presupuesto establecido para la misma.

CREATE OR REPLACE FUNCTION TRFN_GR15_LimiteAporte
() RETURNS trigger AS $$
BEGIN
	if (
	exists (
			SELECT e.id_evento, SUM(p.aporte)
	FROM GR15_Patrocinios P NATURAL JOIN GR15_Evento_Edicion E
			GROUP BY
	(e.id_Evento, e.nro_edicion)    
			HAVING SUM
	(P.aporte) <
	(
						SELECT ee.presupuesto
	FROM GR15_Evento_Edicion ee
	WHERE(ee.id_evento = e.id_evento)
						)
	)
		)then
			raise exception 'La suma de los aportes, no puede superar al presupuesto.';
end
if;
				return new;
END $$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS TR_GR15_Patrocinios_LimiteAporte
ON GR15_Patrocinios;
CREATE TRIGGER TR_GR15_Patrocinios_LimiteAporte
BEFORE
INSERT OR
UPDATE ON GR15_Patrocinios
FOR EACH STATEMENT
EXECUTE PROCEDURE TRFN_GR15_LimiteAporte
();

DROP TRIGGER IF EXISTS TR_GR15_Evento_Edicion_LimiteAporte
ON GR15_Evento_Edicion;
CREATE TRIGGER TR_GR15_Evento_Edicion_LimiteAporte
BEFORE
UPDATE ON GR15_Evento_Edicion
FOR EACH STATEMENT
EXECUTE PROCEDURE TRFN_GR15_LimiteAporte
();

-- --Activa restriccion c

-- INSERT INTO gr15_evento (id_evento, nombre_evento, descripcion_evento, id_categoria, id_subcategoria, id_usuario, id_distrito, dia_evento, mes_evento, repetir)
--                 VALUES (3, 'Restric c evento', '1', 1, 1, 1, 22, 10, 5, false);

-- INSERT INTO GR15_patrocinante(id_patrocinate, razon_social, nombre_responsable, apellido_responsable, direccion, id_distrito)
--                 VALUES(504, 'x', 'x','x','x',22);

-- INSERT INTO gr15_Patrocinios (id_patrocinate, id_evento, nro_edicion, aporte)
--                 VALUES (322, 3 , 1, 100001);

-- INSERT INTO gr15_Patrocinios (id_patrocinate, id_evento, nro_edicion, aporte)
--                 VA
--                 LUES (504, 3 , 1, 9991);

--d. Los Patrocinantes solo pueden patrocinar Ediciones de Eventos de su mismo distrito

CREATE OR REPLACE FUNCTION TRFN_GR15_DistritoPatrocinio
() RETURNS trigger AS $$
BEGIN
	if (

	exists (
			SELECT 1
	FROM GR15_Patrocinante P, GR15_Evento E
	WHERE (P.id_patrocinate = new.id_patrocinate) AND (E.id_evento = new.id_evento) AND (P.id_distrito != E.id_distrito)
			)

		)then
			raise exception 'No puede patrocinar eventos de otro distinto distrito';

end
if;
			return new;
END   $$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS TR_GR15_Patrocinios_DistritoPatrocinio
ON GR15_Patrocinios;
CREATE TRIGGER TR_GR15_Patrocinios_DistritoPatrocinio
BEFORE
INSERT OR
UPDATE ON GR15_Patrocinios
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR15_DistritoPatrocinio
();



CREATE OR REPLACE FUNCTION TRFN_GR15_DistritoPatrocinio_2
() RETURNS trigger AS $$
BEGIN
	if (

	exists (
			SELECT 1
	FROM GR15_Evento E
	WHERE (old.id_distrito != new.id_distrito) 
			)

		)then
			raise exception 'No puede modificar el distrito de un evento';

end
if;
			return new;
END   $$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS TR_GR15_Evento_DistritoPatrocinio
ON GR15_Evento;
CREATE TRIGGER TR_GR15_Evento_DistritoPatrocinio
BEFORE
UPDATE ON GR15_Evento
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR15_DistritoPatrocinio_2
();

-- INSERT INTO gr15_Patrocinios (id_patrocinate, id_evento, nro_edicion, aporte)
--                 VALUES (1, 3 , 1, 9991);

-- UPDATE GR15_evento SET id_distrito = '20'
--     WHERE id_evento = '1';

--Servicios

--a)Cuando se crea un Evento, debe crear las Ediciones de ese Evento, 
--colocando como fecha inicial el 1 del mes en el cual se creó el Evento 
--y como presupuesto, el mismo del año pasado más un 10 %, en caso de 
--que no hubiera uno el año pasado, colocar 100.000

CREATE OR REPLACE FUNCTION TRFN_GR15_IniciarEvento
() RETURNS TRIGGER AS $$
DECLARE
	nuevoPresupuesto integer;
	nuevaEdicion integer;
	var_r record;
BEGIN
	if not exists(
        SELECT *
	FROM GR15_Evento E
	WHERE E.id_Evento = NEW.id_Evento
		LIMIT 1    
		)
		then
	INSERT INTO GR15_Evento_Edicion
		(id_Evento, nro_edicion, fecha_inicio_pub, fecha_fin_pub, presupuesto, fecha_Edicion)
	VALUES
		(NEW.id_Evento, 1, make_date(EXTRACT(YEAR FROM(NOW()))
	::integer, NEW.mes_Evento, 1), NULL, 100000, NULL );
else

		var_r :=
(

					SELECT *

FROM GR15_Evento_Edicion EE

WHERE EE.id_Evento = NEW.id_Evento

ORDER BY EE.nro_Edicion DESC

					LIMIT 1

		);

		nuevaEdicion
:= var_r.nro_Edicion +1;

		nuevoPresupuesto := var_r.presupuesto*1.1;

INSERT INTO GR15_Evento_Edicion
	(id_Evento, nro_Edicion, fecha_inicio_pub, fecha_fin_pub, presupuesto, fecha_Edicion)

VALUES
	(NEW.id_Evento, nuevaEdicion, make_date(2020, NEW.mes_Evento, 1), NULL, nuevoPresupuesto, NULL );

end

if;

				return new;

END  $$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS TR_GR15_Evento_IniciarEvento
ON GR15_Evento;
CREATE TRIGGER TR_GR15_Evento_IniciarEvento
BEFORE
INSERT ON
GR15_Evento
FOR
EACH
ROW
EXECUTE PROCEDURE TRFN_GR15_IniciarEvento
();

--b.Todas las fechas, entre Evento y Evento_Edicion 
--(recordar en Evento_Edicion también) tienen que ser coherentes. 
-- fecha_inicio_pub < DATEFROMPARTS(2020, mes_Evento, dia_Evento)

DROP TRIGGER IF EXISTS TR_GR15_Evento_ControlFechas
ON GR15_Evento;

DROP TRIGGER IF EXISTS TR_GR15_Evento_Edicion_ControlFechas
ON GR15_Evento_Edicion;

DROP FUNCTION IF EXISTS TRFN_GR15_ControlFechas
();
CREATE OR REPLACE FUNCTION TRFN_GR15_ControlFechas
() 
RETURNS TRIGGER 
AS $$
DECLARE
	var_r record;
BEGIN
	FOR var_r IN
	(
			SELECT E.id_Evento, E.dia_Evento, E.mes_Evento, EE.fecha_inicio_pub
	FROM GR15_Evento E
		JOIN GR15_Evento_Edicion EE ON (E.id_Evento = EE.id_Evento)
	WHERE ( EXTRACT( MONTH FROM (EE.fecha_inicio_pub))
	::integer >
	(E.mes_Evento)) OR
	( EXTRACT
	( MONTH FROM
	(EE.fecha_inicio_pub))::integer = E.mes_Evento ) AND
	(EXTRACT
	(DAY FROM
	(EE.fecha_inicio_pub))::integer > E.dia_Evento)
			)
	LOOP
	UPDATE GR15_Evento_Edicion EE
	SET fecha_inicio_pub
	= DATEFROMPARTS
	(YEAR
	(getdate
	()), var_r.mes_Evento, var_r.dia_Evento) WHERE id_evento = var_r.id_evento;
END
LOOP;
return new;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR15_Evento_ControlFechas
BEFORE
INSERT OR UPDATE ON
GR15_Evento
FOR
EACH
STATEMENT
EXECUTE PROCEDURE TRFN_GR15_ControlFechas
();


CREATE TRIGGER TR_GR15_Evento_Edicion_ControlFechas
BEFORE
INSERT OR UPDATE ON
GR15_Evento_Edicion
FOR
EACH
STATEMENT
EXECUTE PROCEDURE TRFN_GR15_ControlFechas
();


--VISTAS

--1.Identificador de los Eventos cuya fecha de realización de su último encuentro 
--esté en el primer trimestre de 2020.
DROP VIEW IF EXISTS GR15_Primer_trimestre_2020;
CREATE VIEW GR15_Primer_trimestre_2020
AS
	SELECT id_Evento
	FROM GR15_Evento
	WHERE mes_Evento between 1 and 4;

--2. Datos completos de los distritos indicando la cantidad de Eventos en cada uno
DROP VIEW IF EXISTS GR15_Eventos_por_distrito;
CREATE VIEW GR15_Eventos_por_distrito
AS
	SELECT D.id_distrito, D.nombre_pais, D.nombre_provincia, D.nombre_distrito, COUNT(*) as "Numero de eventos"
	FROM GR15_Distrito D
		JOIN GR15_Evento E ON (D.id_distrito = E.id_distrito)
	GROUP BY D.id_distrito;

--3. Datos Categorías que poseen Eventos en todas sus subcategorías.
DROP VIEW IF EXISTS GR15_Categorias_Todas_Subcategorias;
CREATE VIEW GR15_Categorias_Todas_Subcategorias
AS
	SELECT C.*
	FROM GR15_Categoria C
	WHERE c.id_categoria NOT IN (
		SELECT sub.id_categoria
		FROM GR15_Subcategoria sub 
			LEFT JOIN GR15_Evento e ON (sub.id_categoria = e.id_categoria AND sub.id_subcategoria = e.id_subcategoria)
		WHERE e.id_evento is NULL
	)
;
	
	  



