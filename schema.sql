--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5
-- Dumped by pg_dump version 10.5

-- Started on 2019-03-12 11:11:16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 9 (class 2615 OID 52114)
-- Name: beta; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA beta;


--
-- TOC entry 1 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 3 (class 3079 OID 50569)
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- TOC entry 2 (class 3079 OID 50580)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- TOC entry 1610 (class 1255 OID 52115)
-- Name: __design_builld_view_project_bathymetry_layer(); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.__design_builld_view_project_bathymetry_layer() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

DROP VIEW beta.view_project_bathymetry_layer;

CREATE VIEW beta.view_project_bathymetry_layer (
    utm_point,
    depth,
    utm_zone,
    utm_lat_band,
    layer_order,
    sediment_type,
    thickness)
AS
SELECT project_bathymetry.utm_point,
    project_bathymetry.depth,
    project_bathymetry.utm_zone,
    project_bathymetry.utm_lat_band,
    project_bathymetry_layer.layer_order,
    project_bathymetry_layer.sediment_type,
    project_bathymetry_layer.zthickness AS thickness
FROM beta.project_bathymetry
     LEFT JOIN beta.project_bathymetry_layer ON project_bathymetry.id =
         project_bathymetry_layer.fk_bathymetry_id;

COMMENT ON VIEW beta.view_project_bathymetry_layer
IS 'This view combines data fro mthe BSTHYMETRY table and the BATHYMETRY LAYER table.
It will return all rows fro mthe BATHYMETRY table and matching rows from the BATHYMETRY LAYER table';


END;
$$;


--
-- TOC entry 1611 (class 1255 OID 52116)
-- Name: __select_lease_boundary(); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.__select_lease_boundary() RETURNS polygon
    LANGUAGE sql
    AS $$
SELECT 
  lease_boundary
FROM 
  beta.farm ;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 214 (class 1259 OID 52117)
-- Name: project_bathymetry; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_bathymetry (
    depth double precision,
    utm_zone integer,
    utm_lat_band character(1),
    id bigint,
    fk_farm_id integer,
    local_index point,
    fk_site_id smallint,
    utm_point public.geometry(Point),
    mannings_no double precision
);


--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN project_bathymetry.depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_bathymetry.depth IS 'Depth at point in metres: positive values';


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN project_bathymetry.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_bathymetry.id IS 'Unique sequential ID for this table';


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN project_bathymetry.fk_farm_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_bathymetry.fk_farm_id IS 'ID of related Farm:  there will not be more than one Farm in the Farm table but this is required to relate each Bathymetry pointto its parent Farm
Alternatively there is an option to dynamically relate the Farm to it''s Bathymetry Point using the Farm Boundary.';


--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN project_bathymetry.local_index; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_bathymetry.local_index IS 'The index of this point w.r.t. the local origin';


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN project_bathymetry.fk_site_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_bathymetry.fk_site_id IS 'ID of related SITE. This ID must be applied usign the coordinates of the site boundary once data is loaded.';


--
-- TOC entry 215 (class 1259 OID 52123)
-- Name: project_bathymetry_layer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_bathymetry_layer (
    id bigint,
    layer_order smallint,
    sediment_type character varying(50),
    zthickness double precision,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    fk_site_id bigint,
    bmry_point public.geometry,
    initial_depth double precision,
    total_depth double precision,
    terminal_depth double precision
);


--
-- TOC entry 216 (class 1259 OID 52129)
-- Name: view_project_bathymetry_layer; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_project_bathymetry_layer AS
 SELECT project_bathymetry.utm_point,
    project_bathymetry.depth,
    project_bathymetry.mannings_no,
    project_bathymetry_layer.layer_order,
    project_bathymetry_layer.sediment_type,
    project_bathymetry_layer.initial_depth,
    project_bathymetry_layer.total_depth,
    project_bathymetry_layer.terminal_depth
   FROM (beta.project_bathymetry
     LEFT JOIN beta.project_bathymetry_layer ON ((project_bathymetry.id = project_bathymetry_layer.fk_bathymetry_id)));


--
-- TOC entry 1612 (class 1255 OID 52133)
-- Name: __select_project_bathymetry_by_polygon(text); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.__select_project_bathymetry_by_polygon(polystring text) RETURNS SETOF beta.view_project_bathymetry_layer
    LANGUAGE sql
    AS $$
SELECT * FROM beta.view_project_bathymetry_layer
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', 0), beta.view_project_bathymetry_layer.utm_point));
$$;


--
-- TOC entry 217 (class 1259 OID 52134)
-- Name: project_cable_corridor_bathymetry; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor_bathymetry (
    depth double precision,
    utm_zone integer,
    utm_lat_band character(1),
    id bigint,
    fk_farm_id integer,
    local_index point,
    fk_site_id smallint,
    utm_point public.geometry,
    mannings_no double precision
);


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN project_cable_corridor_bathymetry.depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_cable_corridor_bathymetry.depth IS 'Depth at point in metres: positive values';


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN project_cable_corridor_bathymetry.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_cable_corridor_bathymetry.id IS 'Unique sequential ID for this table';


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN project_cable_corridor_bathymetry.fk_farm_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_cable_corridor_bathymetry.fk_farm_id IS 'ID of related Farm:  there will not be more than one Farm in the Farm table but this is required to relate each Bathymetry pointto its parent Farm
Alternatively there is an option to dynamically relate the Farm to it''s Bathymetry Point using the Farm Boundary.';


--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN project_cable_corridor_bathymetry.local_index; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_cable_corridor_bathymetry.local_index IS 'The index of this point w.r.t. the local origin';


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN project_cable_corridor_bathymetry.fk_site_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_cable_corridor_bathymetry.fk_site_id IS 'ID of related SITE. This ID must be applied usign the coordinates of the site boundary once data is loaded.';


--
-- TOC entry 218 (class 1259 OID 52140)
-- Name: project_cable_corridor_bathymetry_layer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor_bathymetry_layer (
    id bigint,
    layer_order smallint,
    sediment_type character varying(50),
    zthickness double precision,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    fk_site_id bigint,
    bmry_point public.geometry,
    initial_depth double precision,
    total_depth double precision,
    terminal_depth double precision
);


--
-- TOC entry 219 (class 1259 OID 52146)
-- Name: view_project_cable_corridor_bathymetry_layer; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_project_cable_corridor_bathymetry_layer AS
 SELECT project_cable_corridor_bathymetry.utm_point,
    project_cable_corridor_bathymetry.depth,
    project_cable_corridor_bathymetry.mannings_no,
    project_cable_corridor_bathymetry_layer.layer_order,
    project_cable_corridor_bathymetry_layer.sediment_type,
    project_cable_corridor_bathymetry_layer.initial_depth,
    project_cable_corridor_bathymetry_layer.total_depth,
    project_cable_corridor_bathymetry_layer.terminal_depth
   FROM (beta.project_cable_corridor_bathymetry
     LEFT JOIN beta.project_cable_corridor_bathymetry_layer ON ((project_cable_corridor_bathymetry.id = project_cable_corridor_bathymetry_layer.fk_bathymetry_id)));


--
-- TOC entry 1613 (class 1255 OID 52150)
-- Name: __select_project_cable_corridor_bathymetry_by_polygon(text); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.__select_project_cable_corridor_bathymetry_by_polygon(polystring text) RETURNS SETOF beta.view_project_cable_corridor_bathymetry_layer
    LANGUAGE sql
    AS $$
SELECT * FROM beta.view_project_cable_corridor_bathymetry_layer
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', -1), beta.view_project_cable_corridor_bathymetry_layer.utm_point));
$$;


--
-- TOC entry 220 (class 1259 OID 52151)
-- Name: project_time_series_energy_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_time_series_energy_tidal (
    measure_date date,
    measure_time time(6) without time zone,
    u double precision,
    v double precision,
    id bigint,
    turbulence_intensity double precision,
    ssh double precision,
    fk_point_id bigint
);


--
-- TOC entry 221 (class 1259 OID 52154)
-- Name: view_project_bathymetry_time_series_energy_tidal; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_project_bathymetry_time_series_energy_tidal AS
 SELECT project_bathymetry.depth AS fk_farm_array,
    project_bathymetry.id AS project_bathymetry_id,
    project_bathymetry.fk_farm_id,
    project_bathymetry.local_index,
    project_bathymetry.fk_site_id,
    project_bathymetry.utm_point,
    project_time_series_energy_tidal.measure_date,
    project_time_series_energy_tidal.measure_time,
    project_time_series_energy_tidal.u,
    project_time_series_energy_tidal.v,
    project_time_series_energy_tidal.id,
    project_time_series_energy_tidal.turbulence_intensity,
    project_time_series_energy_tidal.ssh,
    project_time_series_energy_tidal.fk_point_id
   FROM (beta.project_bathymetry
     JOIN beta.project_time_series_energy_tidal ON ((project_bathymetry.id = project_time_series_energy_tidal.fk_point_id)));


--
-- TOC entry 1614 (class 1255 OID 52158)
-- Name: __select_project_tidal_energy_time_series_by_polygon(text); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.__select_project_tidal_energy_time_series_by_polygon(polystring text) RETURNS SETOF beta.view_project_bathymetry_time_series_energy_tidal
    LANGUAGE sql
    AS $$
 SELECT   * FROM   beta.view_project_bathymetry_time_series_energy_tidal
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', 0), beta.view_project_bathymetry_time_series_energy_tidal.utm_point));
$$;


