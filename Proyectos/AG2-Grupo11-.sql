CREATE DATABASE IF NOT EXISTS proyectos;
USE proyectos;
-- Creamos la base de datos si no existe, y con USE indicamos la base de datos que vamos a utilizar

-- Desactivamos la verificación de las restricciones de clave foránea temporalmente para poder 
-- referenciar las tablas entre sí
SET FOREIGN_KEY_CHECKS=0;

-- Creamos la tabla empleados si no existe, indicando que campos pueden o no ser nulos y en especial 
-- indicamos que el sueldo siempre debe ser mayor que 0 y que el municipio, en caso que no se le atribuya un valor
-- tiene por defecto un espacio en blanco.
-- Hemos establecido el tipo de datos de cada tabla y su extensión: 
CREATE TABLE if not exists empleados ( 
	IDEMPLEADO int(11) NOT NULL,
	NOMBRE varchar(25) NOT NULL,
	APELLIDOS varchar(25) NOT NULL,
    SEXO char(1) NOT NULL,
    MUNICIPIO varchar(50) DEFAULT '',  
	FECHA_NAC date,
	SUELDO int(11) CHECK ( SUELDO > 0), 
	IDPTO int(11) 
);

CREATE TABLE if not exists proyectos (
	IDPROYECTO int(11) NOT NULL,
    NOMBRE varchar(25) NOT NULL,
    FECHA_INI date,
    FECHA_FIN date
);

CREATE TABLE if not exists asignacion (
	IDEMPLEADO int(11),
    IDPROYECTO int(11)
);

CREATE TABLE if not exists departamentos (
	IDPTO int(11) NOT NULL,
    NOMBRE varchar(25) NOT NULL,
    PRESUPUESTOS int(11)
);

-- Hemmos llevado a cabo un Bulk insert para la introducción de los datos.

Insert into asignacion (IDEMPLEADO,IDPROYECTO)
values	(10478, 1),
		(10480, 3),
		(10481, 1),
		(10482, 2);

Insert into departamentos (IDPTO, NOMBRE, PRESUPUESTOS)
values	(1, 'I+D', 50000),
		(2, 'Diseño', 25000),
        (3, 'Ventas', 15000),
        (4, 'Marketing', 10000);

Insert into empleados (IDEMPLEADO, NOMBRE, APELLIDOS, SEXO, FECHA_NAC, SUELDO, MUNICIPIO, IDPTO)
values	(10478, 'Alberto', 'Pérez López', 'M', '1965-09-12', 1500, 'Madrid', 1),
		(10479, 'Gloria', 'Ruiz Ruiz', 'F', '1968-06-12', 1650, 'Sevilla', 2),
		(10480, 'Antonio', 'García Montero', 'M', '1969-10-12', 1350, 'Madrid', 1),
		(10481, 'Ana', 'López Ramírez', 'F', '1970-05-12', 1250, 'Sevilla', 3),
		(10482, 'Eduardo', 'Chicón Terrales', 'M', '1920-05-12', 1470, 'Córdoba', 2);
        
Insert into proyectos (IDPROYECTO, NOMBRE, FECHA_INI, FECHA_FIN)
values	(1, 'SINUBE','2018-09-12', '2019-09-12'),
		(2, 'TRASPI', '2017-09-12', '2019-09-12'),
		(3, 'RUNTA','2016-09-12', '2019-09-12'),
		(4, 'CARTAL','2019-05-12', '2019-09-12');

-- Con Alter Table hemos indicado en cada tabla cuales son las claves primarias (son únicas y no aceptan null)
-- y las claves foraneas las cuales nos permiten establecer relación entre tablas. 
-- Hemos creado un indice en la tabla de empleados que nos permite mejorar el rendimiento al filtrar por nombres y apellidos

-- Hemos añadido restricciones de clave externa entre algunas tablas para asegurar la integridad referencial:
-- El valor de los campos seleccionados deberá coincidir entre ellos y además hemos especificado que no se realizarán 
-- acciones automáticas en cascada al eliminar o actualizar filas relacionadas.

ALTER TABLE proyectos
ADD PRIMARY KEY (IDPROYECTO);

ALTER TABLE departamentos
ADD PRIMARY KEY (IDPTO);

ALTER TABLE empleados
ADD PRIMARY KEY (IDEMPLEADO),
ADD CONSTRAINT empleados_ibfk_1 FOREIGN KEY (IDPTO) REFERENCES departamentos (IDPTO) ON DELETE NO ACTION ON UPDATE NO ACTION;
CREATE INDEX indiceEmple ON empleados ( Nombre,Apellidos);  

