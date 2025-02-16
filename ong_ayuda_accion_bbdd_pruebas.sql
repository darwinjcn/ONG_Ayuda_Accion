-- Database: ong_ayuda_accion

-- DROP DATABASE IF EXISTS ong_ayuda_accion;

CREATE DATABASE ong_ayuda_accion
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Venezuela.1252'
    LC_CTYPE = 'Spanish_Venezuela.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;


-- Creación de la tabla Donante
CREATE TABLE Donante (
numero_donante SERIAL PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
apellidos_razon_social VARCHAR(200) NOT NULL,
direccion VARCHAR(255),
telefono VARCHAR(20),
correo_electronico VARCHAR(100) UNIQUE NOT NULL,
tipo_donante VARCHAR(20) CHECK (tipo_donante IN ('individual', 'empresa', 'fundacion')) NOT NULL,
historial_donaciones TEXT,
preferencias_comunicacion TEXT
);

-- Creación de la tabla Proyecto
CREATE TABLE Proyecto (
nombre_proyecto VARCHAR(200) PRIMARY KEY,
descripcion TEXT,
ubicacion VARCHAR(255),
fecha_inicio DATE NOT NULL,
fecha_fin DATE,
presupuesto DECIMAL(15, 2),
objetivos TEXT,
beneficiarios TEXT
);

-- Creación de la tabla DonacionEconomica
CREATE TABLE DonacionEconomica (
numero_donacion SERIAL PRIMARY KEY,
fecha_donacion DATE NOT NULL,
importe DECIMAL(15, 2) NOT NULL,
metodo_pago VARCHAR(30) CHECK (metodo_pago IN ('tarjeta_credito', 'transferencia_bancaria', 'efectivo')) NOT NULL,
estado_donacion VARCHAR(20) CHECK (estado_donacion IN ('recibida', 'confirmada', 'procesada')) NOT NULL,
proyecto_destino VARCHAR(200) REFERENCES Proyecto(nombre_proyecto),
numero_donante INT REFERENCES Donante(numero_donante)
);

-- Creación de la tabla DonacionEspecie
CREATE TABLE DonacionEspecie (
numero_donacion SERIAL PRIMARY KEY,
fecha_donacion DATE NOT NULL,
descripcion_articulos TEXT NOT NULL,
cantidad INT NOT NULL,
unidad_medida VARCHAR(50),
valor_estimado DECIMAL(15, 2),
estado_donacion VARCHAR(20) CHECK (estado_donacion IN ('recibida', 'clasificada', 'distribuida')) NOT NULL,
proyecto_destino VARCHAR(200) REFERENCES Proyecto(nombre_proyecto),
numero_donante INT REFERENCES Donante(numero_donante)
);

-- Creación de la tabla UsoFondos
CREATE TABLE UsoFondos (
id_uso_fondos SERIAL PRIMARY KEY,
proyecto VARCHAR(200) REFERENCES Proyecto(nombre_proyecto),
partida_presupuestaria VARCHAR(200),
importe_asignado DECIMAL(15, 2) NOT NULL,
importe_gastado DECIMAL(15, 2),
fecha_gasto DATE,
descripcion_gasto TEXT
);

-- Creación de la tabla Comunicacion
CREATE TABLE Comunicacion (
id_comunicacion SERIAL PRIMARY KEY,
numero_donante INT REFERENCES Donante(numero_donante),
fecha_envio DATE NOT NULL,
tipo_comunicacion VARCHAR(20) CHECK (tipo_comunicacion IN ('correo_electronico', 'carta')) NOT NULL,
contenido TEXT,
estado VARCHAR(20) CHECK (estado IN ('enviada', 'pendiente')) NOT NULL
);

-- Creación de la tabla Voluntario (opcional)
CREATE TABLE Voluntario (
id_voluntario SERIAL PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
apellidos VARCHAR(100) NOT NULL,
telefono VARCHAR(20),
correo_electronico VARCHAR(100) UNIQUE NOT NULL,
proyecto_asignado VARCHAR(200) REFERENCES Proyecto(nombre_proyecto)
);

