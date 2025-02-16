--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comunicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comunicacion (
    id_comunicacion integer NOT NULL,
    numero_donante integer,
    fecha_envio date NOT NULL,
    tipo_comunicacion character varying(20) NOT NULL,
    contenido text,
    estado character varying(20) NOT NULL,
    CONSTRAINT comunicacion_estado_check CHECK (((estado)::text = ANY ((ARRAY['enviada'::character varying, 'pendiente'::character varying])::text[]))),
    CONSTRAINT comunicacion_tipo_comunicacion_check CHECK (((tipo_comunicacion)::text = ANY ((ARRAY['correo_electronico'::character varying, 'carta'::character varying])::text[])))
);


ALTER TABLE public.comunicacion OWNER TO postgres;

--
-- Name: comunicacion_id_comunicacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comunicacion_id_comunicacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comunicacion_id_comunicacion_seq OWNER TO postgres;

--
-- Name: comunicacion_id_comunicacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comunicacion_id_comunicacion_seq OWNED BY public.comunicacion.id_comunicacion;


--
-- Name: donacioneconomica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donacioneconomica (
    numero_donacion integer NOT NULL,
    fecha_donacion date NOT NULL,
    importe numeric(15,2) NOT NULL,
    metodo_pago character varying(30) NOT NULL,
    estado_donacion character varying(20) NOT NULL,
    proyecto_destino character varying(200),
    numero_donante integer,
    CONSTRAINT donacioneconomica_estado_donacion_check CHECK (((estado_donacion)::text = ANY ((ARRAY['recibida'::character varying, 'confirmada'::character varying, 'procesada'::character varying])::text[]))),
    CONSTRAINT donacioneconomica_metodo_pago_check CHECK (((metodo_pago)::text = ANY ((ARRAY['tarjeta_credito'::character varying, 'tarjeta_debito'::character varying, 'transferencia_bancaria'::character varying, 'pago_movil'::character varying, 'efectivo'::character varying])::text[])))
);


ALTER TABLE public.donacioneconomica OWNER TO postgres;

--
-- Name: donacioneconomica_numero_donacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donacioneconomica_numero_donacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.donacioneconomica_numero_donacion_seq OWNER TO postgres;

--
-- Name: donacioneconomica_numero_donacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donacioneconomica_numero_donacion_seq OWNED BY public.donacioneconomica.numero_donacion;


--
-- Name: donacionespecie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donacionespecie (
    numero_donacion integer NOT NULL,
    fecha_donacion date NOT NULL,
    descripcion_articulos text NOT NULL,
    cantidad integer NOT NULL,
    unidad_medida character varying(50),
    valor_estimado numeric(15,2),
    estado_donacion character varying(20) NOT NULL,
    proyecto_destino character varying(200),
    numero_donante integer,
    CONSTRAINT donacionespecie_estado_donacion_check CHECK (((estado_donacion)::text = ANY ((ARRAY['recibida'::character varying, 'clasificada'::character varying, 'distribuida'::character varying])::text[])))
);


ALTER TABLE public.donacionespecie OWNER TO postgres;

--
-- Name: donacionespecie_numero_donacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donacionespecie_numero_donacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.donacionespecie_numero_donacion_seq OWNER TO postgres;

--
-- Name: donacionespecie_numero_donacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donacionespecie_numero_donacion_seq OWNED BY public.donacionespecie.numero_donacion;


--
-- Name: donante; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donante (
    numero_donante integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellidos_razon_social character varying(200) NOT NULL,
    direccion character varying(255),
    telefono character varying(20),
    correo_electronico character varying(100) NOT NULL,
    tipo_donante character varying(20) NOT NULL,
    historial_donaciones text,
    preferencias_comunicacion text,
    CONSTRAINT donante_tipo_donante_check CHECK (((tipo_donante)::text = ANY ((ARRAY['individual'::character varying, 'empresa'::character varying, 'fundacion'::character varying])::text[])))
);


ALTER TABLE public.donante OWNER TO postgres;