ALTER TABLE asignacion
ADD CONSTRAINT asignacion_ibfk_1 FOREIGN KEY (IDEMPLEADO) REFERENCES empleados (IDEMPLEADO) ON DELETE NO ACTION ON UPDATE NO ACTION,
ADD CONSTRAINT asignacion_ibfk_2 FOREIGN KEY (IDPROYECTO) REFERENCES proyectos (IDPROYECTO) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Hemos reactivado la verificación de restricciones

SET FOREIGN_KEY_CHECKS=1;


-- REQUISITO 1
-- Creamos la vista y seleccionamos todos los datos de la tabla para poder visualizarlos.

CREATE VIEW vista_asignacion AS
SELECT *
FROM asignacion;

CREATE VIEW vista_departamentos AS
SELECT *
FROM departamentos;

CREATE VIEW vista_empleados AS
SELECT *
FROM empleados;

CREATE VIEW vista_proyectos AS
SELECT *
FROM proyectos;

-- Faltaría ejecutar las vistas:
use proyectos;
select * from vista_asignacion;
select * from vista_departamentos;
select * from vista_empleados;
select * from vista_proyectos;

-- REQUISITO 2
-- Hemos seleccionado todos los proyecto y comparado para que solo extraiga el solicitado

CREATE VIEW proyectos_desde_marzo AS
SELECT NOMBRE, FECHA_INI AS FECHA_DE_INICIO
FROM proyectos
WHERE MONTH(FECHA_INI) > 3;

-- REQUISITO 3
-- Hemos seleccionado solo los registros de los apellidos que contienen Lopez

CREATE VIEW apellido_lopez AS
SELECT NOMBRE, APELLIDOS
FROM empleados
WHERE APELLIDOS LIKE '%López%';

-- REQUISITO 4 Y 5
-- Hemos extraido el Id correspondiente del proyecto a traves del id del empleado, 
-- y despues hemos extraido en nombre del proyecto.

SELECT IDPROYECTO
FROM asignacion
WHERE IDEMPLEADO = '10480';

SELECT NOMBRE
FROM proyectos
WHERE IDPROYECTO = '3';

use proyectos;
SELECT pro.idproyecto, asig.idempleado, pro.nombre
FROM asignacion as asig, proyectos as pro
WHERE asig.idproyecto=pro.idproyecto
and asig.idempleado=10478;
-- Pero los joins cargan mucho la máquina, es mejor subconsultas:
-- Hacerlo con subconsulta:
Select nombre
from proyectos 
WHERE idproyecto = (
		 Select idproyecto
         from asignacion
         where idempleado= 10478
         );
         
-- REQUISITO 6
-- Mostramos los nombres, apellidos y municipios de los empleados residentes en Cordoba o Madrid,
-- de dos formas distintas.

CREATE VIEW empleados_madrid_cordoba_1 AS
SELECT NOMBRE, APELLIDOS, MUNICIPIO
FROM empleados
WHERE MUNICIPIO = 'Madrid' OR MUNICIPIO = 'Córdoba';

CREATE VIEW empleados_madrid_cordoba_2 AS
SELECT NOMBRE, APELLIDOS, MUNICIPIO
FROM empleados
WHERE MUNICIPIO IN ('Madrid', 'Córdoba');

-- REQUISITO 7
-- Funciona de la misma manera que el anterior requisito, 
-- pero esta vez se mostraran los datos de los empleados cuyo sueldo se encuentra entre las cantidades fijadas

CREATE VIEW sueldo_1300_1550 AS
SELECT NOMBRE, APELLIDOS, SUELDO
FROM empleados
WHERE SUELDO BETWEEN 1300 AND 1550;

-- REQUISITO 8
-- Se muestran los datos de los empleados a traves de la fecha de nacimiento.
-- No hay ningún empleado que haya nacido después del 1976.

CREATE VIEW empleados_por_fecha_nacimiento2 AS
SELECT NOMBRE, APELLIDOS, FECHA_NAC as FECHA_NACIMIENTO
FROM empleados
WHERE YEAR(FECHA_NAC) > 1976
ORDER BY FECHA_NAC DESC;