-- Creación de la tabla Informe
CREATE TABLE Informe (
id_informe SERIAL PRIMARY KEY,
tipo_informe VARCHAR(50) CHECK (tipo_informe IN ('donaciones_por_donante', 'ingresos_y_gastos', 'impacto_proyectos', 'auditoria_cumplimiento')) NOT NULL,
fecha_generacion DATE NOT NULL,
descripcion TEXT,
donante_relacionado INT REFERENCES Donante(numero_donante),
proyecto_relacionado VARCHAR(200) REFERENCES Proyecto(nombre_proyecto),
total_ingresos DECIMAL(15, 2),
total_gastos DECIMAL(15, 2),
impacto_proyecto TEXT,
observaciones_auditoria TEXT
);

-- Modificar la columna metodo_pago para incluir los nuevos valores
ALTER TABLE DonacionEconomica
DROP CONSTRAINT IF EXISTS donacioneconomica_metodo_pago_check;

ALTER TABLE DonacionEconomica
ADD CONSTRAINT donacioneconomica_metodo_pago_check
CHECK (metodo_pago IN ('tarjeta_credito', 'tarjeta_debito', 'transferencia_bancaria', 'pago_movil', 'efectivo'));



-- VISTAS SQL
--Esta vista muestra el total de donaciones económicas realizadas por cada donante.

CREATE VIEW vw_donaciones_totales_por_donante AS
SELECT
d.numero_donante,
d.nombre || ' ' || d.apellidos_razon_social AS nombre_completo,
SUM(de.importe) AS total_donado
FROM
Donante d
LEFT JOIN
DonacionEconomica de ON d.numero_donante = de.numero_donante
GROUP BY
d.numero_donante, d.nombre, d.apellidos_razon_social;

-- Esta vista muestra el total de gastos registrados en cada proyecto.

CREATE VIEW vw_gastos_totales_por_proyecto AS
SELECT
p.nombre_proyecto,
p.descripcion,
SUM(uf.importe_gastado) AS total_gastado
FROM
Proyecto p
LEFT JOIN
UsoFondos uf ON p.nombre_proyecto = uf.proyecto
GROUP BY
p.nombre_proyecto, p.descripcion;

-- Esta vista muestra el impacto de los proyectos basado en las donaciones recibidas y los gastos realizados.

CREATE VIEW vw_impacto_proyectos AS
SELECT
p.nombre_proyecto,
p.objetivos,
COALESCE(SUM(de.importe), 0) AS total_ingresos,
COALESCE(SUM(uf.importe_gastado), 0) AS total_gastos,
COALESCE(SUM(de.importe), 0) - COALESCE(SUM(uf.importe_gastado), 0) AS saldo_restante
FROM
Proyecto p
LEFT JOIN
DonacionEconomica de ON p.nombre_proyecto = de.proyecto_destino
LEFT JOIN
UsoFondos uf ON p.nombre_proyecto = uf.proyecto
GROUP BY
p.nombre_proyecto, p.objetivos;

-- Esta vista muestra las comunicaciones pendientes que aún no han sido enviadas.

CREATE VIEW vw_comunicaciones_pendientes AS
SELECT
c.id_comunicacion,
d.nombre || ' ' || d.apellidos_razon_social AS nombre_donante,
c.tipo_comunicacion,
c.fecha_envio,
c.estado
FROM
Comunicacion c
JOIN
Donante d ON c.numero_donante = d.numero_donante
WHERE
c.estado = 'pendiente';

-- Esta vista muestra los voluntarios asignados a cada proyecto.

CREATE VIEW vw_voluntarios_por_proyecto AS
SELECT
v.id_voluntario,
v.nombre || ' ' || v.apellidos AS nombre_voluntario,
v.correo_electronico,
p.nombre_proyecto,
p.descripcion
FROM
Voluntario v
JOIN
Proyecto p ON v.proyecto_asignado = p.nombre_proyecto;

-- Esta vista muestra los informes generados, incluyendo detalles sobre el tipo de informe, el donante relacionado (si existe) y el proyecto relacionado (si existe).

CREATE VIEW vw_informes_generados AS
SELECT
i.id_informe,
i.tipo_informe,
i.fecha_generacion,
d.nombre || ' ' || d.apellidos_razon_social AS nombre_donante,
p.nombre_proyecto,
i.total_ingresos,
i.total_gastos,
i.impacto_proyecto
FROM
Informe i
LEFT JOIN
Donante d ON i.donante_relacionado = d.numero_donante
LEFT JOIN
Proyecto p ON i.proyecto_relacionado = p.nombre_proyecto;

-- Esta vista muestra las donaciones en especie recibidas por cada proyecto.