--
-- TOC entry 1615 (class 1255 OID 52159)
-- Name: sp_filter_cable_corridor(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor" 
  SELECT * FROM "beta"."cable_corridor"
  WHERE "beta"."cable_corridor".fk_site_id =
  "site_id"
  ; 
END;$$;


--
-- TOC entry 1616 (class 1255 OID 52160)
-- Name: sp_filter_cable_corridor_constraint(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor_constraint(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor_constraint" 
  SELECT * FROM "beta"."cable_corridor_constraint"
  WHERE "beta"."cable_corridor_constraint".fk_site_farm_id =
  "site_id"
  ; 
END;
$$;


--
-- TOC entry 1617 (class 1255 OID 52161)
-- Name: sp_filter_cable_corridor_constraint_activity_frequency(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor_constraint_activity_frequency(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor_constraint_activity_frequency" 
  SELECT * FROM "beta"."cable_corridor_constraint_activity_frequency"
  WHERE "beta"."cable_corridor_constraint_activity_frequency".fk_site_id =
  "site_id"
  ; 
END;$$;


--
-- TOC entry 1618 (class 1255 OID 52162)
-- Name: sp_filter_cable_corridor_site_bathymetry(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor_site_bathymetry(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor_bathymetry" 
  SELECT * FROM "beta"."cable_corridor_bathymetry"
  WHERE "beta"."cable_corridor_bathymetry".fk_site_id =
  "site_id"
  ;  
END;
$$;


--
-- TOC entry 1619 (class 1255 OID 52163)
-- Name: sp_filter_cable_corridor_site_bathymetry_geotechnic(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor_site_bathymetry_geotechnic(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor_bathymetry_geotechnic" 
  SELECT * FROM "beta"."cable_corridor_bathymetry_geotechnic"
  WHERE "beta"."cable_corridor_bathymetry_geotechnic".fk_site_id =
  "site_id"
  ; 
END;
$$;


--
-- TOC entry 1620 (class 1255 OID 52164)
-- Name: sp_filter_cable_corridor_site_bathymetry_layer(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_cable_corridor_site_bathymetry_layer(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_cable_corridor_bathymetry_layer" 
  SELECT * FROM "beta"."cable_corridor_bathymetry_layer"
  WHERE "beta"."cable_corridor_bathymetry_layer".fk_site_id =
  "site_id"
  ;   
END;
$$;


--
-- TOC entry 1621 (class 1255 OID 52165)
-- Name: sp_filter_constraint(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_constraint(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_constraint" 
  SELECT * FROM "beta"."constraint"
  WHERE "beta"."constraint".fk_site_farm_id =
  "site_id"
  ; 
END;
$$;


--
-- TOC entry 1622 (class 1255 OID 52166)
-- Name: sp_filter_constraint_activity_frequency(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_constraint_activity_frequency(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_constraint_activity_frequency" 
  SELECT * FROM "beta"."constraint_activity_frequency"
  WHERE "beta"."constraint_activity_frequency".fk_site_id =
  "site_id"
  ; 
END;$$;


--
-- TOC entry 1623 (class 1255 OID 52167)
-- Name: sp_filter_device(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_device(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_device" 
  SELECT * FROM "beta"."device"
  WHERE "beta"."device".id =
  "device_id"
  ; 
END;
$$;


--
-- TOC entry 1547 (class 1255 OID 52168)
-- Name: sp_filter_device_data(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_device_data(in_device_id integer) RETURNS void
    LANGUAGE sql
    AS $$
DELETE FROM beta.project_device;
DELETE FROM beta.project_device_power_performance_tidal;
SELECT * FROM beta.sp_filter_device(in_device_id);
SELECT * FROM beta.sp_filter_device_power_performance_tidal(in_device_id);
$$;


--
-- TOC entry 1571 (class 1255 OID 52169)
-- Name: sp_filter_device_power_performance_tidal(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_device_power_performance_tidal(in_device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  
INSERT INTO 
  beta.project_device_power_performance_tidal
(
  fk_device_id,
  velocity,
  thrust_coefficient,
  power_coefficient
)

select * from 
beta.device_power_performance_tidal

where fk_device_id = in_device_id
;
END;
$$;


--
-- TOC entry 1589 (class 1255 OID 52170)
-- Name: sp_filter_farm(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_farm(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_farm" 
  SELECT * FROM "beta"."farm"
  WHERE "beta"."farm".fk_site_id =
  "site_id"
  ; 
END;
$$;


--
-- TOC entry 1590 (class 1255 OID 52171)
-- Name: sp_filter_site(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_site" 
  SELECT * FROM "beta"."site"
  WHERE "beta"."site".id =
  "site_id"
  ; 
END;
$$;


--
-- TOC entry 1607 (class 1255 OID 52172)
-- Name: sp_filter_site_bathymetry(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_bathymetry(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $_$

BEGIN

DELETE FROM beta.project_bathymetry;

EXECUTE (
 SELECT
'INSERT INTO beta.project_bathymetry (' || string_agg(quote_ident(column_name), ',') || ')
 SELECT ' || string_agg('beta.bathymetry.' || quote_ident(column_name), ',') || '
 FROM   beta.bathymetry
 WHERE  beta.bathymetry.fk_site_id = $1;'
FROM   information_schema.columns
WHERE  table_name   = 'bathymetry'       -- table name, case sensitive
AND    table_schema = 'beta'  -- schema name, case sensitive
)
USING site_id;

END;

$_$;


--
-- TOC entry 1599 (class 1255 OID 52173)
-- Name: sp_filter_site_bathymetry_geotechnic(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_bathymetry_geotechnic(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_bathymetry_geotechnic" 
  SELECT * FROM "beta"."bathymetry_geotechnic"
  WHERE "beta"."bathymetry_geotechnic".fk_site_id =
  "site_id"
  ; 
  
END;
$$;


--
-- TOC entry 1624 (class 1255 OID 52174)
-- Name: sp_filter_site_bathymetry_layer(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_bathymetry_layer(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "beta"."project_bathymetry_layer" 
  SELECT * FROM "beta"."bathymetry_layer"
  WHERE "beta"."bathymetry_layer".fk_site_id =
  "site_id"
  ; 
  
END;
$$;


--
-- TOC entry 1625 (class 1255 OID 52175)
-- Name: sp_filter_site_data(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_data(site_id integer) RETURNS void
    LANGUAGE sql
    AS $$
DELETE FROM beta.project_site;
SELECT * FROM beta.sp_filter_site(site_id);

DELETE FROM beta.project_farm;
SELECT * FROM beta.sp_filter_farm(site_id);

DELETE FROM beta.project_cable_corridor;
SELECT * FROM beta.sp_filter_cable_corridor(site_id);

DELETE FROM beta.project_constraint;
SELECT * FROM beta.sp_filter_constraint(site_id);

DELETE FROM beta.project_constraint_activity_frequency;
SELECT * FROM beta.sp_filter_constraint_activity_frequency(site_id);

DELETE FROM beta.project_cable_corridor_constraint;
SELECT * FROM beta.sp_filter_cable_corridor_constraint(site_id);

DELETE FROM beta.project_cable_corridor_constraint_activity_frequency;
SELECT * FROM beta.sp_filter_cable_corridor_constraint_activity_frequency(site_id);

DELETE FROM beta.project_bathymetry;
SELECT * FROM beta.sp_filter_site_bathymetry(site_id);

DELETE FROM beta.project_bathymetry_layer;
SELECT * FROM beta.sp_filter_site_bathymetry_layer(site_id);

DELETE FROM beta.project_bathymetry_geotechnic;
SELECT * FROM beta.sp_filter_site_bathymetry_geotechnic(site_id);

DELETE FROM beta.project_cable_corridor_bathymetry;
SELECT * FROM beta.sp_filter_cable_corridor_site_bathymetry(site_id);

DELETE FROM beta.project_cable_corridor_bathymetry_layer;
SELECT * FROM beta.sp_filter_cable_corridor_site_bathymetry_layer(site_id);

DELETE FROM beta.project_cable_corridor_bathymetry_geotechnic;
SELECT * FROM beta.sp_filter_cable_corridor_site_bathymetry_geotechnic(site_id);

-- Time Series Data
DELETE FROM beta.project_time_series_energy_tidal;
SELECT * FROM beta.sp_filter_site_time_series_energy_tidal(site_id);

DELETE FROM beta.project_time_series_energy_wave;
SELECT * FROM beta.sp_filter_site_time_series_energy_wave(site_id);

DELETE FROM beta.project_time_series_om_tidal;
SELECT * FROM beta.sp_filter_site_time_series_om_tidal(site_id);

DELETE FROM beta.project_time_series_om_wave;
SELECT * FROM beta.sp_filter_site_time_series_om_wave(site_id);

DELETE FROM beta.project_time_series_om_wind;
SELECT * FROM beta.sp_filter_site_time_series_om_wind(site_id);
$$;


--
-- TOC entry 1626 (class 1255 OID 52176)
-- Name: sp_filter_site_time_series_energy_tidal(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_time_series_energy_tidal(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO beta.project_time_series_energy_tidal 
  SELECT beta.time_series_energy_tidal.*
FROM
  beta.bathymetry
  INNER JOIN beta.time_series_energy_tidal 
  ON (beta.time_series_energy_tidal.fk_point_id = beta.bathymetry.id)
  where 
  beta.bathymetry.fk_site_id = site_id
  ; 
  
END;
$$;


--
-- TOC entry 1627 (class 1255 OID 52177)
-- Name: sp_filter_site_time_series_energy_wave(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_time_series_energy_wave(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO beta.project_time_series_energy_wave 
  SELECT beta.time_series_energy_wave.*
FROM
  beta.project_bathymetry_layer
  INNER JOIN beta.time_series_energy_wave 
  ON (beta.project_bathymetry_layer.id = beta.time_series_energy_wave.point_id)
  
   where 
  beta.project_bathymetry_layer.fk_site_id = site_id
  ; 
  
END;
$$;


--
-- TOC entry 1628 (class 1255 OID 52178)
-- Name: sp_filter_site_time_series_om_tidal(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_time_series_om_tidal(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO beta.project_time_series_om_tidal 
  SELECT beta.time_series_om_tidal.*
FROM
  beta.project_farm
  INNER JOIN beta.time_series_om_tidal ON (beta.project_farm.id = beta.time_series_om_tidal.fk_farm_id)
 where 
  beta.project_farm.fk_site_id = site_id
  ; 
  
END;
$$;


--
-- TOC entry 1629 (class 1255 OID 52179)
-- Name: sp_filter_site_time_series_om_wave(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_time_series_om_wave(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO beta.project_time_series_om_wave 
  SELECT beta.time_series_om_wave.*
FROM
  beta.project_farm
  INNER JOIN beta.time_series_om_wave ON (beta.project_farm.id = beta.time_series_om_wave.fk_farm_id)
 where 
  beta.project_farm.fk_site_id = site_id
  ; 
  
END;$$;


--
-- TOC entry 1630 (class 1255 OID 52180)
-- Name: sp_filter_site_time_series_om_wind(integer); Type: FUNCTION; Schema: beta; Owner: -
--

CREATE FUNCTION beta.sp_filter_site_time_series_om_wind(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO beta.project_time_series_om_wind 
  SELECT beta.time_series_om_wind.*
FROM
  beta.project_farm
  INNER JOIN beta.time_series_om_wind ON (beta.project_farm.id = beta.time_series_om_wind.fk_farm_id)
 where 
  beta.project_farm.fk_site_id = site_id
  ; 
  
END;$$;


--
-- TOC entry 222 (class 1259 OID 52181)
-- Name: 400000_bath_layers_initial_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta."400000_bath_layers_initial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 223 (class 1259 OID 52183)
-- Name: 400000_bath_layers_trial_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta."400000_bath_layers_trial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 224 (class 1259 OID 52185)
-- Name: 400000_bath_trial_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta."400000_bath_trial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 225 (class 1259 OID 52187)
-- Name: 400000_soil_type_trial_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta."400000_soil_type_trial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 226 (class 1259 OID 52189)
-- Name: constraint_activity_frequency; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.constraint_activity_frequency (
    id integer NOT NULL,
    constraint_id integer,
    vessel_weight_upper double precision,
    frequency double precision,
    vessel_weight_lower double precision,
    fk_site_id integer
);


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE constraint_activity_frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.constraint_activity_frequency IS 'This tables will store the frequency of commercial traffic in areas of commercial activity.
Each record will be linked to a record in the Constraint Table';


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN constraint_activity_frequency.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_activity_frequency.id IS 'Unique sequential ID for this table
Source: design standards';


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN constraint_activity_frequency.constraint_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_activity_frequency.constraint_id IS 'ID of related constraint record
Source: design standards';


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN constraint_activity_frequency.vessel_weight_upper; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_activity_frequency.vessel_weight_upper IS 'Tonnage of veseel.
Unit to be confirmed
Source: WP3(commercial activity frequency)';


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN constraint_activity_frequency.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_activity_frequency.frequency IS 'Frequency of use of area by vessel
Unit to be confirmed(assumed dimensionless)
Time period to be confirmed.
Source: WP3(commercial activity frequency)';


--
-- TOC entry 227 (class 1259 OID 52192)
-- Name: activity_frequency_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.activity_frequency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 227
-- Name: activity_frequency_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.activity_frequency_id_seq OWNED BY beta.constraint_activity_frequency.id;


--
-- TOC entry 228 (class 1259 OID 52194)
-- Name: bathymetry; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.bathymetry (
    depth double precision,
    utm_zone integer,
    utm_lat_band character(1),
    id bigint NOT NULL,
    fk_farm_id integer,
    local_index point,
    fk_site_id smallint,
    utm_point public.geometry,
    mannings_no double precision
);


--
-- TOC entry 229 (class 1259 OID 52200)
-- Name: bathymetry_geotechnic; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.bathymetry_geotechnic (
    adhesion_factor double precision,
    anchor_soil_parameters double precision,
    bearing_capacity_factor_limit_value double precision,
    bearing_capacity_factor_plain_strain double precision,
    average_undrained_soil_shear_strength double precision,
    representative_undrained_soil_shear_strength_at_tip_level double precision,
    undrained_shear_strength_averaged_over_penetration_depth double precision,
    compression_index double precision,
    correction_factor_subgroups double precision,
    effective_drained_cohesion double precision,
    drained_soil_friction_angle double precision,
    dss_shear_strength double precision,
    reverse_end_bearing_factor double precision,
    coefficient_of_external_shaft_friction double precision,
    holding_capacity_factors double precision,
    holding_capacity_factor_for_drained_soil_condition double precision,
    coefficient_of_internal_shaft_friction_i_e_steel_to_soil double precision,
    lateral_bearing_capacity_factor double precision,
    bearing_capacity_factor_of_buried_mooring_line double precision,
    over_consolidation_ratio double precision,
    pile_maximum_skin_frictional_resistance double precision,
    pile_moment_coefficients double precision,
    pile_tip_maximum_unit_soil_bearing_capacity double precision,
    zzprescribed_footprint_radius double precision,
    relative_soil_density double precision,
    rock_compressive_strength double precision,
    soil_depth_for_each_layer double precision,
    soil_friction_coefficients double precision,
    soil_liquid_limit double precision,
    soil_plastic_limit double precision,
    soil_sensitivity double precision,
    soil_specific_gravity double precision,
    elastic_soil_shear_modulus double precision,
    shape_factor double precision,
    soil_type double precision,
    soil_water_content double precision,
    buoyant_unit_weight_of_soil double precision,
    zzsubsea_cable_connection_point double precision,
    undrained_soil_friction_angle double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision,
    id bigint NOT NULL,
    fk_layer_id bigint,
    fk_site_id bigint,
    undrained_soil_shear_strength_constant_term double precision,
    pile_deflection_coefficients double precision,
    seafloor_friction_coefficient double precision
);


--
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE bathymetry_geotechnic; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.bathymetry_geotechnic IS 'This table records the geotechncial characteristics of a BATHYMETRY LAYER.

Each record in the BATHYMETRY LAYER table will have 0 or 1 matching records in this table.';


--
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.adhesion_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.adhesion_factor IS 'Source: WP4,	site:seafloor:adhesfac	Adhesion factor	Unit:	ND	';


--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.anchor_soil_parameters; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.anchor_soil_parameters IS 'Source: WP4,	site:seafloor:ancparam	Anchor soil parameters	Unit:	ND	';


--
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.bearing_capacity_factor_limit_value; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.bearing_capacity_factor_limit_value IS 'Source: WP4,	site:seafloor:bcflim	Bearing capacity factor limit value	Unit:	ND	';


--
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.bearing_capacity_factor_plain_strain; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.bearing_capacity_factor_plain_strain IS 'Source: WP4,	site:seafloor:bcfplstr	Bearing capacity factor (plain strain)	Unit:	ND	';


--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.average_undrained_soil_shear_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.average_undrained_soil_shear_strength IS 'Source: WP4,	site:seafloor:caisinstallunshstr	Average undrained soil shear strength over penetrated depth at time t after installation	Unit:	N/m^2	';


--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.representative_undrained_soil_shear_strength_at_tip_level; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.representative_undrained_soil_shear_strength_at_tip_level IS 'Source: WP4,	site:seafloor:caistipunshstr	Representative undrained soil shear strength at tip level	Unit:	N/m^2	';


--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.undrained_shear_strength_averaged_over_penetration_depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.undrained_shear_strength_averaged_over_penetration_depth IS 'Source: WP4,	site:seafloor:caisunshstr	Undrained shear strength averaged over penetration depth	Unit:	m/m^2	';


--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.compression_index; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.compression_index IS 'Source: WP4,	site:seafloor:compind	Compression index	Unit:	ND	';


--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.correction_factor_subgroups; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.correction_factor_subgroups IS 'Source: WP4,	site:seafloor:corrfac	Correction factor subgroups 	Unit:	N/A	';


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.effective_drained_cohesion; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.effective_drained_cohesion IS 'Source: WP4,	site:seafloor:draincoh	Effective drained cohesion	Unit:	N/m^2	';


--
-- TOC entry 5050 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.drained_soil_friction_angle; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.drained_soil_friction_angle IS 'Source: WP4,	site:seafloor:dsfang	Drained soil friction angle 	Unit:	deg	';


--
-- TOC entry 5051 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.dss_shear_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.dss_shear_strength IS 'Source: WP4,	site:seafloor:dssshstr	DSS shear strength	Unit:	N/m^2	';


--
-- TOC entry 5052 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.reverse_end_bearing_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.reverse_end_bearing_factor IS 'Source: WP4,	site:seafloor:endbearfac	Reverse end bearing factor (~9)	Unit:	ND	';


--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.coefficient_of_external_shaft_friction; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.coefficient_of_external_shaft_friction IS 'Source: WP4,	site:seafloor:extshfriccoef	Coefficient of external shaft friction (i.e., steel to soil)	Unit:	ND	';


--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.holding_capacity_factors; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.holding_capacity_factors IS 'Source: WP4,	site:seafloor:hcf	Holding capacity factors	Unit:	ND	';


--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.holding_capacity_factor_for_drained_soil_condition; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.holding_capacity_factor_for_drained_soil_condition IS 'Source: WP4,	site:seafloor:hcfdrsoil	Holding capacity factor for drained soil condition	Unit:	ND	';


--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.coefficient_of_internal_shaft_friction_i_e_steel_to_soil; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.coefficient_of_internal_shaft_friction_i_e_steel_to_soil IS 'Source: WP4,	site:seafloor:intshfriccoef	Coefficient of internal shaft friction (i.e., steel to soil)	Unit:	ND	';


--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.lateral_bearing_capacity_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.lateral_bearing_capacity_factor IS 'Source: WP4,	site:seafloor:latbcf	Lateral bearing capacity factor	Unit:	ND	';


--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.bearing_capacity_factor_of_buried_mooring_line; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.bearing_capacity_factor_of_buried_mooring_line IS 'Source: WP4,	site:seafloor:linebcf	Bearing capacity factor of buried mooring line	Unit:	ND	';


--
-- TOC entry 5059 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.over_consolidation_ratio; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.over_consolidation_ratio IS 'Source: WP4,	site:seafloor:ocr	Over-consolidation ratio	Unit:	ND	';


--
-- TOC entry 5060 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.pile_maximum_skin_frictional_resistance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.pile_maximum_skin_frictional_resistance IS 'Source: WP4,	site:seafloor:pilefricres	Pile maximum skin frictional resistance	Unit:	N/m^2	';


--
-- TOC entry 5061 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.pile_moment_coefficients; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.pile_moment_coefficients IS 'Source: WP4,	site:seafloor:pilemomcoef	Pile moment coefficients	Unit:	ND	';


--
-- TOC entry 5062 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.pile_tip_maximum_unit_soil_bearing_capacity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.pile_tip_maximum_unit_soil_bearing_capacity IS 'Source: WP4,	site:seafloor:pilesoilbc	Pile tip maximum unit soil bearing capacity	Unit:	N/m^2	';


--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.zzprescribed_footprint_radius; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.zzprescribed_footprint_radius IS 'Moved to Device
Source: WP4,	site:seafloor:prefootrad	Alternative if foundation/anchor locations havent been specified	Unit:	m';


--
-- TOC entry 5064 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.relative_soil_density; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.relative_soil_density IS 'Source: WP4,	site:seafloor:relsoilden	Relative soil density	Unit:	%	';


--
-- TOC entry 5065 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.rock_compressive_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.rock_compressive_strength IS 'Source: WP4,	site:seafloor:rockcomstr	Rock compressive strength	Unit:	N/m^2	';


--
-- TOC entry 5066 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_depth_for_each_layer; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_depth_for_each_layer IS 'Source: WP4,	site:seafloor:soildep	Soil depth for each layer, Identified soil layers at each grid point up to Layer N (note: Layer 0 at seafloor). Example shows two grid points each with three layers	Unit:	m	';


--
-- TOC entry 5067 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_friction_coefficients; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_friction_coefficients IS 'Source: WP4,	site:seafloor:soilfric	Soil friction coefficients	Unit:	ND	';


--
-- TOC entry 5068 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_liquid_limit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_liquid_limit IS 'Source: WP4,	site:seafloor:soilliqlim	Soil liquid limit	Unit:	%	';


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_plastic_limit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_plastic_limit IS 'Source: WP4,	site:seafloor:soilplalim	Soil plastic limit	Unit:	%	';


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_sensitivity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_sensitivity IS 'Source: WP4,	site:seafloor:soilsen	Soil sensitivity 	Unit:	N/D	';


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_specific_gravity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_specific_gravity IS 'Source: WP4,	site:seafloor:soilsg	Soil specific gravity	Unit:	ND	';


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.elastic_soil_shear_modulus; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.elastic_soil_shear_modulus IS 'Source: WP4,	site:seafloor:soilshmod	Elastic soil shear modulus	Unit:	N/m^2	';


--
-- TOC entry 5073 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.shape_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.shape_factor IS 'Source: WP4,	site:seafloor:soilshpfac	Shape factor	Unit:	ND	';


--
-- TOC entry 5074 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_type IS 'Source: WP4,	site:seafloor:soiltyp	Soil type	Unit:	N/A	';


--
-- TOC entry 5075 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.soil_water_content; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.soil_water_content IS 'Source: WP4,	site:seafloor:soilwatcon	Soil water content	Unit:	%	';


--
-- TOC entry 5076 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.buoyant_unit_weight_of_soil; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.buoyant_unit_weight_of_soil IS 'Source: WP4,	site:seafloor:soilweight	Buoyant unit weight of soil 	Unit:	N/m^3	';


--
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.zzsubsea_cable_connection_point; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.zzsubsea_cable_connection_point IS 'Not requried, output of WP3
Source: WP4,	site:seafloor:subcabconpt	Subsea cable connection point, (x,y,z) w.r.t. global coordinate system	Unit:	m';


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.undrained_soil_friction_angle; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.undrained_soil_friction_angle IS 'Source: WP4,	site:seafloor:unsfang	Undrained soil friction angle 	Unit:	deg	';


--
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.undrained_soil_shear_strength_depth_dependent_term; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.undrained_soil_shear_strength_depth_dependent_term IS 'Changed: Source: bug:
unshstr (list): undrained soil shear strength:  depth dependent term [N/m3],
constant term [N/m2]

Original Source: WP4,	site:seafloor:unshstr	Undrained soil shear strengths 	Unit:	N/m^2';


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.fk_layer_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.fk_layer_id IS 'ID of related bathymetry layer';


--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.fk_site_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.fk_site_id IS 'The id of the related site.
This is used to filter records for a new project.
It is denormalised to this table to imporve performance.';


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN bathymetry_geotechnic.undrained_soil_shear_strength_constant_term; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.bathymetry_geotechnic.undrained_soil_shear_strength_constant_term IS 'Changed: Source: bug:
unshstr (list): undrained soil shear strength:  depth dependent term [N/m2],
constant term [N/m2]

Original Source: WP4,	site:seafloor:unshstr	Undrained soil shear strengths 	Unit:	N/m^2';


--
-- TOC entry 230 (class 1259 OID 52203)
-- Name: bathymetry_geotechnic_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.bathymetry_geotechnic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 230
-- Name: bathymetry_geotechnic_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.bathymetry_geotechnic_id_seq OWNED BY beta.bathymetry_geotechnic.id;


--
-- TOC entry 231 (class 1259 OID 52205)
-- Name: bathymetry_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.bathymetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 231
-- Name: bathymetry_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.bathymetry_id_seq OWNED BY beta.bathymetry.id;


--
-- TOC entry 232 (class 1259 OID 52207)
-- Name: bathymetry_layer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.bathymetry_layer (
    id bigint DEFAULT nextval(('beta.400000_bath_layers_trial_seq'::text)::regclass) NOT NULL,
    layer_order smallint,
    sediment_type character varying(50),
    zthickness double precision,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    fk_site_id bigint,
    bmry_point public.geometry,
    initial_depth double precision,
    total_depth double precision,
    terminal_depth double precision
);


--
-- TOC entry 233 (class 1259 OID 52214)
-- Name: bathymetry_layer_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.bathymetry_layer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 234 (class 1259 OID 52216)
-- Name: cable_corridor; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor (
    id integer NOT NULL,
    current_flow_direction double precision,
    predominant_wave_direction double precision,
    sea_bottom_tidal_current_velocity double precision,
    maximum_seabed_temp double precision,
    maximum_seabed_thermal_resistivity double precision,
    cable_landing_location public.geometry(Point),
    cable_corridor_farm_intersection public.geometry(Point),
    boundary public.geometry(Polygon),
    fk_site_id integer
);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE cable_corridor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.cable_corridor IS 'This table records an area which will cover the corridor through which the export cable will be routed.';


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN cable_corridor.current_flow_direction; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor.current_flow_direction IS 'Unit: degrees
Source: WP3(current flow direction)';


--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN cable_corridor.predominant_wave_direction; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor.predominant_wave_direction IS 'Unit: degrees
Source: WP4(predominant wave direction)';


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN cable_corridor.sea_bottom_tidal_current_velocity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor.sea_bottom_tidal_current_velocity IS 'Source: WP3(Sea bottom tidal current velocity)
Subject to clarification';


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN cable_corridor.maximum_seabed_temp; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor.maximum_seabed_temp IS 'Unit: degrees C
Source: WP3(maximum seabed temperature)';


--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 234
-- Name: COLUMN cable_corridor.maximum_seabed_thermal_resistivity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor.maximum_seabed_thermal_resistivity IS 'Source: WP3(Maximum seabed thermal resistivity)
Unit: ??';


--
-- TOC entry 235 (class 1259 OID 52222)
-- Name: cable_corridor_bathymetry; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor_bathymetry (
    depth double precision,
    utm_zone integer,
    utm_lat_band character(1),
    id bigint NOT NULL,
    fk_farm_id integer,
    local_index point,
    fk_site_id smallint,
    utm_point public.geometry,
    mannings_no double precision
);


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE cable_corridor_bathymetry; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.cable_corridor_bathymetry IS '03/10/2016 - Copied fake data from main site bathymetry to allow testing of corridor functions';


--
-- TOC entry 236 (class 1259 OID 52228)
-- Name: cable_corridor_bathymetry_geotechnic; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor_bathymetry_geotechnic (
    adhesion_factor double precision,
    anchor_soil_parameters double precision,
    bearing_capacity_factor_limit_value double precision,
    bearing_capacity_factor_plain_strain double precision,
    average_undrained_soil_shear_strength double precision,
    representative_undrained_soil_shear_strength_at_tip_level double precision,
    undrained_shear_strength_averaged_over_penetration_depth double precision,
    compression_index double precision,
    correction_factor_subgroups double precision,
    effective_drained_cohesion double precision,
    drained_soil_friction_angle double precision,
    dss_shear_strength double precision,
    reverse_end_bearing_factor double precision,
    coefficient_of_external_shaft_friction double precision,
    holding_capacity_factors double precision,
    holding_capacity_factor_for_drained_soil_condition double precision,
    coefficient_of_internal_shaft_friction_i_e_steel_to_soil double precision,
    lateral_bearing_capacity_factor double precision,
    bearing_capacity_factor_of_buried_mooring_line double precision,
    over_consolidation_ratio double precision,
    pile_maximum_skin_frictional_resistance double precision,
    pile_moment_coefficients double precision,
    pile_tip_maximum_unit_soil_bearing_capacity double precision,
    zzprescribed_footprint_radius double precision,
    relative_soil_density double precision,
    rock_compressive_strength double precision,
    soil_depth_for_each_layer double precision,
    soil_friction_coefficients double precision,
    soil_liquid_limit double precision,
    soil_plastic_limit double precision,
    soil_sensitivity double precision,
    soil_specific_gravity double precision,
    elastic_soil_shear_modulus double precision,
    shape_factor double precision,
    soil_type double precision,
    soil_water_content double precision,
    buoyant_unit_weight_of_soil double precision,
    zzsubsea_cable_connection_point double precision,
    undrained_soil_friction_angle double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision,
    id bigint NOT NULL,
    fk_layer_id bigint,
    fk_site_id bigint,
    undrained_soil_shear_strength_constant_term double precision,
    pile_deflection_coefficients double precision,
    seafloor_friction_coefficient double precision
);


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE cable_corridor_bathymetry_geotechnic; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.cable_corridor_bathymetry_geotechnic IS 'This table records the geotechncial characteristics of a BATHYMETRY LAYER.

Each record in the BATHYMETRY LAYER table will have 0 or 1 matching records in this table.

03/10/2016 - Copied fake data from main site bathymetry to allow testing of corridor functions';


--
-- TOC entry 5093 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.adhesion_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.adhesion_factor IS 'Source: WP4,	site:seafloor:adhesfac	Adhesion factor	Unit:	ND	';


--
-- TOC entry 5094 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.anchor_soil_parameters; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.anchor_soil_parameters IS 'Source: WP4,	site:seafloor:ancparam	Anchor soil parameters	Unit:	ND	';


--
-- TOC entry 5095 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_limit_value; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_limit_value IS 'Source: WP4,	site:seafloor:bcflim	Bearing capacity factor limit value	Unit:	ND	';


--
-- TOC entry 5096 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_plain_strain; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_plain_strain IS 'Source: WP4,	site:seafloor:bcfplstr	Bearing capacity factor (plain strain)	Unit:	ND	';


--
-- TOC entry 5097 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.average_undrained_soil_shear_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.average_undrained_soil_shear_strength IS 'Source: WP4,	site:seafloor:caisinstallunshstr	Average undrained soil shear strength over penetrated depth at time t after installation	Unit:	N/m^2	';


--
-- TOC entry 5098 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.representative_undrained_soil_shear_strength_at_tip_level; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.representative_undrained_soil_shear_strength_at_tip_level IS 'Source: WP4,	site:seafloor:caistipunshstr	Representative undrained soil shear strength at tip level	Unit:	N/m^2	';


--
-- TOC entry 5099 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.undrained_shear_strength_averaged_over_penetration_depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.undrained_shear_strength_averaged_over_penetration_depth IS 'Source: WP4,	site:seafloor:caisunshstr	Undrained shear strength averaged over penetration depth	Unit:	m/m^2	';


--
-- TOC entry 5100 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.compression_index; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.compression_index IS 'Source: WP4,	site:seafloor:compind	Compression index	Unit:	ND	';


--
-- TOC entry 5101 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.correction_factor_subgroups; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.correction_factor_subgroups IS 'Source: WP4,	site:seafloor:corrfac	Correction factor subgroups 	Unit:	N/A	';


--
-- TOC entry 5102 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.effective_drained_cohesion; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.effective_drained_cohesion IS 'Source: WP4,	site:seafloor:draincoh	Effective drained cohesion	Unit:	N/m^2	';


--
-- TOC entry 5103 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.drained_soil_friction_angle; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.drained_soil_friction_angle IS 'Source: WP4,	site:seafloor:dsfang	Drained soil friction angle 	Unit:	deg	';


--
-- TOC entry 5104 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.dss_shear_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.dss_shear_strength IS 'Source: WP4,	site:seafloor:dssshstr	DSS shear strength	Unit:	N/m^2	';


--
-- TOC entry 5105 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.reverse_end_bearing_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.reverse_end_bearing_factor IS 'Source: WP4,	site:seafloor:endbearfac	Reverse end bearing factor (~9)	Unit:	ND	';


--
-- TOC entry 5106 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.coefficient_of_external_shaft_friction; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.coefficient_of_external_shaft_friction IS 'Source: WP4,	site:seafloor:extshfriccoef	Coefficient of external shaft friction (i.e., steel to soil)	Unit:	ND	';


--
-- TOC entry 5107 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.holding_capacity_factors; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.holding_capacity_factors IS 'Source: WP4,	site:seafloor:hcf	Holding capacity factors	Unit:	ND	';


--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.holding_capacity_factor_for_drained_soil_condition; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.holding_capacity_factor_for_drained_soil_condition IS 'Source: WP4,	site:seafloor:hcfdrsoil	Holding capacity factor for drained soil condition	Unit:	ND	';


--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.coefficient_of_internal_shaft_friction_i_e_steel_to_soil; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.coefficient_of_internal_shaft_friction_i_e_steel_to_soil IS 'Source: WP4,	site:seafloor:intshfriccoef	Coefficient of internal shaft friction (i.e., steel to soil)	Unit:	ND	';


--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.lateral_bearing_capacity_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.lateral_bearing_capacity_factor IS 'Source: WP4,	site:seafloor:latbcf	Lateral bearing capacity factor	Unit:	ND	';


--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_of_buried_mooring_line; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.bearing_capacity_factor_of_buried_mooring_line IS 'Source: WP4,	site:seafloor:linebcf	Bearing capacity factor of buried mooring line	Unit:	ND	';


--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.over_consolidation_ratio; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.over_consolidation_ratio IS 'Source: WP4,	site:seafloor:ocr	Over-consolidation ratio	Unit:	ND	';


--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.pile_maximum_skin_frictional_resistance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.pile_maximum_skin_frictional_resistance IS 'Source: WP4,	site:seafloor:pilefricres	Pile maximum skin frictional resistance	Unit:	N/m^2	';


--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.pile_moment_coefficients; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.pile_moment_coefficients IS 'Source: WP4,	site:seafloor:pilemomcoef	Pile moment coefficients	Unit:	ND	';


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.pile_tip_maximum_unit_soil_bearing_capacity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.pile_tip_maximum_unit_soil_bearing_capacity IS 'Source: WP4,	site:seafloor:pilesoilbc	Pile tip maximum unit soil bearing capacity	Unit:	N/m^2	';


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.zzprescribed_footprint_radius; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.zzprescribed_footprint_radius IS 'Moved to Device
Source: WP4,	site:seafloor:prefootrad	Alternative if foundation/anchor locations havent been specified	Unit:	m';


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.relative_soil_density; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.relative_soil_density IS 'Source: WP4,	site:seafloor:relsoilden	Relative soil density	Unit:	%	';


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.rock_compressive_strength; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.rock_compressive_strength IS 'Source: WP4,	site:seafloor:rockcomstr	Rock compressive strength	Unit:	N/m^2	';


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_depth_for_each_layer; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_depth_for_each_layer IS 'Source: WP4,	site:seafloor:soildep	Soil depth for each layer, Identified soil layers at each grid point up to Layer N (note: Layer 0 at seafloor). Example shows two grid points each with three layers	Unit:	m	';


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_friction_coefficients; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_friction_coefficients IS 'Source: WP4,	site:seafloor:soilfric	Soil friction coefficients	Unit:	ND	';


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_liquid_limit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_liquid_limit IS 'Source: WP4,	site:seafloor:soilliqlim	Soil liquid limit	Unit:	%	';


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_plastic_limit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_plastic_limit IS 'Source: WP4,	site:seafloor:soilplalim	Soil plastic limit	Unit:	%	';


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_sensitivity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_sensitivity IS 'Source: WP4,	site:seafloor:soilsen	Soil sensitivity 	Unit:	N/D	';


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_specific_gravity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_specific_gravity IS 'Source: WP4,	site:seafloor:soilsg	Soil specific gravity	Unit:	ND	';


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.elastic_soil_shear_modulus; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.elastic_soil_shear_modulus IS 'Source: WP4,	site:seafloor:soilshmod	Elastic soil shear modulus	Unit:	N/m^2	';


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.shape_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.shape_factor IS 'Source: WP4,	site:seafloor:soilshpfac	Shape factor	Unit:	ND	';


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_type IS 'Source: WP4,	site:seafloor:soiltyp	Soil type	Unit:	N/A	';


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.soil_water_content; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.soil_water_content IS 'Source: WP4,	site:seafloor:soilwatcon	Soil water content	Unit:	%	';


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.buoyant_unit_weight_of_soil; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.buoyant_unit_weight_of_soil IS 'Source: WP4,	site:seafloor:soilweight	Buoyant unit weight of soil 	Unit:	N/m^3	';


--
-- TOC entry 5130 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.zzsubsea_cable_connection_point; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.zzsubsea_cable_connection_point IS 'Not requried, output of WP3
Source: WP4,	site:seafloor:subcabconpt	Subsea cable connection point, (x,y,z) w.r.t. global coordinate system	Unit:	m';


--
-- TOC entry 5131 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.undrained_soil_friction_angle; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.undrained_soil_friction_angle IS 'Source: WP4,	site:seafloor:unsfang	Undrained soil friction angle 	Unit:	deg	';


--
-- TOC entry 5132 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.undrained_soil_shear_strength_depth_dependent_term; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.undrained_soil_shear_strength_depth_dependent_term IS 'Changed: Source: bug:
unshstr (list): undrained soil shear strength:  depth dependent term [N/m3],
constant term [N/m2]

Original Source: WP4,	site:seafloor:unshstr	Undrained soil shear strengths 	Unit:	N/m^2';


--
-- TOC entry 5133 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.fk_layer_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.fk_layer_id IS 'ID of related bathymetry layer';


--
-- TOC entry 5134 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.fk_site_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.fk_site_id IS 'The id of the related site.
This is used to filter records for a new project.
It is denormalised to this table to imporve performance.';


--
-- TOC entry 5135 (class 0 OID 0)
-- Dependencies: 236
-- Name: COLUMN cable_corridor_bathymetry_geotechnic.undrained_soil_shear_strength_constant_term; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_bathymetry_geotechnic.undrained_soil_shear_strength_constant_term IS 'Changed: Source: bug:
unshstr (list): undrained soil shear strength:  depth dependent term [N/m2],
constant term [N/m2]

Original Source: WP4,	site:seafloor:unshstr	Undrained soil shear strengths 	Unit:	N/m^2';


--
-- TOC entry 237 (class 1259 OID 52231)
-- Name: cable_corridor_bathymetry_geotechnic_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.cable_corridor_bathymetry_geotechnic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5136 (class 0 OID 0)
-- Dependencies: 237
-- Name: cable_corridor_bathymetry_geotechnic_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.cable_corridor_bathymetry_geotechnic_id_seq OWNED BY beta.cable_corridor_bathymetry_geotechnic.id;


--
-- TOC entry 238 (class 1259 OID 52233)
-- Name: cable_corridor_bathymetry_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.cable_corridor_bathymetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5137 (class 0 OID 0)
-- Dependencies: 238
-- Name: cable_corridor_bathymetry_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.cable_corridor_bathymetry_id_seq OWNED BY beta.cable_corridor_bathymetry.id;


--
-- TOC entry 239 (class 1259 OID 52235)
-- Name: cable_corridor_bathymetry_layer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor_bathymetry_layer (
    id bigint NOT NULL,
    layer_order smallint,
    sediment_type character varying(50),
    zthickness double precision,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    fk_site_id bigint,
    bmry_point public.geometry,
    initial_depth double precision,
    total_depth double precision,
    terminal_depth double precision
);


--
-- TOC entry 240 (class 1259 OID 52241)
-- Name: cable_corridor_constraint; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor_constraint (
    id integer NOT NULL,
    constraint_type_id integer,
    description text,
    fk_site_farm_id integer,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 5138 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE cable_corridor_constraint; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.cable_corridor_constraint IS 'Ths table records any constraints applicable to the Cable Corridor area
Source: WP3:
Restricted areas
Existing cable routes
Commercial activity areas

03/10/2016 - Copied fake data from main site bathymetry to allow testing of corridor functions
';


--
-- TOC entry 5139 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN cable_corridor_constraint.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_constraint.id IS 'Unique ID of this record';


--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN cable_corridor_constraint.constraint_type_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_constraint.constraint_type_id IS 'ID of related constraint type';


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 240
-- Name: COLUMN cable_corridor_constraint.description; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.cable_corridor_constraint.description IS 'Description of constraint. This may replace Constraint Type ID, depending on usage.';


--
-- TOC entry 241 (class 1259 OID 52247)
-- Name: cable_corridor_constraint_activity_frequency; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.cable_corridor_constraint_activity_frequency (
    id integer NOT NULL,
    constraint_id integer,
    vessel_weight_upper double precision,
    frequency double precision,
    vessel_weight_lower double precision,
    fk_site_id integer
);


--
-- TOC entry 242 (class 1259 OID 52250)
-- Name: cable_corridor_constraint_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.cable_corridor_constraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 242
-- Name: cable_corridor_constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.cable_corridor_constraint_id_seq OWNED BY beta.cable_corridor_constraint.id;


--
-- TOC entry 243 (class 1259 OID 52252)
-- Name: component; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component (
    id bigint NOT NULL,
    fk_component_type_id integer,
    description character varying(200),
    supplier_id integer,
    mass double precision,
    height double precision,
    width double precision,
    length double precision,
    diameter double precision,
    unit character varying(10),
    cost_per_unit double precision,
    mtbf double precision,
    inspection_rate double precision,
    inspection_time double precision,
    maintenance_rate double precision,
    environmental_impact character varying(100),
    category character varying(20),
    reference_quantity double precision,
    colour character varying(30),
    calendar_maintenance_interval integer[],
    soh_function double precision,
    soh_threshold double precision,
    assembly_port boolean,
    bollard_pull double precision,
    density double precision,
    submerged_mass_per_unit_length double precision,
    minimum_breaking_load double precision,
    required_component_reliability double precision,
    load_safety_factor double precision,
    modulus_of_elasticity double precision,
    flexural_stiffness double precision,
    product_code character varying(50),
    weight_air double precision,
    weight_water double precision,
    operational_temp_min double precision,
    operational_temp_max double precision,
    material character varying(20),
    depth double precision,
    load_out_strategy character varying(50),
    transport_method character varying(50),
    component_name character varying(100),
    component_subname character varying(100),
    grade integer,
    yield_stress double precision,
    youngs_modulus double precision,
    thickness double precision,
    connecting_length double precision,
    connecting_size double precision,
    anchor_coefficient double precision[],
    failure_rate double precision[],
    number_failure_modes integer,
    start_date_calendar_based_maintenance date,
    end_date_calendar_based_maintenance date,
    start_date_condition_based_maintenance date,
    end_date_condition_based_maintenance date,
    "Is_floating" boolean,
    code character varying(100),
    centre_of_gravity double precision,
    grout_bond_strength double precision,
    comments text,
    cost double precision,
    dry_mass_per_unit_length double precision,
    wet_mass_per_unit_length double precision,
    dry_unit_mass double precision,
    wet_unit_mass double precision,
    ncfr_lower_bound double precision,
    ncfr_mean double precision,
    ncfr_upper_bound double precision,
    cfr_lower_bound double precision,
    cfr_mean double precision,
    cfr_upper_bound double precision,
    axial_stiffness double precision,
    rope_stiffness_curve double precision[],
    load double precision
);


--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE component; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component IS '
This table records data related to COMPONENTS in the system.

This is based on a hierarchial approach where every component has common characteristics, recorded here.

The specifc characteristics of component types are recorded in related tables, e.g. component_cable.
';


--
-- TOC entry 5144 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.id IS 'Unique sequential ID for each record.
Source: Required for SQLAlchemy mapping';


--
-- TOC entry 5145 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.fk_component_type_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.fk_component_type_id IS 'Related to Component Type Table';


--
-- TOC entry 5146 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.description; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.description IS 'Suppliers description of the component';


--
-- TOC entry 5147 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.mass; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.mass IS 'Source: WP5.Sub-system dry mass	

  Unit:	kg	numerical	Single Value			Define the physical weight of the sub-system components of the device to be assembled on port
Source: WP4, unit Mass, Unit Mass/Length';


--
-- TOC entry 5148 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.diameter; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.diameter IS 'Source: WP4, component:property:compdia
WP3: Cable diameter';


--
-- TOC entry 5149 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.unit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.unit IS 'The unit in which this item is supplied';


--
-- TOC entry 5150 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.cost_per_unit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.cost_per_unit IS 'Source: WP4, component:property:compcost';


--
-- TOC entry 5151 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.mtbf; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.mtbf IS 'man time between failures, expressed in hours?
Check unit';


--
-- TOC entry 5152 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.inspection_rate; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.inspection_rate IS 'Inspection Interval';


--
-- TOC entry 5153 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.inspection_time; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.inspection_time IS 'Inspection Duration';


--
-- TOC entry 5154 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.maintenance_rate; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.maintenance_rate IS 'Maintenance Interval';


--
-- TOC entry 5155 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.environmental_impact; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.environmental_impact IS 'Data type must be defined. Currently set as VARCHAR(100)
Source: WP4, component:property:compenvimp';


--
-- TOC entry 5156 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.category; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.category IS 'The category of component that this component applies to, e.g. electrical, mooring';


--
-- TOC entry 5157 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.reference_quantity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.reference_quantity IS 'The standard number of units that this component can be supplied in. E.g.';


--
-- TOC entry 5158 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.colour; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.colour IS 'Colour of component: appropriate to cables, for environmental theme';


--
-- TOC entry 5159 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.calendar_maintenance_interval; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.calendar_maintenance_interval IS 'number of days between calendar-based maintenance.
Source: WP6, time_between_calendar_maintenance
Should this be a related table of eents?';


--
-- TOC entry 5160 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.soh_function; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.soh_function IS 'Source: WP6, SOH_function
(BP: this parameter belongs to calendar based strategy. Please do not consider at the moment)';


--
-- TOC entry 5161 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.soh_threshold; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.soh_threshold IS 'Source: WP6, SOH_threshold
(BP: this parameter belongs to calendar based strategy. Please do not consider at the moment)';


--
-- TOC entry 5162 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.assembly_port; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.assembly_port IS 'Defines if any assembly is expected to be conducted on port
Source: WP5, assembly on port.';


--
-- TOC entry 5163 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.bollard_pull; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.bollard_pull IS 'Source: WP5
Unit: tonne
Relevant only for towed device/sub-assembly';


--
-- TOC entry 5164 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.density; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.density IS 'Concrete density, Grout density

Source: WP4, (component:property:conden, component:property:groutden)';


--
-- TOC entry 5165 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.submerged_mass_per_unit_length; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.submerged_mass_per_unit_length IS 'Source: WP4:
Component submerged mass per unit length
component:property:compmassleng
Umbilical submerged mass per unit length
component:property:umbmassleng';


--
-- TOC entry 5166 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.minimum_breaking_load; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.minimum_breaking_load IS 'Source: WP4, component:property:compmbl';


--
-- TOC entry 5167 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.required_component_reliability; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.required_component_reliability IS 'Source: WP4, component:property:compreqttf';


--
-- TOC entry 5168 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.load_safety_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.load_safety_factor IS 'Source:WP4, 
Foundation load safety factor
component:property:foundsf
Mooring system load safety factor
component:property:moorsf';


--
-- TOC entry 5169 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.modulus_of_elasticity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.modulus_of_elasticity IS 'Source: WP4, component:property:pilemodulus';


--
-- TOC entry 5170 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.flexural_stiffness; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.flexural_stiffness IS 'Source: WP4, component:property:umbflxstiff	Umbilical flexural stiffness';


--
-- TOC entry 5171 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.product_code; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.product_code IS 'Source: WP3, Product Code';


--
-- TOC entry 5172 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.weight_air; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.weight_air IS 'Unit: kg per unit or pr metre
Source: WP3, Weight in Air';


--
-- TOC entry 5173 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.weight_water; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.weight_water IS 'Unit: kg per unit or pr metre
Source: WP3, Weight in Water';


--
-- TOC entry 5174 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.operational_temp_min; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.operational_temp_min IS 'Source: WP3, Operational temperature, range
May be only relevant to cable records.';


--
-- TOC entry 5175 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.operational_temp_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.operational_temp_max IS 'Source WP3';


--
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.material IS 'Type of material.  Source: WP4, in example of Synthetic Rope';


--
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.load_out_strategy; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.load_out_strategy IS 'Source: WP5
"Load out type list: (skidded; trailer; float away; lift away)
This defines what port characteristics are relevant for the load-out operation of the devices (e.g. dry-dock required, lifting capacities.. etc)"';


--
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.transport_method; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.transport_method IS 'Source: WP5.
Unit:dimensionless
Dry (on deck) or Wet (towed)
"Transportation method list: (deck; tow)
If all device sub-systems are assembled at port it is the full device transportation method otherwise it is the sub-assembly transportation method"';


--
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.component_name; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.component_name IS 'Source: WP4';


--
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.component_subname; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.component_subname IS 'Source: WP4';


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.grade; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.grade IS 'Source: WP4';


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.yield_stress; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.yield_stress IS 'Source: WP4
Refers to Piles';


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.youngs_modulus; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.youngs_modulus IS 'Source: WP4
Refers to Piles';


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.thickness; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.thickness IS 'Source: WP4
Refers to Piles';


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.connecting_length; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.connecting_length IS 'Source: WP4
Refers to Length, Chain, Shackles, Forerunner';


--
-- TOC entry 5186 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.connecting_size; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.connecting_size IS 'Source: WP4
Refers to Anchor';


--
-- TOC entry 5187 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.anchor_coefficient; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.anchor_coefficient IS 'Source: WP4';


--
-- TOC entry 5188 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.failure_rate; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.failure_rate IS 'Source: WP3, 4, 6.
failures per 10^6 (WP4 definition)
To support WP4 there are 6 dimensions
3 for critical, 3 for non-critical.
The first dimension is to be used if only 1 Failure Rate is relevant. (e.g. WP6)';


--
-- TOC entry 5189 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.number_failure_modes; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.number_failure_modes IS 'Source: WP6, number_failure_modes
Number of failure modes for this component
(This is a count of failure mode records for this component)';


--
-- TOC entry 5190 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.start_date_calendar_based_maintenance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.start_date_calendar_based_maintenance IS 'Source: WP6
Start date of calendar-based maintenance for each year';


--
-- TOC entry 5191 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.end_date_calendar_based_maintenance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.end_date_calendar_based_maintenance IS 'Source: WP6
End date of calendar-based maintenance for each year';


--
-- TOC entry 5192 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.start_date_condition_based_maintenance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.start_date_condition_based_maintenance IS 'Source: WP6
Start date of condition-based maintenance for each year';


--
-- TOC entry 5193 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.end_date_condition_based_maintenance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.end_date_condition_based_maintenance IS 'Source: WP6
End date of condition-based maintenance for each year';


--
-- TOC entry 5194 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component."Is_floating"; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component."Is_floating" IS 'WP6, Is_floating

Component is floating and can be towed to port';


--
-- TOC entry 5195 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.code; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.code IS 'Manufacturers product code';


--
-- TOC entry 5196 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.centre_of_gravity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.centre_of_gravity IS 'Source: WP3.';


--
-- TOC entry 5197 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN component.comments; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component.comments IS 'This column is addtionla: it can be used to store the source of data, or any other relevant information.';


--
-- TOC entry 244 (class 1259 OID 52258)
-- Name: component_anchor; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_anchor (
    fk_component_id bigint,
    anchor_type character varying,
    soft_holding_cap_coef_1 double precision,
    soft_holding_cap_coef_2 double precision,
    soft_penetration_coef_1 double precision,
    soft_penetration_coef_2 double precision,
    sand_holding_cap_coef_1 double precision,
    sand_holding_cap_coef_2 double precision,
    sand_penetration_coef_1 double precision,
    sand_penetration_coef_2 double precision
);


--
-- TOC entry 245 (class 1259 OID 52264)
-- Name: component_ancillary; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_ancillary (
    fk_component_id bigint,
    voltage double precision,
    vcurrent double precision,
    frequency double precision,
    real_power double precision,
    reactive_power double precision,
    apparent_power double precision,
    insulation_material character varying(100),
    depth double precision,
    cooling character varying(100),
    operational_temperature double precision,
    outer_coating character varying(100),
    code character varying(100)
);


--
-- TOC entry 5198 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE component_ancillary; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_ancillary IS 'This table records components related to Electrical Ancillary equipment';


--
-- TOC entry 5199 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.fk_component_id IS 'ID of related component record';


--
-- TOC entry 5200 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.voltage IS 'Source: WP3
rms value of voltage between phase-phase';


--
-- TOC entry 5201 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.vcurrent; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.vcurrent IS 'Source: WP3
Rated operating current';


--
-- TOC entry 5202 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.frequency IS 'Source: WP3
Hz	Operating frequency';


--
-- TOC entry 5203 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.real_power; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.real_power IS 'Source: WP3';


--
-- TOC entry 5204 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.reactive_power; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.reactive_power IS 'Source: WP3';


--
-- TOC entry 5205 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.apparent_power; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.apparent_power IS 'Source: WP3';


--
-- TOC entry 5206 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.insulation_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.insulation_material IS 'Source: WP3';


--
-- TOC entry 5207 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.depth IS 'Source: WP3';


--
-- TOC entry 5208 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.cooling; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.cooling IS 'Source: WP3
Definition of the cooling system';


--
-- TOC entry 5209 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.operational_temperature; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.operational_temperature IS 'Source: WP3
Temperature range in which the equipment can operate';


--
-- TOC entry 5210 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN component_ancillary.outer_coating; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_ancillary.outer_coating IS 'Source: WP3
The material of the unit housing';


--
-- TOC entry 246 (class 1259 OID 52267)
-- Name: component_ancillary_fk_component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_ancillary_fk_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5211 (class 0 OID 0)
-- Dependencies: 246
-- Name: component_ancillary_fk_component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_ancillary_fk_component_id_seq OWNED BY beta.component_ancillary.fk_component_id;


--
-- TOC entry 247 (class 1259 OID 52269)
-- Name: component_cable; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_cable (
    number_conductors smallint,
    conductor_csa double precision,
    conductor_material character varying(50),
    maximum_voltage double precision,
    insulation_material character varying(100),
    screen_type character varying(100),
    armouring character varying(100),
    serving character varying(100),
    "rated_voltage_U" double precision,
    resistance_dc_20 double precision,
    resistance_ac_90 double precision,
    inductive_reactance double precision,
    capacitance double precision,
    frequency double precision,
    maximum_pulling_tension double precision,
    minimum_bend_radius double precision,
    fk_component_id integer NOT NULL,
    minimum_voltage double precision,
    code character varying(100),
    rated_current_air double precision,
    rated_current_buried double precision,
    rated_current_jtube double precision,
    cable_type character varying(50),
    fibre_optic double precision,
    cable_diameter double precision,
    conductor_diameter double precision,
    insulation_diameter double precision,
    screen_diameter double precision,
    armouring_thickness double precision,
    impulse_level double precision,
    conductor_short_circuit_current_capacity double precision,
    maximum_conductor_temp_in_service double precision,
    maximum_conductor_temp_in_short_circuit double precision,
    rated_voltage_ou double precision,
    mbr_without_tension double precision,
    mbr_under_tension double precision
);


--
-- TOC entry 5212 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE component_cable; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_cable IS 'The design of this table is based on the Cable Data Field Specification in 20150512_T3_10_CD.docx
Some fields are inherited from the Component Table.';


--
-- TOC entry 5213 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.number_conductors; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.number_conductors IS 'Source: WP3, number of conductors';


--
-- TOC entry 5214 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.conductor_csa; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.conductor_csa IS 'Cross Sectional Area
Units: mm^2
Source: WP3, conductor_csa';


--
-- TOC entry 5215 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.conductor_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.conductor_material IS 'Source: WP3, conductor material';


--
-- TOC entry 5216 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.maximum_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.maximum_voltage IS 'Unit: V
Source: WP3, maximum voltage';


--
-- TOC entry 5217 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.insulation_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.insulation_material IS 'Source: WP3';


--
-- TOC entry 5218 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.screen_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.screen_type IS 'Source: WP3';


--
-- TOC entry 5219 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.armouring; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.armouring IS 'Source: WP3';


--
-- TOC entry 5220 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.serving; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.serving IS 'Source: WP3';


--
-- TOC entry 5221 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable."rated_voltage_U"; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable."rated_voltage_U" IS 'Unit: V
Source: WP3';


--
-- TOC entry 5222 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.resistance_dc_20; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.resistance_dc_20 IS 'Unit:ohm/km
Source: WP3: Electrical Resistance DC 20';


--
-- TOC entry 5223 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.resistance_ac_90; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.resistance_ac_90 IS 'Unit:ohm/km
Source: WP3: Electrical Resistance AC 90';


--
-- TOC entry 5224 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.inductive_reactance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.inductive_reactance IS 'Unit: ohm/km
Source: WP4, Inductive reactance';


--
-- TOC entry 5225 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.capacitance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.capacitance IS 'Unit: uF/km
Source: WP4, capacitance';


--
-- TOC entry 5226 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.frequency IS 'Unit: Hz
Source: WP4, frequency';


--
-- TOC entry 5227 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.maximum_pulling_tension; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.maximum_pulling_tension IS 'Unit: N/A
Source: WP4, maximum_pulling_tension';


--
-- TOC entry 5228 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.minimum_bend_radius; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.minimum_bend_radius IS 'Unit: m
Source: WP4, Minimum bend radius';


--
-- TOC entry 5229 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.minimum_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.minimum_voltage IS 'Unit: V
Source: WP3, minum  voltage
refers to voltage limits.

Unclear whether this refers ot the cable in general or the specific use in the Farm
';


--
-- TOC entry 5230 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.rated_current_air; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.rated_current_air IS 'Unit: A
Source: WP4, Rated current, Bug 56, 12/08/2016';


--
-- TOC entry 5231 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.rated_current_buried; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.rated_current_buried IS 'Unit: A
Source: WP4, Rated current, Bug 56, 12/08/2016';


--
-- TOC entry 5232 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.rated_current_jtube; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.rated_current_jtube IS 'Unit: A
Source: WP4, Rated current, Bug 56, 12/08/2016';


--
-- TOC entry 5233 (class 0 OID 0)
-- Dependencies: 247
-- Name: COLUMN component_cable.cable_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_cable.cable_type IS 'declares if cable is dynamic or static';


--
-- TOC entry 248 (class 1259 OID 52275)
-- Name: component_cable_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_cable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 249 (class 1259 OID 52277)
-- Name: component_collection_point; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_collection_point (
    id integer NOT NULL,
    fk_component_id bigint NOT NULL,
    voltage_1 double precision,
    voltage_2 double precision,
    frequency double precision,
    rated_operating_current double precision,
    conductor_size double precision,
    input_lines integer,
    output_lines integer,
    bus_bar character varying,
    maximum_water_depth double precision,
    connector_type character varying(200),
    connection_equipment character varying(200),
    number_operations integer,
    outer_coating character varying(200),
    operational_temperature double precision,
    foundation character varying(200),
    operating_environment character varying(200),
    fibre_optic integer,
    code character varying(100),
    input_connector_type character varying(200),
    output_connector_type character varying(200),
    cooling character varying(30),
    point_type character varying(30),
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    wet_beam_area double precision,
    dry_beam_area double precision,
    orientation_angle double precision,
    foundation_locations double precision[],
    centre_of_gravity double precision[]
);


--
-- TOC entry 5234 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE component_collection_point; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_collection_point IS 'This table records components related to Electrical Collection Points';


--
-- TOC entry 5235 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.fk_component_id IS 'ID of related component record';


--
-- TOC entry 5236 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.voltage_1; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.voltage_1 IS '	rms value of voltage between phase-phase for low voltage winding		';


--
-- TOC entry 5237 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.voltage_2; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.voltage_2 IS '	rms value of voltage between phase-phase for high voltage winding	This is required if a transformer is included as part of the collection point design	';


--
-- TOC entry 5238 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.frequency IS '	Operating frequency	This may be a range	';


--
-- TOC entry 5239 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.rated_operating_current; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.rated_operating_current IS '	Rated operating current		';


--
-- TOC entry 5240 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.conductor_size; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.conductor_size IS '	Defines cable sizes for which the collection point connector can be used		';


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.input_lines; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.input_lines IS '	Number of input connectors		';


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.output_lines; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.output_lines IS '	Number of output connectors		';


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.bus_bar; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.bus_bar IS '	Bus bar configuration	Default options can be defined for this.	';


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.maximum_water_depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.maximum_water_depth IS '	Maximum water depth to which the unit can operate		';


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.connector_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.connector_type IS '	The type of electrical connection interface	Default options can be defined for this.	';


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.connection_equipment; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.connection_equipment IS '	Installation equipment required to make the connection/disconnection operations	Default options can be defined for this.	';


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.number_operations; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.number_operations IS '	Guaranteed number of mechanical connect/disconnet operations		';


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.outer_coating; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.outer_coating IS '	The material of the unit housing		';


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.operational_temperature; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.operational_temperature IS '	Temperature range in which the equipment can operate	This may be a range of values: expected min and max	';


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.foundation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.foundation IS '	Foundation type	Default options can be defined for this.	';


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.operating_environment; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.operating_environment IS '	Defines if the unit is prepared for subsea, offshore or onshore operation	Default options can be defined for this.	';


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.fibre_optic; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.fibre_optic IS '	The number of fibre optics channels	Zero is allowed	';


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.input_connector_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.input_connector_type IS '	The type of electrical connection interface	Default options can be defined for this.
  Added 12/08/2016, response to bug 54  ';


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.output_connector_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.output_connector_type IS '	The type of electrical connection interface	Default options can be defined for this.
  Added 12/08/2016, response to bug 54  ';


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.cooling; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.cooling IS 'Added in response to Bug 54';


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.point_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.point_type IS 'Added in response to Bug 54.  ';


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.foundation_locations; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.foundation_locations IS 'Required by wp4';


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN component_collection_point.centre_of_gravity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_collection_point.centre_of_gravity IS 'Required by wp4';


--
-- TOC entry 250 (class 1259 OID 52283)
-- Name: component_collection_point_fk_component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_collection_point_fk_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 250
-- Name: component_collection_point_fk_component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_collection_point_fk_component_id_seq OWNED BY beta.component_collection_point.fk_component_id;


--
-- TOC entry 251 (class 1259 OID 52285)
-- Name: component_collection_point_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_collection_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 251
-- Name: component_collection_point_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_collection_point_id_seq OWNED BY beta.component_collection_point.id;


--
-- TOC entry 252 (class 1259 OID 52287)
-- Name: component_connector; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_connector (
    number_contacts integer,
    rated_voltage_u0 double precision,
    rated_voltage_u double precision,
    maximum_rated_voltage double precision,
    rated_current double precision,
    short_circuit_current_capacity double precision,
    frequency double precision,
    contact_resistance double precision,
    fibre_optic integer,
    maximum_water_depth double precision,
    maximum_number_mating_cycles integer,
    mating_force double precision,
    demating_force double precision,
    electrical_cable_csa double precision,
    weight_air double precision,
    weight_water double precision,
    connection_equipment character varying(50),
    outer_coating character varying(200),
    operational_temperature double precision,
    fk_component_id bigint NOT NULL,
    code character varying(100),
    component_type character varying(50),
    electrical_cable_csa_min double precision,
    electrical_cable_csa_max double precision
);


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE component_connector; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_connector IS 'This table records components related to Electrical Connectors';


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.number_contacts; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.number_contacts IS '	Source: WP3	The number of electrical conductors which can be connected	 ';


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.rated_voltage_u0; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.rated_voltage_u0 IS '	Source: WP3	rms value of voltage between phase and earth	 ';


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.rated_voltage_u; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.rated_voltage_u IS '	Source: WP3	rms value of voltage between phase-phase	 ';


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.maximum_rated_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.maximum_rated_voltage IS '	Source: WP3	rms value of the maximum rated voltage phase-phase	 ';


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.rated_current; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.rated_current IS '	Source: WP3	Rated operating current per contact	 ';


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.short_circuit_current_capacity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.short_circuit_current_capacity IS '	Source: WP3	Rated short circuit withstand  current, 1 second value	 ';


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.frequency IS '	Source: WP3	Operating frequency	 ';


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.contact_resistance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.contact_resistance IS '	Source: WP3	Electrical resistance of contact	 ';


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.fibre_optic; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.fibre_optic IS '	Source: WP3	The number of fibre optics channels	 ';


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.maximum_water_depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.maximum_water_depth IS '	Source: WP3	Maximum operating depth	 ';


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.maximum_number_mating_cycles; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.maximum_number_mating_cycles IS '	Source: WP3	Maximum number of connect/disconnect operations	 ';


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.mating_force; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.mating_force IS '	Source: WP3	Force required to make connection	 ';


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.demating_force; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.demating_force IS '	Source: WP3	Force requried to make disconnection	 ';


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.electrical_cable_csa; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.electrical_cable_csa IS '	Source: WP3	Defines cable sizes for which the connector can be used	 ';


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.weight_air; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.weight_air IS '	Source: WP3	Unit weight in air	 ';


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.weight_water; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.weight_water IS '	Source: WP3	Unit weight in water	 ';


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.connection_equipment; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.connection_equipment IS '	Source: WP3	Installation equipment required to make the connection/disconnection operations	 ';


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.outer_coating; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.outer_coating IS '	Source: WP3	The material of the connector housing	 ';


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.operational_temperature; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.operational_temperature IS '	Source: WP3	Temperature range in which the equipment can operate	 ';


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.fk_component_id IS 'ID of related component record';


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN component_connector.component_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_connector.component_type IS 'declares if the component is wet or dry';


--
-- TOC entry 253 (class 1259 OID 52290)
-- Name: component_connector_fk_component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_connector_fk_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 253
-- Name: component_connector_fk_component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_connector_fk_component_id_seq OWNED BY beta.component_connector.fk_component_id;


--
-- TOC entry 254 (class 1259 OID 52292)
-- Name: om_failure_mode; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_failure_mode (
    fk_component_id integer NOT NULL,
    mode_probability double precision,
    id integer NOT NULL,
    spare_mass double precision,
    spare_height double precision,
    spare_width double precision,
    spare_length double precision,
    cost_spare double precision,
    cost_spare_transit double precision,
    cost_spare_loading double precision,
    lead_time_spare double precision
);


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE om_failure_mode; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_failure_mode IS 'This table records the Failure Modes which are associated with Components.
Failure Modes are component-specific so there is a 1 to Many relationship
between records in the Component Table and records in this table.

The fields have been checked against the final set of paraemters

Design Check: 06/01/2016

';


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.mode_probability; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.mode_probability IS 'Probability of occurrence of each failure modes
Source: WP6';


--
-- TOC entry 5286 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.id IS 'Unique sequential ID.
Each record is uniquely identified by the combination of Component Id and Failure Mode Id
Source: WP6
but this makes it easier to identify a single record.
Source : WP6';


--
-- TOC entry 5287 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.spare_mass; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.spare_mass IS 'mass of the spare parts required
Source: WP6.';


--
-- TOC entry 5288 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.spare_height; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.spare_height IS 'height of the spare parts required
Source: WP6.';


--
-- TOC entry 5289 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.spare_width; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.spare_width IS 'width of the spare parts required
Source: WP6.';


--
-- TOC entry 5290 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.spare_length; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.spare_length IS 'length of the spare parts required
Source: WP6.';


--
-- TOC entry 5291 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.cost_spare; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.cost_spare IS 'cost of the spare parts required
Source: WP6.';


--
-- TOC entry 5292 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.cost_spare_transit; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.cost_spare_transit IS 'cost of the transport of spare parts required
Source: WP6.';


--
-- TOC entry 5293 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.cost_spare_loading; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.cost_spare_loading IS 'cost of the transport of spare parts required
Source: WP6.';


--
-- TOC entry 5294 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN om_failure_mode.lead_time_spare; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode.lead_time_spare IS 'Source: WP6
Lead time for spare parts required Source: WP6 [d].';


--
-- TOC entry 255 (class 1259 OID 52295)
-- Name: component_failure_mode_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_failure_mode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5295 (class 0 OID 0)
-- Dependencies: 255
-- Name: component_failure_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_failure_mode_id_seq OWNED BY beta.om_failure_mode.id;


--
-- TOC entry 256 (class 1259 OID 52297)
-- Name: component_functional_area; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_functional_area (
    id integer NOT NULL,
    descr character varying(50)
);


--
-- TOC entry 5296 (class 0 OID 0)
-- Dependencies: 256
-- Name: TABLE component_functional_area; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_functional_area IS 'This table is used to record a set of Functional Areas.

This is used to group components into the area to which they apply, e.g. Moorings, Foundations, Electrical.';


--
-- TOC entry 5297 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN component_functional_area.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_functional_area.id IS 'Unique ID of this record';


--
-- TOC entry 5298 (class 0 OID 0)
-- Dependencies: 256
-- Name: COLUMN component_functional_area.descr; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_functional_area.descr IS 'Description of Functional Area, e.g. Moorings and Foundations';


--
-- TOC entry 257 (class 1259 OID 52300)
-- Name: component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5299 (class 0 OID 0)
-- Dependencies: 257
-- Name: component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_id_seq OWNED BY beta.component.id;


--
-- TOC entry 258 (class 1259 OID 52302)
-- Name: component_mooring; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_mooring (
    id bigint DEFAULT nextval('beta.component_id_seq'::regclass) NOT NULL,
    transport_method character varying(50),
    suction_caisson_uplift_capacity_factor double precision,
    mooring_safety_factor_uls double precision,
    grout_safety_factor double precision,
    fk_component_id bigint,
    code character varying(100)
);


--
-- TOC entry 5300 (class 0 OID 0)
-- Dependencies: 258
-- Name: TABLE component_mooring; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_mooring IS '
This table recrods components which are specific to the Moorings and Foundations module.

It inherits some characteristics from the Component table.';


--
-- TOC entry 5301 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN component_mooring.suction_caisson_uplift_capacity_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_mooring.suction_caisson_uplift_capacity_factor IS 'Source: WP4.
Suction caisson uplift capacity factor
Range 7 to 11, (9 is commonly used) Ref: Jensen';


--
-- TOC entry 5302 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN component_mooring.mooring_safety_factor_uls; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_mooring.mooring_safety_factor_uls IS 'Source: WP4
Mooring safety factor ULS';


--
-- TOC entry 5303 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN component_mooring.grout_safety_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_mooring.grout_safety_factor IS 'Source: WP4
Grout Safety Factor';


--
-- TOC entry 5304 (class 0 OID 0)
-- Dependencies: 258
-- Name: COLUMN component_mooring.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_mooring.fk_component_id IS 'ID of related component';


--
-- TOC entry 259 (class 1259 OID 52306)
-- Name: component_power_quality; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_power_quality (
    id integer NOT NULL,
    fk_component_id bigint NOT NULL,
    control_system character varying(200),
    rated_voltage double precision,
    frequency double precision,
    reactive_power_rating double precision,
    insulation_material character varying(200),
    number_of_control_stages integer,
    reactive_power_of_each_stage double precision,
    switching_time double precision,
    operating_environment character varying(200),
    height_without_control_system double precision,
    width_without_control_system double precision,
    depth_without_control_system double precision,
    height_including_control_system double precision,
    width_including_control_system double precision,
    depth_including_control_system double precision,
    cooling character varying(200),
    remote_controlled boolean,
    outer_coating character varying(200),
    operational_temperature double precision,
    maximum_water_depth double precision,
    code character varying(100),
    component_type character varying(100)
);


--
-- TOC entry 5305 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE component_power_quality; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_power_quality IS 'This table records components related to Electrical Power Quality Components';


--
-- TOC entry 5306 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.id IS 'This table records components related to Power Qualitt';


--
-- TOC entry 5307 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.fk_component_id IS 'ID of related component record';


--
-- TOC entry 5308 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.control_system IS '	Source: WP3 	The classification of the control system	';


--
-- TOC entry 5309 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.rated_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.rated_voltage IS '	Source: WP3 	rms value of voltage between phase-phase	';


--
-- TOC entry 5310 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.frequency IS '	Source: WP3 	Operating frequency	';


--
-- TOC entry 5311 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.reactive_power_rating; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.reactive_power_rating IS '	Source: WP3	Total reactive power capability of the unit	';


--
-- TOC entry 5312 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.insulation_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.insulation_material IS '	Source: WP3	The material of the equipment insulation	';


--
-- TOC entry 5313 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.number_of_control_stages; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.number_of_control_stages IS '	Source: WP3	The number of discrete steps	';


--
-- TOC entry 5314 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.reactive_power_of_each_stage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.reactive_power_of_each_stage IS '	Source: WP3	The reactive power per discrete step	';


--
-- TOC entry 5315 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.switching_time; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.switching_time IS '	Source: WP3	The time required to adjust one discrete step	';


--
-- TOC entry 5316 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.operating_environment; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.operating_environment IS '	Source: WP3	Defines if the unit is prepared for subsea, offshore or onshore operation	';


--
-- TOC entry 5317 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.height_without_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.height_without_control_system IS '	Source: WP3	Unit height without control system	';


--
-- TOC entry 5318 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.width_without_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.width_without_control_system IS '	Source: WP3	Unit width without control system	';


--
-- TOC entry 5319 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.depth_without_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.depth_without_control_system IS '	Source: WP3	Unit depth without control system	';


--
-- TOC entry 5320 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.height_including_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.height_including_control_system IS '	Source: WP3	Unit height with control system	';


--
-- TOC entry 5321 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.width_including_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.width_including_control_system IS '	Source: WP3	Unit width with control system	';


--
-- TOC entry 5322 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.depth_including_control_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.depth_including_control_system IS '	Source: WP3	Unit depth with control system	';


--
-- TOC entry 5323 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.cooling; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.cooling IS '	Source: WP3	Definition of the cooling system	';


--
-- TOC entry 5324 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.remote_controlled; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.remote_controlled IS '	Source: WP3	Defines if the unit can be remote controlled by the network operator	';


--
-- TOC entry 5325 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.outer_coating; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.outer_coating IS '	Source: WP3	The material of the unit housing	';


--
-- TOC entry 5326 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.operational_temperature; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.operational_temperature IS '	Source: WP3	Temperature range in which the equipment can operate	';


--
-- TOC entry 5327 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN component_power_quality.maximum_water_depth; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_power_quality.maximum_water_depth IS '	Source: WP3	Maximum water depth to which the unit can operate	';


--
-- TOC entry 260 (class 1259 OID 52312)
-- Name: component_power_quality_fk_component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_power_quality_fk_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5328 (class 0 OID 0)
-- Dependencies: 260
-- Name: component_power_quality_fk_component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_power_quality_fk_component_id_seq OWNED BY beta.component_power_quality.fk_component_id;


--
-- TOC entry 261 (class 1259 OID 52314)
-- Name: component_power_quality_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_power_quality_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5329 (class 0 OID 0)
-- Dependencies: 261
-- Name: component_power_quality_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_power_quality_id_seq OWNED BY beta.component_power_quality.id;


--
-- TOC entry 262 (class 1259 OID 52316)
-- Name: component_substation; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_substation (
    id integer NOT NULL,
    prescribed_foundation character varying(50),
    centre_of_gravity double precision[],
    dry_beam_area double precision,
    dry_frontal_area double precision,
    mass double precision,
    orientation_angle double precision,
    origin double precision[],
    prescribed_foundation_location double precision[],
    displaced_volume double precision,
    wet_beam_area double precision,
    wet_frontal_area double precision,
    rated_voltage double precision,
    distance_to_substation double precision[],
    losses_to_substation double precision[],
    fk_component_id bigint,
    code character varying(100),
    cable_landing_point public.geometry(Point)
);


--
-- TOC entry 5330 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE component_substation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_substation IS 'This table records components related to Electrical Substations';


--
-- TOC entry 5331 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.prescribed_foundation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.prescribed_foundation IS 'Source: WP4, Unit: 	N/A	Comment:	String options: pin pile, monopile';


--
-- TOC entry 5332 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.centre_of_gravity; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.centre_of_gravity IS 'Source: WP4, Unit: 	m	Comment:	Specified w.r.t. substation origin';


--
-- TOC entry 5333 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.dry_beam_area; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.dry_beam_area IS 'Source: WP4, Unit: 	m^2	Comment:	Above waterline';


--
-- TOC entry 5334 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.dry_frontal_area; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.dry_frontal_area IS 'Source: WP4, Unit: 	m^2	Comment:	Above waterline';


--
-- TOC entry 5335 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.mass; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.mass IS 'Source: WP4, Unit: 	kg';


--
-- TOC entry 5336 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.orientation_angle; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.orientation_angle IS 'Source: WP4, Unit: 	deg	Comment:	Specified w.r.t. grid north';


--
-- TOC entry 5337 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.origin; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.origin IS 'Source: WP4, Unit: 	m	Comment:	(x,y,z) w.r.t. global coordinate system';


--
-- TOC entry 5338 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.prescribed_foundation_location; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.prescribed_foundation_location IS 'Source: WP4, Unit: 	m, m, m	Comment:	(x,y,z) for each foundation point w.r.t. substation origin';


--
-- TOC entry 5339 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.displaced_volume; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.displaced_volume IS 'Source: WP4, Unit: 	m^3	Comment:	For subsea substations';


--
-- TOC entry 5340 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.wet_beam_area; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.wet_beam_area IS 'Source: WP4, Unit: 	m^2	Comment:	Below waterline';


--
-- TOC entry 5341 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.wet_frontal_area; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.wet_frontal_area IS 'Source: WP4, Unit: 	m^2	Comment:	Below waterline';


--
-- TOC entry 5342 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.rated_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.rated_voltage IS 'Source: WP3: 	Onshore substation rated voltage	Unit:	V	Numeric	Single value			The rated voltage of the onshore connection.	This may have more than one value if more than one possible point of connection.	33000';


--
-- TOC entry 5343 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.distance_to_substation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.distance_to_substation IS 'Source: WP3: 	Percentage losses from cable landing location to onshore substation	Unit:	%	Number	Single value			The user can enter these directly.	This may have more than one value if more than one possible point of connection. 11a or 11b are required - not both. Consult with partners.
';


--
-- TOC entry 5344 (class 0 OID 0)
-- Dependencies: 262
-- Name: COLUMN component_substation.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_substation.fk_component_id IS 'ID of related component record';


--
-- TOC entry 263 (class 1259 OID 52322)
-- Name: component_supplier; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_supplier (
    id smallint NOT NULL,
    supplier_name character varying(50) NOT NULL
);


--
-- TOC entry 5345 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE component_supplier; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_supplier IS 'This table is a list of component suppliers.

It is based on the requirements received from WP3.

It may not be required, if the number of supplier is too small or the individual values distinct then the supplier name field can be moved to the Component table. (denormalised)';


--
-- TOC entry 5346 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN component_supplier.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_supplier.id IS 'Unique sequential ID for this table';


--
-- TOC entry 5347 (class 0 OID 0)
-- Dependencies: 263
-- Name: COLUMN component_supplier.supplier_name; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_supplier.supplier_name IS 'Source: WP3, Supplier Name.';


--
-- TOC entry 264 (class 1259 OID 52325)
-- Name: component_supplier_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5348 (class 0 OID 0)
-- Dependencies: 264
-- Name: component_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_supplier_id_seq OWNED BY beta.component_supplier.id;


--
-- TOC entry 265 (class 1259 OID 52327)
-- Name: component_switchgear; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_switchgear (
    fk_component_id bigint NOT NULL,
    rated_voltage double precision,
    frequency double precision,
    rated_operating_current double precision,
    breaking_current double precision,
    making_capacity double precision,
    current_capacity double precision,
    insulation character varying(200),
    cooling character varying(200),
    maximum_water_depth double precision,
    operating_environment character varying(200),
    number_operations integer,
    outer_coating character varying(200),
    operational_temperature double precision,
    id integer NOT NULL,
    code character varying(100),
    component_type character varying(100)
);


--
-- TOC entry 5349 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE component_switchgear; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_switchgear IS 'This table records components related to Electrical Switchgear';


--
-- TOC entry 266 (class 1259 OID 52333)
-- Name: component_switchgear_fk_component_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_switchgear_fk_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5350 (class 0 OID 0)
-- Dependencies: 266
-- Name: component_switchgear_fk_component_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_switchgear_fk_component_id_seq OWNED BY beta.component_switchgear.fk_component_id;


--
-- TOC entry 267 (class 1259 OID 52335)
-- Name: component_switchgear_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_switchgear_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5351 (class 0 OID 0)
-- Dependencies: 267
-- Name: component_switchgear_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_switchgear_id_seq OWNED BY beta.component_switchgear.id;


--
-- TOC entry 268 (class 1259 OID 52337)
-- Name: component_transformer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_transformer (
    supplier character varying(100),
    code character varying(100),
    serial_product character varying(100),
    windings integer,
    winding_material character varying(100),
    insulation character varying(100),
    insulation_level double precision,
    insulation_temperature_class character varying(100),
    power_rating double precision,
    power_primary_winding double precision,
    power_secondary_winding double precision,
    power_tertiary_winding double precision,
    voltage_primary_winding double precision,
    voltage_secondary_winding double precision,
    voltage_tertiary_winding double precision,
    no_load_current double precision,
    no_load_losses double precision,
    losses_1_and_2 double precision,
    losses_1_and_3 double precision,
    losses_2_and_3 double precision,
    tap_changer_primary boolean,
    tap_changer_primary_type character varying(100),
    tap_changer_primary_cycles integer,
    tap_changer_primary_taps integer,
    tap_changer_primary_voltage_step double precision,
    tap_changer_primary_winding_number_of_taps_with_rated_voltage integer,
    tap_changer_secondary_winding boolean,
    tap_changer_secondary_winding_switching_type character varying(100),
    tap_changer_secondary_winding_guaranteed_number_of_switching_cy integer,
    tap_changer_secondary_winding_number_of_taps integer,
    tap_changer_secondary_winding_voltage_step double precision,
    tap_changer_secondary_winding_number_of_taps_with_rated_voltage integer,
    vector character varying(100),
    weight_air double precision,
    weight_water double precision,
    cooling character varying(100),
    height_without_cooling_system double precision,
    width_without_cooling_system double precision,
    depth_without_cooling_system double precision,
    height_with_cooling_system_and_ancillary_devices double precision,
    maximum_water_depth double precision,
    outer_coating character varying(100),
    colour character varying(100),
    operational_temperature double precision,
    impedance double precision,
    id bigint,
    fk_component_id bigint NOT NULL,
    short_circuit_voltage double precision
);


--
-- TOC entry 269 (class 1259 OID 52343)
-- Name: component_transformer_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_transformer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 270 (class 1259 OID 52345)
-- Name: component_transformer_old; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_transformer_old (
    id integer DEFAULT nextval(('beta.component_transformer_id_seq'::text)::regclass) NOT NULL,
    number_conductors smallint,
    conductor_csa double precision,
    conductor_material character varying(50),
    maximum_voltage double precision,
    insulation_material character varying(100),
    screen_type character varying(100),
    armouring character varying(100),
    serving character varying(100),
    rated_voltage double precision,
    resistance_dc_20 double precision,
    resistance_ac_90 double precision,
    inductive_reactance double precision,
    capacitance double precision,
    rated_current double precision,
    frequency double precision,
    maximum_pulling_tension double precision,
    minimum_bend_radius double precision,
    fk_component_id integer,
    code character varying(100)
);


--
-- TOC entry 5352 (class 0 OID 0)
-- Dependencies: 270
-- Name: TABLE component_transformer_old; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_transformer_old IS 'The design of this table is based on the Cable Data Field Specification in 20150512_T3_10_CD.docx
Some fields are inherited from the Component Table.';


--
-- TOC entry 5353 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.id IS 'Source: WP3';


--
-- TOC entry 5354 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.number_conductors; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.number_conductors IS 'Source: WP3, number of conductors';


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.conductor_csa; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.conductor_csa IS 'Cross Sectional Area
Units: mm^2
Source: WP3, conductor_csa';


--
-- TOC entry 5356 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.conductor_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.conductor_material IS 'Source: WP3, conductor material';


--
-- TOC entry 5357 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.maximum_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.maximum_voltage IS 'Unit: V
Source: WP3, maximum voltage';


--
-- TOC entry 5358 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.insulation_material; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.insulation_material IS 'Source: WP3';


--
-- TOC entry 5359 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.screen_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.screen_type IS 'Source: WP3';


--
-- TOC entry 5360 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.armouring; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.armouring IS 'Source: WP3';


--
-- TOC entry 5361 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.serving; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.serving IS 'Source: WP3';


--
-- TOC entry 5362 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.rated_voltage; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.rated_voltage IS 'Unit: V
Source: WP3';


--
-- TOC entry 5363 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.resistance_dc_20; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.resistance_dc_20 IS 'Unit:ohm/km
Source: WP3: Electrical Resistance DC 20';


--
-- TOC entry 5364 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.resistance_ac_90; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.resistance_ac_90 IS 'Unit:ohm/km
Source: WP3: Electrical Resistance AC 90';


--
-- TOC entry 5365 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.inductive_reactance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.inductive_reactance IS 'Unit: ohm/km
Source: WP4, Inductive reactance';


--
-- TOC entry 5366 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.capacitance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.capacitance IS 'Unit: uF/km
Source: WP4, capacitance';


--
-- TOC entry 5367 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.rated_current; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.rated_current IS 'Unit: A
Source: WP4, Rated current';


--
-- TOC entry 5368 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.frequency; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.frequency IS 'Unit: Hz
Source: WP4, frequency';


--
-- TOC entry 5369 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.maximum_pulling_tension; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.maximum_pulling_tension IS 'Unit: N/A
Source: WP4, maximum_pulling_tension';


--
-- TOC entry 5370 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.minimum_bend_radius; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.minimum_bend_radius IS 'Unit: m
Source: WP4, Minimum bend radius';


--
-- TOC entry 5371 (class 0 OID 0)
-- Dependencies: 270
-- Name: COLUMN component_transformer_old.fk_component_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_transformer_old.fk_component_id IS 'ID of related component record';


--
-- TOC entry 271 (class 1259 OID 52352)
-- Name: component_type; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.component_type (
    description character varying(100),
    parent_type_id bigint,
    functional_area_id integer,
    id bigint NOT NULL
);


--
-- TOC entry 5372 (class 0 OID 0)
-- Dependencies: 271
-- Name: TABLE component_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.component_type IS 'This table lists the type of components.
Each record in the COMPONENT table will have a reference to an entry in this table.

DESIGN NOTE: Decide whether to record parent/child relationships here?
Many to many relationship?';


--
-- TOC entry 5373 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN component_type.description; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_type.description IS 'Description of component type';


--
-- TOC entry 5374 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN component_type.parent_type_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_type.parent_type_id IS 'ID of parent type.';


--
-- TOC entry 5375 (class 0 OID 0)
-- Dependencies: 271
-- Name: COLUMN component_type.functional_area_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.component_type.functional_area_id IS 'The functional area for this component, e.g. moorings electrical';


--
-- TOC entry 272 (class 1259 OID 52355)
-- Name: component_type_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.component_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5376 (class 0 OID 0)
-- Dependencies: 272
-- Name: component_type_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.component_type_id_seq OWNED BY beta.component_type.id;


--
-- TOC entry 273 (class 1259 OID 52357)
-- Name: constants; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.constants (
    gravity double precision,
    sea_water_density double precision,
    air_density double precision,
    steel_density double precision,
    concrete_density double precision,
    grout_density double precision,
    id integer NOT NULL
);


--
-- TOC entry 274 (class 1259 OID 52360)
-- Name: constraint; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta."constraint" (
    id integer NOT NULL,
    constraint_type_id integer,
    description text,
    fk_site_farm_id integer,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 5377 (class 0 OID 0)
-- Dependencies: 274
-- Name: TABLE "constraint"; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta."constraint" IS 'Ths table records any constraints applicable to the Farm lease area
Source: WP2: No Go Areas.
Source: WP3:
Restricted areas
Existing cable routes
Commercial activity areas
Commercial activity frequency

';


--
-- TOC entry 5378 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN "constraint".id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta."constraint".id IS 'Unique ID of this record';


--
-- TOC entry 5379 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN "constraint".constraint_type_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta."constraint".constraint_type_id IS 'ID of related constraint type';


--
-- TOC entry 5380 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN "constraint".description; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta."constraint".description IS 'Description of constraint. This may replace Constraint Type ID, depending on usage.';


--
-- TOC entry 5381 (class 0 OID 0)
-- Dependencies: 274
-- Name: COLUMN "constraint".fk_site_farm_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta."constraint".fk_site_farm_id IS 'The ID of the related Farm  or Site to which this Constraint applies.';


--
-- TOC entry 275 (class 1259 OID 52366)
-- Name: constraint_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.constraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5382 (class 0 OID 0)
-- Dependencies: 275
-- Name: constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.constraint_id_seq OWNED BY beta."constraint".id;


--
-- TOC entry 276 (class 1259 OID 52368)
-- Name: constraint_type; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.constraint_type (
    id bigint DEFAULT nextval(('beta.constraint_type_id_seq'::text)::regclass) NOT NULL,
    constraint_desc character varying(50),
    constraint_impact character varying(50)
);


--
-- TOC entry 5383 (class 0 OID 0)
-- Dependencies: 276
-- Name: TABLE constraint_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.constraint_type IS 'This referecne table contians a list of possible constraint types.
this is not explicitly required by the Work PAckages but may help to standardise contraint descriptions.';


--
-- TOC entry 5384 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN constraint_type.constraint_desc; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_type.constraint_desc IS 'Source: Various.
Description of constraint';


--
-- TOC entry 5385 (class 0 OID 0)
-- Dependencies: 276
-- Name: COLUMN constraint_type.constraint_impact; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.constraint_type.constraint_impact IS 'Source:?
Impact or severity of constraint: advisory, binding etc.';


--
-- TOC entry 277 (class 1259 OID 52372)
-- Name: constraint_type_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.constraint_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 32767
    CACHE 1;


--
-- TOC entry 278 (class 1259 OID 52374)
-- Name: device; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.device (
    component_type_id integer,
    description character varying(200),
    device_type character varying(50),
    system_displaced_volume double precision,
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    rotor_swept_area double precision,
    thrust_coefficient_single double precision,
    drag_coefficients double precision,
    zzinertia_coefficients double precision,
    rated_power double precision,
    rated_voltage double precision,
    characteristic_length double precision,
    hub_height double precision,
    installation_depth_max double precision,
    installation_depth_min double precision,
    depth_variation_permitted boolean,
    make character varying(50),
    model character varying(50),
    zzrotational_speed double precision,
    yaw double precision,
    floating boolean,
    working_principle_path text,
    assembly_duration double precision,
    zzradiation_damping character varying(100),
    zzadded_mass double precision,
    support_structure_profile character varying(50),
    system_centre_of_gravity double precision[],
    system_draft double precision,
    dry_beam_area double precision,
    system_mass double precision,
    system_profile character varying(50),
    wet_beam_area double precision,
    heave double precision,
    disconnect_duration double precision,
    cut_in_velocity double precision,
    cut_out_velocity double precision,
    comments text,
    top_thickness double precision,
    bottom_thickness double precision,
    control_signal_no_of_channels smallint,
    control_signal_type character varying(100),
    turbine_diameter double precision,
    zzemerged_footprint double precision,
    position_duration_range double precision[],
    image bytea,
    zzunderwater_noise double precision,
    zzunderwater_noise_distance_measured double precision,
    data_folder boolean,
    data_folder_path text,
    technology_type character varying(6),
    two_ways_flow boolean,
    assembly_strategy character varying(100),
    connect_duration double precision,
    device_surface_roughness double precision,
    sys_height double precision,
    sys_width double precision,
    sys_length double precision,
    prescribed_footprint_radius double precision,
    fk_component_type_id integer,
    minimum_distance_x double precision,
    minimum_distance_y double precision,
    ".turbine_interdistance" double precision,
    prescribed_mooring_system character varying(50),
    prescribed_foundation_system character varying(50),
    load_safety_factor double precision,
    power_factor double precision[],
    fairlead_location double precision[],
    id integer NOT NULL,
    wave_data_directory character varying(200),
    umbilical_connection_point double precision[],
    constant_power_factor double precision,
    connector_type character varying(50),
    maximum_displacement double precision[],
    coordinate_system double precision[],
    footprint_corner_coords double precision[],
    variable_power_factor double precision[],
    foundation_locations double precision[],
    prescribed_umbilical_type character varying(50)
);


--
-- TOC entry 5386 (class 0 OID 0)
-- Dependencies: 278
-- Name: COLUMN device.coordinate_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.device.coordinate_system IS 'To contain position (x,y,z) of tidal device hub or wave device point of rotation.';


--
-- TOC entry 279 (class 1259 OID 52380)
-- Name: device_id_seq1; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.device_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5387 (class 0 OID 0)
-- Dependencies: 279
-- Name: device_id_seq1; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.device_id_seq1 OWNED BY beta.device.id;


--
-- TOC entry 280 (class 1259 OID 52382)
-- Name: device_power_performance_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.device_power_performance_tidal (
    fk_device_id integer,
    velocity double precision NOT NULL,
    thrust_coefficient double precision,
    power_coefficient double precision
);


--
-- TOC entry 281 (class 1259 OID 52385)
-- Name: device_power_performance_tidal_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.device_power_performance_tidal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 282 (class 1259 OID 52387)
-- Name: equipment_cable_burial; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_cable_burial (
    id integer NOT NULL,
    burial_tool_type character varying(100),
    max_operating_depth double precision,
    tow_force_required double precision,
    length double precision,
    width double precision,
    height double precision,
    weight double precision,
    jetting_capability boolean,
    ploughing_capability boolean,
    cutting_capability boolean,
    jetting_trench_depth double precision,
    ploughing_trench_depth double precision,
    cutting_trench_depth double precision,
    max_cable_diameter double precision,
    min_cable_bend_radius double precision,
    ae_footprint double precision,
    ae_weight double precision,
    burial_tool_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 283 (class 1259 OID 52390)
-- Name: equipment_divers; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_divers (
    id integer NOT NULL,
    type_diving character varying(100),
    max_operating_depth double precision,
    deployment_eq_footprint double precision,
    deployment_eq_weight double precision,
    number_supervisors integer,
    number_divers integer,
    number_tenders integer,
    number_technicians integer,
    number_support_technicians integer,
    deployment_eq_day_rate double precision,
    supervisor_day_rate double precision,
    diver_day_rate double precision,
    tender_day_rate double precision,
    technician_day_rate double precision,
    life_support_day_rate double precision,
    total_day_rate double precision
);


--
-- TOC entry 284 (class 1259 OID 52393)
-- Name: equipment_drilling_rigs; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_drilling_rigs (
    id integer NOT NULL,
    diameter double precision,
    length double precision,
    weight double precision,
    drilling_diameter_range double precision,
    max_drilling_depth double precision,
    max_water_depth double precision,
    torque double precision,
    pull_back double precision,
    ae_footprint double precision,
    ae_weight double precision,
    drill_rig_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 285 (class 1259 OID 52396)
-- Name: equipment_excavating; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_excavating (
    id integer NOT NULL,
    depth_rating double precision,
    width double precision,
    height double precision,
    length_or_diameter double precision,
    nozzle_diameter double precision,
    weight double precision,
    max_pressure double precision,
    max_flow_rate double precision,
    max_torque double precision,
    thrust double precision,
    propeller_speed double precision,
    excavator_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 286 (class 1259 OID 52399)
-- Name: equipment_hammer; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_hammer (
    id integer NOT NULL,
    depth_rating double precision,
    length double precision,
    weight_in_air double precision,
    min_pile_diameter double precision,
    max_pile_diameter double precision,
    max_blow_energy double precision,
    min_blow_energy double precision,
    blow_rate_at_max_blow_energy double precision,
    ae_footprint double precision,
    ae_weight double precision,
    hammer_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 287 (class 1259 OID 52402)
-- Name: equipment_mattress; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_mattress (
    id integer NOT NULL,
    concrete_resistance double precision,
    concrete_density double precision,
    unit_length double precision,
    unit_width double precision,
    unit_thickness double precision,
    unit_weight_air double precision,
    unit_weight_water double precision,
    number_looped_ropes double precision,
    rope_diameter double precision,
    cost_per_unit double precision
);


--
-- TOC entry 288 (class 1259 OID 52405)
-- Name: equipment_rock_filter_bags; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_rock_filter_bags (
    id integer NOT NULL,
    weight double precision,
    particle_diameter_min double precision,
    particle_diameter_max double precision,
    mesh_size double precision,
    diameter double precision,
    height double precision,
    volume double precision,
    velocity_unit double precision,
    velocity_grouped double precision,
    cost_per_unit double precision
);


--
-- TOC entry 289 (class 1259 OID 52408)
-- Name: equipment_rov; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_rov (
    id integer NOT NULL,
    rov_class character varying(100),
    depth_rating double precision,
    length double precision,
    width double precision,
    height double precision,
    weight double precision,
    payload double precision,
    horse_power double precision,
    bp_forward double precision,
    bp_lateral double precision,
    bp_vertical double precision,
    manipulator_number double precision,
    manipulator_grip_force double precision,
    manipulator_wrist_torque double precision,
    ae_footprint double precision,
    ae_weight double precision,
    ae_supervisor integer,
    ae_technician integer,
    rov_day_rate double precision,
    supervisor_rate double precision,
    technician_rate double precision
);


--
-- TOC entry 290 (class 1259 OID 52411)
-- Name: equipment_soil_lay_rates; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_soil_lay_rates (
    id integer NOT NULL,
    equipment_type character varying(100),
    operation character varying(50),
    soil_ls double precision,
    soil_ms double precision,
    soil_ds double precision,
    soil_vsc double precision,
    soil_sc double precision,
    soil_fc double precision,
    soil_stc double precision,
    soil_hgt double precision,
    soil_cm double precision,
    soil_src double precision,
    soil_hr double precision,
    soil_gc double precision
);


--
-- TOC entry 291 (class 1259 OID 52414)
-- Name: equipment_soil_penet_rates; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_soil_penet_rates (
    id integer NOT NULL,
    equipment_type character varying(100),
    operation character varying(50),
    soil_ls double precision,
    soil_ms double precision,
    soil_ds double precision,
    soil_vsc double precision,
    soil_sc double precision,
    soil_fc double precision,
    soil_stc double precision,
    soil_hgt double precision,
    soil_cm double precision,
    soil_src double precision,
    soil_hr double precision,
    soil_gc double precision
);


--
-- TOC entry 292 (class 1259 OID 52417)
-- Name: equipment_split_pipe; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_split_pipe (
    id integer NOT NULL,
    material character varying(100),
    unit_weight_air double precision,
    unit_weight_water double precision,
    unit_length double precision,
    unit_wall_thickness double precision,
    unit_inner_diameter double precision,
    unit_outer_diameter double precision,
    max_cable_size double precision,
    min_bend_radius double precision,
    cost_per_unit double precision
);


--
-- TOC entry 293 (class 1259 OID 52420)
-- Name: equipment_vibro_driver; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.equipment_vibro_driver (
    id integer NOT NULL,
    width double precision,
    length double precision,
    height double precision,
    vibro_driver_weight double precision,
    clamp_weight double precision,
    eccentric_moment double precision,
    max_frequency double precision,
    max_centrifugal_force double precision,
    max_line_pull double precision,
    min_pile_diameter double precision,
    max_pile_diameter double precision,
    max_pile_weight double precision,
    power double precision,
    oil_flow double precision,
    ae_footprint double precision,
    ae_weight double precision,
    vibro_driver_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 294 (class 1259 OID 52423)
-- Name: farm; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.farm (
    id integer DEFAULT nextval(('beta.farm_id_seq'::text)::regclass) NOT NULL,
    hat double precision,
    lat double precision,
    surface_current_flow_velocity double precision,
    current_flow_direction double precision,
    significant_wave_height double precision,
    peak_wave_period double precision,
    predominant_wave_direction double precision,
    max_wind_gust_speed double precision,
    predominant_wind_direction double precision,
    sea_surface_elevation double precision,
    storm_surge_min_height double precision,
    storm_surge_max_height double precision,
    zero_upcrossing_wave_period double precision,
    spectrum_peakedness double precision,
    lease_area double precision,
    farm_area double precision,
    lease_volume double precision,
    noise_threshold double precision,
    minimum_q_factor double precision,
    hydrodynamic_folder_path text,
    map_datum text,
    power_law_exponent double precision,
    technology_type character varying(25),
    sea_bottom_tidal_current_velocity double precision,
    maximum_seabed_temp double precision,
    maximum_seabed_thermal_resistivity double precision,
    onshore_infrastructure_cost double precision,
    zzprescribed_mooring_system character varying(50),
    zzprescribed_foundation_system character varying(50),
    prescribed_umbilical_id integer,
    required_environmental_impact character varying(50),
    air_density double precision,
    water_level_max double precision,
    water_level_min double precision,
    wind_gust_direction double precision,
    cost_onshore_infrastructure double precision,
    wave_spectrum_type character varying(20),
    wave_spectrum_gamma double precision,
    wave_spectrum_spreading_parameter double precision,
    wave_spectrum_sigmaa double precision,
    wave_spectrum_sigmab double precision,
    zzfarm_surroundings character varying(100),
    fk_site_id integer,
    initial_electromagnetic_field double precision,
    initial_electric_field double precision,
    array_rated_power double precision,
    "parametrised array description" text,
    mean_wind_speed double precision,
    offshore_reactive_power_limits double precision[],
    onshore_reactive_power_limits double precision[],
    farm_boundary public.geometry(Polygon,4326),
    lease_boundary public.geometry(Polygon,4326),
    lease_boundary1 public.geometry(Polygon),
    blockage_ratio double precision,
    entry_point public.geometry(Point),
    cable_landing_location public.geometry(Point),
    tidal_occurrence_point public.geometry(Point),
    array_main_direction double precision,
    farm_origin public.geometry(Point),
    deployment_area public.geometry(Polygon),
    moor_found_current_profile character varying(20)
);


--
-- TOC entry 295 (class 1259 OID 52430)
-- Name: farm_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.farm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 296 (class 1259 OID 52432)
-- Name: om_failure_mode_equipment; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_failure_mode_equipment (
    equipment_id integer NOT NULL,
    failure_mode_id integer NOT NULL,
    id integer NOT NULL
);


--
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE om_failure_mode_equipment; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_failure_mode_equipment IS 'This table relates the EQUIPMENT table to the FAILURE MODE table.

Source: WP6, indirectly.
This is taken from the list of required equipment, items 29 to 40';


--
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN om_failure_mode_equipment.equipment_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_equipment.equipment_id IS 'ID of related equipment record
Source: WP6, indirectly.
This is taken from the list of required equipment, items 29 to 40';


--
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN om_failure_mode_equipment.failure_mode_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_equipment.failure_mode_id IS 'ID of related logistics operation record.
Source: WP6, indirectly.
This is taken from the list of required equipment, items 29 to 40';


--
-- TOC entry 5391 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN om_failure_mode_equipment.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_equipment.id IS 'Unique ID for this table.
Records should be uniquely identified by the combination of equipment_id and failure_mode_id';


--
-- TOC entry 297 (class 1259 OID 52435)
-- Name: om_component_failure_mode_equipment_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.om_component_failure_mode_equipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5392 (class 0 OID 0)
-- Dependencies: 297
-- Name: om_component_failure_mode_equipment_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.om_component_failure_mode_equipment_id_seq OWNED BY beta.om_failure_mode_equipment.id;


--
-- TOC entry 298 (class 1259 OID 52437)
-- Name: om_failure_mode_inspection; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_failure_mode_inspection (
    duration_inspection double precision,
    delay_crew double precision,
    delay_organisation double precision,
    number_technicians integer,
    number_specialists integer,
    wave_height_max double precision,
    wind_speed_max double precision,
    current_speed_max double precision,
    requires_lifiting boolean,
    requires_divers boolean,
    fk_failure_mode_id bigint
);


--
-- TOC entry 5393 (class 0 OID 0)
-- Dependencies: 298
-- Name: TABLE om_failure_mode_inspection; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_failure_mode_inspection IS 'This table records details of the inspections requried to investigate the incidence of a given Failure Mode.

There is a 1 to many relationship between Failure Mode and Inspection, but in practice this may be restriced to zero ir 1 related Inspection record.

The fields have been checked against the final set of parameters

Design Check: 06/01/2016
';


--
-- TOC entry 5394 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.duration_inspection; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.duration_inspection IS 'duration of time required on site for an inspection (before the actual maintenance) Source: WP6: Item 8 (BP: we need another table for inspection) [hr]';


--
-- TOC entry 5395 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.delay_crew; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.delay_crew IS 'Source: WP6
Duration of time before the crew is ready , Unit:  [hr]';


--
-- TOC entry 5396 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.delay_organisation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.delay_organisation IS 'Source: WP6
duration of time before anything else is ready  Unit: [hr]';


--
-- TOC entry 5397 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.number_technicians; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.number_technicians IS 'Source: WP6
Number of technicians required to do the job';


--
-- TOC entry 5398 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.number_specialists; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.number_specialists IS 'Source: WP6
Number of specialists required to do the job';


--
-- TOC entry 5399 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.wave_height_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.wave_height_max IS 'Source: WP6, WP5(
Unit: m wave_height_max for the repair operation )associated with device) [m]';


--
-- TOC entry 5400 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.wind_speed_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.wind_speed_max IS 'Source: WP6, WP5
Unit: m/s wind_speed_max for the repair operation (device associated) [m/s]';


--
-- TOC entry 5401 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.current_speed_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.current_speed_max IS 'Source: WP6, WP5
Unit: m/s maximum current speed for the repair operation (Associated with device) [m/s]';


--
-- TOC entry 5402 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.requires_lifiting; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.requires_lifiting IS 'Source: WP6';


--
-- TOC entry 5403 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.requires_divers; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.requires_divers IS 'Source: WP6';


--
-- TOC entry 5404 (class 0 OID 0)
-- Dependencies: 298
-- Name: COLUMN om_failure_mode_inspection.fk_failure_mode_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_inspection.fk_failure_mode_id IS 'ID of related Failure Mode';


--
-- TOC entry 299 (class 1259 OID 52440)
-- Name: om_failure_mode_vessel; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_failure_mode_vessel (
    vessel_id integer NOT NULL,
    failure_mode_id integer NOT NULL,
    id integer DEFAULT nextval('beta.om_component_failure_mode_equipment_id_seq'::regclass) NOT NULL
);


--
-- TOC entry 5405 (class 0 OID 0)
-- Dependencies: 299
-- Name: TABLE om_failure_mode_vessel; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_failure_mode_vessel IS 'This table relates the EQUIPMENT table to the FAILURE MODE table.

Source: WP6, indirectly.
This is taken from the list of required equipment, items 29 to 40';


--
-- TOC entry 5406 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN om_failure_mode_vessel.vessel_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_vessel.vessel_id IS 'ID of related vessel record
Source: WP6, indirectly.';


--
-- TOC entry 5407 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN om_failure_mode_vessel.failure_mode_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_vessel.failure_mode_id IS 'ID of related logistics operation record.
Source: WP6, indirectly.
This is taken from the list of required equipment, items 29 to 40';


--
-- TOC entry 5408 (class 0 OID 0)
-- Dependencies: 299
-- Name: COLUMN om_failure_mode_vessel.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_failure_mode_vessel.id IS 'Unique ID for this table.
Records should be uniquely identified by the combination of equipment_id and failure_mode_id';


--
-- TOC entry 300 (class 1259 OID 52444)
-- Name: om_operation_crew_role; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_operation_crew_role (
    logistics_operation_id integer NOT NULL,
    crew_role_id integer NOT NULL,
    id integer NOT NULL
);


--
-- TOC entry 5409 (class 0 OID 0)
-- Dependencies: 300
-- Name: TABLE om_operation_crew_role; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_operation_crew_role IS 'This table lists the CREW ROLES required for each OM task.
Additional filds to be identified: Cost? Sequencing?';


--
-- TOC entry 5410 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN om_operation_crew_role.logistics_operation_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_operation_crew_role.logistics_operation_id IS 'Id of related logistics operation
Source: Design';


--
-- TOC entry 5411 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN om_operation_crew_role.crew_role_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_operation_crew_role.crew_role_id IS 'ID of related Crew Role
Source: Design';


--
-- TOC entry 5412 (class 0 OID 0)
-- Dependencies: 300
-- Name: COLUMN om_operation_crew_role.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_operation_crew_role.id IS 'Unique ID: required for Foreign Keys to work';


--
-- TOC entry 301 (class 1259 OID 52447)
-- Name: om_operation_crew_role_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.om_operation_crew_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5413 (class 0 OID 0)
-- Dependencies: 301
-- Name: om_operation_crew_role_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.om_operation_crew_role_id_seq OWNED BY beta.om_operation_crew_role.id;


--
-- TOC entry 302 (class 1259 OID 52449)
-- Name: om_repair_action; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.om_repair_action (
    fk_failure_mode_id integer NOT NULL,
    id integer DEFAULT nextval('beta.component_failure_mode_id_seq'::regclass) NOT NULL,
    duration_maintenance double precision,
    interruptable boolean,
    delay_crew double precision,
    delay_organisation double precision,
    delay_spare double precision,
    number_technicians integer,
    number_specialists integer,
    wave_height_max double precision,
    wind_speed_max double precision,
    current_speed_max double precision,
    requires_lifiting boolean,
    requires_divers boolean,
    requires_towing boolean,
    hs_acc_boat double precision,
    vw_acc_boat double precision,
    vc_acc_boat double precision,
    hs_acc_heli double precision,
    vw_acc_heli double precision,
    vc_acc_heli double precision
);


--
-- TOC entry 5414 (class 0 OID 0)
-- Dependencies: 302
-- Name: TABLE om_repair_action; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.om_repair_action IS 'This table relates the Component and Failure Mode tables.
This relationship can be changed to an array of values if required.';


--
-- TOC entry 5415 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.id IS 'Unique sequential ID.
Each record is uniquely identified by the combination of Component Id and Failure Mode Id
Source: WP6
but this makes it easier to identify a single record.
Source : WP6';


--
-- TOC entry 5416 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.duration_maintenance; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.duration_maintenance IS 'duration of time required on site for maintenance.
Source: WP6, Item 9';


--
-- TOC entry 5417 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.interruptable; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.interruptable IS 'Is the failure mode type interruptable or not
Source: WP6, Item 10';


--
-- TOC entry 5418 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.delay_crew; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.delay_crew IS 'duration of time before the crew is ready
Source: WP6, Item 11';


--
-- TOC entry 5419 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.delay_organisation; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.delay_organisation IS 'duration of time before anything else is ready
Source: WP6, Item 12';


--
-- TOC entry 5420 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.delay_spare; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.delay_spare IS 'duration of time before the spare parts are ready Source: WP6, Item 13';


--
-- TOC entry 5421 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.number_technicians; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.number_technicians IS 'Number of technicians required to do the job
Source: WP6, Item 14';


--
-- TOC entry 5422 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.number_specialists; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.number_specialists IS 'Number of specialists required to do the job
Source: WP6, Item 15';


--
-- TOC entry 5423 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.wave_height_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.wave_height_max IS 'Unit: m
wave_height_max for the repair operation
Source: WP6, WP5()associated wit hdevice)';


--
-- TOC entry 5424 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.wind_speed_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.wind_speed_max IS 'Unit: m/s
wind_speed_max for the repair operation
Source: WP6, WP5(device associated)';


--
-- TOC entry 5425 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.current_speed_max; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.current_speed_max IS 'Unit: m/s
maximum current speed for the repair operation
Source: WP6, WP5(Associated with device)';


--
-- TOC entry 5426 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.requires_lifiting; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.requires_lifiting IS 'Source: WP6';


--
-- TOC entry 5427 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.requires_divers; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.requires_divers IS 'Source: WP6';


--
-- TOC entry 5428 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.requires_towing; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.requires_towing IS 'Source: WP6';


--
-- TOC entry 5429 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.hs_acc_boat; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.hs_acc_boat IS 'Source: WP6
Max. Hs for boat access [m]';


--
-- TOC entry 5430 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.vw_acc_boat; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.vw_acc_boat IS 'Source: WP6
Max. wind speed for boat access [m/s]';


--
-- TOC entry 5431 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.vc_acc_boat; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.vc_acc_boat IS 'Source: WP6 Max. current speed for boat access [m/s]';


--
-- TOC entry 5432 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.vw_acc_heli; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.vw_acc_heli IS 'Source: WP6
Max. wind speed for helicopter access [m/s]';


--
-- TOC entry 5433 (class 0 OID 0)
-- Dependencies: 302
-- Name: COLUMN om_repair_action.vc_acc_heli; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.om_repair_action.vc_acc_heli IS 'Source: WP6
Max. Hs for helicopter access [m]';


--
-- TOC entry 303 (class 1259 OID 52453)
-- Name: operation_limiting_condition; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.operation_limiting_condition (
    operation_type character varying(100) NOT NULL,
    max_hs double precision,
    max_tp double precision,
    max_wind_speed double precision,
    max_current_speed double precision
);
ALTER TABLE ONLY beta.operation_limiting_condition ALTER COLUMN max_hs SET STATISTICS 0;


--
-- TOC entry 5434 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN operation_limiting_condition.operation_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.operation_limiting_condition.operation_type IS 'Source: WP5
Specify which operation is referenced.
"device positioning"
"device connecting"
"device disconnecting"';


--
-- TOC entry 5435 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN operation_limiting_condition.max_hs; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.operation_limiting_condition.max_hs IS 'Source: WP5
These parameters are used for the weather window calculation.';


--
-- TOC entry 5436 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN operation_limiting_condition.max_tp; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.operation_limiting_condition.max_tp IS 'Source: WP5
Maximum Tp for this operation';


--
-- TOC entry 5437 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN operation_limiting_condition.max_wind_speed; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.operation_limiting_condition.max_wind_speed IS 'Source: WP5
Maximum wind speed for this operation';


--
-- TOC entry 5438 (class 0 OID 0)
-- Dependencies: 303
-- Name: COLUMN operation_limiting_condition.max_current_speed; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.operation_limiting_condition.max_current_speed IS 'Source: WP5
Maximum current speed for this operation';


--
-- TOC entry 304 (class 1259 OID 52456)
-- Name: ports; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ports (
    id integer NOT NULL,
    name character varying(100),
    country character varying(100),
    type character varying(100),
    sea_ocean character varying(100),
    utm_zone character varying(25),
    port_owner character varying(100),
    previous_experience boolean,
    project_name character varying(500),
    port_capabilities_rating integer,
    dedicated_areas boolean,
    number_of_terminals integer,
    name_of_terminal character varying(100),
    type_of_terminal character varying(100),
    entrance_width double precision,
    terminal_length double precision,
    terminal_load_bearing double precision,
    terminal_draught double precision,
    terminal_area double precision,
    hinterland_area double precision,
    gantry_cranes_0_10_tons integer,
    gantry_cranes_10_50_tons integer,
    gantry_cranes_50_100_tons integer,
    gantry_cranes_100_200_tons integer,
    gantry_cranes_200_300_tons integer,
    gantry_cranes_300_400_tons integer,
    gantry_cranes_400_500_tons integer,
    gantry_cranes_500_1000_tons integer,
    gantry_cranes_1000_9999_tons integer,
    max_gantry_crane_lift_capacity double precision,
    tower_cranes_0_10_tons integer,
    tower_cranes_10_50_tons integer,
    tower_cranes_50_100_tons integer,
    tower_cranes_100_200_tons integer,
    tower_cranes_200_300_tons integer,
    tower_cranes_300_400_tons integer,
    tower_cranes_400_500_tons integer,
    tower_cranes_500_1000_tons integer,
    tower_cranes_1000_9999_tons integer,
    max_tower_crane_lift_capacity double precision,
    crane_comments character varying(800),
    jacking_capability boolean,
    jackup_name character varying(100),
    terminal_accessibility character varying(100),
    vertical_overhead_limitation double precision,
    tug_assistance boolean,
    storage_area double precision,
    industrial_area double precision,
    marine_slipway boolean,
    distance_to_railway double precision,
    distance_to_main_road double precision,
    distance_to_airport double precision,
    distance_to_helipad double precision,
    port_connections_comments character varying(800),
    security_certification character varying(100),
    quality_certification character varying(100),
    environmental_certification character varying(100),
    vtms boolean,
    sem boolean,
    fuel_supply boolean,
    diesel_supply boolean,
    water_supply boolean,
    concrete_manufacturing_capabilities boolean,
    concrete_company_name character varying(100),
    nearest_concrete_company_distance double precision,
    steel_manufacturing_capabilities boolean,
    steel_company_name character varying(100),
    nearest_steel_company_distance double precision,
    composite_manufacturing_capabilities boolean,
    composite_company_name character varying(100),
    nearest_composite_company_distance double precision,
    cable_manufacturing_capabilities boolean,
    cable_company_name character varying(100),
    nearest_cable_company_distance double precision,
    tonnage_charges double precision,
    tonnage_charges_comments character varying(400),
    mooring_unmooring_charges double precision,
    mooring_unmooring_charges_comments character varying(400),
    shifting_charges double precision,
    shifting_charges_comments character varying(400),
    port_economic_assessment_comments character varying(400),
    website character varying(400),
    contact_name character varying(100),
    contact_phone character varying(100),
    contact_email character varying(400),
    utm_location public.geometry(Point)
);


--
-- TOC entry 305 (class 1259 OID 52462)
-- Name: project_bathymetry_geotechnic; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_bathymetry_geotechnic (
    adhesion_factor double precision,
    anchor_soil_parameters double precision,
    bearing_capacity_factor_limit_value double precision,
    bearing_capacity_factor_plain_strain double precision,
    average_undrained_soil_shear_strength double precision,
    representative_undrained_soil_shear_strength_at_tip_level double precision,
    undrained_shear_strength_averaged_over_penetration_depth double precision,
    compression_index double precision,
    correction_factor_subgroups double precision,
    effective_drained_cohesion double precision,
    drained_soil_friction_angle double precision,
    dss_shear_strength double precision,
    reverse_end_bearing_factor double precision,
    coefficient_of_external_shaft_friction double precision,
    holding_capacity_factors double precision,
    holding_capacity_factor_for_drained_soil_condition double precision,
    coefficient_of_internal_shaft_friction_i_e_steel_to_soil double precision,
    lateral_bearing_capacity_factor double precision,
    bearing_capacity_factor_of_buried_mooring_line double precision,
    over_consolidation_ratio double precision,
    pile_maximum_skin_frictional_resistance double precision,
    pile_moment_coefficients double precision,
    pile_tip_maximum_unit_soil_bearing_capacity double precision,
    zzprescribed_footprint_radius double precision,
    relative_soil_density double precision,
    rock_compressive_strength double precision,
    soil_depth_for_each_layer double precision,
    soil_friction_coefficients double precision,
    soil_liquid_limit double precision,
    soil_plastic_limit double precision,
    soil_sensitivity double precision,
    soil_specific_gravity double precision,
    elastic_soil_shear_modulus double precision,
    shape_factor double precision,
    soil_type double precision,
    soil_water_content double precision,
    buoyant_unit_weight_of_soil double precision,
    zzsubsea_cable_connection_point double precision,
    undrained_soil_friction_angle double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision,
    id bigint NOT NULL,
    fk_layer_id bigint,
    fk_site_id bigint,
    undrained_soil_shear_strength_constant_term double precision,
    pile_deflection_coefficients double precision,
    seafloor_friction_coefficient double precision
);


--
-- TOC entry 306 (class 1259 OID 52465)
-- Name: project_bathymetry_geotechnic_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_bathymetry_geotechnic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5439 (class 0 OID 0)
-- Dependencies: 306
-- Name: project_bathymetry_geotechnic_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_bathymetry_geotechnic_id_seq OWNED BY beta.project_bathymetry_geotechnic.id;


--
-- TOC entry 307 (class 1259 OID 52467)
-- Name: project_cable_corridor; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor (
    id integer NOT NULL,
    current_flow_direction double precision,
    predominant_wave_direction double precision,
    sea_bottom_tidal_current_velocity double precision,
    maximum_seabed_temp double precision,
    maximum_seabed_thermal_resistivity double precision,
    cable_landing_location public.geometry(Point),
    cable_corridor_farm_intersection public.geometry(Point),
    boundary public.geometry(Polygon),
    fk_site_id integer
);


--
-- TOC entry 308 (class 1259 OID 52473)
-- Name: project_cable_corridor_bathymetry_geotechnic; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor_bathymetry_geotechnic (
    adhesion_factor double precision,
    anchor_soil_parameters double precision,
    bearing_capacity_factor_limit_value double precision,
    bearing_capacity_factor_plain_strain double precision,
    average_undrained_soil_shear_strength double precision,
    representative_undrained_soil_shear_strength_at_tip_level double precision,
    undrained_shear_strength_averaged_over_penetration_depth double precision,
    compression_index double precision,
    correction_factor_subgroups double precision,
    effective_drained_cohesion double precision,
    drained_soil_friction_angle double precision,
    dss_shear_strength double precision,
    reverse_end_bearing_factor double precision,
    coefficient_of_external_shaft_friction double precision,
    holding_capacity_factors double precision,
    holding_capacity_factor_for_drained_soil_condition double precision,
    coefficient_of_internal_shaft_friction_i_e_steel_to_soil double precision,
    lateral_bearing_capacity_factor double precision,
    bearing_capacity_factor_of_buried_mooring_line double precision,
    over_consolidation_ratio double precision,
    pile_maximum_skin_frictional_resistance double precision,
    pile_moment_coefficients double precision,
    pile_tip_maximum_unit_soil_bearing_capacity double precision,
    zzprescribed_footprint_radius double precision,
    relative_soil_density double precision,
    rock_compressive_strength double precision,
    soil_depth_for_each_layer double precision,
    soil_friction_coefficients double precision,
    soil_liquid_limit double precision,
    soil_plastic_limit double precision,
    soil_sensitivity double precision,
    soil_specific_gravity double precision,
    elastic_soil_shear_modulus double precision,
    shape_factor double precision,
    soil_type double precision,
    soil_water_content double precision,
    buoyant_unit_weight_of_soil double precision,
    zzsubsea_cable_connection_point double precision,
    undrained_soil_friction_angle double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision,
    id bigint NOT NULL,
    fk_layer_id bigint,
    fk_site_id bigint,
    undrained_soil_shear_strength_constant_term double precision,
    pile_deflection_coefficients double precision,
    seafloor_friction_coefficient double precision
);


--
-- TOC entry 309 (class 1259 OID 52476)
-- Name: project_cable_corridor_bathymetry_geotechnic_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_cable_corridor_bathymetry_geotechnic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5440 (class 0 OID 0)
-- Dependencies: 309
-- Name: project_cable_corridor_bathymetry_geotechnic_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_cable_corridor_bathymetry_geotechnic_id_seq OWNED BY beta.project_cable_corridor_bathymetry_geotechnic.id;


--
-- TOC entry 310 (class 1259 OID 52478)
-- Name: project_cable_corridor_constraint; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor_constraint (
    id integer NOT NULL,
    constraint_type_id integer,
    description text,
    fk_site_farm_id integer,
    boundary public.geometry
);


--
-- TOC entry 311 (class 1259 OID 52484)
-- Name: project_cable_corridor_constraint_activity_frequency; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_cable_corridor_constraint_activity_frequency (
    id integer NOT NULL,
    constraint_id integer,
    vessel_weight_upper double precision,
    frequency double precision,
    vessel_weight_lower double precision,
    fk_site_id integer
);


--
-- TOC entry 312 (class 1259 OID 52487)
-- Name: project_cable_corridor_constraint_activity_frequency_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_cable_corridor_constraint_activity_frequency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5441 (class 0 OID 0)
-- Dependencies: 312
-- Name: project_cable_corridor_constraint_activity_frequency_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_cable_corridor_constraint_activity_frequency_id_seq OWNED BY beta.project_cable_corridor_constraint_activity_frequency.id;


--
-- TOC entry 313 (class 1259 OID 52489)
-- Name: project_cable_corridor_constraint_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_cable_corridor_constraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5442 (class 0 OID 0)
-- Dependencies: 313
-- Name: project_cable_corridor_constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_cable_corridor_constraint_id_seq OWNED BY beta.project_cable_corridor_constraint.id;


--
-- TOC entry 314 (class 1259 OID 52491)
-- Name: project_constraint; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_constraint (
    id integer NOT NULL,
    constraint_type_id integer,
    description text,
    fk_site_farm_id integer,
    boundary public.geometry
);


--
-- TOC entry 315 (class 1259 OID 52497)
-- Name: project_constraint_activity_frequency; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_constraint_activity_frequency (
    id integer NOT NULL,
    constraint_id integer,
    vessel_weight_upper double precision,
    frequency double precision,
    vessel_weight_lower double precision,
    fk_site_id integer
);


--
-- TOC entry 316 (class 1259 OID 52500)
-- Name: project_constraint_activity_frequency_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_constraint_activity_frequency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5443 (class 0 OID 0)
-- Dependencies: 316
-- Name: project_constraint_activity_frequency_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_constraint_activity_frequency_id_seq OWNED BY beta.project_constraint_activity_frequency.id;


--
-- TOC entry 317 (class 1259 OID 52502)
-- Name: project_constraint_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_constraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5444 (class 0 OID 0)
-- Dependencies: 317
-- Name: project_constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_constraint_id_seq OWNED BY beta.project_constraint.id;


--
-- TOC entry 318 (class 1259 OID 52504)
-- Name: project_device; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_device (
    component_type_id integer,
    description character varying(200),
    device_type character varying(50),
    system_displaced_volume double precision,
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    rotor_swept_area double precision,
    thrust_coefficient_single double precision,
    drag_coefficients double precision,
    zzinertia_coefficients double precision,
    rated_power double precision,
    rated_voltage double precision,
    characteristic_length double precision,
    hub_height double precision,
    installation_depth_max double precision,
    installation_depth_min double precision,
    depth_variation_permitted boolean,
    make character varying(50),
    model character varying(50),
    zzrotational_speed double precision,
    yaw double precision,
    floating boolean,
    working_principle_path text,
    assembly_duration double precision,
    zzradiation_damping character varying(100),
    zzadded_mass double precision,
    support_structure_profile character varying(50),
    system_centre_of_gravity double precision[],
    system_draft double precision,
    dry_beam_area double precision,
    system_mass double precision,
    system_profile character varying(50),
    wet_beam_area double precision,
    heave double precision,
    disconnect_duration double precision,
    cut_in_velocity double precision,
    cut_out_velocity double precision,
    comments text,
    top_thickness double precision,
    bottom_thickness double precision,
    control_signal_no_of_channels smallint,
    control_signal_type character varying(100),
    turbine_diameter double precision,
    zzemerged_footprint double precision,
    position_duration_range double precision[],
    image bytea,
    zzunderwater_noise double precision,
    zzunderwater_noise_distance_measured double precision,
    data_folder boolean,
    data_folder_path text,
    technology_type character varying(6),
    two_ways_flow boolean,
    assembly_strategy character varying(100),
    connect_duration double precision,
    device_surface_roughness double precision,
    sys_height double precision,
    sys_width double precision,
    sys_length double precision,
    prescribed_footprint_radius double precision,
    fk_component_type_id integer,
    minimum_distance_x double precision,
    minimum_distance_y double precision,
    ".turbine_interdistance" double precision,
    prescribed_mooring_system character varying(50),
    prescribed_foundation_system character varying(50),
    load_safety_factor double precision,
    power_factor double precision[],
    fairlead_location double precision[],
    id integer,
    wave_data_directory character varying(200),
    umbilical_connection_point double precision[],
    constant_power_factor double precision,
    connector_type character varying(50),
    maximum_displacement double precision[],
    coordinate_system double precision[],
    footprint_corner_coords double precision[],
    variable_power_factor double precision[],
    foundation_locations double precision[],
    prescribed_umbilical_type character varying(50)
);


--
-- TOC entry 5445 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN project_device.connector_type; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_device.connector_type IS 'Column requested on 22/8/16 by DB, to hold values Wet-Mate & Dry-Mate.';


--
-- TOC entry 5446 (class 0 OID 0)
-- Dependencies: 318
-- Name: COLUMN project_device.coordinate_system; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_device.coordinate_system IS 'To contain position (x,y,z) of tidal device hub or wave device point of rotation.”';


--
-- TOC entry 319 (class 1259 OID 52510)
-- Name: project_device1_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_device1_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5447 (class 0 OID 0)
-- Dependencies: 319
-- Name: project_device1_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_device1_id_seq OWNED BY beta.project_device.id;


--
-- TOC entry 320 (class 1259 OID 52512)
-- Name: project_device_power_performance_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_device_power_performance_tidal (
    fk_device_id integer,
    velocity double precision,
    thrust_coefficient double precision,
    power_coefficient double precision
);


--
-- TOC entry 321 (class 1259 OID 52515)
-- Name: project_farm; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_farm (
    id bigint NOT NULL,
    hat double precision,
    lat double precision,
    surface_current_flow_velocity double precision,
    current_flow_direction double precision,
    significant_wave_height double precision,
    peak_wave_period double precision,
    predominant_wave_direction double precision,
    max_wind_gust_speed double precision,
    predominant_wind_direction double precision,
    sea_surface_elevation double precision,
    storm_surge_min_height double precision,
    storm_surge_max_height double precision,
    zero_upcrossing_wave_period double precision,
    spectrum_peakedness double precision,
    lease_area double precision,
    farm_area double precision,
    lease_volume double precision,
    noise_threshold double precision,
    minimum_q_factor double precision,
    hydrodynamic_folder_path text,
    map_datum text,
    power_law_exponent double precision,
    technology_type character varying(25),
    sea_bottom_tidal_current_velocity double precision,
    maximum_seabed_temp double precision,
    maximum_seabed_thermal_resistivity double precision,
    onshore_infrastructure_cost double precision,
    zzprescribed_mooring_system character varying(50),
    zzprescribed_foundation_system character varying(50),
    prescribed_umbilical_id integer,
    required_environmental_impact character varying(50),
    air_density double precision,
    water_level_max double precision,
    water_level_min double precision,
    wind_gust_direction double precision,
    cost_onshore_infrastructure double precision,
    wave_spectrum_type character varying(20),
    wave_spectrum_gamma double precision,
    wave_spectrum_spreading_parameter double precision,
    wave_spectrum_sigmaa double precision,
    wave_spectrum_sigmab double precision,
    zzfarm_surroundings character varying(100),
    fk_site_id integer NOT NULL,
    initial_electromagnetic_field double precision,
    initial_electric_field double precision,
    array_rated_power double precision,
    "parametrised array description" text,
    mean_wind_speed double precision,
    offshore_reactive_power_limits double precision[],
    onshore_reactive_power_limits double precision[],
    farm_boundary public.geometry,
    lease_boundary public.geometry,
    lease_boundary1 public.geometry,
    blockage_ratio double precision,
    entry_point public.geometry,
    cable_landing_location public.geometry,
    tidal_occurrence_point public.geometry(Point),
    array_main_direction double precision,
    farm_origin public.geometry(Point),
    deployment_area public.geometry(Polygon),
    moor_found_current_profile character varying(20)
);


--
-- TOC entry 322 (class 1259 OID 52521)
-- Name: project_farm_fk_site_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_farm_fk_site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5448 (class 0 OID 0)
-- Dependencies: 322
-- Name: project_farm_fk_site_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.project_farm_fk_site_id_seq OWNED BY beta.project_farm.fk_site_id;


--
-- TOC entry 323 (class 1259 OID 52523)
-- Name: project_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 324 (class 1259 OID 52525)
-- Name: project_site; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_site (
    id smallint,
    site_name character varying(20),
    lease_area_proj4_string character varying(100),
    lease_boundary_old public.geometry(Polygon),
    site_boundary_old public.geometry(Polygon,4326),
    site_boundary public.geometry(Polygon,4326),
    lease_boundary public.geometry(Polygon),
    corridor_boundary public.geometry(Polygon)
);


--
-- TOC entry 325 (class 1259 OID 52531)
-- Name: project_time_series_energy_wave; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_time_series_energy_wave (
    measure_date date,
    measure_time time(6) without time zone,
    te double precision,
    direction double precision,
    height double precision,
    fk_period_type smallint,
    point_id bigint,
    id bigint NOT NULL,
    spectrum_name character varying(10),
    gamma_factor double precision,
    spreading_parameter double precision
);


--
-- TOC entry 5449 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.te; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.te IS 'Source: WP2
Energy Period';


--
-- TOC entry 5450 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.direction; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.direction IS 'Unit: Decimal Degree';


--
-- TOC entry 5451 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.height; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.height IS 'Unit: m';


--
-- TOC entry 5452 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.point_id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.point_id IS 'ID of related point in the Bathymetry Table.
';


--
-- TOC entry 5453 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.id IS 'Unique sequential ID for this tabel.
Source: requiredfor SQLAlchemy Automapper';


--
-- TOC entry 5454 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.spectrum_name; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.spectrum_name IS 'Source: WP2, email
spectrum name (str): spectrum type name either ''regular'', ''jonswap'', ''PM''';


--
-- TOC entry 5455 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.gamma_factor; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.gamma_factor IS 'Source: WP2, email
gamma factor (float): peak enhancement factor of the wave spectrum';


--
-- TOC entry 5456 (class 0 OID 0)
-- Dependencies: 325
-- Name: COLUMN project_time_series_energy_wave.spreading_parameter; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_energy_wave.spreading_parameter IS 'Source: WP2, email
spreading parameter (float): directional spreading parameter';


--
-- TOC entry 326 (class 1259 OID 52534)
-- Name: project_time_series_om_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_time_series_om_tidal (
    measure_date date,
    measure_time time(6) without time zone,
    current_speed double precision,
    fk_farm_id bigint
);


--
-- TOC entry 5457 (class 0 OID 0)
-- Dependencies: 326
-- Name: TABLE project_time_series_om_tidal; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.project_time_series_om_tidal IS 'u_comp: zonal component/x-coordinate
v_comp: meridional component/y-coordinate';


--
-- TOC entry 5458 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN project_time_series_om_tidal.measure_date; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_tidal.measure_date IS 'Source: WP5';


--
-- TOC entry 5459 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN project_time_series_om_tidal.measure_time; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_tidal.measure_time IS 'Source: WP5';


--
-- TOC entry 5460 (class 0 OID 0)
-- Dependencies: 326
-- Name: COLUMN project_time_series_om_tidal.current_speed; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_tidal.current_speed IS 'Magnitude of vector of current speed
Unit m/s
Source: WP5(tidal speed)';


--
-- TOC entry 327 (class 1259 OID 52537)
-- Name: project_time_series_om_wave; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_time_series_om_wave (
    measure_date date,
    measure_time time(6) without time zone,
    period_tp double precision,
    height_hs double precision,
    fk_farm_id integer
);


--
-- TOC entry 5461 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN project_time_series_om_wave.measure_date; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wave.measure_date IS 'Source: WP5';


--
-- TOC entry 5462 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN project_time_series_om_wave.measure_time; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wave.measure_time IS 'Source: WP5';


--
-- TOC entry 5463 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN project_time_series_om_wave.period_tp; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wave.period_tp IS 'Unit: s
Source: WP5(Tp)';


--
-- TOC entry 5464 (class 0 OID 0)
-- Dependencies: 327
-- Name: COLUMN project_time_series_om_wave.height_hs; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wave.height_hs IS 'Unit: m
Source: WP5 (Hs)';


--
-- TOC entry 328 (class 1259 OID 52540)
-- Name: project_time_series_om_wind; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.project_time_series_om_wind (
    measure_date date,
    measure_time time(6) without time zone,
    wind_speed double precision,
    fk_farm_id integer
);


--
-- TOC entry 5465 (class 0 OID 0)
-- Dependencies: 328
-- Name: COLUMN project_time_series_om_wind.measure_date; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wind.measure_date IS 'Source: WP5';


--
-- TOC entry 5466 (class 0 OID 0)
-- Dependencies: 328
-- Name: COLUMN project_time_series_om_wind.measure_time; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wind.measure_time IS 'Source: WP5';


--
-- TOC entry 5467 (class 0 OID 0)
-- Dependencies: 328
-- Name: COLUMN project_time_series_om_wind.wind_speed; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.project_time_series_om_wind.wind_speed IS 'Unit: m/s
Sourcd: WP5(wind speed)';


--
-- TOC entry 329 (class 1259 OID 52543)
-- Name: ref_component_functional_area_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.ref_component_functional_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5468 (class 0 OID 0)
-- Dependencies: 329
-- Name: ref_component_functional_area_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.ref_component_functional_area_id_seq OWNED BY beta.component_functional_area.id;


--
-- TOC entry 330 (class 1259 OID 52545)
-- Name: ref_current_drag_coef_rect; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_current_drag_coef_rect (
    width_length double precision,
    thickness_width double precision
);


--
-- TOC entry 331 (class 1259 OID 52548)
-- Name: ref_drag_coef_cyl; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_drag_coef_cyl (
    reynolds_number double precision,
    smooth double precision,
    roughness_1e_5 double precision,
    roughness_1e_2 double precision
);


--
-- TOC entry 332 (class 1259 OID 52551)
-- Name: ref_drift_coef_float_rect; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_drift_coef_float_rect (
    wavenumber_draft double precision,
    reflection_coefficient double precision
);


--
-- TOC entry 333 (class 1259 OID 52554)
-- Name: ref_general_parameter; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_general_parameter (
    id integer NOT NULL,
    coststeel double precision,
    costgrout double precision,
    costcon double precision,
    groutstr double precision,
    fabcost double precision
);


--
-- TOC entry 5469 (class 0 OID 0)
-- Dependencies: 333
-- Name: TABLE ref_general_parameter; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON TABLE beta.ref_general_parameter IS 'This table is used ot record single-value items for reference.';


--
-- TOC entry 5470 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.id; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.id IS 'Unique sequential ID';


--
-- TOC entry 5471 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.coststeel; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.coststeel IS 'cost of steel';


--
-- TOC entry 5472 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.costgrout; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.costgrout IS 'cost of grout';


--
-- TOC entry 5473 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.costcon; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.costcon IS 'cost of concrete';


--
-- TOC entry 5474 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.groutstr; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.groutstr IS 'Grout Compressive Strength
Source: BitBucket';


--
-- TOC entry 5475 (class 0 OID 0)
-- Dependencies: 333
-- Name: COLUMN ref_general_parameter.fabcost; Type: COMMENT; Schema: beta; Owner: -
--

COMMENT ON COLUMN beta.ref_general_parameter.fabcost IS 'fabrication factor applied to
material cost Source: WP4 (email, 01/03/2016)';


--
-- TOC entry 334 (class 1259 OID 52557)
-- Name: ref_general_parameter_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.ref_general_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5476 (class 0 OID 0)
-- Dependencies: 334
-- Name: ref_general_parameter_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.ref_general_parameter_id_seq OWNED BY beta.ref_general_parameter.id;


--
-- TOC entry 335 (class 1259 OID 52559)
-- Name: ref_holding_capacity_factors_plate_anchors; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_holding_capacity_factors_plate_anchors (
    relative_embedment_depth double precision,
    drained_friction_angle_20deg double precision,
    drained_friction_angle_25deg double precision,
    drained_friction_angle_30deg double precision,
    drained_friction_angle_35deg double precision,
    drained_friction_angle_40deg double precision
);


--
-- TOC entry 336 (class 1259 OID 52562)
-- Name: ref_line_bcf; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_line_bcf (
    soil_friction_angle double precision NOT NULL,
    bearing_capacity_factor double precision
);


--
-- TOC entry 337 (class 1259 OID 52565)
-- Name: ref_pile_deflection_coefficients; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_pile_deflection_coefficients (
    depth_coefficient double precision,
    coefficient_ay double precision,
    coefficient_by double precision
);


--
-- TOC entry 338 (class 1259 OID 52568)
-- Name: ref_pile_limiting_values_noncalcareous; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_pile_limiting_values_noncalcareous (
    soil_friction_angle double precision,
    friction_angle_sand_pile double precision,
    bearing_capacity_factor double precision,
    max_unit_skin_friction double precision,
    max_end_bearing_capacity double precision
);


--
-- TOC entry 339 (class 1259 OID 52571)
-- Name: ref_pile_moment_coefficient_sam; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_pile_moment_coefficient_sam (
    depth_coefficient double precision,
    pile_length_relative_soil_pile_stiffness_10 double precision,
    pile_length_relative_soil_pile_stiffness_5 double precision,
    pile_length_relative_soil_pile_stiffness_4 double precision,
    pile_length_relative_soil_pile_stiffness_3 double precision,
    pile_length_relative_soil_pile_stiffness_2 double precision
);


--
-- TOC entry 340 (class 1259 OID 52574)
-- Name: ref_pile_moment_coefficient_sbm; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_pile_moment_coefficient_sbm (
    depth_coefficient double precision,
    pile_length_relative_soil_pile_stiffness_10 double precision,
    pile_length_relative_soil_pile_stiffness_5 double precision,
    pile_length_relative_soil_pile_stiffness_4 double precision,
    pile_length_relative_soil_pile_stiffness_3 double precision,
    pile_length_relative_soil_pile_stiffness_2 double precision
);


--
-- TOC entry 341 (class 1259 OID 52577)
-- Name: ref_rectangular_wave_inertia; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_rectangular_wave_inertia (
    "width/length" double precision,
    inertia_coefficients double precision
);


--
-- TOC entry 342 (class 1259 OID 52580)
-- Name: ref_subgrade_reaction_coefficient_cohesionless; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_subgrade_reaction_coefficient_cohesionless (
    allowable_deflection_diameter double precision,
    relative_density_35 double precision,
    relative_density_50 double precision,
    relative_density_65 double precision,
    relative_density_85 double precision
);


--
-- TOC entry 343 (class 1259 OID 52583)
-- Name: ref_subgrade_reaction_coefficient_k1_cohesive; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_subgrade_reaction_coefficient_k1_cohesive (
    allowable_deflection_diameter double precision,
    softclay double precision,
    stiffclay double precision
);


--
-- TOC entry 344 (class 1259 OID 52586)
-- Name: ref_superline_nylon; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_superline_nylon (
    extension double precision,
    load_mbl double precision
);


--
-- TOC entry 345 (class 1259 OID 52589)
-- Name: ref_superline_polyester; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_superline_polyester (
    extension double precision,
    load_mbl double precision
);


--
-- TOC entry 346 (class 1259 OID 52592)
-- Name: ref_superline_steelite; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_superline_steelite (
    extension double precision,
    load_mbl double precision
);


--
-- TOC entry 347 (class 1259 OID 52595)
-- Name: ref_wake_amplification_factor_cyl; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_wake_amplification_factor_cyl (
    kc_steady_drag_coefficient double precision,
    amplification_factor_for_smooth_cylinders double precision,
    amplification_factor_for_rough_cylinders double precision
);


--
-- TOC entry 348 (class 1259 OID 52598)
-- Name: ref_wind_drag_coef_rect; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.ref_wind_drag_coef_rect (
    width_length double precision,
    height_breadth_between_0_1 double precision,
    height_breadth_less_1 double precision,
    height_breadth_less_2 double precision,
    height_breadth_less_4 double precision,
    height_breadth_less_6 double precision,
    height_breadth_less_10 double precision,
    height_breadth_less_20 double precision
);


--
-- TOC entry 349 (class 1259 OID 52601)
-- Name: site; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.site (
    id smallint NOT NULL,
    site_name character varying(20),
    lease_area_proj4_string character varying(100),
    site_boundary_old public.geometry(Polygon,4326),
    site_boundary public.geometry(Polygon,4326),
    lease_boundary_old public.geometry(Polygon),
    lease_boundary public.geometry(Polygon),
    corridor_boundary public.geometry(Polygon)
);


--
-- TOC entry 350 (class 1259 OID 52607)
-- Name: soil_type; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.soil_type (
    id integer DEFAULT nextval('beta."400000_soil_type_trial_seq"'::regclass) NOT NULL,
    soil_group character varying(20),
    soil_type character varying(40)
);


--
-- TOC entry 351 (class 1259 OID 52611)
-- Name: soil_type_geotechnical_properties; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.soil_type_geotechnical_properties (
    soil_type character varying(50),
    drained_soil_friction_angle double precision,
    relative_soil_density double precision,
    buoyant_unit_weight_of_soil double precision,
    effective_drained_cohesion double precision,
    seafloor_friction_coefficient double precision,
    soil_sensitivity double precision,
    rock_compressive_strength double precision,
    id bigint NOT NULL,
    undrained_soil_shear_strength_constant_term double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision
);


--
-- TOC entry 352 (class 1259 OID 52614)
-- Name: soil_type_id_seq1; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.soil_type_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5477 (class 0 OID 0)
-- Dependencies: 352
-- Name: soil_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.soil_type_id_seq1 OWNED BY beta.soil_type.id;


--
-- TOC entry 353 (class 1259 OID 52616)
-- Name: substation_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.substation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5478 (class 0 OID 0)
-- Dependencies: 353
-- Name: substation_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.substation_id_seq OWNED BY beta.component_substation.id;


--
-- TOC entry 354 (class 1259 OID 52618)
-- Name: time_series_energy_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.time_series_energy_tidal (
    measure_date date,
    measure_time time(6) without time zone,
    u double precision,
    v double precision,
    id bigint NOT NULL,
    turbulence_intensity double precision,
    ssh double precision,
    fk_point_id bigint
);


--
-- TOC entry 355 (class 1259 OID 52621)
-- Name: time_series_energy_tidal_id_seq1; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.time_series_energy_tidal_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5479 (class 0 OID 0)
-- Dependencies: 355
-- Name: time_series_energy_tidal_id_seq1; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.time_series_energy_tidal_id_seq1 OWNED BY beta.time_series_energy_tidal.id;


--
-- TOC entry 356 (class 1259 OID 52623)
-- Name: time_series_energy_wave; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.time_series_energy_wave (
    measure_date date,
    measure_time time(6) without time zone,
    te double precision,
    direction double precision,
    height double precision,
    fk_period_type smallint,
    point_id bigint,
    id bigint NOT NULL,
    spectrum_name character varying(10),
    gamma_factor double precision,
    spreading_parameter double precision
);


--
-- TOC entry 357 (class 1259 OID 52626)
-- Name: time_series_energy_wave_id_seq1; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.time_series_energy_wave_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5480 (class 0 OID 0)
-- Dependencies: 357
-- Name: time_series_energy_wave_id_seq1; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.time_series_energy_wave_id_seq1 OWNED BY beta.time_series_energy_wave.id;


--
-- TOC entry 358 (class 1259 OID 52628)
-- Name: time_series_energy_wave_project_id_seq; Type: SEQUENCE; Schema: beta; Owner: -
--

CREATE SEQUENCE beta.time_series_energy_wave_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5481 (class 0 OID 0)
-- Dependencies: 358
-- Name: time_series_energy_wave_project_id_seq; Type: SEQUENCE OWNED BY; Schema: beta; Owner: -
--

ALTER SEQUENCE beta.time_series_energy_wave_project_id_seq OWNED BY beta.project_time_series_energy_wave.id;


--
-- TOC entry 359 (class 1259 OID 52630)
-- Name: time_series_om_tidal; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.time_series_om_tidal (
    measure_date date,
    measure_time time(6) without time zone,
    current_speed double precision,
    fk_farm_id bigint
);


--
-- TOC entry 360 (class 1259 OID 52633)
-- Name: time_series_om_wave; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.time_series_om_wave (
    measure_date date,
    measure_time time(6) without time zone,
    period_tp double precision,
    height_hs double precision,
    fk_farm_id integer
);


--
-- TOC entry 361 (class 1259 OID 52636)
-- Name: time_series_om_wind; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.time_series_om_wind (
    measure_date date,
    measure_time time(6) without time zone,
    wind_speed double precision,
    fk_farm_id integer
);


--
-- TOC entry 362 (class 1259 OID 52639)
-- Name: vessels; Type: TABLE; Schema: beta; Owner: -
--

CREATE TABLE beta.vessels (
    id integer NOT NULL,
    vessel_class character varying(100),
    vessel_type character varying(100),
    gross_tonnage double precision,
    length double precision,
    beam double precision,
    min_draft double precision,
    max_draft double precision,
    travel_range double precision,
    engine_size double precision,
    fuel_tank double precision,
    consumption double precision,
    consumption_towing double precision,
    deck_space double precision,
    deck_loading double precision,
    max_cargo double precision,
    transit_speed double precision,
    max_speed double precision,
    bollard_pull double precision,
    crew_size integer,
    external_personel integer,
    transit_max_hs double precision,
    transit_max_tp double precision,
    transit_max_cs double precision,
    transit_max_ws double precision,
    towing_max_hs double precision,
    towing_max_tp double precision,
    towing_max_cs double precision,
    towing_max_ws double precision,
    jacking_max_hs double precision,
    jacking_max_tp double precision,
    jacking_max_cs double precision,
    jacking_max_ws double precision,
    crane_capacity double precision,
    crane_radius double precision,
    number_turntables integer,
    turntable_loading double precision,
    turntable_outer_diameter double precision,
    turntable_inner_diameter double precision,
    turntable_height double precision,
    cable_splice boolean,
    ground_out_capabilities boolean,
    dp integer,
    rock_storage_capacity double precision,
    max_dumping_depth double precision,
    max_dumping_capacity double precision,
    fall_pipe_diameter double precision,
    diving_moonpool boolean,
    diving_depth double precision,
    diving_capacity double precision,
    rov_inspection boolean,
    rov_inspection_max_depth double precision,
    rov_workclass boolean,
    rov_workclass_max_depth double precision,
    jackup_leg_length double precision,
    jackup_leg_diameter double precision,
    jackup_max_water_depth double precision,
    jackup_speed_up double precision,
    jackup_speed_down double precision,
    jackup_max_payload double precision,
    number_mooring_winches integer,
    mooring_line_pull double precision,
    mooring_wire_length double precision,
    number_mooring_anchors integer,
    mooring_anchor_weight double precision,
    ah_drum_capacity double precision,
    ah_wire_size double precision,
    ah_winch_rated_pull double precision,
    ah_winch_break_load double precision,
    dredge_depth double precision,
    dredge_type character varying(100),
    mob_time double precision,
    mob_percentage double precision,
    op_min_day_rate double precision,
    op_max_day_rate double precision
);


--
-- TOC entry 363 (class 1259 OID 52642)
-- Name: view_component_cable; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_cable AS
 SELECT component.id AS component_id,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_cable.number_conductors AS number_of_conductors,
    component_cable.conductor_csa,
    component_cable.conductor_material AS conductor_diameter,
    component_cable.insulation_material,
    component_cable.screen_type,
    component_cable.armouring,
    component_cable.serving,
    component.diameter AS cable_diameter,
    component_cable."rated_voltage_U" AS rated_voltage,
    component_cable.maximum_voltage AS maximum_rated_voltage,
    component_cable.minimum_voltage AS minimum_rated_voltage,
    component_cable.resistance_dc_20 AS electrical_resistance_dc_20,
    component_cable.resistance_ac_90 AS electrical_resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.rated_current_air AS rated_current_in_air_40,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube AS rated_current_j_tube,
    component_cable.frequency,
    component.weight_air,
    component.weight_water,
    component_cable.maximum_pulling_tension,
    component_cable.minimum_bend_radius,
    component.colour AS serving_colour,
    component.operational_temp_min,
    component.operational_temp_max,
    component.comments AS source,
    component.cost
   FROM ((beta.component
     JOIN beta.component_cable ON ((component.id = component_cable.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 364 (class 1259 OID 52647)
-- Name: view_component_cable_dynamic; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_cable_dynamic AS
 SELECT component.id AS component_id,
    component.fk_component_type_id,
    component.description AS component_description,
    component.supplier_id,
    component.mass,
    component.height,
    component.width,
    component.length,
    component.diameter,
    component.unit,
    component.cost_per_unit,
    component.mtbf,
    component.inspection_rate,
    component.inspection_time,
    component.maintenance_rate,
    component.environmental_impact,
    component.category,
    component.reference_quantity,
    component.colour,
    component.calendar_maintenance_interval,
    component.soh_function,
    component.soh_threshold,
    component.assembly_port,
    component.bollard_pull,
    component.density,
    component.submerged_mass_per_unit_length,
    component.minimum_breaking_load,
    component.required_component_reliability,
    component.load_safety_factor,
    component.modulus_of_elasticity,
    component.flexural_stiffness,
    component.product_code,
    component.weight_air,
    component.weight_water,
    component.operational_temp_min,
    component.operational_temp_max,
    component.material,
    component.depth,
    component.load_out_strategy,
    component.transport_method,
    component.component_name,
    component.component_subname,
    component.grade,
    component.yield_stress,
    component.youngs_modulus,
    component.thickness,
    component.connecting_length,
    component.connecting_size,
    component.anchor_coefficient,
    component.failure_rate,
    component.number_failure_modes,
    component.start_date_calendar_based_maintenance,
    component.end_date_calendar_based_maintenance,
    component.start_date_condition_based_maintenance,
    component.end_date_condition_based_maintenance,
    component."Is_floating" AS is_floating,
    component.code,
    component.centre_of_gravity,
    component.grout_bond_strength,
    component.comments,
    component.cost,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.dry_mass_per_unit_length,
    component.wet_mass_per_unit_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound,
    component_cable.number_conductors,
    component_cable.conductor_csa,
    component_cable.conductor_material,
    component_cable.maximum_voltage,
    component_cable.insulation_material,
    component_cable.screen_type,
    component_cable.armouring,
    component_cable.serving,
    component_cable."rated_voltage_U" AS rated_voltage_u,
    component_cable.resistance_dc_20,
    component_cable.resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.frequency,
    component_cable.maximum_pulling_tension,
    component_cable.minimum_bend_radius,
    component_cable.fk_component_id,
    component_cable.minimum_voltage,
    component_cable.rated_current_air,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube,
    component_cable.cable_type,
    component_cable.fibre_optic,
    component_cable.cable_diameter,
    component_cable.conductor_diameter,
    component_cable.insulation_diameter,
    component_cable.screen_diameter,
    component_cable.armouring_thickness,
    component_cable.impulse_level,
    component_cable.conductor_short_circuit_current_capacity,
    component_cable.maximum_conductor_temp_in_service,
    component_cable.maximum_conductor_temp_in_short_circuit,
    component_cable.rated_voltage_ou,
    component_cable.mbr_without_tension,
    component_cable.mbr_under_tension,
    component_type.description,
    component_type.parent_type_id,
    component_type.functional_area_id,
    component_type.id AS component_type_id,
    component_supplier.id AS component_supplier_id,
    component_supplier.supplier_name
   FROM (((beta.component
     JOIN beta.component_cable ON ((component.id = component_cable.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)))
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_cable.cable_type)::text = 'dynamic'::text);


--
-- TOC entry 365 (class 1259 OID 52652)
-- Name: view_component_cable_static; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_cable_static AS
 SELECT component.id AS component_id,
    component.fk_component_type_id,
    component.description AS component_description,
    component.supplier_id,
    component.mass,
    component.height,
    component.width,
    component.length,
    component.diameter,
    component.unit,
    component.cost_per_unit,
    component.mtbf,
    component.inspection_rate,
    component.inspection_time,
    component.maintenance_rate,
    component.environmental_impact,
    component.category,
    component.reference_quantity,
    component.colour,
    component.calendar_maintenance_interval,
    component.soh_function,
    component.soh_threshold,
    component.assembly_port,
    component.bollard_pull,
    component.density,
    component.submerged_mass_per_unit_length,
    component.minimum_breaking_load,
    component.required_component_reliability,
    component.load_safety_factor,
    component.modulus_of_elasticity,
    component.flexural_stiffness,
    component.product_code,
    component.weight_air,
    component.weight_water,
    component.operational_temp_min,
    component.operational_temp_max,
    component.material,
    component.depth,
    component.load_out_strategy,
    component.transport_method,
    component.component_name,
    component.component_subname,
    component.grade,
    component.yield_stress,
    component.youngs_modulus,
    component.thickness,
    component.connecting_length,
    component.connecting_size,
    component.anchor_coefficient,
    component.failure_rate,
    component.number_failure_modes,
    component.start_date_calendar_based_maintenance,
    component.end_date_calendar_based_maintenance,
    component.start_date_condition_based_maintenance,
    component.end_date_condition_based_maintenance,
    component."Is_floating" AS is_floating,
    component.code,
    component.centre_of_gravity,
    component.grout_bond_strength,
    component.comments,
    component.cost,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.dry_mass_per_unit_length,
    component.wet_mass_per_unit_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound,
    component_cable.number_conductors,
    component_cable.conductor_csa,
    component_cable.conductor_material,
    component_cable.maximum_voltage,
    component_cable.insulation_material,
    component_cable.screen_type,
    component_cable.armouring,
    component_cable.serving,
    component_cable."rated_voltage_U" AS rated_voltage_u,
    component_cable.resistance_dc_20,
    component_cable.resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.frequency,
    component_cable.maximum_pulling_tension,
    component_cable.minimum_bend_radius,
    component_cable.fk_component_id,
    component_cable.minimum_voltage,
    component_cable.rated_current_air,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube,
    component_cable.cable_type,
    component_cable.fibre_optic,
    component_cable.cable_diameter,
    component_cable.conductor_diameter,
    component_cable.insulation_diameter,
    component_cable.screen_diameter,
    component_cable.armouring_thickness,
    component_cable.impulse_level,
    component_cable.conductor_short_circuit_current_capacity,
    component_cable.maximum_conductor_temp_in_service,
    component_cable.maximum_conductor_temp_in_short_circuit,
    component_cable.rated_voltage_ou,
    component_cable.mbr_without_tension,
    component_cable.mbr_under_tension,
    component_type.description,
    component_type.parent_type_id,
    component_type.functional_area_id,
    component_type.id AS component_type_id,
    component_supplier.id AS component_supplier_id,
    component_supplier.supplier_name
   FROM (((beta.component
     JOIN beta.component_cable ON ((component.id = component_cable.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)))
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_cable.cable_type)::text = 'static'::text);


--
-- TOC entry 366 (class 1259 OID 52657)
-- Name: view_component_collection_point; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_collection_point AS
 SELECT component_collection_point.id AS collection_point_id,
    component_collection_point.fk_component_id AS component_id,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_collection_point.voltage_1,
    component_collection_point.voltage_2,
    component_collection_point.frequency,
    component_collection_point.rated_operating_current,
    component_collection_point.conductor_size,
    component_collection_point.input_lines,
    component_collection_point.output_lines,
    component_collection_point.bus_bar,
    component.weight_air,
    component.weight_water,
    component.height,
    component.width,
    component.depth,
    component_collection_point.maximum_water_depth,
    component_collection_point.connector_type,
    component_collection_point.connection_equipment,
    component_collection_point.number_operations,
    component_collection_point.outer_coating,
    component.colour,
    component.operational_temp_min AS opertional_temp_min,
    component.operational_temp_max AS opertional_temp_max,
    component_collection_point.operational_temperature AS opertional_temperature,
    component_collection_point.foundation,
    component.centre_of_gravity,
    component_collection_point.operating_environment,
    component_collection_point.fibre_optic,
    component.comments AS source,
    component_collection_point.input_connector_type,
    component_collection_point.output_connector_type,
    component_collection_point.cooling,
    component_collection_point.point_type,
    component.cost,
    component.mass,
    component.length,
    component.environmental_impact,
    component_collection_point.wet_frontal_area,
    component_collection_point.dry_frontal_area,
    component_collection_point.wet_beam_area,
    component_collection_point.dry_beam_area,
    component_collection_point.orientation_angle,
    component_collection_point.foundation_locations AS foundation_location,
    component_collection_point.centre_of_gravity AS cp_centre_of_gravity,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM ((beta.component
     JOIN beta.component_collection_point ON ((component.id = component_collection_point.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 367 (class 1259 OID 52662)
-- Name: view_component_connector; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_connector AS
 SELECT component.id AS component_id,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_connector.number_contacts AS number_of_contacts,
    component_connector.rated_voltage_u0,
    component_connector.rated_voltage_u,
    component_connector.maximum_rated_voltage,
    component_connector.rated_current,
    component_connector.short_circuit_current_capacity,
    component_connector.frequency,
    component_connector.contact_resistance,
    component_connector.fibre_optic,
    component_connector.maximum_water_depth,
    component_connector.maximum_number_mating_cycles AS maximum_number_of_mating_cycles,
    component_connector.mating_force,
    component_connector.demating_force,
    component_connector.electrical_cable_csa,
    component_connector.weight_air,
    component_connector.weight_water,
    component.height,
    component.width,
    component.depth,
    component_connector.connection_equipment,
    component_connector.outer_coating,
    component.colour,
    component.operational_temp_min,
    component.operational_temp_max,
    component_connector.operational_temperature,
    component.comments AS source,
    component.cost,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM ((beta.component
     JOIN beta.component_connector ON ((component.id = component_connector.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 368 (class 1259 OID 52667)
-- Name: view_component_connector_drymate; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_connector_drymate AS
 SELECT component.id AS component_id,
    component.fk_component_type_id,
    component.description AS component_description,
    component.supplier_id,
    component.mass,
    component.height,
    component.width,
    component.length,
    component.diameter,
    component.unit,
    component.cost_per_unit,
    component.mtbf,
    component.inspection_rate,
    component.inspection_time,
    component.maintenance_rate,
    component.environmental_impact,
    component.category,
    component.reference_quantity,
    component.colour,
    component.calendar_maintenance_interval,
    component.soh_function,
    component.soh_threshold,
    component.assembly_port,
    component.bollard_pull,
    component.density,
    component.submerged_mass_per_unit_length,
    component.minimum_breaking_load,
    component.required_component_reliability,
    component.load_safety_factor,
    component.modulus_of_elasticity,
    component.flexural_stiffness,
    component.product_code,
    component.weight_air,
    component.weight_water,
    component.operational_temp_min,
    component.operational_temp_max,
    component.material,
    component.depth,
    component.load_out_strategy,
    component.transport_method,
    component.component_name,
    component.component_subname,
    component.grade,
    component.yield_stress,
    component.youngs_modulus,
    component.thickness,
    component.connecting_length,
    component.connecting_size,
    component.anchor_coefficient,
    component.failure_rate,
    component.number_failure_modes,
    component.start_date_calendar_based_maintenance,
    component.end_date_calendar_based_maintenance,
    component.start_date_condition_based_maintenance,
    component.end_date_condition_based_maintenance,
    component."Is_floating" AS is_floating,
    component.code,
    component.centre_of_gravity,
    component.grout_bond_strength,
    component.comments,
    component.cost,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.dry_mass_per_unit_length,
    component.wet_mass_per_unit_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound,
    component_connector.number_contacts,
    component_connector.rated_voltage_u0,
    component_connector.rated_voltage_u,
    component_connector.maximum_rated_voltage,
    component_connector.rated_current,
    component_connector.short_circuit_current_capacity,
    component_connector.frequency,
    component_connector.contact_resistance,
    component_connector.fibre_optic,
    component_connector.maximum_water_depth,
    component_connector.maximum_number_mating_cycles,
    component_connector.mating_force,
    component_connector.demating_force,
    component_connector.electrical_cable_csa,
    component_connector.connection_equipment,
    component_connector.outer_coating,
    component_connector.operational_temperature,
    component_connector.fk_component_id,
    component_connector.component_type,
    component_connector.electrical_cable_csa_min,
    component_connector.electrical_cable_csa_max,
    component_type.description,
    component_type.parent_type_id,
    component_type.functional_area_id,
    component_type.id AS component_type_id,
    component_supplier.id AS component_supplier_id,
    component_supplier.supplier_name
   FROM (((beta.component
     JOIN beta.component_connector ON ((component.id = component_connector.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)))
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_connector.component_type)::text = 'dry-mate'::text);


--
-- TOC entry 369 (class 1259 OID 52672)
-- Name: view_component_connector_wetmate; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_connector_wetmate AS
 SELECT component.id AS component_id,
    component.fk_component_type_id,
    component.description AS component_description,
    component.supplier_id,
    component.mass,
    component.height,
    component.width,
    component.length,
    component.diameter,
    component.unit,
    component.cost_per_unit,
    component.mtbf,
    component.inspection_rate,
    component.inspection_time,
    component.maintenance_rate,
    component.environmental_impact,
    component.category,
    component.reference_quantity,
    component.colour,
    component.calendar_maintenance_interval,
    component.soh_function,
    component.soh_threshold,
    component.assembly_port,
    component.bollard_pull,
    component.density,
    component.submerged_mass_per_unit_length,
    component.minimum_breaking_load,
    component.required_component_reliability,
    component.load_safety_factor,
    component.modulus_of_elasticity,
    component.flexural_stiffness,
    component.product_code,
    component.weight_air,
    component.weight_water,
    component.operational_temp_min,
    component.operational_temp_max,
    component.material,
    component.depth,
    component.load_out_strategy,
    component.transport_method,
    component.component_name,
    component.component_subname,
    component.grade,
    component.yield_stress,
    component.youngs_modulus,
    component.thickness,
    component.connecting_length,
    component.connecting_size,
    component.anchor_coefficient,
    component.failure_rate,
    component.number_failure_modes,
    component.start_date_calendar_based_maintenance,
    component.end_date_calendar_based_maintenance,
    component.start_date_condition_based_maintenance,
    component.end_date_condition_based_maintenance,
    component."Is_floating" AS is_floating,
    component.code,
    component.centre_of_gravity,
    component.grout_bond_strength,
    component.comments,
    component.cost,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.dry_mass_per_unit_length,
    component.wet_mass_per_unit_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound,
    component_connector.number_contacts,
    component_connector.rated_voltage_u0,
    component_connector.rated_voltage_u,
    component_connector.maximum_rated_voltage,
    component_connector.rated_current,
    component_connector.short_circuit_current_capacity,
    component_connector.frequency,
    component_connector.contact_resistance,
    component_connector.fibre_optic,
    component_connector.maximum_water_depth,
    component_connector.maximum_number_mating_cycles,
    component_connector.mating_force,
    component_connector.demating_force,
    component_connector.electrical_cable_csa,
    component_connector.connection_equipment,
    component_connector.outer_coating,
    component_connector.operational_temperature,
    component_connector.fk_component_id,
    component_connector.component_type,
    component_connector.electrical_cable_csa_min,
    component_connector.electrical_cable_csa_max,
    component_type.description,
    component_type.parent_type_id,
    component_type.functional_area_id,
    component_type.id AS component_type_id,
    component_supplier.id AS component_supplier_id,
    component_supplier.supplier_name
   FROM (((beta.component
     JOIN beta.component_connector ON ((component.id = component_connector.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)))
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_connector.component_type)::text = 'wet-mate'::text);


--
-- TOC entry 370 (class 1259 OID 52677)
-- Name: view_component_foundations_anchor; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_foundations_anchor AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.width,
    component.depth,
    component.height,
    component.connecting_size,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.cost,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'anchor'::text);


--
-- TOC entry 371 (class 1259 OID 52682)
-- Name: view_component_foundations_pile; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_foundations_pile AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.yield_stress,
    component.rope_stiffness_curve,
    component.youngs_modulus,
    component.diameter,
    component.thickness,
    component.dry_mass_per_unit_length,
    component.length,
    component.submerged_mass_per_unit_length,
    component.cost_per_unit,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'piles'::text);


--
-- TOC entry 372 (class 1259 OID 52687)
-- Name: view_component_moorings_chain; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_chain AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.diameter,
    component.connecting_length,
    component.dry_mass_per_unit_length,
    component.length,
    component.submerged_mass_per_unit_length,
    component.cost_per_unit,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'chain'::text);


--
-- TOC entry 373 (class 1259 OID 52692)
-- Name: view_component_moorings_forerunner; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_forerunner AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.diameter,
    component.connecting_length,
    component.dry_mass_per_unit_length,
    component.length,
    component.submerged_mass_per_unit_length,
    component.cost_per_unit,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'forerunner assembly'::text);


--
-- TOC entry 374 (class 1259 OID 52697)
-- Name: view_component_moorings_rope; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_rope AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.diameter,
    component.dry_mass_per_unit_length,
    component.length,
    component.submerged_mass_per_unit_length,
    component.cost_per_unit,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'rope'::text);


--
-- TOC entry 375 (class 1259 OID 52702)
-- Name: view_component_moorings_shackle; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_shackle AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.diameter,
    component.connecting_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.cost,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'shackle'::text);


--
-- TOC entry 376 (class 1259 OID 52707)
-- Name: view_component_moorings_swivel; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_swivel AS
 SELECT component.id AS component_id,
    component_type.description,
    component.material,
    component.grade,
    component.colour,
    component.minimum_breaking_load,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.diameter,
    component.connecting_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.cost,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM (beta.component
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'swivel'::text);


--
-- TOC entry 377 (class 1259 OID 52712)
-- Name: view_component_moorings_umbilical; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_moorings_umbilical AS
 SELECT component.id AS component_id,
    component.fk_component_type_id,
    component.description AS component_description,
    component.supplier_id,
    component.mass,
    component.height,
    component.width,
    component.length,
    component.diameter,
    component.unit,
    component.cost_per_unit,
    component.mtbf,
    component.inspection_rate,
    component.inspection_time,
    component.maintenance_rate,
    component.environmental_impact,
    component.category,
    component.reference_quantity,
    component.colour,
    component.calendar_maintenance_interval,
    component.soh_function,
    component.soh_threshold,
    component.assembly_port,
    component.bollard_pull,
    component.density,
    component.submerged_mass_per_unit_length,
    component.minimum_breaking_load,
    component.required_component_reliability,
    component.load_safety_factor,
    component.modulus_of_elasticity,
    component.flexural_stiffness,
    component.product_code,
    component.weight_air,
    component.weight_water,
    component.operational_temp_min,
    component.operational_temp_max,
    component.material,
    component.depth,
    component.load_out_strategy,
    component.transport_method,
    component.component_name,
    component.component_subname,
    component.grade,
    component.yield_stress,
    component.youngs_modulus,
    component.thickness,
    component.connecting_length,
    component.connecting_size,
    component.anchor_coefficient,
    component.failure_rate,
    component.number_failure_modes,
    component.start_date_calendar_based_maintenance,
    component.end_date_calendar_based_maintenance,
    component.start_date_condition_based_maintenance,
    component.end_date_condition_based_maintenance,
    component."Is_floating" AS is_floating,
    component.code,
    component.centre_of_gravity,
    component.grout_bond_strength,
    component.comments,
    component.cost,
    component.rope_stiffness_curve,
    component.axial_stiffness,
    component.dry_mass_per_unit_length,
    component.wet_mass_per_unit_length,
    component.dry_unit_mass,
    component.wet_unit_mass,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound,
    component_cable.number_conductors,
    component_cable.conductor_csa,
    component_cable.conductor_material,
    component_cable.maximum_voltage,
    component_cable.insulation_material,
    component_cable.screen_type,
    component_cable.armouring,
    component_cable.serving,
    component_cable."rated_voltage_U" AS rated_voltage_u,
    component_cable.resistance_dc_20,
    component_cable.resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.frequency,
    component_cable.maximum_pulling_tension,
    component_cable.minimum_bend_radius,
    component_cable.fk_component_id,
    component_cable.minimum_voltage,
    component_cable.rated_current_air,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube,
    component_cable.cable_type,
    component_cable.fibre_optic,
    component_cable.cable_diameter,
    component_cable.conductor_diameter,
    component_cable.insulation_diameter,
    component_cable.screen_diameter,
    component_cable.armouring_thickness,
    component_cable.impulse_level,
    component_cable.conductor_short_circuit_current_capacity,
    component_cable.maximum_conductor_temp_in_service,
    component_cable.maximum_conductor_temp_in_short_circuit,
    component_cable.rated_voltage_ou,
    component_cable.mbr_without_tension,
    component_cable.mbr_under_tension,
    component_type.description,
    component_type.parent_type_id,
    component_type.functional_area_id,
    component_type.id AS component_type_id,
    component_supplier.id AS component_supplier_id,
    component_supplier.supplier_name
   FROM (((beta.component
     JOIN beta.component_cable ON ((component.id = component_cable.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)))
     JOIN beta.component_type ON ((component.fk_component_type_id = component_type.id)))
  WHERE ((component_cable.cable_type)::text = 'dynamic'::text);


--
-- TOC entry 378 (class 1259 OID 52717)
-- Name: view_component_power_quality; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_power_quality AS
 SELECT component_power_quality.id AS power_quality_id,
    component.id AS component_id,
    component.description,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_power_quality.control_system,
    component_power_quality.rated_voltage,
    component_power_quality.frequency,
    component_power_quality.reactive_power_rating,
    component_power_quality.insulation_material,
    component_power_quality.number_of_control_stages,
    component_power_quality.reactive_power_of_each_stage,
    component_power_quality.switching_time,
    component.weight_air,
    component.weight_water,
    component_power_quality.operating_environment,
    component_power_quality.height_without_control_system,
    component_power_quality.width_without_control_system,
    component_power_quality.depth_without_control_system,
    component_power_quality.height_including_control_system,
    component_power_quality.width_including_control_system,
    component_power_quality.depth_including_control_system,
    component_power_quality.cooling,
    component_power_quality.remote_controlled,
    component_power_quality.outer_coating,
    component.colour,
    component.operational_temp_min,
    component.operational_temp_max,
    component_power_quality.maximum_water_depth,
    component.comments AS source,
    component.cost,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM ((beta.component
     JOIN beta.component_power_quality ON ((component.id = component_power_quality.fk_component_id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 379 (class 1259 OID 52722)
-- Name: view_component_switchgear; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_switchgear AS
 SELECT component.id AS component_id,
    component_switchgear.id AS switchgear_id,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_switchgear.rated_voltage,
    component_switchgear.frequency,
    component_switchgear.rated_operating_current,
    component_switchgear.breaking_current,
    component_switchgear.making_capacity,
    component_switchgear.current_capacity,
    component_switchgear.insulation,
    component.weight_air,
    component.weight_water,
    component.height,
    component.width,
    component.depth,
    component_switchgear.cooling,
    component_switchgear.maximum_water_depth,
    component_switchgear.operating_environment,
    component_switchgear.number_operations,
    component_switchgear.outer_coating,
    component.colour,
    component.operational_temp_min,
    component.operational_temp_max,
    component_switchgear.operational_temperature,
    component.comments AS source,
    component.cost,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM ((beta.component
     JOIN beta.component_switchgear ON ((component.id = component_switchgear.id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 380 (class 1259 OID 52727)
-- Name: view_component_transformer; Type: VIEW; Schema: beta; Owner: -
--

CREATE VIEW beta.view_component_transformer AS
 SELECT component_transformer.id,
    component_transformer.fk_component_id,
    component_supplier.supplier_name,
    component.supplier_id,
    component.code,
    component_transformer.serial_product,
    component_transformer.windings,
    component_transformer.winding_material,
    component_transformer.insulation,
    component_transformer.insulation_level,
    component_transformer.insulation_temperature_class,
    component_transformer.power_rating,
    component_transformer.power_primary_winding,
    component_transformer.power_secondary_winding,
    component_transformer.power_tertiary_winding,
    component_transformer.voltage_primary_winding,
    component_transformer.voltage_secondary_winding,
    component_transformer.voltage_tertiary_winding,
    component_transformer.no_load_current,
    component_transformer.no_load_losses,
    component_transformer.losses_1_and_2,
    component_transformer.losses_1_and_3,
    component_transformer.losses_2_and_3,
    component_transformer.tap_changer_primary,
    component_transformer.tap_changer_primary_type,
    component_transformer.tap_changer_primary_cycles,
    component_transformer.tap_changer_primary_taps,
    component_transformer.tap_changer_primary_voltage_step,
    component_transformer.tap_changer_primary_winding_number_of_taps_with_rated_voltage,
    component_transformer.tap_changer_secondary_winding,
    component_transformer.tap_changer_secondary_winding_switching_type,
    component_transformer.tap_changer_secondary_winding_guaranteed_number_of_switching_cy,
    component_transformer.tap_changer_secondary_winding_number_of_taps,
    component_transformer.tap_changer_secondary_winding_voltage_step,
    component_transformer.tap_changer_secondary_winding_number_of_taps_with_rated_voltage,
    component_transformer.vector,
    component.weight_air,
    component.weight_water,
    component_transformer.height_without_cooling_system,
    component_transformer.width_without_cooling_system,
    component_transformer.depth_without_cooling_system,
    component_transformer.height_with_cooling_system_and_ancillary_devices,
    component_transformer.maximum_water_depth,
    component_transformer.outer_coating,
    component.colour,
    component.operational_temp_min,
    component.operational_temp_max,
    component_transformer.operational_temperature,
    component_transformer.impedance,
    component.cost,
    component_transformer.cooling,
    component.environmental_impact,
    component.ncfr_lower_bound,
    component.ncfr_mean,
    component.ncfr_upper_bound,
    component.cfr_lower_bound,
    component.cfr_mean,
    component.cfr_upper_bound
   FROM ((beta.component
     JOIN beta.component_transformer ON ((component.id = component_transformer.id)))
     JOIN beta.component_supplier ON ((component.supplier_id = component_supplier.id)));


--
-- TOC entry 4736 (class 2604 OID 52732)
-- Name: bathymetry_geotechnic id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.bathymetry_geotechnic ALTER COLUMN id SET DEFAULT nextval('beta.bathymetry_geotechnic_id_seq'::regclass);


--
-- TOC entry 4738 (class 2604 OID 52733)
-- Name: cable_corridor_bathymetry id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_bathymetry ALTER COLUMN id SET DEFAULT nextval('beta.cable_corridor_bathymetry_id_seq'::regclass);


--
-- TOC entry 4739 (class 2604 OID 52734)
-- Name: cable_corridor_bathymetry_geotechnic id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_bathymetry_geotechnic ALTER COLUMN id SET DEFAULT nextval('beta.cable_corridor_bathymetry_geotechnic_id_seq'::regclass);


--
-- TOC entry 4740 (class 2604 OID 52735)
-- Name: cable_corridor_constraint id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_constraint ALTER COLUMN id SET DEFAULT nextval('beta.cable_corridor_constraint_id_seq'::regclass);


--
-- TOC entry 4741 (class 2604 OID 52736)
-- Name: component id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component ALTER COLUMN id SET DEFAULT nextval('beta.component_id_seq'::regclass);


--
-- TOC entry 4742 (class 2604 OID 52737)
-- Name: component_collection_point id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_collection_point ALTER COLUMN id SET DEFAULT nextval('beta.component_collection_point_id_seq'::regclass);


--
-- TOC entry 4743 (class 2604 OID 52738)
-- Name: component_collection_point fk_component_id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_collection_point ALTER COLUMN fk_component_id SET DEFAULT nextval('beta.component_collection_point_fk_component_id_seq'::regclass);


--
-- TOC entry 4745 (class 2604 OID 52739)
-- Name: component_functional_area id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_functional_area ALTER COLUMN id SET DEFAULT nextval('beta.ref_component_functional_area_id_seq'::regclass);


--
-- TOC entry 4747 (class 2604 OID 52740)
-- Name: component_power_quality id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_power_quality ALTER COLUMN id SET DEFAULT nextval('beta.component_power_quality_id_seq'::regclass);


--
-- TOC entry 4748 (class 2604 OID 52741)
-- Name: component_power_quality fk_component_id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_power_quality ALTER COLUMN fk_component_id SET DEFAULT nextval('beta.component_power_quality_fk_component_id_seq'::regclass);


--
-- TOC entry 4749 (class 2604 OID 52742)
-- Name: component_substation id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_substation ALTER COLUMN id SET DEFAULT nextval('beta.substation_id_seq'::regclass);


--
-- TOC entry 4750 (class 2604 OID 52743)
-- Name: component_supplier id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_supplier ALTER COLUMN id SET DEFAULT nextval('beta.component_supplier_id_seq'::regclass);


--
-- TOC entry 4751 (class 2604 OID 52744)
-- Name: component_switchgear fk_component_id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_switchgear ALTER COLUMN fk_component_id SET DEFAULT nextval('beta.component_switchgear_fk_component_id_seq'::regclass);


--
-- TOC entry 4752 (class 2604 OID 52745)
-- Name: component_switchgear id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_switchgear ALTER COLUMN id SET DEFAULT nextval('beta.component_switchgear_id_seq'::regclass);


--
-- TOC entry 4754 (class 2604 OID 52746)
-- Name: component_type id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_type ALTER COLUMN id SET DEFAULT nextval('beta.component_type_id_seq'::regclass);


--
-- TOC entry 4755 (class 2604 OID 52747)
-- Name: constraint id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta."constraint" ALTER COLUMN id SET DEFAULT nextval('beta.constraint_id_seq'::regclass);


--
-- TOC entry 4735 (class 2604 OID 52748)
-- Name: constraint_activity_frequency id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.constraint_activity_frequency ALTER COLUMN id SET DEFAULT nextval('beta.activity_frequency_id_seq'::regclass);


--
-- TOC entry 4757 (class 2604 OID 52749)
-- Name: device id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.device ALTER COLUMN id SET DEFAULT nextval('beta.device_id_seq1'::regclass);


--
-- TOC entry 4744 (class 2604 OID 52750)
-- Name: om_failure_mode id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_failure_mode ALTER COLUMN id SET DEFAULT nextval('beta.component_failure_mode_id_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 52751)
-- Name: om_failure_mode_equipment id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_failure_mode_equipment ALTER COLUMN id SET DEFAULT nextval('beta.om_component_failure_mode_equipment_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 52752)
-- Name: om_operation_crew_role id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_operation_crew_role ALTER COLUMN id SET DEFAULT nextval('beta.om_operation_crew_role_id_seq'::regclass);


--
-- TOC entry 4763 (class 2604 OID 52753)
-- Name: project_bathymetry_geotechnic id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_bathymetry_geotechnic ALTER COLUMN id SET DEFAULT nextval('beta.project_bathymetry_geotechnic_id_seq'::regclass);


--
-- TOC entry 4764 (class 2604 OID 52754)
-- Name: project_cable_corridor_bathymetry_geotechnic id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_cable_corridor_bathymetry_geotechnic ALTER COLUMN id SET DEFAULT nextval('beta.project_cable_corridor_bathymetry_geotechnic_id_seq'::regclass);


--
-- TOC entry 4765 (class 2604 OID 52755)
-- Name: project_cable_corridor_constraint id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_cable_corridor_constraint ALTER COLUMN id SET DEFAULT nextval('beta.project_cable_corridor_constraint_id_seq'::regclass);


--
-- TOC entry 4766 (class 2604 OID 52756)
-- Name: project_cable_corridor_constraint_activity_frequency id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_cable_corridor_constraint_activity_frequency ALTER COLUMN id SET DEFAULT nextval('beta.project_cable_corridor_constraint_activity_frequency_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 52757)
-- Name: project_constraint id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_constraint ALTER COLUMN id SET DEFAULT nextval('beta.project_constraint_id_seq'::regclass);


--
-- TOC entry 4768 (class 2604 OID 52758)
-- Name: project_constraint_activity_frequency id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_constraint_activity_frequency ALTER COLUMN id SET DEFAULT nextval('beta.project_constraint_activity_frequency_id_seq'::regclass);


--
-- TOC entry 4769 (class 2604 OID 52759)
-- Name: project_farm fk_site_id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_farm ALTER COLUMN fk_site_id SET DEFAULT nextval('beta.project_farm_fk_site_id_seq'::regclass);


--
-- TOC entry 4770 (class 2604 OID 52760)
-- Name: project_time_series_energy_wave id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_time_series_energy_wave ALTER COLUMN id SET DEFAULT nextval('beta.time_series_energy_wave_project_id_seq'::regclass);


--
-- TOC entry 4771 (class 2604 OID 52761)
-- Name: ref_general_parameter id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.ref_general_parameter ALTER COLUMN id SET DEFAULT nextval('beta.ref_general_parameter_id_seq'::regclass);


--
-- TOC entry 4773 (class 2604 OID 52762)
-- Name: time_series_energy_tidal id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.time_series_energy_tidal ALTER COLUMN id SET DEFAULT nextval('beta.time_series_energy_tidal_id_seq1'::regclass);


--
-- TOC entry 4774 (class 2604 OID 52763)
-- Name: time_series_energy_wave id; Type: DEFAULT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.time_series_energy_wave ALTER COLUMN id SET DEFAULT nextval('beta.time_series_energy_wave_id_seq1'::regclass);


--
-- TOC entry 4776 (class 2606 OID 52767)
-- Name: constraint_activity_frequency activity_frequency_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.constraint_activity_frequency
    ADD CONSTRAINT activity_frequency_pkey PRIMARY KEY (id);


--
-- TOC entry 4778 (class 2606 OID 52769)
-- Name: bathymetry bathymetry_bathymetry_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.bathymetry
    ADD CONSTRAINT bathymetry_bathymetry_pkey PRIMARY KEY (id);


--
-- TOC entry 4780 (class 2606 OID 52771)
-- Name: bathymetry_geotechnic bathymetry_geotechnic_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.bathymetry_geotechnic
    ADD CONSTRAINT bathymetry_geotechnic_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 52773)
-- Name: bathymetry_layer bathymetry_layer_bathymetry_layer_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.bathymetry_layer
    ADD CONSTRAINT bathymetry_layer_bathymetry_layer_pkey PRIMARY KEY (id);


--
-- TOC entry 4788 (class 2606 OID 52775)
-- Name: cable_corridor_bathymetry_geotechnic cable_corridor_bathymetry_geotechnic_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_bathymetry_geotechnic
    ADD CONSTRAINT cable_corridor_bathymetry_geotechnic_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 52777)
-- Name: cable_corridor_bathymetry_layer cable_corridor_bathymetry_layer_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_bathymetry_layer
    ADD CONSTRAINT cable_corridor_bathymetry_layer_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 52779)
-- Name: cable_corridor_bathymetry cable_corridor_bathymetry_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_bathymetry
    ADD CONSTRAINT cable_corridor_bathymetry_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 52781)
-- Name: cable_corridor_constraint cable_corridor_constraint_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_constraint
    ADD CONSTRAINT cable_corridor_constraint_pkey PRIMARY KEY (id);


--
-- TOC entry 4784 (class 2606 OID 52783)
-- Name: cable_corridor cable_corridor_site_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor
    ADD CONSTRAINT cable_corridor_site_pkey PRIMARY KEY (id);


--
-- TOC entry 4834 (class 2606 OID 52785)
-- Name: equipment_soil_lay_rates cd; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.equipment_soil_lay_rates
    ADD CONSTRAINT cd PRIMARY KEY (id);


--
-- TOC entry 4796 (class 2606 OID 52787)
-- Name: component component_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component
    ADD CONSTRAINT component_pkey PRIMARY KEY (id);


--
-- TOC entry 4812 (class 2606 OID 52789)
-- Name: component_supplier component_supplier_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_supplier
    ADD CONSTRAINT component_supplier_pkey PRIMARY KEY (id);


--
-- TOC entry 4814 (class 2606 OID 52791)
-- Name: component_supplier component_supplier_supplier_name_key; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_supplier
    ADD CONSTRAINT component_supplier_supplier_name_key UNIQUE (supplier_name);


--
-- TOC entry 4820 (class 2606 OID 52793)
-- Name: component_transformer_old component_transformer_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_transformer_old
    ADD CONSTRAINT component_transformer_pkey PRIMARY KEY (id);


--
-- TOC entry 4822 (class 2606 OID 52795)
-- Name: component_type component_type_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_type
    ADD CONSTRAINT component_type_pkey PRIMARY KEY (id);


--
-- TOC entry 4826 (class 2606 OID 52797)
-- Name: constraint constraint_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta."constraint"
    ADD CONSTRAINT constraint_pkey PRIMARY KEY (id);


--
-- TOC entry 4828 (class 2606 OID 52799)
-- Name: constraint_type constraint_type_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.constraint_type
    ADD CONSTRAINT constraint_type_pkey PRIMARY KEY (id);


--
-- TOC entry 4830 (class 2606 OID 52801)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- TOC entry 4832 (class 2606 OID 52803)
-- Name: device_power_performance_tidal device_power_performance_tidal_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.device_power_performance_tidal
    ADD CONSTRAINT device_power_performance_tidal_pkey PRIMARY KEY (velocity);


--
-- TOC entry 4836 (class 2606 OID 52805)
-- Name: equipment_soil_penet_rates equipment_soil_rates_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.equipment_soil_penet_rates
    ADD CONSTRAINT equipment_soil_rates_pkey PRIMARY KEY (id);


--
-- TOC entry 4800 (class 2606 OID 52807)
-- Name: component_collection_point ght; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_collection_point
    ADD CONSTRAINT ght PRIMARY KEY (id);


--
-- TOC entry 4861 (class 2606 OID 52809)
-- Name: site idpk; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.site
    ADD CONSTRAINT idpk PRIMARY KEY (id);


--
-- TOC entry 4824 (class 2606 OID 52811)
-- Name: constants ip; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.constants
    ADD CONSTRAINT ip PRIMARY KEY (id);


--
-- TOC entry 4840 (class 2606 OID 52813)
-- Name: om_failure_mode_equipment om_component_failure_mode_equipment_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_failure_mode_equipment
    ADD CONSTRAINT om_component_failure_mode_equipment_pkey PRIMARY KEY (id);


--
-- TOC entry 4804 (class 2606 OID 52815)
-- Name: om_failure_mode om_failure_mode_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_failure_mode
    ADD CONSTRAINT om_failure_mode_pkey PRIMARY KEY (id);


--
-- TOC entry 4842 (class 2606 OID 52817)
-- Name: om_failure_mode_vessel om_failure_mode_vessel_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_failure_mode_vessel
    ADD CONSTRAINT om_failure_mode_vessel_pkey PRIMARY KEY (id);


--
-- TOC entry 4851 (class 2606 OID 52819)
-- Name: om_repair_action om_logisitics_operation_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_repair_action
    ADD CONSTRAINT om_logisitics_operation_pkey PRIMARY KEY (id);


--
-- TOC entry 4845 (class 2606 OID 52821)
-- Name: om_operation_crew_role om_operation_crew_role_id_key; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_operation_crew_role
    ADD CONSTRAINT om_operation_crew_role_id_key UNIQUE (id);


--
-- TOC entry 4848 (class 2606 OID 52823)
-- Name: om_operation_crew_role om_operation_crew_role_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.om_operation_crew_role
    ADD CONSTRAINT om_operation_crew_role_pkey PRIMARY KEY (logistics_operation_id, crew_role_id);


--
-- TOC entry 4853 (class 2606 OID 52825)
-- Name: operation_limiting_condition operation_limiting_condition_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.operation_limiting_condition
    ADD CONSTRAINT operation_limiting_condition_pkey PRIMARY KEY (operation_type);


--
-- TOC entry 4794 (class 2606 OID 52827)
-- Name: cable_corridor_constraint_activity_frequency pkc; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.cable_corridor_constraint_activity_frequency
    ADD CONSTRAINT pkc PRIMARY KEY (id);


--
-- TOC entry 4855 (class 2606 OID 52829)
-- Name: project_cable_corridor pkf; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_cable_corridor
    ADD CONSTRAINT pkf PRIMARY KEY (id);


--
-- TOC entry 4816 (class 2606 OID 52831)
-- Name: component_switchgear pky; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_switchgear
    ADD CONSTRAINT pky PRIMARY KEY (fk_component_id);


--
-- TOC entry 4818 (class 2606 OID 52833)
-- Name: component_transformer pkyy; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_transformer
    ADD CONSTRAINT pkyy PRIMARY KEY (fk_component_id);


--
-- TOC entry 4806 (class 2606 OID 52835)
-- Name: component_functional_area ref_component_functional_area_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_functional_area
    ADD CONSTRAINT ref_component_functional_area_pkey PRIMARY KEY (id);


--
-- TOC entry 4859 (class 2606 OID 52837)
-- Name: ref_general_parameter sa; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.ref_general_parameter
    ADD CONSTRAINT sa PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 52839)
-- Name: component_substation substation_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_substation
    ADD CONSTRAINT substation_pkey PRIMARY KEY (id);


--
-- TOC entry 4808 (class 2606 OID 52841)
-- Name: component_power_quality tf; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_power_quality
    ADD CONSTRAINT tf PRIMARY KEY (id);


--
-- TOC entry 4857 (class 2606 OID 52843)
-- Name: project_time_series_energy_wave time_series_energy_wave_project_pkey; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.project_time_series_energy_wave
    ADD CONSTRAINT time_series_energy_wave_project_pkey PRIMARY KEY (id);


--
-- TOC entry 4798 (class 2606 OID 52845)
-- Name: component_cable tr; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_cable
    ADD CONSTRAINT tr PRIMARY KEY (fk_component_id);


--
-- TOC entry 4863 (class 2606 OID 52847)
-- Name: soil_type_geotechnical_properties ygf; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.soil_type_geotechnical_properties
    ADD CONSTRAINT ygf PRIMARY KEY (id);


--
-- TOC entry 4802 (class 2606 OID 52849)
-- Name: component_connector yt; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.component_connector
    ADD CONSTRAINT yt PRIMARY KEY (fk_component_id);


--
-- TOC entry 4838 (class 2606 OID 52851)
-- Name: farm yy; Type: CONSTRAINT; Schema: beta; Owner: -
--

ALTER TABLE ONLY beta.farm
    ADD CONSTRAINT yy PRIMARY KEY (id);


--
-- TOC entry 4849 (class 1259 OID 52852)
-- Name: om_logisitics_operation_fk_failure_mode_id_key; Type: INDEX; Schema: beta; Owner: -
--

CREATE UNIQUE INDEX om_logisitics_operation_fk_failure_mode_id_key ON beta.om_repair_action USING btree (fk_failure_mode_id);


--
-- TOC entry 4843 (class 1259 OID 52853)
-- Name: om_operation_crew_role_crew_role_id_key; Type: INDEX; Schema: beta; Owner: -
--

CREATE UNIQUE INDEX om_operation_crew_role_crew_role_id_key ON beta.om_operation_crew_role USING btree (crew_role_id);


--
-- TOC entry 4846 (class 1259 OID 52854)
-- Name: om_operation_crew_role_logistics_operation_id_key; Type: INDEX; Schema: beta; Owner: -
--

CREATE UNIQUE INDEX om_operation_crew_role_logistics_operation_id_key ON beta.om_operation_crew_role USING btree (logistics_operation_id);


-- Completed on 2019-03-12 11:11:18

--
-- PostgreSQL database dump complete
--