--
-- Name: donante_numero_donante_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donante_numero_donante_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.donante_numero_donante_seq OWNER TO postgres;

--
-- Name: donante_numero_donante_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donante_numero_donante_seq OWNED BY public.donante.numero_donante;


--
-- Name: informe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.informe (
    id_informe integer NOT NULL,
    tipo_informe character varying(50) NOT NULL,
    fecha_generacion date NOT NULL,
    descripcion text,
    donante_relacionado integer,
    proyecto_relacionado character varying(200),
    total_ingresos numeric(15,2),
    total_gastos numeric(15,2),
    impacto_proyecto text,
    observaciones_auditoria text,
    CONSTRAINT informe_tipo_informe_check CHECK (((tipo_informe)::text = ANY ((ARRAY['donaciones_por_donante'::character varying, 'ingresos_y_gastos'::character varying, 'impacto_proyectos'::character varying, 'auditoria_cumplimiento'::character varying])::text[])))
);


ALTER TABLE public.informe OWNER TO postgres;

--
-- Name: informe_id_informe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.informe_id_informe_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.informe_id_informe_seq OWNER TO postgres;

--
-- Name: informe_id_informe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.informe_id_informe_seq OWNED BY public.informe.id_informe;


--
-- Name: proyecto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.proyecto (
    nombre_proyecto character varying(200) NOT NULL,
    descripcion text,
    ubicacion character varying(255),
    fecha_inicio date NOT NULL,
    fecha_fin date,
    presupuesto numeric(15,2),
    objetivos text,
    beneficiarios text
);
ALTER TABLE ONLY public.proyecto ALTER COLUMN descripcion SET STORAGE EXTERNAL;


ALTER TABLE public.proyecto OWNER TO postgres;

--
-- Name: usofondos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usofondos (
    id_uso_fondos integer NOT NULL,
    proyecto character varying(200),
    partida_presupuestaria character varying(200),
    importe_asignado numeric(15,2) NOT NULL,
    importe_gastado numeric(15,2),
    fecha_gasto date,
    descripcion_gasto text
);


ALTER TABLE public.usofondos OWNER TO postgres;

--
-- Name: usofondos_id_uso_fondos_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usofondos_id_uso_fondos_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usofondos_id_uso_fondos_seq OWNER TO postgres;

--
-- Name: usofondos_id_uso_fondos_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usofondos_id_uso_fondos_seq OWNED BY public.usofondos.id_uso_fondos;


--
-- Name: voluntario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voluntario (
    id_voluntario integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellidos character varying(100) NOT NULL,
    telefono character varying(20),
    correo_electronico character varying(100) NOT NULL,
    proyecto_asignado character varying(200)
);


ALTER TABLE public.voluntario OWNER TO postgres;

--
-- Name: voluntario_id_voluntario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voluntario_id_voluntario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.voluntario_id_voluntario_seq OWNER TO postgres;

--
-- Name: voluntario_id_voluntario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voluntario_id_voluntario_seq OWNED BY public.voluntario.id_voluntario;


--
-- Name: vw_comunicaciones_pendientes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_comunicaciones_pendientes AS
 SELECT c.id_comunicacion,
    (((d.nombre)::text || ' '::text) || (d.apellidos_razon_social)::text) AS nombre_donante,
    c.tipo_comunicacion,
    c.fecha_envio,
    c.estado
   FROM (public.comunicacion c
     JOIN public.donante d ON ((c.numero_donante = d.numero_donante)))
  WHERE ((c.estado)::text = 'pendiente'::text);


ALTER VIEW public.vw_comunicaciones_pendientes OWNER TO postgres;

--
-- Name: vw_donaciones_especie_por_proyecto; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_donaciones_especie_por_proyecto AS
 SELECT p.nombre_proyecto,
    p.descripcion,
    count(ds.numero_donacion) AS cantidad_donaciones,
    sum(((ds.cantidad)::numeric * ds.valor_estimado)) AS valor_total_estimado
   FROM (public.proyecto p
     LEFT JOIN public.donacionespecie ds ON (((p.nombre_proyecto)::text = (ds.proyecto_destino)::text)))
  GROUP BY p.nombre_proyecto, p.descripcion;