CREATE VIEW vw_donaciones_especie_por_proyecto AS
SELECT
p.nombre_proyecto,
p.descripcion,
COUNT(ds.numero_donacion) AS cantidad_donaciones,
SUM(ds.cantidad * ds.valor_estimado) AS valor_total_estimado
FROM
Proyecto p
LEFT JOIN
DonacionEspecie ds ON p.nombre_proyecto = ds.proyecto_destino
GROUP BY
p.nombre_proyecto, p.descripcion;



-- VISTAS SQL

-- Este índice mejora la búsqueda de donantes por su correo electrónico, una operación común al registrar o consultar donantes.

CREATE INDEX idx_donante_correo_electronico ON Donante(correo_electronico);


-- Este índice optimiza las consultas que filtran donaciones económicas por fecha, como informes mensuales o anuales.

CREATE INDEX idx_donacioneconomica_fecha_donacion ON DonacionEconomica(fecha_donacion);


-- Este índice acelera las consultas que filtran donaciones económicas por su estado (recibida, confirmada, procesada).

CREATE INDEX idx_donacioneconomica_estado_donacion ON DonacionEconomica(estado_donacion);


-- Este índice optimiza las consultas que vinculan donaciones económicas o en especie con proyectos específicos.

CREATE INDEX idx_donacion_proyecto_destino ON DonacionEconomica(proyecto_destino);

CREATE INDEX idx_donacionespecie_proyecto_destino ON DonacionEspecie(proyecto_destino);


-- Este índice mejora las consultas que filtran comunicaciones por su estado (enviada, pendiente).

CREATE INDEX idx_comunicacion_estado ON Comunicacion(estado);


-- Este índice optimiza las consultas que filtran informes por su fecha de generación.

CREATE INDEX idx_informe_fecha_generacion ON Informe(fecha_generacion);



-- INSERSION DE DATOS EN LA BBDD
-- Tarea 2.1: Inserción de datos:

INSERT INTO Donante (nombre, apellidos_razon_social, direccion, telefono, correo_electronico, tipo_donante, historial_donaciones, preferencias_comunicacion)
VALUES 
('Juan', 'Pérez López', 'Calle 123, caracas', '0412-1238080', 'juan.perez@gmail.com', 'individual', 'Frecuente', 'Correo electrónico'),
('María', 'García Fernández', 'Avenida 456, Pueblo', '0416-7990000', 'maria.garcia@gmail.com', 'individual', 'Esporádico', 'Teléfono'),
('Empresa Solidaria', 'S.A.', 'Oficina 789, caracas', '0212-9001500', 'contacto@solidaria.com.ve', 'empresa', 'Anual', 'Correo electrónico'),
('Ana', 'Martínez Torres', 'Calle 321, caracas', '0424-1230000', 'ana.martinez@gmail.com', 'individual', 'Primera vez', 'Correo electrónico');


INSERT INTO Proyecto (nombre_proyecto, descripcion, ubicacion, fecha_inicio, fecha_fin, presupuesto, objetivos, beneficiarios)
VALUES 
('Educación para Todos', 'Proyecto educativo en zonas rurales', 'Región Norte', '2025-01-01', '2025-12-31', 500000.00, 'Mejorar acceso a educación', 'Niños y jóvenes'),
('Agua Limpia', 'Proyecto de acceso a agua potable', 'Región Sur', '2025-03-01', '2025-06-30', 7500000.00, 'Instalar sistemas de agua', 'Comunidades rurales'),
('Vivienda Digna', 'Construcción de viviendas', 'Región Central', '2025-05-01', '2025-11-30', 10000000.00, 'Proporcionar vivienda segura', 'Familias vulnerables');


INSERT INTO DonacionEconomica (fecha_donacion, importe, metodo_pago, estado_donacion, proyecto_destino, numero_donante)
VALUES 
('2025-01-15', 5000.00, 'tarjeta_credito', 'confirmada', 'Educación para Todos', 2),
('2025-02-20', 3000.00, 'transferencia_bancaria', 'procesada', 'Agua Limpia', 3),
('2025-03-10', 10000.00, 'pago_movil', 'recibida', 'Vivienda Digna', 4),
('2025-10-05', 2000.00, 'tarjeta_debito', 'confirmada', 'Educación para Todos', 5);