-- SI TENGO EL COMMIT EN ON ES COMO SI CADA SENTENCIA YA TUVIESE INCORPORADO UN COMMIT.
-- SI LO TIENES A OFF TU LOS MARCAS CON LAS TRANSACCIONES
select @@autocommit;
-- lo ponemos a cero:
set autocommit=off;
-- REQUISITO 9
-- Hemos actualizado el presupuesto de la tabla departamento donde nombre coincida con "Marketing".
use proyectos;
start transaction;
UPDATE departamentos
SET PRESUPUESTOS = PRESUPUESTOS + 5000
WHERE NOMBRE = 'Marketing';
rollback;

-- REQUISITO 10
-- Hemos realizado un Select anidado tanto en el SET como en el Where de este UPDATE.
-- Esto es así porque hemos querido indicar que necesitamos por un lado: 
-- 1- Modificar el idproyecto por el que tenga el nombre 'RUNTA' en la tabla proyectos.
-- 2- Y esto hacerlo donde el Id empleado coincida con en nombre y apellidos indicados en la tabla empleados.

UPDATE asignacion
SET IDPROYECTO = (
			  	  SELECT IDPROYECTO
				  FROM proyectos
				  WHERE NOMBRE = 'RUNTA'
				  )
WHERE IDEMPLEADO = (
					SELECT IDEMPLEADO
                    FROM empleados
                    WHERE NOMBRE = 'Alberto' AND APELLIDOS = 'Pérez López'
                    );
                    
-- Para poder visualizar este cambio podemos utilizar el Join, el cual nos une las tablas empleados y proyectos a través
-- de la tabla asignación:

SELECT * 
FROM asignacion
WHERE IDPROYECTO = (
			  	  SELECT IDPROYECTO
				  FROM proyectos
				  WHERE NOMBRE = 'RUNTA'
				  )
AND IDEMPLEADO = (
					SELECT IDEMPLEADO
                    FROM empleados
                    WHERE NOMBRE = 'Alberto' AND APELLIDOS = 'Pérez López'
                    );


SELECT *
FROM asignacion, proyectos, empleados
WHERE asignacion.Idempleado = empleados.Idempleado
AND asignacion.Idproyecto = proyectos.Idproyecto
and empleados.Nombre like 'Alberto' AND empleados.Apellidos like 'Pérez López';

-- REQUISITO 11
-- En dos pasos hemos seleccionado el nombre Antonio de empleados para encontrae su ID y luego
--  le hemos modificado el Idproyecto por null a través del id empleado.
SELECT IDEMPLEADO
FROM EMPLEADOS
WHERE NOMBRE = 'Antonio';

UPDATE asignacion
SET IDPROYECTO = 3
WHERE IDEMPLEADO = '10480';

DELETE FROM asignacion
WHERE idproyecto = (SELECT IDPROYECTO
				  FROM proyectos
				  WHERE NOMBRE = 'RUNTA')
AND IDEMPLEADO IN (SELECT IDEMPLEADO
                    FROM empleados
                    WHERE NOMBRE = 'Alberto' AND APELLIDOS = 'Pérez López'
                    );
 


-- REQUISITO 12
-- Hemos llevado a cabo un Select anidado en el where para poder identificar el ID del departamento con el nombre 'diseño'
-- Y luego una vez teniendo el idDPTO hemos buscado en empleados los que tengan ese ID y un sueldo mayor a 1500

CREATE VIEW empleados_diseno_1500 AS
SELECT *
FROM empleados
WHERE IDPTO = (
			   SELECT IDPTO
               FROM departamentos
               WHERE NOMBRE = 'Diseño'
               )
AND SUELDO >1500;

-- Ejemplo con inner join:
CREATE VIEW InnerJoin_empleados_diseno_1500 AS
SELECT departamentos.idpto , departamentos.nombre, empleados.nombre, empleados.apellidos,
empleados.sueldo
FROM empleados INNER JOIN departamentos ON empleados.idpto=departamentos.idpto
WHERE empleados.sueldo> 1500 AND departamentos.nombre like 'Diseño';


-- REQUISITO 13
-- Hemos llevado a cabo los mismos pasos que el anterior, pero una vez localizado el empleado,
-- le hemos aumentado el sueldo un 5%.
-- Como 

UPDATE empleados
SET SUELDO = SUELDO * 1.05
WHERE IDPTO = (
			   SELECT IDPTO
               FROM departamentos
               WHERE NOMBRE = 'I+D'
               )
AND SUELDO < 1400;

COMMIT;