ALTER VIEW public.vw_donaciones_especie_por_proyecto OWNER TO postgres;

--
-- Name: vw_donaciones_totales_por_donante; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_donaciones_totales_por_donante AS
 SELECT d.numero_donante,
    (((d.nombre)::text || ' '::text) || (d.apellidos_razon_social)::text) AS nombre_completo,
    sum(de.importe) AS total_donado
   FROM (public.donante d
     LEFT JOIN public.donacioneconomica de ON ((d.numero_donante = de.numero_donante)))
  GROUP BY d.numero_donante, d.nombre, d.apellidos_razon_social;


ALTER VIEW public.vw_donaciones_totales_por_donante OWNER TO postgres;

--
-- Name: vw_gastos_totales_por_proyecto; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_gastos_totales_por_proyecto AS
 SELECT p.nombre_proyecto,
    p.descripcion,
    sum(uf.importe_gastado) AS total_gastado
   FROM (public.proyecto p
     LEFT JOIN public.usofondos uf ON (((p.nombre_proyecto)::text = (uf.proyecto)::text)))
  GROUP BY p.nombre_proyecto, p.descripcion;


ALTER VIEW public.vw_gastos_totales_por_proyecto OWNER TO postgres;

--
-- Name: vw_impacto_proyectos; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_impacto_proyectos AS
 SELECT p.nombre_proyecto,
    p.objetivos,
    COALESCE(sum(de.importe), (0)::numeric) AS total_ingresos,
    COALESCE(sum(uf.importe_gastado), (0)::numeric) AS total_gastos,
    (COALESCE(sum(de.importe), (0)::numeric) - COALESCE(sum(uf.importe_gastado), (0)::numeric)) AS saldo_restante
   FROM ((public.proyecto p
     LEFT JOIN public.donacioneconomica de ON (((p.nombre_proyecto)::text = (de.proyecto_destino)::text)))
     LEFT JOIN public.usofondos uf ON (((p.nombre_proyecto)::text = (uf.proyecto)::text)))
  GROUP BY p.nombre_proyecto, p.objetivos;


ALTER VIEW public.vw_impacto_proyectos OWNER TO postgres;

--
-- Name: vw_informes_generados; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_informes_generados AS
 SELECT i.id_informe,
    i.tipo_informe,
    i.fecha_generacion,
    (((d.nombre)::text || ' '::text) || (d.apellidos_razon_social)::text) AS nombre_donante,
    p.nombre_proyecto,
    i.total_ingresos,
    i.total_gastos,
    i.impacto_proyecto
   FROM ((public.informe i
     LEFT JOIN public.donante d ON ((i.donante_relacionado = d.numero_donante)))
     LEFT JOIN public.proyecto p ON (((i.proyecto_relacionado)::text = (p.nombre_proyecto)::text)));


ALTER VIEW public.vw_informes_generados OWNER TO postgres;

--
-- Name: vw_voluntarios_por_proyecto; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_voluntarios_por_proyecto AS
 SELECT v.id_voluntario,
    (((v.nombre)::text || ' '::text) || (v.apellidos)::text) AS nombre_voluntario,
    v.correo_electronico,
    p.nombre_proyecto,
    p.descripcion
   FROM (public.voluntario v
     JOIN public.proyecto p ON (((v.proyecto_asignado)::text = (p.nombre_proyecto)::text)));


ALTER VIEW public.vw_voluntarios_por_proyecto OWNER TO postgres;

--
-- Name: comunicacion id_comunicacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comunicacion ALTER COLUMN id_comunicacion SET DEFAULT nextval('public.comunicacion_id_comunicacion_seq'::regclass);


--
-- Name: donacioneconomica numero_donacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacioneconomica ALTER COLUMN numero_donacion SET DEFAULT nextval('public.donacioneconomica_numero_donacion_seq'::regclass);