INSERT INTO DonacionEspecie (fecha_donacion, descripcion_articulos, cantidad, unidad_medida, valor_estimado, estado_donacion, proyecto_destino, numero_donante)
VALUES 
('2025-01-20', 'Libros escolares', 50, 'unidades', 250.00, 'clasificada', 'Educación para Todos', 2),
('2025-02-25', 'Ropa de invierno', 100, 'kilogramos', 500.00, 'distribuida', 'Agua Limpia', 3),
('2025-03-15', 'Materiales de construcción', 200, 'metros', 1000.00, 'recibida', 'Vivienda Digna', 4),
('2025-10-10', 'Juguetes educativos', 30, 'unidades', 150.00, 'clasificada', 'Educación para Todos', 5);



INSERT INTO UsoFondos (proyecto, partida_presupuestaria, importe_asignado, importe_gastado, fecha_gasto, descripcion_gasto)
VALUES 
('Educación para Todos', 'Material didáctico', 100000.00, 80000.00, '2025-02-01', 'Compra de libros y cuadernos'),
('Agua Limpia', 'Infraestructura', 500000.00, 450000.00, '2025-03-15', 'Instalación de tuberías'),
('Vivienda Digna', 'Construcción', 750000.00, 700000.00, '2025-04-10', 'Compra de materiales'),
('Educación para Todos', 'Capacitación docente', 500000.00, 400000.00, '2025-09-20', 'Talleres para profesores');


INSERT INTO Comunicacion (numero_donante, fecha_envio, tipo_comunicacion, contenido, estado)
VALUES 
(2, '2025-01-20', 'correo_electronico', 'Gracias por su donación al proyecto Educación para Todos.', 'enviada'),
(3, '2025-02-25', 'carta', 'Informe sobre el impacto de su donación.', 'pendiente'),
(4, '2025-03-10', 'correo_electronico', 'Actualización del proyecto Agua Limpia.', 'enviada'),
(5, '2025-10-05', 'correo_electronico', 'Agradecimiento por su apoyo continuo.', 'enviada');


INSERT INTO Voluntario (nombre, apellidos, telefono, correo_electronico, proyecto_asignado)
VALUES 
('Carlos', 'Ramírez Pérez', '0414-0021578', 'carlos.ramirez@outlook.com', 'Educación para Todos'),
('Laura', 'Torres Gómez', '0424-2345678', 'laura.torres@outlook.com', 'Agua Limpia'),
('Pedro', 'Hernández López', '0426-2587410', 'pedro.hernandez@outlook.com', 'Vivienda Digna'),
('Sofía', 'Martínez Ruiz', '0412-5697015', 'sofia.martinez@outlook.com', 'Educación para Todos');

INSERT INTO Informe (tipo_informe, fecha_generacion, descripcion, donante_relacionado, proyecto_relacionado, total_ingresos, total_gastos, impacto_proyecto, observaciones_auditoria)
VALUES 
('donaciones_por_donante', '2025-01-31', 'Resumen de donaciones realizadas por Juan Pérez.', 2, 'Educación para Todos', 50000.00, 45000.00, 'Alcanzamos a 100 niños.', NULL),
('ingresos_y_gastos', '2025-02-28', 'Informe financiero del proyecto Agua Limpia.', 3, 'Agua Limpia', 750000.00, 700000.00, 'Beneficiamos a 500 personas.', NULL),
('impacto_proyectos', '2025-03-31', 'Impacto del proyecto Vivienda Digna.', 4, 'Vivienda Digna', 1000000.00, 950000.00, 'Construidas 20 viviendas.', NULL),
('auditoria_cumplimiento', '2025-10-31', 'Auditoría de cumplimiento normativo.', NULL, NULL, NULL, NULL, NULL, 'Cumple con todas las regulaciones.');



-- Tarea 2.2: Consultas básicas:
-- Consultar todos los donantes
SELECT 
    numero_donante, 
    nombre, 
    apellidos_razon_social, 
    correo_electronico, 
    tipo_donante 
FROM 
    Donante;


-- Consultar todos los proyectos
SELECT 
    nombre_proyecto, 
    descripcion, 
    ubicacion, 
    fecha_inicio, 
    presupuesto 
FROM 
    Proyecto;


-- Consultar todos los gastos realizados en los proyectos
SELECT 
    uf.proyecto, 
    uf.partida_presupuestaria, 
    uf.importe_asignado, 
    uf.importe_gastado, 
    uf.fecha_gasto, 
    uf.descripcion_gasto 
FROM 
    UsoFondos uf;