--
-- Name: donacionespecie numero_donacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacionespecie ALTER COLUMN numero_donacion SET DEFAULT nextval('public.donacionespecie_numero_donacion_seq'::regclass);


--
-- Name: donante numero_donante; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donante ALTER COLUMN numero_donante SET DEFAULT nextval('public.donante_numero_donante_seq'::regclass);


--
-- Name: informe id_informe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informe ALTER COLUMN id_informe SET DEFAULT nextval('public.informe_id_informe_seq'::regclass);


--
-- Name: usofondos id_uso_fondos; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usofondos ALTER COLUMN id_uso_fondos SET DEFAULT nextval('public.usofondos_id_uso_fondos_seq'::regclass);


--
-- Name: voluntario id_voluntario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario ALTER COLUMN id_voluntario SET DEFAULT nextval('public.voluntario_id_voluntario_seq'::regclass);


--
-- Data for Name: comunicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comunicacion (id_comunicacion, numero_donante, fecha_envio, tipo_comunicacion, contenido, estado) FROM stdin;
10	2	2025-01-20	correo_electronico	Gracias por su donación al proyecto Educación para Todos.	enviada
12	4	2025-03-10	correo_electronico	Actualización del proyecto Agua Limpia.	enviada
13	5	2025-10-05	correo_electronico	Agradecimiento por su apoyo continuo.	enviada
\.


--
-- Data for Name: donacioneconomica; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donacioneconomica (numero_donacion, fecha_donacion, importe, metodo_pago, estado_donacion, proyecto_destino, numero_donante) FROM stdin;
2	2025-01-15	5000.00	tarjeta_credito	confirmada	Educación para Todos	2
4	2025-03-10	10000.00	pago_movil	recibida	Vivienda Digna	4
5	2025-10-05	2000.00	tarjeta_debito	procesada	Educación para Todos	5
\.


--
-- Data for Name: donacionespecie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donacionespecie (numero_donacion, fecha_donacion, descripcion_articulos, cantidad, unidad_medida, valor_estimado, estado_donacion, proyecto_destino, numero_donante) FROM stdin;
2	2025-01-20	Libros escolares	50	unidades	250.00	clasificada	Educación para Todos	2
3	2025-02-25	Ropa de invierno	100	kilogramos	500.00	distribuida	Agua Limpia	3
4	2025-03-15	Materiales de construcción	200	metros	1000.00	recibida	Vivienda Digna	4
5	2025-10-10	Juguetes educativos	30	unidades	150.00	clasificada	Educación para Todos	5
\.


--
-- Data for Name: donante; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donante (numero_donante, nombre, apellidos_razon_social, direccion, telefono, correo_electronico, tipo_donante, historial_donaciones, preferencias_comunicacion) FROM stdin;
2	Juan	Pérez López	Calle 123, caracas	0412-1238080	juan.perez@gmail.com	individual	Frecuente	Correo electrónico
4	Empresa Solidaria	S.A.	Oficina 789, caracas	0212-9001500	contacto@solidaria.com.ve	empresa	Anual	Correo electrónico
5	Ana	Martínez Torres	Calle 321, caracas	0424-1230000	ana.martinez@gmail.com	individual	Primera vez	Correo electrónico
3	María	García Fernández	Avenida 456, Pueblo	0416-7990000	fernandezmaria@gmail.com	individual	Esporádico	Teléfono
\.


--
-- Data for Name: informe; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.informe (id_informe, tipo_informe, fecha_generacion, descripcion, donante_relacionado, proyecto_relacionado, total_ingresos, total_gastos, impacto_proyecto, observaciones_auditoria) FROM stdin;
2	donaciones_por_donante	2025-01-31	Resumen de donaciones realizadas por Juan Pérez.	2	Educación para Todos	50000.00	45000.00	Alcanzamos a 100 niños.	\N
3	ingresos_y_gastos	2025-02-28	Informe financiero del proyecto Agua Limpia.	3	Agua Limpia	750000.00	700000.00	Beneficiamos a 500 personas.	\N
4	impacto_proyectos	2025-03-31	Impacto del proyecto Vivienda Digna.	4	Vivienda Digna	1000000.00	950000.00	Construidas 20 viviendas.	\N
5	auditoria_cumplimiento	2025-10-31	Auditoría de cumplimiento normativo.	\N	\N	\N	\N	\N	Cumple con todas las regulaciones.
\.


--
-- Data for Name: proyecto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.proyecto (nombre_proyecto, descripcion, ubicacion, fecha_inicio, fecha_fin, presupuesto, objetivos, beneficiarios) FROM stdin;
Educación para Todos	Proyecto educativo en zonas rurales	Región Norte	2025-01-01	2025-12-31	500000.00	Mejorar acceso a educación	Niños y jóvenes
Agua Limpia	Proyecto de acceso a agua potable	Región Sur	2025-03-01	2025-06-30	7500000.00	Instalar sistemas de agua	Comunidades rurales
Vivienda Digna	Construcción de viviendas	Región Central	2025-05-01	2025-11-30	10000000.00	Proporcionar vivienda segura	Familias vulnerables
\.


--
-- Data for Name: usofondos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usofondos (id_uso_fondos, proyecto, partida_presupuestaria, importe_asignado, importe_gastado, fecha_gasto, descripcion_gasto) FROM stdin;
2	Educación para Todos	Material didáctico	100000.00	80000.00	2025-02-01	Compra de libros y cuadernos
3	Agua Limpia	Infraestructura	500000.00	450000.00	2025-03-15	Instalación de tuberías
4	Vivienda Digna	Construcción	750000.00	700000.00	2025-04-10	Compra de materiales
5	Educación para Todos	Capacitación docente	500000.00	400000.00	2025-09-20	Talleres para profesores
\.


--
-- Data for Name: voluntario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voluntario (id_voluntario, nombre, apellidos, telefono, correo_electronico, proyecto_asignado) FROM stdin;
2	Carlos	Ramírez Pérez	0414-0021578	carlos.ramirez@outlook.com	Educación para Todos
3	Laura	Torres Gómez	0424-2345678	laura.torres@outlook.com	Agua Limpia
4	Pedro	Hernández López	0426-2587410	pedro.hernandez@outlook.com	Vivienda Digna
5	Sofía	Martínez Ruiz	0412-5697015	sofia.martinez@outlook.com	Educación para Todos
\.


--
-- Name: comunicacion_id_comunicacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comunicacion_id_comunicacion_seq', 13, true);


--
-- Name: donacioneconomica_numero_donacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donacioneconomica_numero_donacion_seq', 5, true);


--
-- Name: donacionespecie_numero_donacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donacionespecie_numero_donacion_seq', 5, true);


--
-- Name: donante_numero_donante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donante_numero_donante_seq', 5, true);


--
-- Name: informe_id_informe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.informe_id_informe_seq', 5, true);


--
-- Name: usofondos_id_uso_fondos_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usofondos_id_uso_fondos_seq', 5, true);


--
-- Name: voluntario_id_voluntario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voluntario_id_voluntario_seq', 5, true);


--
-- Name: comunicacion comunicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comunicacion
    ADD CONSTRAINT comunicacion_pkey PRIMARY KEY (id_comunicacion);


--
-- Name: donacioneconomica donacioneconomica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacioneconomica
    ADD CONSTRAINT donacioneconomica_pkey PRIMARY KEY (numero_donacion);


--
-- Name: donacionespecie donacionespecie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacionespecie
    ADD CONSTRAINT donacionespecie_pkey PRIMARY KEY (numero_donacion);


--
-- Name: donante donante_correo_electronico_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donante
    ADD CONSTRAINT donante_correo_electronico_key UNIQUE (correo_electronico);


--
-- Name: donante donante_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donante
    ADD CONSTRAINT donante_pkey PRIMARY KEY (numero_donante);


--
-- Name: informe informe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informe
    ADD CONSTRAINT informe_pkey PRIMARY KEY (id_informe);