-- Consultar todos los voluntarios asignados a proyectos
SELECT 
    v.id_voluntario, 
    v.nombre || ' ' || v.apellidos AS nombre_voluntario, 
    v.correo_electronico, 
    v.proyecto_asignado 
FROM 
    Voluntario v;



-- PUNTO 2.3 CONSULTAS AVANZADAS
-- Consultar todas las donaciones económicas con detalles del donante
SELECT 
    d.numero_donacion, 
    d.fecha_donacion, 
    d.importe, 
    d.metodo_pago, 
    dn.nombre || ' ' || dn.apellidos_razon_social AS nombre_donante, 
    d.proyecto_destino 
FROM 
    DonacionEconomica d
JOIN 
    Donante dn ON d.numero_donante = dn.numero_donante;


-- Consultar todas las donaciones en especie con detalles del donante
SELECT 
    ds.numero_donacion, 
    ds.fecha_donacion, 
    ds.descripcion_articulos, 
    ds.cantidad, 
    ds.valor_estimado, 
    dn.nombre || ' ' || dn.apellidos_razon_social AS nombre_donante, 
    ds.proyecto_destino 
FROM 
    DonacionEspecie ds
JOIN 
    Donante dn ON ds.numero_donante = dn.numero_donante;


-- Consultar todas las comunicaciones enviadas a los donantes
SELECT 
    c.id_comunicacion, 
    dn.nombre || ' ' || dn.apellidos_razon_social AS nombre_donante, 
    c.fecha_envio, 
    c.tipo_comunicacion, 
    c.estado 
FROM 
    Comunicacion c
JOIN 
    Donante dn ON c.numero_donante = dn.numero_donante;


-- Consultar todos los informes generados
SELECT 
    i.id_informe, 
    i.tipo_informe, 
    i.fecha_generacion, 
    i.descripcion, 
    dn.nombre || ' ' || dn.apellidos_razon_social AS nombre_donante, 
    i.proyecto_relacionado, 
    i.total_ingresos, 
    i.total_gastos 
FROM 
    Informe i
LEFT JOIN 
    Donante dn ON i.donante_relacionado = dn.numero_donante;


-- Tarea 2.4: Eliminación de datos:
-- consulta antes de eliminar al donante
SELECT * FROM donacioneconomica;

-- Eliminar todas las donaciones económicas de un proyecto
DELETE FROM DonacionEconomica
WHERE proyecto_destino = 'Agua Limpia';


-- eliminar comunicacion
SELECT * FROM
comunicacion;

-- Eliminar todas las comunicaciones pendientes
DELETE FROM Comunicacion
WHERE estado = 'pendiente';


-- Tarea 2.5: Actualización de datos:
-- consulta antes de actualizar correo
SELECT * FROM
donante;


-- Actualizar el correo electrónico de un donante
UPDATE Donante
SET correo_electronico = 'fernandezmaria@gmail.com'
WHERE numero_donante = 3;

-- nueva consulta despues de actualizar correo
SELECT * FROM
donante;

-- consulta antes de cambiar estado de una donacion economica
SELECT * FROM DonacionEconomica;

-- Cambiar el estado de una donación económica
UPDATE DonacionEconomica
SET estado_donacion = 'procesada'
WHERE numero_donacion = 5;

-- nueva consulta despues de cambiar estado de una donacion economica
SELECT * FROM DonacionEconomica;



-- Fase 3: Diseño Lógico y Físico de la Base de Datos
-- Tarea 3.2: Diseño físico:

-- Usar TOAST
ALTER TABLE Proyecto ALTER COLUMN descripcion SET STORAGE EXTERNAL;


-- Indices frecuentemente consultados (YA FUERON CREADOS MAS ARRIBA, SOLO QUE SE PONEN COMO REFERNCIA PARA LA TAREA)
CREATE INDEX idx_donante_correo_electronico ON Donante(correo_electronico);
CREATE INDEX idx_donacioneconomica_fecha_donacion ON DonacionEconomica(fecha_donacion);


-- Tarea 3.3: Tuneado de Consultas
-- Analizar una consulta para obtener donaciones económicas de un proyecto específico
EXPLAIN ANALYZE
SELECT * FROM DonacionEconomica WHERE proyecto_destino = 'Educación para Todos';

CREATE INDEX idx_donacioneconomica_proyecto_destino ON DonacionEconomica(proyecto_destino);