--
-- Name: proyecto proyecto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.proyecto
    ADD CONSTRAINT proyecto_pkey PRIMARY KEY (nombre_proyecto);


--
-- Name: usofondos usofondos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usofondos
    ADD CONSTRAINT usofondos_pkey PRIMARY KEY (id_uso_fondos);


--
-- Name: voluntario voluntario_correo_electronico_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT voluntario_correo_electronico_key UNIQUE (correo_electronico);


--
-- Name: voluntario voluntario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT voluntario_pkey PRIMARY KEY (id_voluntario);


--
-- Name: idx_comunicacion_estado; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comunicacion_estado ON public.comunicacion USING btree (estado);


--
-- Name: idx_donacion_proyecto_destino; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donacion_proyecto_destino ON public.donacioneconomica USING btree (proyecto_destino);


--
-- Name: idx_donacioneconomica_estado_donacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donacioneconomica_estado_donacion ON public.donacioneconomica USING btree (estado_donacion);


--
-- Name: idx_donacioneconomica_fecha_donacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donacioneconomica_fecha_donacion ON public.donacioneconomica USING btree (fecha_donacion);


--
-- Name: idx_donacioneconomica_proyecto_destino; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donacioneconomica_proyecto_destino ON public.donacioneconomica USING btree (proyecto_destino);


--
-- Name: idx_donacionespecie_proyecto_destino; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donacionespecie_proyecto_destino ON public.donacionespecie USING btree (proyecto_destino);


--
-- Name: idx_donante_correo_electronico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_donante_correo_electronico ON public.donante USING btree (correo_electronico);


--
-- Name: idx_informe_fecha_generacion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_informe_fecha_generacion ON public.informe USING btree (fecha_generacion);


--
-- Name: comunicacion comunicacion_numero_donante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comunicacion
    ADD CONSTRAINT comunicacion_numero_donante_fkey FOREIGN KEY (numero_donante) REFERENCES public.donante(numero_donante);


--
-- Name: donacioneconomica donacioneconomica_numero_donante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacioneconomica
    ADD CONSTRAINT donacioneconomica_numero_donante_fkey FOREIGN KEY (numero_donante) REFERENCES public.donante(numero_donante);


--
-- Name: donacioneconomica donacioneconomica_proyecto_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacioneconomica
    ADD CONSTRAINT donacioneconomica_proyecto_destino_fkey FOREIGN KEY (proyecto_destino) REFERENCES public.proyecto(nombre_proyecto);


--
-- Name: donacionespecie donacionespecie_numero_donante_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacionespecie
    ADD CONSTRAINT donacionespecie_numero_donante_fkey FOREIGN KEY (numero_donante) REFERENCES public.donante(numero_donante);


--
-- Name: donacionespecie donacionespecie_proyecto_destino_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacionespecie
    ADD CONSTRAINT donacionespecie_proyecto_destino_fkey FOREIGN KEY (proyecto_destino) REFERENCES public.proyecto(nombre_proyecto);


--
-- Name: informe informe_donante_relacionado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informe
    ADD CONSTRAINT informe_donante_relacionado_fkey FOREIGN KEY (donante_relacionado) REFERENCES public.donante(numero_donante);


--
-- Name: informe informe_proyecto_relacionado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informe
    ADD CONSTRAINT informe_proyecto_relacionado_fkey FOREIGN KEY (proyecto_relacionado) REFERENCES public.proyecto(nombre_proyecto);


--
-- Name: usofondos usofondos_proyecto_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usofondos
    ADD CONSTRAINT usofondos_proyecto_fkey FOREIGN KEY (proyecto) REFERENCES public.proyecto(nombre_proyecto);


--
-- Name: voluntario voluntario_proyecto_asignado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voluntario
    ADD CONSTRAINT voluntario_proyecto_asignado_fkey FOREIGN KEY (proyecto_asignado) REFERENCES public.proyecto(nombre_proyecto);


--
-- PostgreSQL database dump complete
--

