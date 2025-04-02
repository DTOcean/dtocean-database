--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Debian 17.4-1.pgdg110+2)
-- Dumped by pg_dump version 17.4

-- Started on 2025-03-18 12:25:56 UTC

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

--
-- TOC entry 8 (class 2615 OID 20809)
-- Name: filter; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA filter;


--
-- TOC entry 9 (class 2615 OID 20810)
-- Name: project; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA project;


--
-- TOC entry 10 (class 2615 OID 20811)
-- Name: reference; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA reference;


--
-- TOC entry 1234 (class 1255 OID 20812)
-- Name: sp_build_tables(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_tables() RETURNS void
    LANGUAGE plpgsql
    AS $$

DECLARE
   arr varchar[] := array['bathymetry',
              'bathymetry_layer',
              'cable_corridor_bathymetry',
              'cable_corridor_bathymetry_layer',
              'cable_corridor_constraint',
              'constraint',
              'device_shared',
              'device_floating',
              'device_tidal',
              'device_tidal_power_performance',
              'device_wave',
              'lease_area',
              'sub_systems_access',
              'sub_systems_economic',
              'sub_systems_install',
              'sub_systems_inspection',
              'sub_systems_maintenance',
              'sub_systems_operation_weightings',
              'sub_systems_replace',
              'time_series_energy_tidal',
              'time_series_energy_wave',
              'time_series_om_tidal',
              'time_series_om_wave',
              'time_series_om_wind'
              ];
   y TEXT;
   x TEXT;
   r RECORD;
BEGIN
   FOREACH x IN ARRAY arr
   LOOP
      y := 'DROP TABLE filter.' || x;
      RAISE NOTICE '%', y;
      BEGIN
        EXECUTE y;
      EXCEPTION
        WHEN SQLSTATE '42P01' THEN NULL;
      END;
      y := 'CREATE TABLE filter.' || x || ' (LIKE project.' || x || ')';
      RAISE NOTICE '%', y;
      EXECUTE y;
   END LOOP;
END

$$;


--
-- TOC entry 1235 (class 1255 OID 20813)
-- Name: sp_build_view_bathymetry_layer(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_bathymetry_layer() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_bathymetry_layer AS 
 SELECT 
    bathymetry.utm_point,
    bathymetry.depth,
    bathymetry.mannings_no,
    bathymetry_layer.layer_order,
    bathymetry_layer.initial_depth,
    soil_type.description AS sediment_type
   FROM filter.bathymetry
     LEFT JOIN filter.bathymetry_layer
         ON bathymetry.id = bathymetry_layer.fk_bathymetry_id
     LEFT JOIN reference.soil_type
         ON bathymetry_layer.fk_soil_type_id = soil_type.id;
$$;


--
-- TOC entry 1236 (class 1255 OID 20814)
-- Name: sp_build_view_cable_corridor_bathymetry_layer(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_cable_corridor_bathymetry_layer() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_cable_corridor_bathymetry_layer AS 
 SELECT cable_corridor_bathymetry.utm_point,
    cable_corridor_bathymetry.depth,
    cable_corridor_bathymetry_layer.layer_order,
    cable_corridor_bathymetry_layer.initial_depth,
    soil_type.description AS sediment_type
   FROM filter.cable_corridor_bathymetry
     LEFT JOIN filter.cable_corridor_bathymetry_layer
         ON cable_corridor_bathymetry.id = cable_corridor_bathymetry_layer.fk_bathymetry_id
     LEFT JOIN reference.soil_type
         ON cable_corridor_bathymetry_layer.fk_soil_type_id = soil_type.id;
$$;


--
-- TOC entry 1237 (class 1255 OID 20815)
-- Name: sp_build_view_control_system_access(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_access() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_access AS 
  SELECT 
    sub_system,
    operation_duration,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    "filter"."sub_systems_access" INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_access"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1238 (class 1255 OID 20816)
-- Name: sp_build_view_control_system_economic(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_economic() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_economic AS 
  SELECT 
    sub_system,
    cost,
    failure_rate
  FROM
    "filter"."sub_systems_economic" INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_economic"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1239 (class 1255 OID 20817)
-- Name: sp_build_view_control_system_inspection(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_inspection() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_inspection AS 
  SELECT 
    sub_system,
    sub_systems_inspection.operation_duration,
    sub_systems_inspection.crew_lead_time,
    sub_systems_inspection.other_lead_time,
    sub_systems_inspection.n_specialists,
    sub_systems_inspection.n_technicians,
    sub_systems_inspection.max_hs,
    sub_systems_inspection.max_tp,
    sub_systems_inspection.max_ws,
    sub_systems_inspection.max_cs
  FROM
    filter.sub_systems_inspection INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_inspection"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1240 (class 1255 OID 20818)
-- Name: sp_build_view_control_system_installation(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_installation() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_installation AS 
  SELECT 
    sub_system,
    length,
    width,
    height,
    dry_mass,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    filter.sub_systems_install INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_install"."fk_sub_system_id" = "project"."sub_systems"."id")
    WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1241 (class 1255 OID 20819)
-- Name: sp_build_view_control_system_maintenance(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_maintenance() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_maintenance AS 
  SELECT
    sub_system,
    operation_duration,
    interruptible,
    parts_length,
    parts_width,
    parts_height,
    parts_dry_mass,
    assembly_lead_time,
    crew_lead_time,
    other_lead_time,
    n_specialists,
    n_technicians,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    filter.sub_systems_maintenance INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_maintenance"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1242 (class 1255 OID 20820)
-- Name: sp_build_view_control_system_operation_weightings(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_operation_weightings() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_operation_weightings AS 
  SELECT
    sub_system,
    maintenance,
    replacement,
    inspection
  FROM
    filter.sub_systems_operation_weightings INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_operation_weightings"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1243 (class 1255 OID 20821)
-- Name: sp_build_view_control_system_replace(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_control_system_replace() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_control_system_replace AS 
  SELECT
    sub_system,
    operation_duration,
    interruptible,
    assembly_lead_time,
    crew_lead_time,
    other_lead_time,
    n_specialists,
    n_technicians
  FROM
    filter.sub_systems_replace INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_replace"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Control System');
$$;


--
-- TOC entry 1244 (class 1255 OID 20822)
-- Name: sp_build_view_sub_systems_access(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_access() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_access AS 
  SELECT 
    sub_system,
    operation_duration,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    "filter"."sub_systems_access" INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_access"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1245 (class 1255 OID 20823)
-- Name: sp_build_view_sub_systems_economic(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_economic() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_economic AS 
  SELECT 
    sub_system,
    cost,
    failure_rate
  FROM
    "filter"."sub_systems_economic" INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_economic"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1246 (class 1255 OID 20824)
-- Name: sp_build_view_sub_systems_inspection(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_inspection() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_inspection AS 
  SELECT 
    sub_system,
    sub_systems_inspection.operation_duration,
    sub_systems_inspection.crew_lead_time,
    sub_systems_inspection.other_lead_time,
    sub_systems_inspection.n_specialists,
    sub_systems_inspection.n_technicians,
    sub_systems_inspection.max_hs,
    sub_systems_inspection.max_tp,
    sub_systems_inspection.max_ws,
    sub_systems_inspection.max_cs
  FROM
    filter.sub_systems_inspection INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_inspection"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1247 (class 1255 OID 20825)
-- Name: sp_build_view_sub_systems_installation(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_installation() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_installation AS 
  SELECT 
    sub_system,
    length,
    width,
    height,
    dry_mass,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    filter.sub_systems_install INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_install"."fk_sub_system_id" = "project"."sub_systems"."id")
    WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1248 (class 1255 OID 20826)
-- Name: sp_build_view_sub_systems_maintenance(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_maintenance() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_maintenance AS 
  SELECT
    sub_system,
    operation_duration,
    interruptible,
    parts_length,
    parts_width,
    parts_height,
    parts_dry_mass,
    assembly_lead_time,
    crew_lead_time,
    other_lead_time,
    n_specialists,
    n_technicians,
    max_hs,
    max_tp,
    max_ws,
    max_cs
  FROM
    filter.sub_systems_maintenance INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_maintenance"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1249 (class 1255 OID 20827)
-- Name: sp_build_view_sub_systems_operation_weightings(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_operation_weightings() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_operation_weightings AS 
  SELECT
    sub_system,
    maintenance,
    replacement,
    inspection
  FROM
    filter.sub_systems_operation_weightings INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_operation_weightings"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1250 (class 1255 OID 20828)
-- Name: sp_build_view_sub_systems_replace(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_sub_systems_replace() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_sub_systems_replace AS 
  SELECT
    sub_system,
    operation_duration,
    interruptible,
    assembly_lead_time,
    crew_lead_time,
    other_lead_time,
    n_specialists,
    n_technicians
  FROM
    filter.sub_systems_replace INNER JOIN "project"."sub_systems"
    ON ("filter"."sub_systems_replace"."fk_sub_system_id" = "project"."sub_systems"."id")
  WHERE sub_system in ('Prime Mover', 'PTO', 'Support Structure');
$$;


--
-- TOC entry 1251 (class 1255 OID 20829)
-- Name: sp_build_view_time_series_energy_tidal(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_view_time_series_energy_tidal() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW filter.view_time_series_energy_tidal AS 
 SELECT bathymetry.utm_point,
    time_series_energy_tidal.measure_date,
    time_series_energy_tidal.measure_time,
    time_series_energy_tidal.u,
    time_series_energy_tidal.v,
    time_series_energy_tidal.turbulence_intensity,
    time_series_energy_tidal.ssh
   FROM filter.bathymetry
     JOIN filter.time_series_energy_tidal ON bathymetry.id = time_series_energy_tidal.fk_bathymetry_id;
$$;


--
-- TOC entry 1252 (class 1255 OID 20830)
-- Name: sp_build_views(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_build_views() RETURNS void
    LANGUAGE sql
    AS $$
SELECT filter.sp_build_view_bathymetry_layer();
SELECT filter.sp_build_view_cable_corridor_bathymetry_layer();
SELECT filter.sp_build_view_time_series_energy_tidal();
SELECT filter.sp_build_view_sub_systems_installation();
SELECT filter.sp_build_view_sub_systems_access();
SELECT filter.sp_build_view_sub_systems_inspection();
SELECT filter.sp_build_view_sub_systems_maintenance();
SELECT filter.sp_build_view_sub_systems_replace();
SELECT filter.sp_build_view_sub_systems_economic();
SELECT filter.sp_build_view_sub_systems_operation_weightings();
SELECT filter.sp_build_view_control_system_installation();
SELECT filter.sp_build_view_control_system_access();
SELECT filter.sp_build_view_control_system_economic();
SELECT filter.sp_build_view_control_system_inspection();
SELECT filter.sp_build_view_control_system_maintenance();
SELECT filter.sp_build_view_control_system_operation_weightings();
SELECT filter.sp_build_view_control_system_replace();
$$;


--
-- TOC entry 1253 (class 1255 OID 20831)
-- Name: sp_drop_views(); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_drop_views() RETURNS void
    LANGUAGE sql
    AS $$
DROP VIEW filter.view_bathymetry_layer;
DROP VIEW filter.view_cable_corridor_bathymetry_layer;
DROP VIEW filter.view_time_series_energy_tidal;
DROP VIEW filter.view_sub_systems_installation;
DROP VIEW filter.view_control_system_installation;
DROP VIEW filter.view_sub_systems_access;
DROP VIEW filter.view_sub_systems_inspection;
DROP VIEW filter.view_sub_systems_maintenance;
DROP VIEW filter.view_sub_systems_replace;
DROP VIEW filter.view_sub_systems_economic;
DROP VIEW filter.view_sub_systems_operation_weightings;
DROP VIEW filter.view_control_system_access;
DROP VIEW filter.view_control_system_economic;
DROP VIEW filter.view_control_system_inspection;
DROP VIEW filter.view_control_system_maintenance;
DROP VIEW filter.view_control_system_operation_weightings;
DROP VIEW filter.view_control_system_replace;
$$;


--
-- TOC entry 1254 (class 1255 OID 20832)
-- Name: sp_filter_cable_corridor_constraint(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_cable_corridor_constraint(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."cable_corridor_constraint" 
  SELECT * FROM "project"."cable_corridor_constraint"
  WHERE "project"."cable_corridor_constraint".fk_site_id = "site_id"; 
END;
$$;


--
-- TOC entry 1255 (class 1255 OID 20833)
-- Name: sp_filter_cable_corridor_site_bathymetry(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_cable_corridor_site_bathymetry(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."cable_corridor_bathymetry" 
  SELECT * FROM "project"."cable_corridor_bathymetry"
  WHERE "project"."cable_corridor_bathymetry".fk_site_id = "site_id";  
END;
$$;


--
-- TOC entry 1256 (class 1255 OID 20834)
-- Name: sp_filter_cable_corridor_site_bathymetry_layer(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_cable_corridor_site_bathymetry_layer(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."cable_corridor_bathymetry_layer" 
  SELECT "cable_corridor_bathymetry_layer".*
  FROM
     "project"."cable_corridor_bathymetry"
     INNER JOIN "project"."cable_corridor_bathymetry_layer"
     ON ("project"."cable_corridor_bathymetry_layer"."fk_bathymetry_id" = "project"."cable_corridor_bathymetry"."id")
     WHERE 
       "project"."cable_corridor_bathymetry"."fk_site_id" = site_id;
 END;
$$;


--
-- TOC entry 1257 (class 1255 OID 20835)
-- Name: sp_filter_constraint(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_constraint(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."constraint" 
  SELECT * FROM "project"."constraint"
  WHERE "project"."constraint".fk_site_id = "site_id"; 
END;
$$;


--
-- TOC entry 1258 (class 1255 OID 20836)
-- Name: sp_filter_device_data(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_data(device_id integer) RETURNS void
    LANGUAGE sql
    AS $$
TRUNCATE filter.device_shared;
SELECT * FROM filter.sp_filter_device_shared(device_id);

TRUNCATE filter.device_floating;
SELECT * FROM filter.sp_filter_device_floating(device_id);

TRUNCATE filter.device_tidal;
SELECT * FROM filter.sp_filter_device_tidal(device_id);

TRUNCATE filter.device_tidal_power_performance;
SELECT * FROM filter.sp_filter_device_tidal_power_performance(device_id);

TRUNCATE filter.device_wave;
SELECT * FROM filter.sp_filter_device_wave(device_id);

TRUNCATE filter.sub_systems_install;
SELECT * FROM filter.sp_filter_sub_systems_install(device_id);

TRUNCATE filter.sub_systems_access;
SELECT * FROM filter.sp_filter_sub_systems_access(device_id);

TRUNCATE filter.sub_systems_economic;
SELECT * FROM filter.sp_filter_sub_systems_economic(device_id);

TRUNCATE filter.sub_systems_inspection;
SELECT * FROM filter.sp_filter_sub_systems_inspection(device_id);

TRUNCATE filter.sub_systems_maintenance;
SELECT * FROM filter.sp_filter_sub_systems_maintenance(device_id);

TRUNCATE filter.sub_systems_operation_weightings;
SELECT * FROM filter.sp_filter_sub_systems_operation_weightings(device_id);

TRUNCATE filter.sub_systems_replace;
SELECT * FROM filter.sp_filter_sub_systems_replace(device_id);
$$;


--
-- TOC entry 1259 (class 1255 OID 20837)
-- Name: sp_filter_device_floating(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_floating(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."device_floating" 
  SELECT * FROM "project"."device_floating"
  WHERE "project"."device_floating".fk_device_id = "device_id"; 
END;
$$;


--
-- TOC entry 1260 (class 1255 OID 20838)
-- Name: sp_filter_device_shared(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_shared(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."device_shared" 
  SELECT * FROM "project"."device_shared"
  WHERE "project"."device_shared".fk_device_id = "device_id"; 
END;
$$;


--
-- TOC entry 1261 (class 1255 OID 20839)
-- Name: sp_filter_device_tidal(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_tidal(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."device_tidal" 
  SELECT * FROM "project"."device_tidal"
  WHERE "project"."device_tidal".fk_device_id = "device_id"; 
END;
$$;


--
-- TOC entry 1262 (class 1255 OID 20840)
-- Name: sp_filter_device_tidal_power_performance(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_tidal_power_performance(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."device_tidal_power_performance" 
  SELECT * FROM "project"."device_tidal_power_performance"
  WHERE "project"."device_tidal_power_performance".fk_device_id = "device_id"; 
END;
$$;


--
-- TOC entry 1263 (class 1255 OID 20841)
-- Name: sp_filter_device_wave(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_device_wave(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."device_wave" 
  SELECT * FROM "project"."device_wave"
  WHERE "project"."device_wave".fk_device_id = "device_id"; 
END;
$$;


--
-- TOC entry 1264 (class 1255 OID 20842)
-- Name: sp_filter_lease_area(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_lease_area(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."lease_area" 
  SELECT * FROM "project"."lease_area"
  WHERE "project"."lease_area".fk_site_id = "site_id"; 
END;
$$;


--
-- TOC entry 1265 (class 1255 OID 20843)
-- Name: sp_filter_site_bathymetry(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_bathymetry(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."bathymetry" 
  SELECT * FROM "project"."bathymetry"
  WHERE "project"."bathymetry".fk_site_id = "site_id"; 
END;
$$;


--
-- TOC entry 1266 (class 1255 OID 20844)
-- Name: sp_filter_site_bathymetry_layer(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_bathymetry_layer(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."bathymetry_layer" 
  SELECT "bathymetry_layer".*
  FROM
     "project"."bathymetry"
     INNER JOIN "project"."bathymetry_layer"
     ON ("project"."bathymetry_layer"."fk_bathymetry_id" = "project"."bathymetry"."id")
     WHERE 
       "project"."bathymetry"."fk_site_id" = site_id; 
END;
$$;


--
-- TOC entry 1267 (class 1255 OID 20845)
-- Name: sp_filter_site_data(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_data(site_id integer) RETURNS void
    LANGUAGE sql
    AS $$
TRUNCATE filter.lease_area;
SELECT * FROM filter.sp_filter_lease_area(site_id);

TRUNCATE filter.constraint;
SELECT * FROM filter.sp_filter_constraint(site_id);

TRUNCATE filter.cable_corridor_constraint;
SELECT * FROM filter.sp_filter_cable_corridor_constraint(site_id);

TRUNCATE filter.bathymetry;
SELECT * FROM filter.sp_filter_site_bathymetry(site_id);

TRUNCATE filter.bathymetry_layer;
SELECT * FROM filter.sp_filter_site_bathymetry_layer(site_id);

TRUNCATE filter.cable_corridor_bathymetry;
SELECT * FROM filter.sp_filter_cable_corridor_site_bathymetry(site_id);

TRUNCATE filter.cable_corridor_bathymetry_layer;
SELECT * FROM filter.sp_filter_cable_corridor_site_bathymetry_layer(site_id);

-- Time Series Data
TRUNCATE filter.time_series_energy_tidal;
SELECT * FROM filter.sp_filter_site_time_series_energy_tidal(site_id);

TRUNCATE filter.time_series_energy_wave;
SELECT * FROM filter.sp_filter_site_time_series_energy_wave(site_id);

TRUNCATE filter.time_series_om_tidal;
SELECT * FROM filter.sp_filter_site_time_series_om_tidal(site_id);

TRUNCATE filter.time_series_om_wave;
SELECT * FROM filter.sp_filter_site_time_series_om_wave(site_id);

TRUNCATE filter.time_series_om_wind;
SELECT * FROM filter.sp_filter_site_time_series_om_wind(site_id);
$$;


--
-- TOC entry 1268 (class 1255 OID 20846)
-- Name: sp_filter_site_time_series_energy_tidal(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_time_series_energy_tidal(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO filter.time_series_energy_tidal 
  SELECT project.time_series_energy_tidal.*
  FROM
     project.bathymetry
     INNER JOIN project.time_series_energy_tidal 
     ON (project.time_series_energy_tidal.fk_bathymetry_id = project.bathymetry.id)
     WHERE 
       project.bathymetry.fk_site_id = site_id; 
  
END;
$$;


--
-- TOC entry 1269 (class 1255 OID 20847)
-- Name: sp_filter_site_time_series_energy_wave(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_time_series_energy_wave(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."time_series_energy_wave" 
  SELECT * FROM "project"."time_series_energy_wave"
  WHERE "project"."time_series_energy_wave"."fk_site_id" = "site_id"; 
END;
$$;


--
-- TOC entry 1270 (class 1255 OID 20848)
-- Name: sp_filter_site_time_series_om_tidal(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_time_series_om_tidal(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."time_series_om_tidal" 
  SELECT * FROM "project"."time_series_om_tidal"
  WHERE "project"."time_series_om_tidal"."fk_site_id" = "site_id"; 
END;
$$;


--
-- TOC entry 1271 (class 1255 OID 20849)
-- Name: sp_filter_site_time_series_om_wave(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_time_series_om_wave(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."time_series_om_wave" 
  SELECT * FROM "project"."time_series_om_wave"
  WHERE "project"."time_series_om_wave"."fk_site_id" = "site_id";
END;
$$;


--
-- TOC entry 1272 (class 1255 OID 20850)
-- Name: sp_filter_site_time_series_om_wind(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_site_time_series_om_wind(site_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."time_series_om_wind" 
  SELECT * FROM "project"."time_series_om_wind"
  WHERE "project"."time_series_om_wind"."fk_site_id" = "site_id"; 
END;
$$;


--
-- TOC entry 1273 (class 1255 OID 20851)
-- Name: sp_filter_sub_systems_access(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_access(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_access" 
  SELECT
     "sub_systems_access".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_access"
     ON ("project"."sub_systems_access"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1274 (class 1255 OID 20852)
-- Name: sp_filter_sub_systems_economic(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_economic(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_economic" 
  SELECT
     "sub_systems_economic".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_economic"
     ON ("project"."sub_systems_economic"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1275 (class 1255 OID 20853)
-- Name: sp_filter_sub_systems_inspection(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_inspection(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_inspection" 
  SELECT
     "sub_systems_inspection".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_inspection"
     ON ("project"."sub_systems_inspection"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1276 (class 1255 OID 20854)
-- Name: sp_filter_sub_systems_install(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_install(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_install" 
  SELECT
     "sub_systems_install".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_install"
     ON ("project"."sub_systems_install"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1277 (class 1255 OID 20855)
-- Name: sp_filter_sub_systems_maintenance(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_maintenance(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_maintenance" 
  SELECT
     "sub_systems_maintenance".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_maintenance"
     ON ("project"."sub_systems_maintenance"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1278 (class 1255 OID 20856)
-- Name: sp_filter_sub_systems_operation_weightings(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_operation_weightings(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_operation_weightings" 
  SELECT
     "sub_systems_operation_weightings".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_operation_weightings"
     ON ("project"."sub_systems_operation_weightings"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1279 (class 1255 OID 20857)
-- Name: sp_filter_sub_systems_replace(integer); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_filter_sub_systems_replace(device_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "filter"."sub_systems_replace" 
  SELECT
     "sub_systems_replace".*
  FROM
     "project"."sub_systems"
     INNER JOIN "project"."sub_systems_replace"
     ON ("project"."sub_systems_replace"."fk_sub_system_id" = "project"."sub_systems"."id")
     WHERE 
       "project"."sub_systems"."fk_device_id" = device_id; 
END;
$$;


--
-- TOC entry 1280 (class 1255 OID 20858)
-- Name: sp_select_bathymetry_by_polygon(text); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_select_bathymetry_by_polygon(polystring text) RETURNS TABLE(utm_point public.geometry, depth double precision, mannings_no double precision, layer_order smallint, initial_depth double precision, sediment_type character varying)
    LANGUAGE sql ROWS 100000
    AS $$
SELECT 
  utm_point,
  depth,
  mannings_no,
  layer_order,
  initial_depth,
  sediment_type
FROM filter.view_bathymetry_layer
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', 0), filter.view_bathymetry_layer.utm_point));
$$;


--
-- TOC entry 1281 (class 1255 OID 20859)
-- Name: sp_select_cable_corridor_bathymetry_by_polygon(text); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_select_cable_corridor_bathymetry_by_polygon(polystring text) RETURNS TABLE(utm_point public.geometry, depth double precision, layer_order smallint, initial_depth double precision, sediment_type character varying)
    LANGUAGE sql ROWS 100000
    AS $$
SELECT 
  utm_point,
  depth,
  layer_order,
  initial_depth,
  sediment_type
FROM filter.view_cable_corridor_bathymetry_layer
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', -1), filter.view_cable_corridor_bathymetry_layer.utm_point));
$$;


--
-- TOC entry 1282 (class 1255 OID 20860)
-- Name: sp_select_tidal_energy_time_series_by_polygon(text); Type: FUNCTION; Schema: filter; Owner: -
--

CREATE FUNCTION filter.sp_select_tidal_energy_time_series_by_polygon(polystring text) RETURNS TABLE(utm_point public.geometry, measure_date date, measure_time time without time zone, u double precision, v double precision, turbulence_intensity double precision, ssh double precision)
    LANGUAGE sql ROWS 5
    AS $$
SELECT
  utm_point,
  measure_date,
  measure_time,
  u,
  v,
  turbulence_intensity,
  ssh
FROM filter.view_time_series_energy_tidal
WHERE 
(ST_Covers(ST_GeomFromText('POLYGON(('|| polystring || '))', 0), filter.view_time_series_energy_tidal.utm_point));
$$;

--
-- TOC entry 1285 (class 1255 OID 20861)
-- Name: sp_build_view_component_cable_dynamic(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_cable_dynamic() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_cable_dynamic AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    minimum_breaking_load,
    minimum_bend_radius,
    number_conductors,
    number_fibre_channels,
    resistance_dc_20,
    resistance_ac_90,
    inductive_reactance,
    capacitance,
    rated_current_air,
    rated_current_buried,
    rated_current_jtube,
    rated_voltage_u0,
    operational_temp_max,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_cable
   JOIN reference.component_continuous ON component_cable.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id
   JOIN reference.component_type ON component_cable.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'cable dynamic'::text;
  $$;


--
-- TOC entry 1286 (class 1255 OID 20862)
-- Name: sp_build_view_component_cable_static(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_cable_static() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_cable_static AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    minimum_breaking_load,
    minimum_bend_radius,
    number_conductors,
    number_fibre_channels,
    resistance_dc_20,
    resistance_ac_90,
    inductive_reactance,
    capacitance,
    rated_current_air,
    rated_current_buried,
    rated_current_jtube,
    rated_voltage_u0,
    operational_temp_max,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_cable
   JOIN reference.component_continuous ON component_cable.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id
   JOIN reference.component_type ON component_cable.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'cable static'::text;
$$;


--
-- TOC entry 1287 (class 1255 OID 20863)
-- Name: sp_build_view_component_collection_point(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_collection_point() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_collection_point AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    wet_frontal_area,
    dry_frontal_area,
    wet_beam_area,
    dry_beam_area,
    maximum_water_depth,
    orientation_angle,
    input_lines,
    output_lines,
    input_connector_type,
    output_connector_type,
    number_fibre_channels,
    voltage_primary_winding,
    voltage_secondary_winding,
    rated_operating_current,
    operational_temp_min,
    operational_temp_max,
    foundation_locations,
    centre_of_gravity,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_collection_point
   JOIN reference.component_discrete ON component_collection_point.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id;
$$;


--
-- TOC entry 1288 (class 1255 OID 20864)
-- Name: sp_build_view_component_connector_drymate(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_connector_drymate() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_connector_drymate AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    maximum_water_depth,
    number_contacts,
    number_fibre_channels,
    mating_force,
    demating_force,
    rated_voltage_u0,
    rated_current,
    cable_area_min,
    cable_area_max,
    operational_temp_min,
    operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_connector
   JOIN reference.component_discrete ON component_connector.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id
   JOIN reference.component_type ON component_connector.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'connector dry-mate'::text;
$$;


--
-- TOC entry 1291 (class 1255 OID 20865)
-- Name: sp_build_view_component_connector_wetmate(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_connector_wetmate() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_connector_wetmate AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    maximum_water_depth,
    number_contacts,
    number_fibre_channels,
    mating_force,
    demating_force,
    rated_voltage_u0,
    rated_current,
    cable_area_min,
    cable_area_max,
    operational_temp_min,
    operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_connector
   JOIN reference.component_discrete ON component_connector.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id
   JOIN reference.component_type ON component_connector.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'connector wet-mate'::text;
$$;


--
-- TOC entry 1292 (class 1255 OID 20866)
-- Name: sp_build_view_component_foundations_anchor(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_foundations_anchor() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_foundations_anchor AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    connecting_size,
    minimum_breaking_load,
    axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_anchor
   JOIN reference.component_discrete ON component_anchor.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id;
$$;


--
-- TOC entry 1293 (class 1255 OID 20867)
-- Name: sp_build_view_component_foundations_anchor_coefs(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_foundations_anchor_coefs() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_foundations_anchor_coefs AS 
 SELECT component.id AS component_id,
    soft_holding_cap_coef_1,
    soft_holding_cap_coef_2,
    soft_penetration_coef_1,
    soft_penetration_coef_2,
    sand_holding_cap_coef_1,
    sand_holding_cap_coef_2,
    sand_penetration_coef_1,
    sand_penetration_coef_2
   FROM reference.component_anchor
   JOIN reference.component_discrete ON component_anchor.fk_component_discrete_id = component_discrete.id
   JOIN reference.component ON component_discrete.fk_component_id = component.id;
$$;


--
-- TOC entry 1294 (class 1255 OID 20868)
-- Name: sp_build_view_component_foundations_pile(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_foundations_pile() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_foundations_pile AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    wall_thickness,
    yield_stress,
    youngs_modulus,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_pile
   JOIN reference.component_continuous ON component_pile.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id;
$$;


--
-- TOC entry 1295 (class 1255 OID 20869)
-- Name: sp_build_view_component_moorings_chain(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_moorings_chain() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_moorings_chain AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    connecting_length,
    minimum_breaking_load,
    axial_stiffness,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_mooring_continuous
   JOIN reference.component_continuous ON component_mooring_continuous.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id
   JOIN reference.component_type ON component_mooring_continuous.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'chain'::text;
$$;


--
-- TOC entry 1297 (class 1255 OID 20870)
-- Name: sp_build_view_component_moorings_forerunner(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_moorings_forerunner() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_moorings_forerunner AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    connecting_length,
    minimum_breaking_load,
    axial_stiffness,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_mooring_continuous
   JOIN reference.component_continuous ON component_mooring_continuous.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id
   JOIN reference.component_type ON component_mooring_continuous.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'forerunner'::text;
$$;


--
-- TOC entry 1298 (class 1255 OID 20871)
-- Name: sp_build_view_component_moorings_rope(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_moorings_rope() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_moorings_rope AS 
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    material,
    minimum_breaking_load,
    rope_stiffness_curve,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_rope
   JOIN reference.component_continuous ON component_rope.fk_component_continuous_id = component_continuous.id
   JOIN reference.component_shared ON component_continuous.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_continuous.fk_component_id = component.id;
$$;


--
-- TOC entry 1299 (class 1255 OID 20872)
-- Name: sp_build_view_component_moorings_shackle(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_moorings_shackle() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_moorings_shackle AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    nominal_diameter,
    connecting_length,
    minimum_breaking_load,
    axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_mooring_discrete
   JOIN reference.component_discrete ON component_mooring_discrete.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id
   JOIN reference.component_type ON component_mooring_discrete.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'shackle'::text;
$$;


--
-- TOC entry 1300 (class 1255 OID 20873)
-- Name: sp_build_view_component_moorings_swivel(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_moorings_swivel() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_moorings_swivel AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    nominal_diameter,
    connecting_length,
    minimum_breaking_load,
    axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_mooring_discrete
   JOIN reference.component_discrete ON component_mooring_discrete.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id
   JOIN reference.component_type ON component_mooring_discrete.fk_component_type_id = component_type.id
   WHERE component_type.description::text = 'swivel'::text;
$$;


--
-- TOC entry 1301 (class 1255 OID 20874)
-- Name: sp_build_view_component_transformer(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_component_transformer() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_component_transformer AS 
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    maximum_water_depth,
    power_rating,
    impedance,
    windings,
    voltage_primary_winding,
    voltage_secondary_winding,
    voltage_tertiary_winding,
    operational_temp_min,
    operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM reference.component_transformer
   JOIN reference.component_discrete ON component_transformer.fk_component_discrete_id = component_discrete.id
   JOIN reference.component_shared ON component_discrete.fk_component_id = component_shared.fk_component_id
   JOIN reference.component ON component_discrete.fk_component_id = component.id;
$$;


--
-- TOC entry 1302 (class 1255 OID 20875)
-- Name: sp_build_view_operations_limit_cs(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_operations_limit_cs() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_operations_limit_cs AS 
  SELECT
    operations_type.description AS operations_type,
    cs_limit
  FROM reference.operations_limit_cs
  JOIN reference.operations_type ON operations_limit_cs.fk_operations_id = operations_type.id;
$$;


--
-- TOC entry 1283 (class 1255 OID 20876)
-- Name: sp_build_view_operations_limit_hs(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_operations_limit_hs() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_operations_limit_hs AS 
  SELECT
    operations_type.description AS operations_type,
    hs_limit
  FROM reference.operations_limit_hs
  JOIN reference.operations_type ON operations_limit_hs.fk_operations_id = operations_type.id;
$$;


--
-- TOC entry 1284 (class 1255 OID 20877)
-- Name: sp_build_view_operations_limit_tp(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_operations_limit_tp() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_operations_limit_tp AS 
  SELECT
    operations_type.description AS operations_type,
    tp_limit
  FROM reference.operations_limit_tp
  JOIN reference.operations_type ON operations_limit_tp.fk_operations_id = operations_type.id;
$$;


--
-- TOC entry 1289 (class 1255 OID 20878)
-- Name: sp_build_view_operations_limit_ws(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_operations_limit_ws() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_operations_limit_ws AS 
  SELECT
    operations_type.description AS operations_type,
    ws_limit
  FROM reference.operations_limit_ws
  JOIN reference.operations_type ON operations_limit_ws.fk_operations_id = operations_type.id;
$$;


--
-- TOC entry 1290 (class 1255 OID 20879)
-- Name: sp_build_view_soil_type_geotechnical_properties(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_soil_type_geotechnical_properties() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_soil_type_geotechnical_properties AS 
  SELECT
    soil_type.description AS soil_type,
    drained_soil_friction_angle,
    relative_soil_density,
    buoyant_unit_weight_of_soil,
    undrained_soil_shear_strength_constant_term,
    undrained_soil_shear_strength_depth_dependent_term,
    effective_drained_cohesion,
    seafloor_friction_coefficient,
    soil_sensitivity,
    rock_compressive_strength
  FROM reference.soil_type_geotechnical_properties
  JOIN reference.soil_type ON soil_type_geotechnical_properties.fk_soil_type_id = soil_type.id;
$$;


--
-- TOC entry 1296 (class 1255 OID 20880)
-- Name: sp_build_view_vehicle_helicopter(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_helicopter() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_helicopter AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_helicopter
   JOIN reference.vehicle_shared ON vehicle_helicopter.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id;
$$;


--
-- TOC entry 1303 (class 1255 OID 20881)
-- Name: sp_build_view_vehicle_vessel_ahts(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_ahts() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_ahts AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    consumption_towing,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    bollard_pull,
    anchor_handling_drum_capacity,
    anchor_handling_winch_rated_pull,
    external_personel,
    towing_max_hs,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_anchor_handling
   JOIN reference.vehicle_shared ON vehicle_vessel_anchor_handling.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_anchor_handling.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'anchor handling tug supply vessel'::text;
$$;


--
-- TOC entry 1304 (class 1255 OID 20882)
-- Name: sp_build_view_vehicle_vessel_barge(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_barge() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_barge AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cargo
   JOIN reference.vehicle_shared ON vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'barge'::text;
$$;


--
-- TOC entry 1305 (class 1255 OID 20883)
-- Name: sp_build_view_vehicle_vessel_clb(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_clb() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_clb AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    number_turntables,
    turntable_max_load_mass,
    turntable_inner_diameter,
    cable_splice_capabilities,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cable_laying
   JOIN reference.vehicle_shared ON vehicle_vessel_cable_laying.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cable_laying.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'cable laying barge'::text;
$$;


--
-- TOC entry 1306 (class 1255 OID 20884)
-- Name: sp_build_view_vehicle_vessel_clv(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_clv() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_clv AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    bollard_pull,
    number_turntables,
    turntable_max_load_mass,
    turntable_inner_diameter,
    cable_splice_capabilities,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cable_laying
   JOIN reference.vehicle_shared ON vehicle_vessel_cable_laying.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cable_laying.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'cable laying vessel'::text;
$$;


--
-- TOC entry 1307 (class 1255 OID 20885)
-- Name: sp_build_view_vehicle_vessel_crane_barge(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_crane_barge() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_crane_barge AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cargo
   JOIN reference.vehicle_shared ON vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'crane barge'::text;
$$;


--
-- TOC entry 1308 (class 1255 OID 20886)
-- Name: sp_build_view_vehicle_vessel_crane_vessel(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_crane_vessel() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_crane_vessel AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cargo
   JOIN reference.vehicle_shared ON vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'crane vessel'::text;
$$;


--
-- TOC entry 1309 (class 1255 OID 20887)
-- Name: sp_build_view_vehicle_vessel_csv(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_csv() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_csv AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cargo
   JOIN reference.vehicle_shared ON vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'construction support vessel'::text;
$$;


--
-- TOC entry 1310 (class 1255 OID 20888)
-- Name: sp_build_view_vehicle_vessel_ctv(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_ctv() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_ctv AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_cargo
   JOIN reference.vehicle_shared ON vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'crew transfer vessel'::text;
$$;


--
-- TOC entry 1311 (class 1255 OID 20889)
-- Name: sp_build_view_vehicle_vessel_jackup_barge(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_jackup_barge() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_jackup_barge AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    jackup_max_water_depth,
    jackup_speed_down,
    jackup_max_payload_mass,
    jacking_max_hs,
    jacking_max_tp,
    jacking_max_cs,
    jacking_max_ws,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_jackup
   JOIN reference.vehicle_shared ON vehicle_vessel_jackup.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_jackup.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'jackup barge'::text;
$$;


--
-- TOC entry 1312 (class 1255 OID 20890)
-- Name: sp_build_view_vehicle_vessel_jackup_vessel(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_jackup_vessel() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_jackup_vessel AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    dynamic_positioning_capabilities,
    external_personel,
    jackup_max_water_depth,
    jackup_speed_down,
    jackup_max_payload_mass,
    jacking_max_hs,
    jacking_max_tp,
    jacking_max_cs,
    jacking_max_ws,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_jackup
   JOIN reference.vehicle_shared ON vehicle_vessel_jackup.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_jackup.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'jackup vessel'::text;
$$;


--
-- TOC entry 1313 (class 1255 OID 20891)
-- Name: sp_build_view_vehicle_vessel_multicat(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_multicat() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_multicat AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    consumption_towing,
    vehicle_shared.transit_speed,
    deck_space,
    max_deck_load_pressure,
    max_cargo_mass,
    crane_max_load_mass,
    bollard_pull,
    anchor_handling_drum_capacity,
    anchor_handling_winch_rated_pull,
    external_personel,
    towing_max_hs,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_anchor_handling
   JOIN reference.vehicle_shared ON vehicle_vessel_anchor_handling.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id
   JOIN reference.vehicle_type ON vehicle_vessel_anchor_handling.fk_vehicle_type_id = vehicle_type.id
   WHERE vehicle_type.description::text = 'multicat'::text;
$$;


--
-- TOC entry 1314 (class 1255 OID 20892)
-- Name: sp_build_view_vehicle_vessel_tugboat(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_view_vehicle_vessel_tugboat() RETURNS void
    LANGUAGE sql
    AS $$
CREATE OR REPLACE VIEW reference.view_vehicle_vessel_tugboat AS 
 SELECT
    vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    beam,
    max_draft,
    vehicle_shared.consumption,
    consumption_towing,
    vehicle_shared.transit_speed,
    bollard_pull,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM reference.vehicle_vessel_tugboat
   JOIN reference.vehicle_shared ON vehicle_vessel_tugboat.fk_vehicle_id = vehicle_shared.fk_vehicle_id
   JOIN reference.vehicle ON vehicle_shared.fk_vehicle_id = vehicle.id;
$$;


--
-- TOC entry 1315 (class 1255 OID 20893)
-- Name: sp_build_views(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_build_views() RETURNS void
    LANGUAGE sql
    AS $$
SELECT reference.sp_build_view_component_cable_dynamic();
SELECT reference.sp_build_view_component_cable_static();
SELECT reference.sp_build_view_component_collection_point();
SELECT reference.sp_build_view_component_connector_drymate();
SELECT reference.sp_build_view_component_connector_wetmate();
SELECT reference.sp_build_view_component_foundations_anchor();
SELECT reference.sp_build_view_component_foundations_anchor_coefs();
SELECT reference.sp_build_view_component_foundations_pile();
SELECT reference.sp_build_view_component_moorings_chain();
SELECT reference.sp_build_view_component_moorings_forerunner();
SELECT reference.sp_build_view_component_moorings_rope();
SELECT reference.sp_build_view_component_moorings_shackle();
SELECT reference.sp_build_view_component_moorings_swivel();
SELECT reference.sp_build_view_component_transformer();
SELECT reference.sp_build_view_operations_limit_hs();
SELECT reference.sp_build_view_operations_limit_tp();
SELECT reference.sp_build_view_operations_limit_ws();
SELECT reference.sp_build_view_operations_limit_cs();
SELECT reference.sp_build_view_soil_type_geotechnical_properties();
SELECT reference.sp_build_view_vehicle_helicopter();
SELECT reference.sp_build_view_vehicle_vessel_ahts();
SELECT reference.sp_build_view_vehicle_vessel_barge();
SELECT reference.sp_build_view_vehicle_vessel_clb();
SELECT reference.sp_build_view_vehicle_vessel_clv();
SELECT reference.sp_build_view_vehicle_vessel_crane_barge();
SELECT reference.sp_build_view_vehicle_vessel_crane_vessel();
SELECT reference.sp_build_view_vehicle_vessel_csv();
SELECT reference.sp_build_view_vehicle_vessel_ctv();
SELECT reference.sp_build_view_vehicle_vessel_jackup_barge();
SELECT reference.sp_build_view_vehicle_vessel_jackup_vessel();
SELECT reference.sp_build_view_vehicle_vessel_multicat();
SELECT reference.sp_build_view_vehicle_vessel_tugboat();
$$;


--
-- TOC entry 1316 (class 1255 OID 20894)
-- Name: sp_drop_views(); Type: FUNCTION; Schema: reference; Owner: -
--

CREATE FUNCTION reference.sp_drop_views() RETURNS void
    LANGUAGE sql
    AS $$
DROP VIEW reference.view_component_cable_dynamic;
DROP VIEW reference.view_component_cable_static;
DROP VIEW reference.view_component_collection_point;
DROP VIEW reference.view_component_connector_drymate;
DROP VIEW reference.view_component_connector_wetmate;
DROP VIEW reference.view_component_foundations_anchor;
DROP VIEW reference.view_component_foundations_anchor_coefs;
DROP VIEW reference.view_component_foundations_pile;
DROP VIEW reference.view_component_moorings_chain;
DROP VIEW reference.view_component_moorings_forerunner;
DROP VIEW reference.view_component_moorings_rope;
DROP VIEW reference.view_component_moorings_shackle;
DROP VIEW reference.view_component_moorings_swivel;
DROP VIEW reference.view_component_transformer;
DROP VIEW reference.view_operations_limit_hs;
DROP VIEW reference.view_operations_limit_tp;
DROP VIEW reference.view_operations_limit_ws;
DROP VIEW reference.view_operations_limit_cs;
DROP VIEW reference.view_soil_type_geotechnical_properties;
DROP VIEW reference.view_vehicle_helicopter;
DROP VIEW reference.view_vehicle_vessel_ahts;
DROP VIEW reference.view_vehicle_vessel_barge;
DROP VIEW reference.view_vehicle_vessel_clb;
DROP VIEW reference.view_vehicle_vessel_clv;
DROP VIEW reference.view_vehicle_vessel_crane_barge;
DROP VIEW reference.view_vehicle_vessel_crane_vessel;
DROP VIEW reference.view_vehicle_vessel_csv;
DROP VIEW reference.view_vehicle_vessel_ctv;
DROP VIEW reference.view_vehicle_vessel_jackup_barge;
DROP VIEW reference.view_vehicle_vessel_jackup_vessel;
DROP VIEW reference.view_vehicle_vessel_multicat;
DROP VIEW reference.view_vehicle_vessel_tugboat;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 20895)
-- Name: bathymetry; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.bathymetry (
    id bigint NOT NULL,
    fk_site_id smallint,
    utm_point public.geometry,
    depth double precision,
    mannings_no double precision
);


--
-- TOC entry 228 (class 1259 OID 20900)
-- Name: bathymetry_layer; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.bathymetry_layer (
    id bigint NOT NULL,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    layer_order smallint,
    initial_depth double precision
);


--
-- TOC entry 229 (class 1259 OID 20903)
-- Name: cable_corridor_bathymetry; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.cable_corridor_bathymetry (
    id bigint NOT NULL,
    fk_site_id integer,
    utm_point public.geometry,
    depth double precision
);


--
-- TOC entry 230 (class 1259 OID 20908)
-- Name: cable_corridor_bathymetry_layer; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.cable_corridor_bathymetry_layer (
    id bigint NOT NULL,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    layer_order smallint,
    initial_depth double precision
);


--
-- TOC entry 231 (class 1259 OID 20911)
-- Name: cable_corridor_constraint; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.cable_corridor_constraint (
    id integer NOT NULL,
    fk_site_id integer,
    description text,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 232 (class 1259 OID 20916)
-- Name: constraint; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter."constraint" (
    id integer NOT NULL,
    fk_site_id integer,
    description text,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 233 (class 1259 OID 20921)
-- Name: device_floating; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.device_floating (
    id integer NOT NULL,
    fk_device_id integer,
    draft double precision,
    maximum_displacement double precision[],
    depth_variation_permitted boolean,
    fairlead_locations double precision[],
    umbilical_connection_point double precision[],
    prescribed_mooring_system character varying(50),
    prescribed_umbilical_type character varying(50)
);


--
-- TOC entry 234 (class 1259 OID 20926)
-- Name: device_shared; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.device_shared (
    id integer NOT NULL,
    fk_device_id integer,
    height double precision,
    width double precision,
    length double precision,
    displaced_volume double precision,
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    wet_beam_area double precision,
    dry_beam_area double precision,
    centre_of_gravity double precision[],
    mass double precision,
    profile character varying(12),
    surface_roughness double precision,
    yaw double precision,
    prescribed_footprint_radius double precision,
    footprint_corner_coords double precision[],
    installation_depth_max double precision,
    installation_depth_min double precision,
    minimum_distance_x double precision,
    minimum_distance_y double precision,
    prescribed_foundation_system character varying(50),
    foundation_locations double precision[],
    rated_power double precision,
    rated_voltage_u0 double precision,
    connector_type character varying(8),
    constant_power_factor double precision,
    variable_power_factor double precision[],
    assembly_duration double precision,
    connect_duration double precision,
    disconnect_duration double precision,
    load_out_method character varying(10),
    transportation_method character varying(4),
    bollard_pull double precision,
    two_stage_assembly boolean,
    cost double precision
);


--
-- TOC entry 235 (class 1259 OID 20931)
-- Name: device_tidal; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.device_tidal (
    id integer NOT NULL,
    fk_device_id integer,
    cut_in_velocity double precision,
    cut_out_velocity double precision,
    hub_height double precision,
    turbine_diameter double precision,
    two_ways_flow boolean,
    turbine_interdistance double precision
);


--
-- TOC entry 236 (class 1259 OID 20934)
-- Name: device_tidal_power_performance; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.device_tidal_power_performance (
    id integer NOT NULL,
    fk_device_id integer,
    velocity double precision NOT NULL,
    thrust_coefficient double precision,
    power_coefficient double precision
);


--
-- TOC entry 237 (class 1259 OID 20937)
-- Name: device_wave; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.device_wave (
    id integer NOT NULL,
    fk_device_id integer,
    wave_data_directory character varying(200)
);


--
-- TOC entry 238 (class 1259 OID 20940)
-- Name: lease_area; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.lease_area (
    id integer NOT NULL,
    fk_site_id integer,
    blockage_ratio double precision,
    tidal_occurrence_point public.geometry(Point),
    wave_spectrum_type character varying(22),
    wave_spectrum_gamma double precision,
    wave_spectrum_spreading_parameter double precision,
    surface_current_flow_velocity double precision,
    current_flow_direction double precision,
    moor_found_current_profile character varying(20),
    significant_wave_height double precision,
    peak_wave_period double precision,
    predominant_wave_direction double precision,
    jonswap_gamma double precision,
    mean_wind_speed double precision,
    predominant_wind_direction double precision,
    max_wind_gust_speed double precision,
    wind_gust_direction double precision,
    water_level_max double precision,
    water_level_min double precision,
    soil_sensitivity double precision,
    has_helipad boolean
);


--
-- TOC entry 239 (class 1259 OID 20945)
-- Name: site_infrastructure; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.site_infrastructure (
    id integer NOT NULL,
    fk_site_id integer,
    has_helipad boolean
);


--
-- TOC entry 240 (class 1259 OID 20948)
-- Name: sub_systems_access; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_access (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 241 (class 1259 OID 20951)
-- Name: sub_systems_economic; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_economic (
    id integer NOT NULL,
    fk_sub_system_id integer,
    cost double precision,
    failure_rate double precision
);


--
-- TOC entry 242 (class 1259 OID 20954)
-- Name: sub_systems_inspection; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_inspection (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 243 (class 1259 OID 20957)
-- Name: sub_systems_install; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_install (
    id integer NOT NULL,
    fk_sub_system_id integer,
    length double precision,
    width double precision,
    height double precision,
    dry_mass double precision,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 244 (class 1259 OID 20960)
-- Name: sub_systems_maintenance; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_maintenance (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    interruptible boolean,
    parts_length double precision,
    parts_width double precision,
    parts_height double precision,
    parts_dry_mass double precision,
    assembly_lead_time double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 245 (class 1259 OID 20963)
-- Name: sub_systems_operation_weightings; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_operation_weightings (
    id integer NOT NULL,
    fk_sub_system_id integer,
    maintenance double precision,
    replacement double precision,
    inspection double precision
);


--
-- TOC entry 246 (class 1259 OID 20966)
-- Name: sub_systems_replace; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.sub_systems_replace (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    interruptible boolean,
    assembly_lead_time double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer
);


--
-- TOC entry 247 (class 1259 OID 20969)
-- Name: time_series_energy_tidal; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.time_series_energy_tidal (
    id bigint NOT NULL,
    fk_bathymetry_id bigint,
    measure_date date,
    measure_time time(6) without time zone,
    u double precision,
    v double precision,
    turbulence_intensity double precision,
    ssh double precision
);


--
-- TOC entry 248 (class 1259 OID 20972)
-- Name: time_series_energy_wave; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.time_series_energy_wave (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    height double precision,
    te double precision,
    direction double precision
);


--
-- TOC entry 249 (class 1259 OID 20975)
-- Name: time_series_om_tidal; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.time_series_om_tidal (
    id bigint NOT NULL,
    fk_site_id bigint,
    measure_date date,
    measure_time time(6) without time zone,
    current_speed double precision
);


--
-- TOC entry 250 (class 1259 OID 20978)
-- Name: time_series_om_wave; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.time_series_om_wave (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    period_tp double precision,
    height_hs double precision
);


--
-- TOC entry 251 (class 1259 OID 20981)
-- Name: time_series_om_wind; Type: TABLE; Schema: filter; Owner: -
--

CREATE TABLE filter.time_series_om_wind (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    wind_speed double precision
);


--
-- TOC entry 252 (class 1259 OID 20984)
-- Name: soil_type; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.soil_type (
    id integer NOT NULL,
    description character varying(40)
);


--
-- TOC entry 253 (class 1259 OID 20987)
-- Name: view_bathymetry_layer; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_bathymetry_layer AS
 SELECT bathymetry.utm_point,
    bathymetry.depth,
    bathymetry.mannings_no,
    bathymetry_layer.layer_order,
    bathymetry_layer.initial_depth,
    soil_type.description AS sediment_type
   FROM ((filter.bathymetry
     LEFT JOIN filter.bathymetry_layer ON ((bathymetry.id = bathymetry_layer.fk_bathymetry_id)))
     LEFT JOIN reference.soil_type ON ((bathymetry_layer.fk_soil_type_id = soil_type.id)));


--
-- TOC entry 254 (class 1259 OID 20991)
-- Name: view_cable_corridor_bathymetry_layer; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_cable_corridor_bathymetry_layer AS
 SELECT cable_corridor_bathymetry.utm_point,
    cable_corridor_bathymetry.depth,
    cable_corridor_bathymetry_layer.layer_order,
    cable_corridor_bathymetry_layer.initial_depth,
    soil_type.description AS sediment_type
   FROM ((filter.cable_corridor_bathymetry
     LEFT JOIN filter.cable_corridor_bathymetry_layer ON ((cable_corridor_bathymetry.id = cable_corridor_bathymetry_layer.fk_bathymetry_id)))
     LEFT JOIN reference.soil_type ON ((cable_corridor_bathymetry_layer.fk_soil_type_id = soil_type.id)));


--
-- TOC entry 255 (class 1259 OID 20995)
-- Name: sub_systems; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems (
    id integer NOT NULL,
    fk_device_id integer,
    sub_system character varying(20),
    CONSTRAINT sub_systems_sub_system_check CHECK (((sub_system)::text = ANY (ARRAY[('Control System'::character varying)::text, ('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text])))
);


--
-- TOC entry 256 (class 1259 OID 20999)
-- Name: view_control_system_access; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_access AS
 SELECT sub_systems.sub_system,
    sub_systems_access.operation_duration,
    sub_systems_access.max_hs,
    sub_systems_access.max_tp,
    sub_systems_access.max_ws,
    sub_systems_access.max_cs
   FROM (filter.sub_systems_access
     JOIN project.sub_systems ON ((sub_systems_access.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 257 (class 1259 OID 21003)
-- Name: view_control_system_economic; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_economic AS
 SELECT sub_systems.sub_system,
    sub_systems_economic.cost,
    sub_systems_economic.failure_rate
   FROM (filter.sub_systems_economic
     JOIN project.sub_systems ON ((sub_systems_economic.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 258 (class 1259 OID 21007)
-- Name: view_control_system_inspection; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_inspection AS
 SELECT sub_systems.sub_system,
    sub_systems_inspection.operation_duration,
    sub_systems_inspection.crew_lead_time,
    sub_systems_inspection.other_lead_time,
    sub_systems_inspection.n_specialists,
    sub_systems_inspection.n_technicians,
    sub_systems_inspection.max_hs,
    sub_systems_inspection.max_tp,
    sub_systems_inspection.max_ws,
    sub_systems_inspection.max_cs
   FROM (filter.sub_systems_inspection
     JOIN project.sub_systems ON ((sub_systems_inspection.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 259 (class 1259 OID 21012)
-- Name: view_control_system_installation; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_installation AS
 SELECT sub_systems.sub_system,
    sub_systems_install.length,
    sub_systems_install.width,
    sub_systems_install.height,
    sub_systems_install.dry_mass,
    sub_systems_install.max_hs,
    sub_systems_install.max_tp,
    sub_systems_install.max_ws,
    sub_systems_install.max_cs
   FROM (filter.sub_systems_install
     JOIN project.sub_systems ON ((sub_systems_install.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 260 (class 1259 OID 21016)
-- Name: view_control_system_maintenance; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_maintenance AS
 SELECT sub_systems.sub_system,
    sub_systems_maintenance.operation_duration,
    sub_systems_maintenance.interruptible,
    sub_systems_maintenance.parts_length,
    sub_systems_maintenance.parts_width,
    sub_systems_maintenance.parts_height,
    sub_systems_maintenance.parts_dry_mass,
    sub_systems_maintenance.assembly_lead_time,
    sub_systems_maintenance.crew_lead_time,
    sub_systems_maintenance.other_lead_time,
    sub_systems_maintenance.n_specialists,
    sub_systems_maintenance.n_technicians,
    sub_systems_maintenance.max_hs,
    sub_systems_maintenance.max_tp,
    sub_systems_maintenance.max_ws,
    sub_systems_maintenance.max_cs
   FROM (filter.sub_systems_maintenance
     JOIN project.sub_systems ON ((sub_systems_maintenance.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 261 (class 1259 OID 21021)
-- Name: view_control_system_operation_weightings; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_operation_weightings AS
 SELECT sub_systems.sub_system,
    sub_systems_operation_weightings.maintenance,
    sub_systems_operation_weightings.replacement,
    sub_systems_operation_weightings.inspection
   FROM (filter.sub_systems_operation_weightings
     JOIN project.sub_systems ON ((sub_systems_operation_weightings.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 262 (class 1259 OID 21025)
-- Name: view_control_system_replace; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_control_system_replace AS
 SELECT sub_systems.sub_system,
    sub_systems_replace.operation_duration,
    sub_systems_replace.interruptible,
    sub_systems_replace.assembly_lead_time,
    sub_systems_replace.crew_lead_time,
    sub_systems_replace.other_lead_time,
    sub_systems_replace.n_specialists,
    sub_systems_replace.n_technicians
   FROM (filter.sub_systems_replace
     JOIN project.sub_systems ON ((sub_systems_replace.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = 'Control System'::text);


--
-- TOC entry 263 (class 1259 OID 21029)
-- Name: view_sub_systems_access; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_access AS
 SELECT sub_systems.sub_system,
    sub_systems_access.operation_duration,
    sub_systems_access.max_hs,
    sub_systems_access.max_tp,
    sub_systems_access.max_ws,
    sub_systems_access.max_cs
   FROM (filter.sub_systems_access
     JOIN project.sub_systems ON ((sub_systems_access.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 264 (class 1259 OID 21033)
-- Name: view_sub_systems_economic; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_economic AS
 SELECT sub_systems.sub_system,
    sub_systems_economic.cost,
    sub_systems_economic.failure_rate
   FROM (filter.sub_systems_economic
     JOIN project.sub_systems ON ((sub_systems_economic.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 265 (class 1259 OID 21037)
-- Name: view_sub_systems_inspection; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_inspection AS
 SELECT sub_systems.sub_system,
    sub_systems_inspection.operation_duration,
    sub_systems_inspection.crew_lead_time,
    sub_systems_inspection.other_lead_time,
    sub_systems_inspection.n_specialists,
    sub_systems_inspection.n_technicians,
    sub_systems_inspection.max_hs,
    sub_systems_inspection.max_tp,
    sub_systems_inspection.max_ws,
    sub_systems_inspection.max_cs
   FROM (filter.sub_systems_inspection
     JOIN project.sub_systems ON ((sub_systems_inspection.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 266 (class 1259 OID 21042)
-- Name: view_sub_systems_installation; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_installation AS
 SELECT sub_systems.sub_system,
    sub_systems_install.length,
    sub_systems_install.width,
    sub_systems_install.height,
    sub_systems_install.dry_mass,
    sub_systems_install.max_hs,
    sub_systems_install.max_tp,
    sub_systems_install.max_ws,
    sub_systems_install.max_cs
   FROM (filter.sub_systems_install
     JOIN project.sub_systems ON ((sub_systems_install.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 267 (class 1259 OID 21047)
-- Name: view_sub_systems_maintenance; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_maintenance AS
 SELECT sub_systems.sub_system,
    sub_systems_maintenance.operation_duration,
    sub_systems_maintenance.interruptible,
    sub_systems_maintenance.parts_length,
    sub_systems_maintenance.parts_width,
    sub_systems_maintenance.parts_height,
    sub_systems_maintenance.parts_dry_mass,
    sub_systems_maintenance.assembly_lead_time,
    sub_systems_maintenance.crew_lead_time,
    sub_systems_maintenance.other_lead_time,
    sub_systems_maintenance.n_specialists,
    sub_systems_maintenance.n_technicians,
    sub_systems_maintenance.max_hs,
    sub_systems_maintenance.max_tp,
    sub_systems_maintenance.max_ws,
    sub_systems_maintenance.max_cs
   FROM (filter.sub_systems_maintenance
     JOIN project.sub_systems ON ((sub_systems_maintenance.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 268 (class 1259 OID 21052)
-- Name: view_sub_systems_operation_weightings; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_operation_weightings AS
 SELECT sub_systems.sub_system,
    sub_systems_operation_weightings.maintenance,
    sub_systems_operation_weightings.replacement,
    sub_systems_operation_weightings.inspection
   FROM (filter.sub_systems_operation_weightings
     JOIN project.sub_systems ON ((sub_systems_operation_weightings.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 269 (class 1259 OID 21056)
-- Name: view_sub_systems_replace; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_sub_systems_replace AS
 SELECT sub_systems.sub_system,
    sub_systems_replace.operation_duration,
    sub_systems_replace.interruptible,
    sub_systems_replace.assembly_lead_time,
    sub_systems_replace.crew_lead_time,
    sub_systems_replace.other_lead_time,
    sub_systems_replace.n_specialists,
    sub_systems_replace.n_technicians
   FROM (filter.sub_systems_replace
     JOIN project.sub_systems ON ((sub_systems_replace.fk_sub_system_id = sub_systems.id)))
  WHERE ((sub_systems.sub_system)::text = ANY (ARRAY[('Prime Mover'::character varying)::text, ('PTO'::character varying)::text, ('Support Structure'::character varying)::text]));


--
-- TOC entry 270 (class 1259 OID 21061)
-- Name: view_time_series_energy_tidal; Type: VIEW; Schema: filter; Owner: -
--

CREATE VIEW filter.view_time_series_energy_tidal AS
 SELECT bathymetry.utm_point,
    time_series_energy_tidal.measure_date,
    time_series_energy_tidal.measure_time,
    time_series_energy_tidal.u,
    time_series_energy_tidal.v,
    time_series_energy_tidal.turbulence_intensity,
    time_series_energy_tidal.ssh
   FROM (filter.bathymetry
     JOIN filter.time_series_energy_tidal ON ((bathymetry.id = time_series_energy_tidal.fk_bathymetry_id)));


--
-- TOC entry 271 (class 1259 OID 21065)
-- Name: bathymetry; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.bathymetry (
    id bigint NOT NULL,
    fk_site_id smallint,
    utm_point public.geometry,
    depth double precision,
    mannings_no double precision
);


--
-- TOC entry 272 (class 1259 OID 21070)
-- Name: bathymetry_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.bathymetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5518 (class 0 OID 0)
-- Dependencies: 272
-- Name: bathymetry_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.bathymetry_id_seq OWNED BY project.bathymetry.id;


--
-- TOC entry 273 (class 1259 OID 21071)
-- Name: bathymetry_layer_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.bathymetry_layer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 274 (class 1259 OID 21072)
-- Name: bathymetry_layer; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.bathymetry_layer (
    id bigint DEFAULT nextval('project.bathymetry_layer_id_seq'::regclass) NOT NULL,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    layer_order smallint,
    initial_depth double precision
);


--
-- TOC entry 275 (class 1259 OID 21076)
-- Name: cable_corridor_bathymetry; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.cable_corridor_bathymetry (
    id bigint NOT NULL,
    fk_site_id integer,
    utm_point public.geometry,
    depth double precision
);


--
-- TOC entry 276 (class 1259 OID 21081)
-- Name: cable_corridor_bathymetry_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.cable_corridor_bathymetry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5519 (class 0 OID 0)
-- Dependencies: 276
-- Name: cable_corridor_bathymetry_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.cable_corridor_bathymetry_id_seq OWNED BY project.cable_corridor_bathymetry.id;


--
-- TOC entry 277 (class 1259 OID 21082)
-- Name: cable_corridor_bathymetry_layer; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.cable_corridor_bathymetry_layer (
    id bigint NOT NULL,
    fk_bathymetry_id bigint,
    fk_soil_type_id integer,
    layer_order smallint,
    initial_depth double precision
);


--
-- TOC entry 278 (class 1259 OID 21085)
-- Name: cable_corridor_bathymetry_layer_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.cable_corridor_bathymetry_layer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5520 (class 0 OID 0)
-- Dependencies: 278
-- Name: cable_corridor_bathymetry_layer_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.cable_corridor_bathymetry_layer_id_seq OWNED BY project.cable_corridor_bathymetry_layer.id;


--
-- TOC entry 279 (class 1259 OID 21086)
-- Name: cable_corridor_constraint; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.cable_corridor_constraint (
    id integer NOT NULL,
    fk_site_id integer,
    description text,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 280 (class 1259 OID 21091)
-- Name: cable_corridor_constraint_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.cable_corridor_constraint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5521 (class 0 OID 0)
-- Dependencies: 280
-- Name: cable_corridor_constraint_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.cable_corridor_constraint_id_seq OWNED BY project.cable_corridor_constraint.id;


--
-- TOC entry 281 (class 1259 OID 21092)
-- Name: constraint; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project."constraint" (
    id integer NOT NULL,
    fk_site_id integer,
    description text,
    boundary public.geometry(Polygon)
);


--
-- TOC entry 282 (class 1259 OID 21097)
-- Name: constraint_type_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.constraint_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 32767
    CACHE 1;


--
-- TOC entry 283 (class 1259 OID 21098)
-- Name: device; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device (
    id integer NOT NULL,
    description character varying(200),
    device_type character varying(50),
    image bytea,
    CONSTRAINT device_device_type_check CHECK (((device_type)::text = ANY (ARRAY[('Tidal Fixed'::character varying)::text, ('Tidal Floating'::character varying)::text, ('Wave Fixed'::character varying)::text, ('Wave Floating'::character varying)::text])))
);


--
-- TOC entry 284 (class 1259 OID 21104)
-- Name: device_floating; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device_floating (
    id integer NOT NULL,
    fk_device_id integer,
    draft double precision,
    maximum_displacement double precision[],
    depth_variation_permitted boolean,
    fairlead_locations double precision[],
    umbilical_connection_point double precision[],
    prescribed_mooring_system character varying(50),
    prescribed_umbilical_type character varying(50)
);


--
-- TOC entry 285 (class 1259 OID 21109)
-- Name: device_floating_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_floating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5522 (class 0 OID 0)
-- Dependencies: 285
-- Name: device_floating_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_floating_id_seq OWNED BY project.device_floating.id;


--
-- TOC entry 286 (class 1259 OID 21110)
-- Name: device_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5523 (class 0 OID 0)
-- Dependencies: 286
-- Name: device_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_id_seq OWNED BY project.device.id;


--
-- TOC entry 287 (class 1259 OID 21111)
-- Name: device_power_performance_tidal_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_power_performance_tidal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- TOC entry 288 (class 1259 OID 21112)
-- Name: device_shared; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device_shared (
    id integer NOT NULL,
    fk_device_id integer,
    height double precision,
    width double precision,
    length double precision,
    displaced_volume double precision,
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    wet_beam_area double precision,
    dry_beam_area double precision,
    centre_of_gravity double precision[],
    mass double precision,
    profile character varying(12),
    surface_roughness double precision,
    yaw double precision,
    prescribed_footprint_radius double precision,
    footprint_corner_coords double precision[],
    installation_depth_max double precision,
    installation_depth_min double precision,
    minimum_distance_x double precision,
    minimum_distance_y double precision,
    prescribed_foundation_system character varying(50),
    foundation_locations double precision[],
    rated_power double precision,
    rated_voltage_u0 double precision,
    connector_type character varying(8),
    constant_power_factor double precision,
    variable_power_factor double precision[],
    assembly_duration double precision,
    connect_duration double precision,
    disconnect_duration double precision,
    load_out_method character varying(10),
    transportation_method character varying(4),
    bollard_pull double precision,
    two_stage_assembly boolean,
    cost double precision,
    CONSTRAINT device_shared_connector_type_check CHECK (((connector_type)::text = ANY (ARRAY[('Wet-Mate'::character varying)::text, ('Dry-Mate'::character varying)::text]))),
    CONSTRAINT device_shared_load_out_method_check CHECK (((load_out_method)::text = ANY (ARRAY[('Skidded'::character varying)::text, ('Trailer'::character varying)::text, ('Float Away'::character varying)::text, ('Lift Away'::character varying)::text]))),
    CONSTRAINT device_shared_profile_check CHECK (((profile)::text = ANY (ARRAY[('Cylindrical'::character varying)::text, ('Rectangular'::character varying)::text]))),
    CONSTRAINT device_shared_transportation_method_check CHECK (((transportation_method)::text = ANY (ARRAY[('Deck'::character varying)::text, ('Tow'::character varying)::text])))
);


--
-- TOC entry 289 (class 1259 OID 21121)
-- Name: device_shared_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_shared_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5524 (class 0 OID 0)
-- Dependencies: 289
-- Name: device_shared_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_shared_id_seq OWNED BY project.device_shared.id;


--
-- TOC entry 290 (class 1259 OID 21122)
-- Name: device_tidal; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device_tidal (
    id integer NOT NULL,
    fk_device_id integer,
    cut_in_velocity double precision,
    cut_out_velocity double precision,
    hub_height double precision,
    turbine_diameter double precision,
    two_ways_flow boolean,
    turbine_interdistance double precision
);


--
-- TOC entry 291 (class 1259 OID 21125)
-- Name: device_tidal_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_tidal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5525 (class 0 OID 0)
-- Dependencies: 291
-- Name: device_tidal_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_tidal_id_seq OWNED BY project.device_tidal.id;


--
-- TOC entry 292 (class 1259 OID 21126)
-- Name: device_tidal_power_performance; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device_tidal_power_performance (
    id integer NOT NULL,
    fk_device_id integer,
    velocity double precision NOT NULL,
    thrust_coefficient double precision,
    power_coefficient double precision
);


--
-- TOC entry 293 (class 1259 OID 21129)
-- Name: device_tidal_power_performance_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_tidal_power_performance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5526 (class 0 OID 0)
-- Dependencies: 293
-- Name: device_tidal_power_performance_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_tidal_power_performance_id_seq OWNED BY project.device_tidal_power_performance.id;


--
-- TOC entry 294 (class 1259 OID 21130)
-- Name: device_wave; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.device_wave (
    id integer NOT NULL,
    fk_device_id integer,
    wave_data_directory character varying(200)
);


--
-- TOC entry 295 (class 1259 OID 21133)
-- Name: device_wave_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.device_wave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5527 (class 0 OID 0)
-- Dependencies: 295
-- Name: device_wave_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.device_wave_id_seq OWNED BY project.device_wave.id;


--
-- TOC entry 296 (class 1259 OID 21134)
-- Name: lease_area; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.lease_area (
    id integer NOT NULL,
    fk_site_id integer,
    blockage_ratio double precision,
    tidal_occurrence_point public.geometry(Point),
    wave_spectrum_type character varying(22),
    wave_spectrum_gamma double precision,
    wave_spectrum_spreading_parameter double precision,
    surface_current_flow_velocity double precision,
    current_flow_direction double precision,
    moor_found_current_profile character varying(20),
    significant_wave_height double precision,
    peak_wave_period double precision,
    predominant_wave_direction double precision,
    jonswap_gamma double precision,
    mean_wind_speed double precision,
    predominant_wind_direction double precision,
    max_wind_gust_speed double precision,
    wind_gust_direction double precision,
    water_level_max double precision,
    water_level_min double precision,
    soil_sensitivity double precision,
    has_helipad boolean,
    CONSTRAINT lease_area_moor_found_current_profile_check CHECK (((moor_found_current_profile)::text = ANY (ARRAY[('Uniform'::character varying)::text, ('1/7 Power Law'::character varying)::text]))),
    CONSTRAINT lease_area_wave_spectrum_type_check CHECK (((wave_spectrum_type)::text = ANY (ARRAY[('Regular'::character varying)::text, ('Pierson-Moskowitz'::character varying)::text, ('JONSWAP'::character varying)::text, ('Bretschneider'::character varying)::text, ('Modified Bretschneider'::character varying)::text])))
);


--
-- TOC entry 297 (class 1259 OID 21141)
-- Name: lease_area_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.lease_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5528 (class 0 OID 0)
-- Dependencies: 297
-- Name: lease_area_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.lease_area_id_seq OWNED BY project.lease_area.id;


--
-- TOC entry 298 (class 1259 OID 21142)
-- Name: site; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.site (
    id integer NOT NULL,
    site_name character varying(20),
    lease_area_proj4_string character varying(100),
    site_boundary public.geometry(Polygon,4326),
    lease_boundary public.geometry(Polygon),
    corridor_boundary public.geometry(Polygon),
    cable_landing_location public.geometry(Point)
);


--
-- TOC entry 299 (class 1259 OID 21147)
-- Name: site_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.site_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5529 (class 0 OID 0)
-- Dependencies: 299
-- Name: site_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.site_id_seq OWNED BY project.site.id;


--
-- TOC entry 300 (class 1259 OID 21148)
-- Name: sub_systems_access; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_access (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 301 (class 1259 OID 21151)
-- Name: sub_systems_access_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5530 (class 0 OID 0)
-- Dependencies: 301
-- Name: sub_systems_access_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_access_id_seq OWNED BY project.sub_systems_access.id;


--
-- TOC entry 302 (class 1259 OID 21152)
-- Name: sub_systems_economic; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_economic (
    id integer NOT NULL,
    fk_sub_system_id integer,
    cost double precision,
    failure_rate double precision
);


--
-- TOC entry 303 (class 1259 OID 21155)
-- Name: sub_systems_economic_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_economic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5531 (class 0 OID 0)
-- Dependencies: 303
-- Name: sub_systems_economic_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_economic_id_seq OWNED BY project.sub_systems_economic.id;


--
-- TOC entry 304 (class 1259 OID 21156)
-- Name: sub_systems_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5532 (class 0 OID 0)
-- Dependencies: 304
-- Name: sub_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_id_seq OWNED BY project.sub_systems.id;


--
-- TOC entry 305 (class 1259 OID 21157)
-- Name: sub_systems_inspection; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_inspection (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 306 (class 1259 OID 21160)
-- Name: sub_systems_inspection_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_inspection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5533 (class 0 OID 0)
-- Dependencies: 306
-- Name: sub_systems_inspection_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_inspection_id_seq OWNED BY project.sub_systems_inspection.id;


--
-- TOC entry 307 (class 1259 OID 21161)
-- Name: sub_systems_install; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_install (
    id integer NOT NULL,
    fk_sub_system_id integer,
    length double precision,
    width double precision,
    height double precision,
    dry_mass double precision,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 308 (class 1259 OID 21164)
-- Name: sub_systems_install_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_install_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5534 (class 0 OID 0)
-- Dependencies: 308
-- Name: sub_systems_install_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_install_id_seq OWNED BY project.sub_systems_install.id;


--
-- TOC entry 309 (class 1259 OID 21165)
-- Name: sub_systems_maintenance; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_maintenance (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    interruptible boolean,
    parts_length double precision,
    parts_width double precision,
    parts_height double precision,
    parts_dry_mass double precision,
    assembly_lead_time double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer,
    max_hs double precision,
    max_tp double precision,
    max_ws double precision,
    max_cs double precision
);


--
-- TOC entry 310 (class 1259 OID 21168)
-- Name: sub_systems_maintenance_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_maintenance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5535 (class 0 OID 0)
-- Dependencies: 310
-- Name: sub_systems_maintenance_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_maintenance_id_seq OWNED BY project.sub_systems_maintenance.id;


--
-- TOC entry 311 (class 1259 OID 21169)
-- Name: sub_systems_operation_weightings; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_operation_weightings (
    id integer NOT NULL,
    fk_sub_system_id integer,
    maintenance double precision,
    replacement double precision,
    inspection double precision
);


--
-- TOC entry 312 (class 1259 OID 21172)
-- Name: sub_systems_operation_weightings_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_operation_weightings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5536 (class 0 OID 0)
-- Dependencies: 312
-- Name: sub_systems_operation_weightings_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_operation_weightings_id_seq OWNED BY project.sub_systems_operation_weightings.id;


--
-- TOC entry 313 (class 1259 OID 21173)
-- Name: sub_systems_replace; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.sub_systems_replace (
    id integer NOT NULL,
    fk_sub_system_id integer,
    operation_duration double precision,
    interruptible boolean,
    assembly_lead_time double precision,
    crew_lead_time double precision,
    other_lead_time double precision,
    n_specialists integer,
    n_technicians integer
);


--
-- TOC entry 314 (class 1259 OID 21176)
-- Name: sub_systems_replace_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.sub_systems_replace_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5537 (class 0 OID 0)
-- Dependencies: 314
-- Name: sub_systems_replace_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.sub_systems_replace_id_seq OWNED BY project.sub_systems_replace.id;


--
-- TOC entry 315 (class 1259 OID 21177)
-- Name: time_series_energy_tidal; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.time_series_energy_tidal (
    id bigint NOT NULL,
    fk_bathymetry_id bigint,
    measure_date date,
    measure_time time(6) without time zone,
    u double precision,
    v double precision,
    turbulence_intensity double precision,
    ssh double precision
);


--
-- TOC entry 316 (class 1259 OID 21180)
-- Name: time_series_energy_tidal_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.time_series_energy_tidal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5538 (class 0 OID 0)
-- Dependencies: 316
-- Name: time_series_energy_tidal_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.time_series_energy_tidal_id_seq OWNED BY project.time_series_energy_tidal.id;


--
-- TOC entry 317 (class 1259 OID 21181)
-- Name: time_series_energy_wave; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.time_series_energy_wave (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    height double precision,
    te double precision,
    direction double precision
);


--
-- TOC entry 318 (class 1259 OID 21184)
-- Name: time_series_energy_wave_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.time_series_energy_wave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5539 (class 0 OID 0)
-- Dependencies: 318
-- Name: time_series_energy_wave_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.time_series_energy_wave_id_seq OWNED BY project.time_series_energy_wave.id;


--
-- TOC entry 319 (class 1259 OID 21185)
-- Name: time_series_om_tidal; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.time_series_om_tidal (
    id bigint NOT NULL,
    fk_site_id bigint,
    measure_date date,
    measure_time time(6) without time zone,
    current_speed double precision
);


--
-- TOC entry 320 (class 1259 OID 21188)
-- Name: time_series_om_tidal_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.time_series_om_tidal_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5540 (class 0 OID 0)
-- Dependencies: 320
-- Name: time_series_om_tidal_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.time_series_om_tidal_id_seq OWNED BY project.time_series_om_tidal.id;


--
-- TOC entry 321 (class 1259 OID 21189)
-- Name: time_series_om_wave; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.time_series_om_wave (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    period_tp double precision,
    height_hs double precision
);


--
-- TOC entry 322 (class 1259 OID 21192)
-- Name: time_series_om_wave_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.time_series_om_wave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5541 (class 0 OID 0)
-- Dependencies: 322
-- Name: time_series_om_wave_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.time_series_om_wave_id_seq OWNED BY project.time_series_om_wave.id;


--
-- TOC entry 323 (class 1259 OID 21193)
-- Name: time_series_om_wind; Type: TABLE; Schema: project; Owner: -
--

CREATE TABLE project.time_series_om_wind (
    id bigint NOT NULL,
    fk_site_id integer,
    measure_date date,
    measure_time time(6) without time zone,
    wind_speed double precision
);


--
-- TOC entry 324 (class 1259 OID 21196)
-- Name: time_series_om_wind_id_seq; Type: SEQUENCE; Schema: project; Owner: -
--

CREATE SEQUENCE project.time_series_om_wind_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5542 (class 0 OID 0)
-- Dependencies: 324
-- Name: time_series_om_wind_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: -
--

ALTER SEQUENCE project.time_series_om_wind_id_seq OWNED BY project.time_series_om_wind.id;


--
-- TOC entry 325 (class 1259 OID 21197)
-- Name: component; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component (
    id bigint NOT NULL,
    description character varying(200)
);


--
-- TOC entry 326 (class 1259 OID 21200)
-- Name: component_anchor; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_anchor (
    id integer NOT NULL,
    fk_component_discrete_id bigint,
    fk_component_type_id smallint,
    connecting_size double precision,
    minimum_breaking_load double precision,
    axial_stiffness double precision,
    soft_holding_cap_coef_1 double precision,
    soft_holding_cap_coef_2 double precision,
    soft_penetration_coef_1 double precision,
    soft_penetration_coef_2 double precision,
    sand_holding_cap_coef_1 double precision,
    sand_holding_cap_coef_2 double precision,
    sand_penetration_coef_1 double precision,
    sand_penetration_coef_2 double precision,
    CONSTRAINT component_anchor_fk_component_type_id_check CHECK ((fk_component_type_id = 1))
);


--
-- TOC entry 327 (class 1259 OID 21204)
-- Name: component_anchor_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_anchor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5543 (class 0 OID 0)
-- Dependencies: 327
-- Name: component_anchor_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_anchor_id_seq OWNED BY reference.component_anchor.id;


--
-- TOC entry 328 (class 1259 OID 21205)
-- Name: component_cable; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_cable (
    id integer NOT NULL,
    fk_component_continuous_id bigint,
    fk_component_type_id smallint,
    minimum_breaking_load double precision,
    minimum_bend_radius double precision,
    number_conductors smallint,
    number_fibre_channels smallint,
    resistance_dc_20 double precision,
    resistance_ac_90 double precision,
    inductive_reactance double precision,
    capacitance double precision,
    rated_current_air double precision,
    rated_current_buried double precision,
    rated_current_jtube double precision,
    rated_voltage_u0 double precision,
    operational_temp_max double precision,
    CONSTRAINT component_cable_fk_component_type_id_check CHECK ((fk_component_type_id = ANY (ARRAY[2, 3])))
);


--
-- TOC entry 329 (class 1259 OID 21209)
-- Name: component_cable_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_cable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5544 (class 0 OID 0)
-- Dependencies: 329
-- Name: component_cable_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_cable_id_seq OWNED BY reference.component_cable.id;


--
-- TOC entry 330 (class 1259 OID 21210)
-- Name: component_collection_point; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_collection_point (
    id integer NOT NULL,
    fk_component_discrete_id bigint,
    fk_component_type_id smallint,
    wet_frontal_area double precision,
    dry_frontal_area double precision,
    wet_beam_area double precision,
    dry_beam_area double precision,
    maximum_water_depth double precision,
    orientation_angle double precision,
    input_lines integer,
    output_lines integer,
    input_connector_type character varying(8),
    output_connector_type character varying(8),
    number_fibre_channels integer,
    voltage_primary_winding double precision,
    voltage_secondary_winding double precision,
    rated_operating_current double precision,
    operational_temp_min double precision,
    operational_temp_max double precision,
    foundation_locations double precision[],
    centre_of_gravity double precision[],
    CONSTRAINT component_collection_point_fk_component_type_id_check CHECK ((fk_component_type_id = 5)),
    CONSTRAINT component_collection_point_input_connector_type_check CHECK (((input_connector_type)::text = ANY (ARRAY[('wet-mate'::character varying)::text, ('dry-mate'::character varying)::text]))),
    CONSTRAINT component_collection_point_output_connector_type_check CHECK (((output_connector_type)::text = ANY (ARRAY[('wet-mate'::character varying)::text, ('dry-mate'::character varying)::text])))
);


--
-- TOC entry 331 (class 1259 OID 21218)
-- Name: component_collection_point_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_collection_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5545 (class 0 OID 0)
-- Dependencies: 331
-- Name: component_collection_point_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_collection_point_id_seq OWNED BY reference.component_collection_point.id;


--
-- TOC entry 332 (class 1259 OID 21219)
-- Name: component_connector; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_connector (
    id integer NOT NULL,
    fk_component_discrete_id bigint,
    fk_component_type_id smallint,
    maximum_water_depth double precision,
    number_contacts integer,
    number_fibre_channels integer,
    mating_force double precision,
    demating_force double precision,
    rated_voltage_u0 double precision,
    rated_current double precision,
    cable_area_min double precision,
    cable_area_max double precision,
    operational_temp_min double precision,
    operational_temp_max double precision,
    CONSTRAINT component_connector_fk_component_type_id_check CHECK ((fk_component_type_id = ANY (ARRAY[6, 7])))
);


--
-- TOC entry 333 (class 1259 OID 21223)
-- Name: component_connector_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_connector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5546 (class 0 OID 0)
-- Dependencies: 333
-- Name: component_connector_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_connector_id_seq OWNED BY reference.component_connector.id;


--
-- TOC entry 334 (class 1259 OID 21224)
-- Name: component_continuous; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_continuous (
    id bigint NOT NULL,
    fk_component_id bigint,
    diameter double precision,
    dry_mass_per_unit_length double precision,
    wet_mass_per_unit_length double precision,
    cost_per_unit_length double precision
);


--
-- TOC entry 335 (class 1259 OID 21227)
-- Name: component_continuous_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_continuous_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5547 (class 0 OID 0)
-- Dependencies: 335
-- Name: component_continuous_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_continuous_id_seq OWNED BY reference.component_continuous.id;


--
-- TOC entry 336 (class 1259 OID 21228)
-- Name: component_discrete; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_discrete (
    id bigint NOT NULL,
    fk_component_id bigint,
    length double precision,
    width double precision,
    height double precision,
    dry_mass double precision,
    wet_mass double precision,
    cost double precision
);


--
-- TOC entry 337 (class 1259 OID 21231)
-- Name: component_discrete_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_discrete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5548 (class 0 OID 0)
-- Dependencies: 337
-- Name: component_discrete_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_discrete_id_seq OWNED BY reference.component_discrete.id;


--
-- TOC entry 338 (class 1259 OID 21232)
-- Name: component_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5549 (class 0 OID 0)
-- Dependencies: 338
-- Name: component_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_id_seq OWNED BY reference.component.id;


--
-- TOC entry 339 (class 1259 OID 21233)
-- Name: component_mooring_continuous; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_mooring_continuous (
    id integer NOT NULL,
    fk_component_continuous_id bigint,
    fk_component_type_id smallint,
    connecting_length double precision,
    minimum_breaking_load double precision,
    axial_stiffness double precision,
    CONSTRAINT component_mooring_continuous_fk_component_type_id_check CHECK ((fk_component_type_id = ANY (ARRAY[4, 8])))
);


--
-- TOC entry 340 (class 1259 OID 21237)
-- Name: component_mooring_continuous_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_mooring_continuous_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5550 (class 0 OID 0)
-- Dependencies: 340
-- Name: component_mooring_continuous_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_mooring_continuous_id_seq OWNED BY reference.component_mooring_continuous.id;


--
-- TOC entry 341 (class 1259 OID 21238)
-- Name: component_mooring_discrete; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_mooring_discrete (
    id integer NOT NULL,
    fk_component_discrete_id bigint,
    fk_component_type_id smallint,
    nominal_diameter double precision,
    connecting_length double precision,
    minimum_breaking_load double precision,
    axial_stiffness double precision,
    CONSTRAINT component_mooring_discrete_fk_component_type_id_check CHECK ((fk_component_type_id = ANY (ARRAY[11, 12])))
);


--
-- TOC entry 342 (class 1259 OID 21242)
-- Name: component_mooring_discrete_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_mooring_discrete_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5551 (class 0 OID 0)
-- Dependencies: 342
-- Name: component_mooring_discrete_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_mooring_discrete_id_seq OWNED BY reference.component_mooring_discrete.id;


--
-- TOC entry 343 (class 1259 OID 21243)
-- Name: component_pile; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_pile (
    id bigint NOT NULL,
    fk_component_continuous_id bigint,
    fk_component_type_id smallint,
    wall_thickness double precision,
    yield_stress double precision,
    youngs_modulus double precision,
    CONSTRAINT component_pile_fk_component_type_id_check CHECK ((fk_component_type_id = 9))
);


--
-- TOC entry 344 (class 1259 OID 21247)
-- Name: component_pile_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_pile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5552 (class 0 OID 0)
-- Dependencies: 344
-- Name: component_pile_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_pile_id_seq OWNED BY reference.component_pile.id;


--
-- TOC entry 345 (class 1259 OID 21248)
-- Name: component_rope; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_rope (
    id integer NOT NULL,
    fk_component_continuous_id bigint,
    fk_component_type_id smallint,
    material character varying(10),
    minimum_breaking_load double precision,
    rope_stiffness_curve double precision[],
    CONSTRAINT component_rope_fk_component_type_id_check CHECK ((fk_component_type_id = 10)),
    CONSTRAINT component_rope_material_check CHECK (((material)::text = ANY (ARRAY[('polyester'::character varying)::text, ('nylon'::character varying)::text, ('hmpe'::character varying)::text, ('steelite'::character varying)::text])))
);


--
-- TOC entry 346 (class 1259 OID 21255)
-- Name: component_rope_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_rope_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5553 (class 0 OID 0)
-- Dependencies: 346
-- Name: component_rope_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_rope_id_seq OWNED BY reference.component_rope.id;


--
-- TOC entry 347 (class 1259 OID 21256)
-- Name: component_shared; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_shared (
    id bigint NOT NULL,
    fk_component_id bigint,
    preparation_person_hours double precision,
    inspection_person_hours double precision,
    maintenance_person_hours double precision,
    replacement_person_hours double precision,
    ncfr_lower_bound double precision,
    ncfr_mean double precision,
    ncfr_upper_bound double precision,
    cfr_lower_bound double precision,
    cfr_mean double precision,
    cfr_upper_bound double precision,
    environmental_impact character varying(100)
);


--
-- TOC entry 348 (class 1259 OID 21259)
-- Name: component_shared_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_shared_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5554 (class 0 OID 0)
-- Dependencies: 348
-- Name: component_shared_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_shared_id_seq OWNED BY reference.component_shared.id;


--
-- TOC entry 349 (class 1259 OID 21260)
-- Name: component_transformer; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_transformer (
    id integer NOT NULL,
    fk_component_discrete_id bigint,
    fk_component_type_id smallint,
    maximum_water_depth double precision,
    power_rating double precision,
    impedance double precision,
    windings integer,
    voltage_primary_winding double precision,
    voltage_secondary_winding double precision,
    voltage_tertiary_winding double precision,
    operational_temp_min double precision,
    operational_temp_max double precision,
    CONSTRAINT component_transformer_fk_component_type_id_check CHECK ((fk_component_type_id = 13))
);


--
-- TOC entry 350 (class 1259 OID 21264)
-- Name: component_transformer_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_transformer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5555 (class 0 OID 0)
-- Dependencies: 350
-- Name: component_transformer_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_transformer_id_seq OWNED BY reference.component_transformer.id;


--
-- TOC entry 351 (class 1259 OID 21265)
-- Name: component_type; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.component_type (
    id smallint NOT NULL,
    description character varying(20)
);


--
-- TOC entry 352 (class 1259 OID 21268)
-- Name: component_type_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.component_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5556 (class 0 OID 0)
-- Dependencies: 352
-- Name: component_type_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.component_type_id_seq OWNED BY reference.component_type.id;


--
-- TOC entry 353 (class 1259 OID 21269)
-- Name: constants; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.constants (
    lock character(1) NOT NULL,
    gravity double precision,
    sea_water_density double precision,
    air_density double precision,
    steel_density double precision,
    concrete_density double precision,
    grout_density double precision,
    grout_strength double precision,
    CONSTRAINT constants_lock_check CHECK ((lock = 'X'::bpchar))
);


--
-- TOC entry 5557 (class 0 OID 0)
-- Dependencies: 353
-- Name: COLUMN constants.lock; Type: COMMENT; Schema: reference; Owner: -
--

COMMENT ON COLUMN reference.constants.lock IS 'Ensures table always has a single row. Value should be "X".';


--
-- TOC entry 354 (class 1259 OID 21273)
-- Name: constraint_type_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.constraint_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 32767
    CACHE 1;


--
-- TOC entry 355 (class 1259 OID 21274)
-- Name: equipment_cable_burial; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_cable_burial (
    id integer NOT NULL,
    description character varying(200),
    width double precision,
    length double precision,
    height double precision,
    dry_mass double precision,
    max_operating_depth double precision,
    tow_force_required double precision,
    jetting_capability boolean,
    ploughing_capability boolean,
    cutting_capability boolean,
    jetting_trench_depth double precision,
    ploughing_trench_depth double precision,
    cutting_trench_depth double precision,
    max_cable_diameter double precision,
    min_cable_bend_radius double precision,
    additional_equipment_footprint double precision,
    additional_equipment_mass double precision,
    equipment_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 356 (class 1259 OID 21277)
-- Name: equipment_cable_burial_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_cable_burial_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5558 (class 0 OID 0)
-- Dependencies: 356
-- Name: equipment_cable_burial_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_cable_burial_id_seq OWNED BY reference.equipment_cable_burial.id;


--
-- TOC entry 357 (class 1259 OID 21278)
-- Name: equipment_divers; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_divers (
    id integer NOT NULL,
    description character varying(200),
    max_operating_depth double precision,
    deployment_eq_footprint double precision,
    deployment_eq_mass double precision,
    total_day_rate double precision
);


--
-- TOC entry 358 (class 1259 OID 21281)
-- Name: equipment_divers_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_divers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5559 (class 0 OID 0)
-- Dependencies: 358
-- Name: equipment_divers_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_divers_id_seq OWNED BY reference.equipment_divers.id;


--
-- TOC entry 359 (class 1259 OID 21282)
-- Name: equipment_drilling_rigs; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_drilling_rigs (
    id integer NOT NULL,
    description character varying(200),
    diameter double precision,
    length double precision,
    dry_mass double precision,
    max_water_depth double precision,
    max_drilling_depth double precision,
    drilling_diameter_range double precision,
    additional_equipment_footprint double precision,
    additional_equipment_mass double precision,
    equipment_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 360 (class 1259 OID 21285)
-- Name: equipment_drilling_rigs_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_drilling_rigs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5560 (class 0 OID 0)
-- Dependencies: 360
-- Name: equipment_drilling_rigs_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_drilling_rigs_id_seq OWNED BY reference.equipment_drilling_rigs.id;


--
-- TOC entry 361 (class 1259 OID 21286)
-- Name: equipment_excavating; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_excavating (
    id integer NOT NULL,
    description character varying(200),
    width double precision,
    height double precision,
    dry_mass double precision,
    depth_rating double precision,
    equipment_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 362 (class 1259 OID 21289)
-- Name: equipment_excavating_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_excavating_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5561 (class 0 OID 0)
-- Dependencies: 362
-- Name: equipment_excavating_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_excavating_id_seq OWNED BY reference.equipment_excavating.id;


--
-- TOC entry 363 (class 1259 OID 21290)
-- Name: equipment_hammer; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_hammer (
    id integer NOT NULL,
    description character varying(200),
    length double precision,
    dry_mass double precision,
    depth_rating double precision,
    min_pile_diameter double precision,
    max_pile_diameter double precision,
    additional_equipment_footprint double precision,
    additional_equipment_mass double precision,
    equipment_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 364 (class 1259 OID 21293)
-- Name: equipment_hammer_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_hammer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5562 (class 0 OID 0)
-- Dependencies: 364
-- Name: equipment_hammer_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_hammer_id_seq OWNED BY reference.equipment_hammer.id;


--
-- TOC entry 365 (class 1259 OID 21294)
-- Name: equipment_mattress; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_mattress (
    id integer NOT NULL,
    description character varying(200),
    width double precision,
    length double precision,
    thickness double precision,
    dry_mass double precision,
    cost double precision
);


--
-- TOC entry 366 (class 1259 OID 21297)
-- Name: equipment_mattress_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_mattress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5563 (class 0 OID 0)
-- Dependencies: 366
-- Name: equipment_mattress_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_mattress_id_seq OWNED BY reference.equipment_mattress.id;


--
-- TOC entry 367 (class 1259 OID 21298)
-- Name: equipment_rock_filter_bags; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_rock_filter_bags (
    id integer NOT NULL,
    description character varying(200),
    diameter double precision,
    height double precision,
    dry_mass double precision,
    cost double precision
);


--
-- TOC entry 368 (class 1259 OID 21301)
-- Name: equipment_rock_filter_bags_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_rock_filter_bags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5564 (class 0 OID 0)
-- Dependencies: 368
-- Name: equipment_rock_filter_bags_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_rock_filter_bags_id_seq OWNED BY reference.equipment_rock_filter_bags.id;


--
-- TOC entry 369 (class 1259 OID 21302)
-- Name: equipment_rov; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_rov (
    id integer NOT NULL,
    description character varying(200),
    rov_class character varying(16),
    width double precision,
    length double precision,
    height double precision,
    dry_mass double precision,
    depth_rating double precision,
    payload double precision,
    manipulator_grip_force double precision,
    additional_equipment_footprint double precision,
    additional_equipment_mass double precision,
    additional_equipment_supervisors integer,
    additional_equipment_technicians integer,
    equipment_day_rate double precision,
    supervisor_day_rate double precision,
    technician_day_rate double precision,
    CONSTRAINT equipment_rov_rov_class_check CHECK (((rov_class)::text = ANY (ARRAY[('Inspection class'::character varying)::text, ('Workclass'::character varying)::text])))
);


--
-- TOC entry 370 (class 1259 OID 21306)
-- Name: equipment_rov_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_rov_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5565 (class 0 OID 0)
-- Dependencies: 370
-- Name: equipment_rov_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_rov_id_seq OWNED BY reference.equipment_rov.id;


--
-- TOC entry 371 (class 1259 OID 21307)
-- Name: equipment_soil_lay_rates; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_soil_lay_rates (
    equipment_type character varying(100) NOT NULL,
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
-- TOC entry 372 (class 1259 OID 21310)
-- Name: equipment_soil_penet_rates; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_soil_penet_rates (
    equipment_type character varying(100) NOT NULL,
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
-- TOC entry 373 (class 1259 OID 21313)
-- Name: equipment_split_pipe; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_split_pipe (
    id integer NOT NULL,
    description character varying(200),
    length double precision,
    cost double precision
);


--
-- TOC entry 374 (class 1259 OID 21316)
-- Name: equipment_split_pipe_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_split_pipe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5566 (class 0 OID 0)
-- Dependencies: 374
-- Name: equipment_split_pipe_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_split_pipe_id_seq OWNED BY reference.equipment_split_pipe.id;


--
-- TOC entry 375 (class 1259 OID 21317)
-- Name: equipment_vibro_driver; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.equipment_vibro_driver (
    id integer NOT NULL,
    description character varying(200),
    width double precision,
    length double precision,
    height double precision,
    vibro_driver_mass double precision,
    clamp_mass double precision,
    min_pile_diameter double precision,
    max_pile_diameter double precision,
    max_pile_mass double precision,
    additional_equipment_footprint double precision,
    additional_equipment_mass double precision,
    equipment_day_rate double precision,
    personnel_day_rate double precision
);


--
-- TOC entry 376 (class 1259 OID 21320)
-- Name: equipment_vibro_driver_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.equipment_vibro_driver_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5567 (class 0 OID 0)
-- Dependencies: 376
-- Name: equipment_vibro_driver_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.equipment_vibro_driver_id_seq OWNED BY reference.equipment_vibro_driver.id;


--
-- TOC entry 377 (class 1259 OID 21321)
-- Name: operations_limit_cs; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.operations_limit_cs (
    id smallint NOT NULL,
    fk_operations_id smallint,
    cs_limit double precision
);


--
-- TOC entry 378 (class 1259 OID 21324)
-- Name: operations_limit_cs_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.operations_limit_cs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5568 (class 0 OID 0)
-- Dependencies: 378
-- Name: operations_limit_cs_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.operations_limit_cs_id_seq OWNED BY reference.operations_limit_cs.id;


--
-- TOC entry 379 (class 1259 OID 21325)
-- Name: operations_limit_hs; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.operations_limit_hs (
    id smallint NOT NULL,
    fk_operations_id smallint,
    hs_limit double precision
);


--
-- TOC entry 380 (class 1259 OID 21328)
-- Name: operations_limit_hs_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.operations_limit_hs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5569 (class 0 OID 0)
-- Dependencies: 380
-- Name: operations_limit_hs_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.operations_limit_hs_id_seq OWNED BY reference.operations_limit_hs.id;


--
-- TOC entry 381 (class 1259 OID 21329)
-- Name: operations_limit_tp; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.operations_limit_tp (
    id smallint NOT NULL,
    fk_operations_id smallint,
    tp_limit double precision
);


--
-- TOC entry 382 (class 1259 OID 21332)
-- Name: operations_limit_tp_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.operations_limit_tp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5570 (class 0 OID 0)
-- Dependencies: 382
-- Name: operations_limit_tp_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.operations_limit_tp_id_seq OWNED BY reference.operations_limit_tp.id;


--
-- TOC entry 383 (class 1259 OID 21333)
-- Name: operations_limit_ws; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.operations_limit_ws (
    id smallint NOT NULL,
    fk_operations_id smallint,
    ws_limit double precision
);


--
-- TOC entry 384 (class 1259 OID 21336)
-- Name: operations_limit_ws_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.operations_limit_ws_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5571 (class 0 OID 0)
-- Dependencies: 384
-- Name: operations_limit_ws_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.operations_limit_ws_id_seq OWNED BY reference.operations_limit_ws.id;


--
-- TOC entry 385 (class 1259 OID 21337)
-- Name: operations_type; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.operations_type (
    id smallint NOT NULL,
    description character varying(150)
);


--
-- TOC entry 386 (class 1259 OID 21340)
-- Name: operations_type_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.operations_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5572 (class 0 OID 0)
-- Dependencies: 386
-- Name: operations_type_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.operations_type_id_seq OWNED BY reference.operations_type.id;


--
-- TOC entry 387 (class 1259 OID 21341)
-- Name: ports; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ports (
    id integer NOT NULL,
    name character varying(100),
    country character varying(100),
    type_of_terminal character varying(8),
    entrance_width double precision,
    terminal_length double precision,
    terminal_load_bearing double precision,
    terminal_draught double precision,
    terminal_area double precision,
    max_gantry_crane_lift_capacity double precision,
    max_tower_crane_lift_capacity double precision,
    jacking_capability boolean,
    point_location public.geometry(Point,4326),
    CONSTRAINT ports_type_of_terminal_check CHECK (((type_of_terminal)::text = ANY (ARRAY[('Quay'::character varying)::text, ('Dry-dock'::character varying)::text])))
);


--
-- TOC entry 388 (class 1259 OID 21347)
-- Name: ports_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.ports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5573 (class 0 OID 0)
-- Dependencies: 388
-- Name: ports_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.ports_id_seq OWNED BY reference.ports.id;


--
-- TOC entry 389 (class 1259 OID 21348)
-- Name: ref_current_drag_coef_rect; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_current_drag_coef_rect (
    width_length double precision NOT NULL,
    thickness_width double precision
);


--
-- TOC entry 390 (class 1259 OID 21351)
-- Name: ref_drag_coef_cyl; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_drag_coef_cyl (
    reynolds_number double precision NOT NULL,
    smooth double precision,
    roughness_1e_5 double precision,
    roughness_1e_2 double precision
);


--
-- TOC entry 391 (class 1259 OID 21354)
-- Name: ref_drift_coef_float_rect; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_drift_coef_float_rect (
    wavenumber_draft double precision NOT NULL,
    reflection_coefficient double precision
);


--
-- TOC entry 392 (class 1259 OID 21357)
-- Name: ref_holding_capacity_factors_plate_anchors; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_holding_capacity_factors_plate_anchors (
    relative_embedment_depth double precision NOT NULL,
    drained_friction_angle_20deg double precision,
    drained_friction_angle_25deg double precision,
    drained_friction_angle_30deg double precision,
    drained_friction_angle_35deg double precision,
    drained_friction_angle_40deg double precision
);


--
-- TOC entry 393 (class 1259 OID 21360)
-- Name: ref_line_bcf; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_line_bcf (
    soil_friction_angle double precision NOT NULL,
    bearing_capacity_factor double precision
);


--
-- TOC entry 394 (class 1259 OID 21363)
-- Name: ref_pile_deflection_coefficients; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_pile_deflection_coefficients (
    depth_coefficient double precision NOT NULL,
    coefficient_ay double precision,
    coefficient_by double precision
);


--
-- TOC entry 395 (class 1259 OID 21366)
-- Name: ref_pile_limiting_values_noncalcareous; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_pile_limiting_values_noncalcareous (
    soil_friction_angle double precision NOT NULL,
    friction_angle_sand_pile double precision,
    bearing_capacity_factor double precision,
    max_unit_skin_friction double precision,
    max_end_bearing_capacity double precision
);


--
-- TOC entry 396 (class 1259 OID 21369)
-- Name: ref_pile_moment_coefficient_sam; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_pile_moment_coefficient_sam (
    depth_coefficient double precision NOT NULL,
    pile_length_relative_soil_pile_stiffness_10 double precision,
    pile_length_relative_soil_pile_stiffness_5 double precision,
    pile_length_relative_soil_pile_stiffness_4 double precision,
    pile_length_relative_soil_pile_stiffness_3 double precision,
    pile_length_relative_soil_pile_stiffness_2 double precision
);


--
-- TOC entry 397 (class 1259 OID 21372)
-- Name: ref_pile_moment_coefficient_sbm; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_pile_moment_coefficient_sbm (
    depth_coefficient double precision NOT NULL,
    pile_length_relative_soil_pile_stiffness_10 double precision,
    pile_length_relative_soil_pile_stiffness_5 double precision,
    pile_length_relative_soil_pile_stiffness_4 double precision,
    pile_length_relative_soil_pile_stiffness_3 double precision,
    pile_length_relative_soil_pile_stiffness_2 double precision
);


--
-- TOC entry 398 (class 1259 OID 21375)
-- Name: ref_rectangular_wave_inertia; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_rectangular_wave_inertia (
    "width/length" double precision NOT NULL,
    inertia_coefficients double precision
);


--
-- TOC entry 399 (class 1259 OID 21378)
-- Name: ref_subgrade_reaction_coefficient_cohesionless; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_subgrade_reaction_coefficient_cohesionless (
    allowable_deflection_diameter double precision NOT NULL,
    relative_density_35 double precision,
    relative_density_50 double precision,
    relative_density_65 double precision,
    relative_density_85 double precision
);


--
-- TOC entry 400 (class 1259 OID 21381)
-- Name: ref_subgrade_reaction_coefficient_k1_cohesive; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_subgrade_reaction_coefficient_k1_cohesive (
    allowable_deflection_diameter double precision NOT NULL,
    softclay double precision,
    stiffclay double precision
);


--
-- TOC entry 401 (class 1259 OID 21384)
-- Name: ref_superline_nylon; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_superline_nylon (
    extension double precision NOT NULL,
    load_mbl double precision
);


--
-- TOC entry 402 (class 1259 OID 21387)
-- Name: ref_superline_polyester; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_superline_polyester (
    extension double precision NOT NULL,
    load_mbl double precision
);


--
-- TOC entry 403 (class 1259 OID 21390)
-- Name: ref_superline_steelite; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_superline_steelite (
    extension double precision NOT NULL,
    load_mbl double precision
);


--
-- TOC entry 404 (class 1259 OID 21393)
-- Name: ref_wake_amplification_factor_cyl; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_wake_amplification_factor_cyl (
    kc_steady_drag_coefficient double precision NOT NULL,
    amplification_factor_for_smooth_cylinders double precision,
    amplification_factor_for_rough_cylinders double precision
);


--
-- TOC entry 405 (class 1259 OID 21396)
-- Name: ref_wind_drag_coef_rect; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.ref_wind_drag_coef_rect (
    width_length double precision NOT NULL,
    height_breadth_between_0_1 double precision,
    height_breadth_less_1 double precision,
    height_breadth_less_2 double precision,
    height_breadth_less_4 double precision,
    height_breadth_less_6 double precision,
    height_breadth_less_10 double precision,
    height_breadth_less_20 double precision
);


--
-- TOC entry 406 (class 1259 OID 21399)
-- Name: soil_type_geotechnical_properties; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.soil_type_geotechnical_properties (
    fk_soil_type_id integer NOT NULL,
    drained_soil_friction_angle double precision,
    relative_soil_density double precision,
    buoyant_unit_weight_of_soil double precision,
    effective_drained_cohesion double precision,
    seafloor_friction_coefficient double precision,
    soil_sensitivity double precision,
    rock_compressive_strength double precision,
    undrained_soil_shear_strength_constant_term double precision,
    undrained_soil_shear_strength_depth_dependent_term double precision
);


--
-- TOC entry 407 (class 1259 OID 21402)
-- Name: soil_type_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.soil_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5574 (class 0 OID 0)
-- Dependencies: 407
-- Name: soil_type_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.soil_type_id_seq OWNED BY reference.soil_type.id;


--
-- TOC entry 408 (class 1259 OID 21403)
-- Name: vehicle; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle (
    id bigint NOT NULL,
    description character varying(200)
);


--
-- TOC entry 409 (class 1259 OID 21406)
-- Name: vehicle_helicopter; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_helicopter (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    deck_space double precision,
    max_deck_load_pressure double precision,
    max_cargo_mass double precision,
    crane_max_load_mass double precision,
    external_personel integer,
    CONSTRAINT vehicle_helicopter_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = 9))
);


--
-- TOC entry 410 (class 1259 OID 21410)
-- Name: vehicle_helicopter_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_helicopter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5575 (class 0 OID 0)
-- Dependencies: 410
-- Name: vehicle_helicopter_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_helicopter_id_seq OWNED BY reference.vehicle_helicopter.id;


--
-- TOC entry 411 (class 1259 OID 21411)
-- Name: vehicle_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5576 (class 0 OID 0)
-- Dependencies: 411
-- Name: vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_id_seq OWNED BY reference.vehicle.id;


--
-- TOC entry 412 (class 1259 OID 21412)
-- Name: vehicle_shared; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_shared (
    id bigint NOT NULL,
    fk_vehicle_id bigint,
    gross_tonnage double precision,
    length double precision,
    consumption double precision,
    transit_speed double precision,
    transit_max_hs double precision,
    transit_max_tp double precision,
    transit_max_cs double precision,
    transit_max_ws double precision,
    mobilisation_time double precision,
    mobilisation_percentage_cost double precision,
    min_day_rate double precision,
    max_day_rate double precision
);


--
-- TOC entry 413 (class 1259 OID 21415)
-- Name: vehicle_shared_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_shared_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5577 (class 0 OID 0)
-- Dependencies: 413
-- Name: vehicle_shared_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_shared_id_seq OWNED BY reference.vehicle_shared.id;


--
-- TOC entry 414 (class 1259 OID 21416)
-- Name: vehicle_type; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_type (
    id smallint NOT NULL,
    description character varying(40)
);


--
-- TOC entry 415 (class 1259 OID 21419)
-- Name: vehicle_type_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5578 (class 0 OID 0)
-- Dependencies: 415
-- Name: vehicle_type_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_type_id_seq OWNED BY reference.vehicle_type.id;


--
-- TOC entry 416 (class 1259 OID 21420)
-- Name: vehicle_vessel_anchor_handling; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_vessel_anchor_handling (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    beam double precision,
    max_draft double precision,
    consumption_towing double precision,
    deck_space double precision,
    max_deck_load_pressure double precision,
    max_cargo_mass double precision,
    crane_max_load_mass double precision,
    bollard_pull double precision,
    anchor_handling_drum_capacity double precision,
    anchor_handling_winch_rated_pull double precision,
    external_personel integer,
    towing_max_hs double precision,
    CONSTRAINT vehicle_vessel_anchor_handling_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = ANY (ARRAY[1, 12])))
);


--
-- TOC entry 417 (class 1259 OID 21424)
-- Name: vehicle_vessel_anchor_handling_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_vessel_anchor_handling_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5579 (class 0 OID 0)
-- Dependencies: 417
-- Name: vehicle_vessel_anchor_handling_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_vessel_anchor_handling_id_seq OWNED BY reference.vehicle_vessel_anchor_handling.id;


--
-- TOC entry 418 (class 1259 OID 21425)
-- Name: vehicle_vessel_cable_laying; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_vessel_cable_laying (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    beam double precision,
    max_draft double precision,
    deck_space double precision,
    max_deck_load_pressure double precision,
    max_cargo_mass double precision,
    crane_max_load_mass double precision,
    bollard_pull double precision,
    number_turntables integer,
    turntable_max_load_mass double precision,
    turntable_inner_diameter double precision,
    cable_splice_capabilities boolean,
    dynamic_positioning_capabilities boolean,
    external_personel integer,
    CONSTRAINT vehicle_vessel_cable_laying_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = ANY (ARRAY[3, 4])))
);


--
-- TOC entry 419 (class 1259 OID 21429)
-- Name: vehicle_vessel_cable_laying_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_vessel_cable_laying_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5580 (class 0 OID 0)
-- Dependencies: 419
-- Name: vehicle_vessel_cable_laying_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_vessel_cable_laying_id_seq OWNED BY reference.vehicle_vessel_cable_laying.id;


--
-- TOC entry 420 (class 1259 OID 21430)
-- Name: vehicle_vessel_cargo; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_vessel_cargo (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    beam double precision,
    max_draft double precision,
    deck_space double precision,
    max_deck_load_pressure double precision,
    max_cargo_mass double precision,
    crane_max_load_mass double precision,
    dynamic_positioning_capabilities boolean,
    external_personel integer,
    CONSTRAINT vehicle_vessel_cargo_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = ANY (ARRAY[2, 5, 6, 7, 8])))
);


--
-- TOC entry 421 (class 1259 OID 21434)
-- Name: vehicle_vessel_cargo_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_vessel_cargo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5581 (class 0 OID 0)
-- Dependencies: 421
-- Name: vehicle_vessel_cargo_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_vessel_cargo_id_seq OWNED BY reference.vehicle_vessel_cargo.id;


--
-- TOC entry 422 (class 1259 OID 21435)
-- Name: vehicle_vessel_jackup; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_vessel_jackup (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    beam double precision,
    max_draft double precision,
    deck_space double precision,
    max_deck_load_pressure double precision,
    max_cargo_mass double precision,
    crane_max_load_mass double precision,
    dynamic_positioning_capabilities boolean,
    jackup_max_water_depth double precision,
    jackup_speed_down double precision,
    jackup_max_payload_mass double precision,
    external_personel integer,
    jacking_max_hs double precision,
    jacking_max_tp double precision,
    jacking_max_cs double precision,
    jacking_max_ws double precision,
    CONSTRAINT vehicle_vessel_jackup_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = ANY (ARRAY[10, 11])))
);


--
-- TOC entry 423 (class 1259 OID 21439)
-- Name: vehicle_vessel_jackup_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_vessel_jackup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5582 (class 0 OID 0)
-- Dependencies: 423
-- Name: vehicle_vessel_jackup_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_vessel_jackup_id_seq OWNED BY reference.vehicle_vessel_jackup.id;


--
-- TOC entry 424 (class 1259 OID 21440)
-- Name: vehicle_vessel_tugboat; Type: TABLE; Schema: reference; Owner: -
--

CREATE TABLE reference.vehicle_vessel_tugboat (
    id integer NOT NULL,
    fk_vehicle_id bigint,
    fk_vehicle_type_id smallint,
    beam double precision,
    max_draft double precision,
    consumption_towing double precision,
    bollard_pull double precision,
    CONSTRAINT vehicle_vessel_tugboat_fk_vehicle_type_id_check CHECK ((fk_vehicle_type_id = 13))
);


--
-- TOC entry 425 (class 1259 OID 21444)
-- Name: vehicle_vessel_tugboat_id_seq; Type: SEQUENCE; Schema: reference; Owner: -
--

CREATE SEQUENCE reference.vehicle_vessel_tugboat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5583 (class 0 OID 0)
-- Dependencies: 425
-- Name: vehicle_vessel_tugboat_id_seq; Type: SEQUENCE OWNED BY; Schema: reference; Owner: -
--

ALTER SEQUENCE reference.vehicle_vessel_tugboat_id_seq OWNED BY reference.vehicle_vessel_tugboat.id;


--
-- TOC entry 426 (class 1259 OID 21445)
-- Name: view_component_cable_dynamic; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_cable_dynamic AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_cable.minimum_breaking_load,
    component_cable.minimum_bend_radius,
    component_cable.number_conductors,
    component_cable.number_fibre_channels,
    component_cable.resistance_dc_20,
    component_cable.resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.rated_current_air,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube,
    component_cable.rated_voltage_u0,
    component_cable.operational_temp_max,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_cable
     JOIN reference.component_continuous ON ((component_cable.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_cable.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'cable dynamic'::text);


--
-- TOC entry 427 (class 1259 OID 21450)
-- Name: view_component_cable_static; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_cable_static AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_cable.minimum_breaking_load,
    component_cable.minimum_bend_radius,
    component_cable.number_conductors,
    component_cable.number_fibre_channels,
    component_cable.resistance_dc_20,
    component_cable.resistance_ac_90,
    component_cable.inductive_reactance,
    component_cable.capacitance,
    component_cable.rated_current_air,
    component_cable.rated_current_buried,
    component_cable.rated_current_jtube,
    component_cable.rated_voltage_u0,
    component_cable.operational_temp_max,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_cable
     JOIN reference.component_continuous ON ((component_cable.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_cable.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'cable static'::text);


--
-- TOC entry 428 (class 1259 OID 21455)
-- Name: view_component_collection_point; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_collection_point AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_collection_point.wet_frontal_area,
    component_collection_point.dry_frontal_area,
    component_collection_point.wet_beam_area,
    component_collection_point.dry_beam_area,
    component_collection_point.maximum_water_depth,
    component_collection_point.orientation_angle,
    component_collection_point.input_lines,
    component_collection_point.output_lines,
    component_collection_point.input_connector_type,
    component_collection_point.output_connector_type,
    component_collection_point.number_fibre_channels,
    component_collection_point.voltage_primary_winding,
    component_collection_point.voltage_secondary_winding,
    component_collection_point.rated_operating_current,
    component_collection_point.operational_temp_min,
    component_collection_point.operational_temp_max,
    component_collection_point.foundation_locations,
    component_collection_point.centre_of_gravity,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM (((reference.component_collection_point
     JOIN reference.component_discrete ON ((component_collection_point.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)));


--
-- TOC entry 429 (class 1259 OID 21460)
-- Name: view_component_connector_drymate; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_connector_drymate AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_connector.maximum_water_depth,
    component_connector.number_contacts,
    component_connector.number_fibre_channels,
    component_connector.mating_force,
    component_connector.demating_force,
    component_connector.rated_voltage_u0,
    component_connector.rated_current,
    component_connector.cable_area_min,
    component_connector.cable_area_max,
    component_connector.operational_temp_min,
    component_connector.operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_connector
     JOIN reference.component_discrete ON ((component_connector.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_connector.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'connector dry-mate'::text);


--
-- TOC entry 430 (class 1259 OID 21465)
-- Name: view_component_connector_wetmate; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_connector_wetmate AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_connector.maximum_water_depth,
    component_connector.number_contacts,
    component_connector.number_fibre_channels,
    component_connector.mating_force,
    component_connector.demating_force,
    component_connector.rated_voltage_u0,
    component_connector.rated_current,
    component_connector.cable_area_min,
    component_connector.cable_area_max,
    component_connector.operational_temp_min,
    component_connector.operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_connector
     JOIN reference.component_discrete ON ((component_connector.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_connector.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'connector wet-mate'::text);


--
-- TOC entry 431 (class 1259 OID 21470)
-- Name: view_component_foundations_anchor; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_foundations_anchor AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_anchor.connecting_size,
    component_anchor.minimum_breaking_load,
    component_anchor.axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM (((reference.component_anchor
     JOIN reference.component_discrete ON ((component_anchor.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)));


--
-- TOC entry 432 (class 1259 OID 21475)
-- Name: view_component_foundations_anchor_coefs; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_foundations_anchor_coefs AS
 SELECT component.id AS component_id,
    component_anchor.soft_holding_cap_coef_1,
    component_anchor.soft_holding_cap_coef_2,
    component_anchor.soft_penetration_coef_1,
    component_anchor.soft_penetration_coef_2,
    component_anchor.sand_holding_cap_coef_1,
    component_anchor.sand_holding_cap_coef_2,
    component_anchor.sand_penetration_coef_1,
    component_anchor.sand_penetration_coef_2
   FROM ((reference.component_anchor
     JOIN reference.component_discrete ON ((component_anchor.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)));


--
-- TOC entry 433 (class 1259 OID 21480)
-- Name: view_component_foundations_pile; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_foundations_pile AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_pile.wall_thickness,
    component_pile.yield_stress,
    component_pile.youngs_modulus,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM (((reference.component_pile
     JOIN reference.component_continuous ON ((component_pile.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)));


--
-- TOC entry 434 (class 1259 OID 21485)
-- Name: view_component_moorings_chain; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_moorings_chain AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_mooring_continuous.connecting_length,
    component_mooring_continuous.minimum_breaking_load,
    component_mooring_continuous.axial_stiffness,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_mooring_continuous
     JOIN reference.component_continuous ON ((component_mooring_continuous.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_mooring_continuous.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'chain'::text);


--
-- TOC entry 435 (class 1259 OID 21490)
-- Name: view_component_moorings_forerunner; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_moorings_forerunner AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_mooring_continuous.connecting_length,
    component_mooring_continuous.minimum_breaking_load,
    component_mooring_continuous.axial_stiffness,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_mooring_continuous
     JOIN reference.component_continuous ON ((component_mooring_continuous.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_mooring_continuous.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'forerunner'::text);


--
-- TOC entry 436 (class 1259 OID 21495)
-- Name: view_component_moorings_rope; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_moorings_rope AS
 SELECT component.id AS component_id,
    component.description,
    component_continuous.diameter,
    component_continuous.dry_mass_per_unit_length,
    component_continuous.wet_mass_per_unit_length,
    component_rope.material,
    component_rope.minimum_breaking_load,
    component_rope.rope_stiffness_curve,
    component_continuous.cost_per_unit_length,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM (((reference.component_rope
     JOIN reference.component_continuous ON ((component_rope.fk_component_continuous_id = component_continuous.id)))
     JOIN reference.component_shared ON ((component_continuous.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_continuous.fk_component_id = component.id)));


--
-- TOC entry 437 (class 1259 OID 21500)
-- Name: view_component_moorings_shackle; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_moorings_shackle AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_mooring_discrete.nominal_diameter,
    component_mooring_discrete.connecting_length,
    component_mooring_discrete.minimum_breaking_load,
    component_mooring_discrete.axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_mooring_discrete
     JOIN reference.component_discrete ON ((component_mooring_discrete.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_mooring_discrete.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'shackle'::text);


--
-- TOC entry 438 (class 1259 OID 21505)
-- Name: view_component_moorings_swivel; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_moorings_swivel AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_mooring_discrete.nominal_diameter,
    component_mooring_discrete.connecting_length,
    component_mooring_discrete.minimum_breaking_load,
    component_mooring_discrete.axial_stiffness,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM ((((reference.component_mooring_discrete
     JOIN reference.component_discrete ON ((component_mooring_discrete.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)))
     JOIN reference.component_type ON ((component_mooring_discrete.fk_component_type_id = component_type.id)))
  WHERE ((component_type.description)::text = 'swivel'::text);


--
-- TOC entry 439 (class 1259 OID 21510)
-- Name: view_component_transformer; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_component_transformer AS
 SELECT component.id AS component_id,
    component.description,
    component_discrete.width,
    component_discrete.length AS depth,
    component_discrete.height,
    component_discrete.dry_mass,
    component_discrete.wet_mass,
    component_transformer.maximum_water_depth,
    component_transformer.power_rating,
    component_transformer.impedance,
    component_transformer.windings,
    component_transformer.voltage_primary_winding,
    component_transformer.voltage_secondary_winding,
    component_transformer.voltage_tertiary_winding,
    component_transformer.operational_temp_min,
    component_transformer.operational_temp_max,
    component_discrete.cost,
    component_shared.preparation_person_hours,
    component_shared.inspection_person_hours,
    component_shared.maintenance_person_hours,
    component_shared.replacement_person_hours,
    component_shared.ncfr_lower_bound,
    component_shared.ncfr_mean,
    component_shared.ncfr_upper_bound,
    component_shared.cfr_lower_bound,
    component_shared.cfr_mean,
    component_shared.cfr_upper_bound,
    component_shared.environmental_impact
   FROM (((reference.component_transformer
     JOIN reference.component_discrete ON ((component_transformer.fk_component_discrete_id = component_discrete.id)))
     JOIN reference.component_shared ON ((component_discrete.fk_component_id = component_shared.fk_component_id)))
     JOIN reference.component ON ((component_discrete.fk_component_id = component.id)));


--
-- TOC entry 440 (class 1259 OID 21515)
-- Name: view_operations_limit_cs; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_operations_limit_cs AS
 SELECT operations_type.description AS operations_type,
    operations_limit_cs.cs_limit
   FROM (reference.operations_limit_cs
     JOIN reference.operations_type ON ((operations_limit_cs.fk_operations_id = operations_type.id)));


--
-- TOC entry 441 (class 1259 OID 21519)
-- Name: view_operations_limit_hs; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_operations_limit_hs AS
 SELECT operations_type.description AS operations_type,
    operations_limit_hs.hs_limit
   FROM (reference.operations_limit_hs
     JOIN reference.operations_type ON ((operations_limit_hs.fk_operations_id = operations_type.id)));


--
-- TOC entry 442 (class 1259 OID 21523)
-- Name: view_operations_limit_tp; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_operations_limit_tp AS
 SELECT operations_type.description AS operations_type,
    operations_limit_tp.tp_limit
   FROM (reference.operations_limit_tp
     JOIN reference.operations_type ON ((operations_limit_tp.fk_operations_id = operations_type.id)));


--
-- TOC entry 443 (class 1259 OID 21527)
-- Name: view_operations_limit_ws; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_operations_limit_ws AS
 SELECT operations_type.description AS operations_type,
    operations_limit_ws.ws_limit
   FROM (reference.operations_limit_ws
     JOIN reference.operations_type ON ((operations_limit_ws.fk_operations_id = operations_type.id)));


--
-- TOC entry 444 (class 1259 OID 21531)
-- Name: view_soil_type_geotechnical_properties; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_soil_type_geotechnical_properties AS
 SELECT soil_type.description AS soil_type,
    soil_type_geotechnical_properties.drained_soil_friction_angle,
    soil_type_geotechnical_properties.relative_soil_density,
    soil_type_geotechnical_properties.buoyant_unit_weight_of_soil,
    soil_type_geotechnical_properties.undrained_soil_shear_strength_constant_term,
    soil_type_geotechnical_properties.undrained_soil_shear_strength_depth_dependent_term,
    soil_type_geotechnical_properties.effective_drained_cohesion,
    soil_type_geotechnical_properties.seafloor_friction_coefficient,
    soil_type_geotechnical_properties.soil_sensitivity,
    soil_type_geotechnical_properties.rock_compressive_strength
   FROM (reference.soil_type_geotechnical_properties
     JOIN reference.soil_type ON ((soil_type_geotechnical_properties.fk_soil_type_id = soil_type.id)));


--
-- TOC entry 445 (class 1259 OID 21535)
-- Name: view_vehicle_helicopter; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_helicopter AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_helicopter.deck_space,
    vehicle_helicopter.max_deck_load_pressure,
    vehicle_helicopter.max_cargo_mass,
    vehicle_helicopter.crane_max_load_mass,
    vehicle_helicopter.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM ((reference.vehicle_helicopter
     JOIN reference.vehicle_shared ON ((vehicle_helicopter.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)));


--
-- TOC entry 446 (class 1259 OID 21540)
-- Name: view_vehicle_vessel_ahts; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_ahts AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_anchor_handling.beam,
    vehicle_vessel_anchor_handling.max_draft,
    vehicle_shared.consumption,
    vehicle_vessel_anchor_handling.consumption_towing,
    vehicle_shared.transit_speed,
    vehicle_vessel_anchor_handling.deck_space,
    vehicle_vessel_anchor_handling.max_deck_load_pressure,
    vehicle_vessel_anchor_handling.max_cargo_mass,
    vehicle_vessel_anchor_handling.crane_max_load_mass,
    vehicle_vessel_anchor_handling.bollard_pull,
    vehicle_vessel_anchor_handling.anchor_handling_drum_capacity,
    vehicle_vessel_anchor_handling.anchor_handling_winch_rated_pull,
    vehicle_vessel_anchor_handling.external_personel,
    vehicle_vessel_anchor_handling.towing_max_hs,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_anchor_handling
     JOIN reference.vehicle_shared ON ((vehicle_vessel_anchor_handling.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_anchor_handling.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'anchor handling tug supply vessel'::text);


--
-- TOC entry 447 (class 1259 OID 21545)
-- Name: view_vehicle_vessel_barge; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_barge AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cargo.beam,
    vehicle_vessel_cargo.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cargo.deck_space,
    vehicle_vessel_cargo.max_deck_load_pressure,
    vehicle_vessel_cargo.max_cargo_mass,
    vehicle_vessel_cargo.crane_max_load_mass,
    vehicle_vessel_cargo.dynamic_positioning_capabilities,
    vehicle_vessel_cargo.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cargo
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'barge'::text);


--
-- TOC entry 448 (class 1259 OID 21550)
-- Name: view_vehicle_vessel_clb; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_clb AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cable_laying.beam,
    vehicle_vessel_cable_laying.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cable_laying.deck_space,
    vehicle_vessel_cable_laying.max_deck_load_pressure,
    vehicle_vessel_cable_laying.max_cargo_mass,
    vehicle_vessel_cable_laying.crane_max_load_mass,
    vehicle_vessel_cable_laying.number_turntables,
    vehicle_vessel_cable_laying.turntable_max_load_mass,
    vehicle_vessel_cable_laying.turntable_inner_diameter,
    vehicle_vessel_cable_laying.cable_splice_capabilities,
    vehicle_vessel_cable_laying.dynamic_positioning_capabilities,
    vehicle_vessel_cable_laying.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cable_laying
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cable_laying.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cable_laying.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'cable laying barge'::text);


--
-- TOC entry 449 (class 1259 OID 21555)
-- Name: view_vehicle_vessel_clv; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_clv AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cable_laying.beam,
    vehicle_vessel_cable_laying.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cable_laying.deck_space,
    vehicle_vessel_cable_laying.max_deck_load_pressure,
    vehicle_vessel_cable_laying.max_cargo_mass,
    vehicle_vessel_cable_laying.crane_max_load_mass,
    vehicle_vessel_cable_laying.bollard_pull,
    vehicle_vessel_cable_laying.number_turntables,
    vehicle_vessel_cable_laying.turntable_max_load_mass,
    vehicle_vessel_cable_laying.turntable_inner_diameter,
    vehicle_vessel_cable_laying.cable_splice_capabilities,
    vehicle_vessel_cable_laying.dynamic_positioning_capabilities,
    vehicle_vessel_cable_laying.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cable_laying
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cable_laying.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cable_laying.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'cable laying vessel'::text);


--
-- TOC entry 450 (class 1259 OID 21560)
-- Name: view_vehicle_vessel_crane_barge; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_crane_barge AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cargo.beam,
    vehicle_vessel_cargo.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cargo.deck_space,
    vehicle_vessel_cargo.max_deck_load_pressure,
    vehicle_vessel_cargo.max_cargo_mass,
    vehicle_vessel_cargo.crane_max_load_mass,
    vehicle_vessel_cargo.dynamic_positioning_capabilities,
    vehicle_vessel_cargo.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cargo
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'crane barge'::text);


--
-- TOC entry 451 (class 1259 OID 21565)
-- Name: view_vehicle_vessel_crane_vessel; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_crane_vessel AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cargo.beam,
    vehicle_vessel_cargo.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cargo.deck_space,
    vehicle_vessel_cargo.max_deck_load_pressure,
    vehicle_vessel_cargo.max_cargo_mass,
    vehicle_vessel_cargo.crane_max_load_mass,
    vehicle_vessel_cargo.dynamic_positioning_capabilities,
    vehicle_vessel_cargo.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cargo
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'crane vessel'::text);


--
-- TOC entry 452 (class 1259 OID 21570)
-- Name: view_vehicle_vessel_csv; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_csv AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cargo.beam,
    vehicle_vessel_cargo.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cargo.deck_space,
    vehicle_vessel_cargo.max_deck_load_pressure,
    vehicle_vessel_cargo.max_cargo_mass,
    vehicle_vessel_cargo.crane_max_load_mass,
    vehicle_vessel_cargo.dynamic_positioning_capabilities,
    vehicle_vessel_cargo.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cargo
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'construction support vessel'::text);


--
-- TOC entry 453 (class 1259 OID 21575)
-- Name: view_vehicle_vessel_ctv; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_ctv AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_cargo.beam,
    vehicle_vessel_cargo.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_cargo.deck_space,
    vehicle_vessel_cargo.max_deck_load_pressure,
    vehicle_vessel_cargo.max_cargo_mass,
    vehicle_vessel_cargo.crane_max_load_mass,
    vehicle_vessel_cargo.dynamic_positioning_capabilities,
    vehicle_vessel_cargo.external_personel,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_cargo
     JOIN reference.vehicle_shared ON ((vehicle_vessel_cargo.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_cargo.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'crew transfer vessel'::text);


--
-- TOC entry 454 (class 1259 OID 21580)
-- Name: view_vehicle_vessel_jackup_barge; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_jackup_barge AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_jackup.beam,
    vehicle_vessel_jackup.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_jackup.deck_space,
    vehicle_vessel_jackup.max_deck_load_pressure,
    vehicle_vessel_jackup.max_cargo_mass,
    vehicle_vessel_jackup.crane_max_load_mass,
    vehicle_vessel_jackup.dynamic_positioning_capabilities,
    vehicle_vessel_jackup.external_personel,
    vehicle_vessel_jackup.jackup_max_water_depth,
    vehicle_vessel_jackup.jackup_speed_down,
    vehicle_vessel_jackup.jackup_max_payload_mass,
    vehicle_vessel_jackup.jacking_max_hs,
    vehicle_vessel_jackup.jacking_max_tp,
    vehicle_vessel_jackup.jacking_max_cs,
    vehicle_vessel_jackup.jacking_max_ws,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_jackup
     JOIN reference.vehicle_shared ON ((vehicle_vessel_jackup.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_jackup.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'jackup barge'::text);


--
-- TOC entry 455 (class 1259 OID 21585)
-- Name: view_vehicle_vessel_jackup_vessel; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_jackup_vessel AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_jackup.beam,
    vehicle_vessel_jackup.max_draft,
    vehicle_shared.consumption,
    vehicle_shared.transit_speed,
    vehicle_vessel_jackup.deck_space,
    vehicle_vessel_jackup.max_deck_load_pressure,
    vehicle_vessel_jackup.max_cargo_mass,
    vehicle_vessel_jackup.crane_max_load_mass,
    vehicle_vessel_jackup.dynamic_positioning_capabilities,
    vehicle_vessel_jackup.external_personel,
    vehicle_vessel_jackup.jackup_max_water_depth,
    vehicle_vessel_jackup.jackup_speed_down,
    vehicle_vessel_jackup.jackup_max_payload_mass,
    vehicle_vessel_jackup.jacking_max_hs,
    vehicle_vessel_jackup.jacking_max_tp,
    vehicle_vessel_jackup.jacking_max_cs,
    vehicle_vessel_jackup.jacking_max_ws,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_jackup
     JOIN reference.vehicle_shared ON ((vehicle_vessel_jackup.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_jackup.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'jackup vessel'::text);


--
-- TOC entry 456 (class 1259 OID 21590)
-- Name: view_vehicle_vessel_multicat; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_multicat AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_anchor_handling.beam,
    vehicle_vessel_anchor_handling.max_draft,
    vehicle_shared.consumption,
    vehicle_vessel_anchor_handling.consumption_towing,
    vehicle_shared.transit_speed,
    vehicle_vessel_anchor_handling.deck_space,
    vehicle_vessel_anchor_handling.max_deck_load_pressure,
    vehicle_vessel_anchor_handling.max_cargo_mass,
    vehicle_vessel_anchor_handling.crane_max_load_mass,
    vehicle_vessel_anchor_handling.bollard_pull,
    vehicle_vessel_anchor_handling.anchor_handling_drum_capacity,
    vehicle_vessel_anchor_handling.anchor_handling_winch_rated_pull,
    vehicle_vessel_anchor_handling.external_personel,
    vehicle_vessel_anchor_handling.towing_max_hs,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM (((reference.vehicle_vessel_anchor_handling
     JOIN reference.vehicle_shared ON ((vehicle_vessel_anchor_handling.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)))
     JOIN reference.vehicle_type ON ((vehicle_vessel_anchor_handling.fk_vehicle_type_id = vehicle_type.id)))
  WHERE ((vehicle_type.description)::text = 'multicat'::text);


--
-- TOC entry 457 (class 1259 OID 21595)
-- Name: view_vehicle_vessel_tugboat; Type: VIEW; Schema: reference; Owner: -
--

CREATE VIEW reference.view_vehicle_vessel_tugboat AS
 SELECT vehicle.description,
    vehicle_shared.gross_tonnage,
    vehicle_shared.length,
    vehicle_vessel_tugboat.beam,
    vehicle_vessel_tugboat.max_draft,
    vehicle_shared.consumption,
    vehicle_vessel_tugboat.consumption_towing,
    vehicle_shared.transit_speed,
    vehicle_vessel_tugboat.bollard_pull,
    vehicle_shared.transit_max_hs,
    vehicle_shared.transit_max_tp,
    vehicle_shared.transit_max_cs,
    vehicle_shared.transit_max_ws,
    vehicle_shared.mobilisation_time,
    vehicle_shared.mobilisation_percentage_cost,
    vehicle_shared.min_day_rate,
    vehicle_shared.max_day_rate
   FROM ((reference.vehicle_vessel_tugboat
     JOIN reference.vehicle_shared ON ((vehicle_vessel_tugboat.fk_vehicle_id = vehicle_shared.fk_vehicle_id)))
     JOIN reference.vehicle ON ((vehicle_shared.fk_vehicle_id = vehicle.id)));


--
-- TOC entry 4913 (class 2604 OID 21600)
-- Name: bathymetry id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry ALTER COLUMN id SET DEFAULT nextval('project.bathymetry_id_seq'::regclass);


--
-- TOC entry 4915 (class 2604 OID 21601)
-- Name: cable_corridor_bathymetry id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry ALTER COLUMN id SET DEFAULT nextval('project.cable_corridor_bathymetry_id_seq'::regclass);


--
-- TOC entry 4916 (class 2604 OID 21602)
-- Name: cable_corridor_bathymetry_layer id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry_layer ALTER COLUMN id SET DEFAULT nextval('project.cable_corridor_bathymetry_layer_id_seq'::regclass);


--
-- TOC entry 4917 (class 2604 OID 21603)
-- Name: cable_corridor_constraint id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_constraint ALTER COLUMN id SET DEFAULT nextval('project.cable_corridor_constraint_id_seq'::regclass);


--
-- TOC entry 4918 (class 2604 OID 21604)
-- Name: device id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device ALTER COLUMN id SET DEFAULT nextval('project.device_id_seq'::regclass);


--
-- TOC entry 4919 (class 2604 OID 21605)
-- Name: device_floating id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_floating ALTER COLUMN id SET DEFAULT nextval('project.device_floating_id_seq'::regclass);


--
-- TOC entry 4920 (class 2604 OID 21606)
-- Name: device_shared id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_shared ALTER COLUMN id SET DEFAULT nextval('project.device_shared_id_seq'::regclass);


--
-- TOC entry 4921 (class 2604 OID 21607)
-- Name: device_tidal id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal ALTER COLUMN id SET DEFAULT nextval('project.device_tidal_id_seq'::regclass);


--
-- TOC entry 4922 (class 2604 OID 21608)
-- Name: device_tidal_power_performance id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal_power_performance ALTER COLUMN id SET DEFAULT nextval('project.device_tidal_power_performance_id_seq'::regclass);


--
-- TOC entry 4923 (class 2604 OID 21609)
-- Name: device_wave id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_wave ALTER COLUMN id SET DEFAULT nextval('project.device_wave_id_seq'::regclass);


--
-- TOC entry 4924 (class 2604 OID 21610)
-- Name: lease_area id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.lease_area ALTER COLUMN id SET DEFAULT nextval('project.lease_area_id_seq'::regclass);


--
-- TOC entry 4925 (class 2604 OID 21611)
-- Name: site id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.site ALTER COLUMN id SET DEFAULT nextval('project.site_id_seq'::regclass);


--
-- TOC entry 4912 (class 2604 OID 21612)
-- Name: sub_systems id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_id_seq'::regclass);


--
-- TOC entry 4926 (class 2604 OID 21613)
-- Name: sub_systems_access id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_access ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_access_id_seq'::regclass);


--
-- TOC entry 4927 (class 2604 OID 21614)
-- Name: sub_systems_economic id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_economic ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_economic_id_seq'::regclass);


--
-- TOC entry 4928 (class 2604 OID 21615)
-- Name: sub_systems_inspection id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_inspection ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_inspection_id_seq'::regclass);


--
-- TOC entry 4929 (class 2604 OID 21616)
-- Name: sub_systems_install id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_install ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_install_id_seq'::regclass);


--
-- TOC entry 4930 (class 2604 OID 21617)
-- Name: sub_systems_maintenance id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_maintenance ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_maintenance_id_seq'::regclass);


--
-- TOC entry 4931 (class 2604 OID 21618)
-- Name: sub_systems_operation_weightings id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_operation_weightings ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_operation_weightings_id_seq'::regclass);


--
-- TOC entry 4932 (class 2604 OID 21619)
-- Name: sub_systems_replace id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_replace ALTER COLUMN id SET DEFAULT nextval('project.sub_systems_replace_id_seq'::regclass);


--
-- TOC entry 4933 (class 2604 OID 21620)
-- Name: time_series_energy_tidal id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_tidal ALTER COLUMN id SET DEFAULT nextval('project.time_series_energy_tidal_id_seq'::regclass);


--
-- TOC entry 4934 (class 2604 OID 21621)
-- Name: time_series_energy_wave id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_wave ALTER COLUMN id SET DEFAULT nextval('project.time_series_energy_wave_id_seq'::regclass);


--
-- TOC entry 4935 (class 2604 OID 21622)
-- Name: time_series_om_tidal id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_tidal ALTER COLUMN id SET DEFAULT nextval('project.time_series_om_tidal_id_seq'::regclass);


--
-- TOC entry 4936 (class 2604 OID 21623)
-- Name: time_series_om_wave id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wave ALTER COLUMN id SET DEFAULT nextval('project.time_series_om_wave_id_seq'::regclass);


--
-- TOC entry 4937 (class 2604 OID 21624)
-- Name: time_series_om_wind id; Type: DEFAULT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wind ALTER COLUMN id SET DEFAULT nextval('project.time_series_om_wind_id_seq'::regclass);


--
-- TOC entry 4938 (class 2604 OID 21625)
-- Name: component id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component ALTER COLUMN id SET DEFAULT nextval('reference.component_id_seq'::regclass);


--
-- TOC entry 4939 (class 2604 OID 21626)
-- Name: component_anchor id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_anchor ALTER COLUMN id SET DEFAULT nextval('reference.component_anchor_id_seq'::regclass);


--
-- TOC entry 4940 (class 2604 OID 21627)
-- Name: component_cable id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_cable ALTER COLUMN id SET DEFAULT nextval('reference.component_cable_id_seq'::regclass);


--
-- TOC entry 4941 (class 2604 OID 21628)
-- Name: component_collection_point id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_collection_point ALTER COLUMN id SET DEFAULT nextval('reference.component_collection_point_id_seq'::regclass);


--
-- TOC entry 4942 (class 2604 OID 21629)
-- Name: component_connector id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_connector ALTER COLUMN id SET DEFAULT nextval('reference.component_connector_id_seq'::regclass);


--
-- TOC entry 4943 (class 2604 OID 21630)
-- Name: component_continuous id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_continuous ALTER COLUMN id SET DEFAULT nextval('reference.component_continuous_id_seq'::regclass);


--
-- TOC entry 4944 (class 2604 OID 21631)
-- Name: component_discrete id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_discrete ALTER COLUMN id SET DEFAULT nextval('reference.component_discrete_id_seq'::regclass);


--
-- TOC entry 4945 (class 2604 OID 21632)
-- Name: component_mooring_continuous id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_continuous ALTER COLUMN id SET DEFAULT nextval('reference.component_mooring_continuous_id_seq'::regclass);


--
-- TOC entry 4946 (class 2604 OID 21633)
-- Name: component_mooring_discrete id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_discrete ALTER COLUMN id SET DEFAULT nextval('reference.component_mooring_discrete_id_seq'::regclass);


--
-- TOC entry 4947 (class 2604 OID 21634)
-- Name: component_pile id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_pile ALTER COLUMN id SET DEFAULT nextval('reference.component_pile_id_seq'::regclass);


--
-- TOC entry 4948 (class 2604 OID 21635)
-- Name: component_rope id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_rope ALTER COLUMN id SET DEFAULT nextval('reference.component_rope_id_seq'::regclass);


--
-- TOC entry 4949 (class 2604 OID 21636)
-- Name: component_shared id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_shared ALTER COLUMN id SET DEFAULT nextval('reference.component_shared_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 21637)
-- Name: component_transformer id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_transformer ALTER COLUMN id SET DEFAULT nextval('reference.component_transformer_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 21638)
-- Name: component_type id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_type ALTER COLUMN id SET DEFAULT nextval('reference.component_type_id_seq'::regclass);


--
-- TOC entry 4952 (class 2604 OID 21639)
-- Name: equipment_cable_burial id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_cable_burial ALTER COLUMN id SET DEFAULT nextval('reference.equipment_cable_burial_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 21640)
-- Name: equipment_divers id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_divers ALTER COLUMN id SET DEFAULT nextval('reference.equipment_divers_id_seq'::regclass);


--
-- TOC entry 4954 (class 2604 OID 21641)
-- Name: equipment_drilling_rigs id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_drilling_rigs ALTER COLUMN id SET DEFAULT nextval('reference.equipment_drilling_rigs_id_seq'::regclass);


--
-- TOC entry 4955 (class 2604 OID 21642)
-- Name: equipment_excavating id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_excavating ALTER COLUMN id SET DEFAULT nextval('reference.equipment_excavating_id_seq'::regclass);


--
-- TOC entry 4956 (class 2604 OID 21643)
-- Name: equipment_hammer id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_hammer ALTER COLUMN id SET DEFAULT nextval('reference.equipment_hammer_id_seq'::regclass);


--
-- TOC entry 4957 (class 2604 OID 21644)
-- Name: equipment_mattress id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_mattress ALTER COLUMN id SET DEFAULT nextval('reference.equipment_mattress_id_seq'::regclass);


--
-- TOC entry 4958 (class 2604 OID 21645)
-- Name: equipment_rock_filter_bags id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_rock_filter_bags ALTER COLUMN id SET DEFAULT nextval('reference.equipment_rock_filter_bags_id_seq'::regclass);


--
-- TOC entry 4959 (class 2604 OID 21646)
-- Name: equipment_rov id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_rov ALTER COLUMN id SET DEFAULT nextval('reference.equipment_rov_id_seq'::regclass);


--
-- TOC entry 4960 (class 2604 OID 21647)
-- Name: equipment_split_pipe id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_split_pipe ALTER COLUMN id SET DEFAULT nextval('reference.equipment_split_pipe_id_seq'::regclass);


--
-- TOC entry 4961 (class 2604 OID 21648)
-- Name: equipment_vibro_driver id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_vibro_driver ALTER COLUMN id SET DEFAULT nextval('reference.equipment_vibro_driver_id_seq'::regclass);


--
-- TOC entry 4962 (class 2604 OID 21649)
-- Name: operations_limit_cs id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_cs ALTER COLUMN id SET DEFAULT nextval('reference.operations_limit_cs_id_seq'::regclass);


--
-- TOC entry 4963 (class 2604 OID 21650)
-- Name: operations_limit_hs id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_hs ALTER COLUMN id SET DEFAULT nextval('reference.operations_limit_hs_id_seq'::regclass);


--
-- TOC entry 4964 (class 2604 OID 21651)
-- Name: operations_limit_tp id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_tp ALTER COLUMN id SET DEFAULT nextval('reference.operations_limit_tp_id_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 21652)
-- Name: operations_limit_ws id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_ws ALTER COLUMN id SET DEFAULT nextval('reference.operations_limit_ws_id_seq'::regclass);


--
-- TOC entry 4966 (class 2604 OID 21653)
-- Name: operations_type id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_type ALTER COLUMN id SET DEFAULT nextval('reference.operations_type_id_seq'::regclass);


--
-- TOC entry 4967 (class 2604 OID 21654)
-- Name: ports id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ports ALTER COLUMN id SET DEFAULT nextval('reference.ports_id_seq'::regclass);


--
-- TOC entry 4911 (class 2604 OID 21655)
-- Name: soil_type id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.soil_type ALTER COLUMN id SET DEFAULT nextval('reference.soil_type_id_seq'::regclass);


--
-- TOC entry 4968 (class 2604 OID 21656)
-- Name: vehicle id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_id_seq'::regclass);


--
-- TOC entry 4969 (class 2604 OID 21657)
-- Name: vehicle_helicopter id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_helicopter ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_helicopter_id_seq'::regclass);


--
-- TOC entry 4970 (class 2604 OID 21658)
-- Name: vehicle_shared id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_shared ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_shared_id_seq'::regclass);


--
-- TOC entry 4971 (class 2604 OID 21659)
-- Name: vehicle_type id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_type ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_type_id_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 21660)
-- Name: vehicle_vessel_anchor_handling id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_anchor_handling ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_vessel_anchor_handling_id_seq'::regclass);


--
-- TOC entry 4973 (class 2604 OID 21661)
-- Name: vehicle_vessel_cable_laying id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cable_laying ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_vessel_cable_laying_id_seq'::regclass);


--
-- TOC entry 4974 (class 2604 OID 21662)
-- Name: vehicle_vessel_cargo id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cargo ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_vessel_cargo_id_seq'::regclass);


--
-- TOC entry 4975 (class 2604 OID 21663)
-- Name: vehicle_vessel_jackup id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_jackup ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_vessel_jackup_id_seq'::regclass);


--
-- TOC entry 4976 (class 2604 OID 21664)
-- Name: vehicle_vessel_tugboat id; Type: DEFAULT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_tugboat ALTER COLUMN id SET DEFAULT nextval('reference.vehicle_vessel_tugboat_id_seq'::regclass);


--
-- TOC entry 5020 (class 2606 OID 21666)
-- Name: bathymetry_layer bathymetry_layer_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry_layer
    ADD CONSTRAINT bathymetry_layer_pkey PRIMARY KEY (id);


--
-- TOC entry 5016 (class 2606 OID 21668)
-- Name: bathymetry bathymetry_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry
    ADD CONSTRAINT bathymetry_pkey PRIMARY KEY (id);


--
-- TOC entry 5027 (class 2606 OID 21670)
-- Name: cable_corridor_bathymetry_layer cable_corridor_bathymetry_layer_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry_layer
    ADD CONSTRAINT cable_corridor_bathymetry_layer_pkey PRIMARY KEY (id);


--
-- TOC entry 5023 (class 2606 OID 21672)
-- Name: cable_corridor_bathymetry cable_corridor_bathymetry_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry
    ADD CONSTRAINT cable_corridor_bathymetry_pkey PRIMARY KEY (id);


--
-- TOC entry 5030 (class 2606 OID 21674)
-- Name: cable_corridor_constraint cable_corridor_constraint_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_constraint
    ADD CONSTRAINT cable_corridor_constraint_pkey PRIMARY KEY (id);


--
-- TOC entry 5033 (class 2606 OID 21676)
-- Name: constraint constraint_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project."constraint"
    ADD CONSTRAINT constraint_pkey PRIMARY KEY (id);


--
-- TOC entry 5038 (class 2606 OID 21678)
-- Name: device_floating device_floating_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_floating
    ADD CONSTRAINT device_floating_pkey PRIMARY KEY (id);


--
-- TOC entry 5035 (class 2606 OID 21680)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- TOC entry 5041 (class 2606 OID 21682)
-- Name: device_shared device_shared_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_shared
    ADD CONSTRAINT device_shared_pkey PRIMARY KEY (id);


--
-- TOC entry 5044 (class 2606 OID 21684)
-- Name: device_tidal device_tidal_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal
    ADD CONSTRAINT device_tidal_pkey PRIMARY KEY (id);


--
-- TOC entry 5047 (class 2606 OID 21686)
-- Name: device_tidal_power_performance device_tidal_power_performance_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal_power_performance
    ADD CONSTRAINT device_tidal_power_performance_pkey PRIMARY KEY (id);


--
-- TOC entry 5050 (class 2606 OID 21688)
-- Name: device_wave device_wave_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_wave
    ADD CONSTRAINT device_wave_pkey PRIMARY KEY (id);


--
-- TOC entry 5053 (class 2606 OID 21690)
-- Name: lease_area lease_area_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.lease_area
    ADD CONSTRAINT lease_area_pkey PRIMARY KEY (id);


--
-- TOC entry 5055 (class 2606 OID 21692)
-- Name: site site_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.site
    ADD CONSTRAINT site_pkey PRIMARY KEY (id);


--
-- TOC entry 5058 (class 2606 OID 21694)
-- Name: sub_systems_access sub_systems_access_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_access
    ADD CONSTRAINT sub_systems_access_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 21696)
-- Name: sub_systems_economic sub_systems_economic_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_economic
    ADD CONSTRAINT sub_systems_economic_pkey PRIMARY KEY (id);


--
-- TOC entry 5064 (class 2606 OID 21698)
-- Name: sub_systems_inspection sub_systems_inspection_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_inspection
    ADD CONSTRAINT sub_systems_inspection_pkey PRIMARY KEY (id);


--
-- TOC entry 5067 (class 2606 OID 21700)
-- Name: sub_systems_install sub_systems_install_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_install
    ADD CONSTRAINT sub_systems_install_pkey PRIMARY KEY (id);


--
-- TOC entry 5070 (class 2606 OID 21702)
-- Name: sub_systems_maintenance sub_systems_maintenance_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_maintenance
    ADD CONSTRAINT sub_systems_maintenance_pkey PRIMARY KEY (id);


--
-- TOC entry 5073 (class 2606 OID 21704)
-- Name: sub_systems_operation_weightings sub_systems_operation_weightings_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_operation_weightings
    ADD CONSTRAINT sub_systems_operation_weightings_pkey PRIMARY KEY (id);


--
-- TOC entry 5013 (class 2606 OID 21706)
-- Name: sub_systems sub_systems_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems
    ADD CONSTRAINT sub_systems_pkey PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 21708)
-- Name: sub_systems_replace sub_systems_replace_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_replace
    ADD CONSTRAINT sub_systems_replace_pkey PRIMARY KEY (id);


--
-- TOC entry 5079 (class 2606 OID 21710)
-- Name: time_series_energy_tidal time_series_energy_tidal_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_tidal
    ADD CONSTRAINT time_series_energy_tidal_pkey PRIMARY KEY (id);


--
-- TOC entry 5082 (class 2606 OID 21712)
-- Name: time_series_energy_wave time_series_energy_wave_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_wave
    ADD CONSTRAINT time_series_energy_wave_pkey PRIMARY KEY (id);


--
-- TOC entry 5085 (class 2606 OID 21714)
-- Name: time_series_om_tidal time_series_om_tidal_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_tidal
    ADD CONSTRAINT time_series_om_tidal_pkey PRIMARY KEY (id);


--
-- TOC entry 5088 (class 2606 OID 21716)
-- Name: time_series_om_wave time_series_om_wave_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wave
    ADD CONSTRAINT time_series_om_wave_pkey PRIMARY KEY (id);


--
-- TOC entry 5091 (class 2606 OID 21718)
-- Name: time_series_om_wind time_series_om_wind_pkey; Type: CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wind
    ADD CONSTRAINT time_series_om_wind_pkey PRIMARY KEY (id);


--
-- TOC entry 5097 (class 2606 OID 21720)
-- Name: component_anchor component_anchor_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_anchor
    ADD CONSTRAINT component_anchor_pkey PRIMARY KEY (id);


--
-- TOC entry 5101 (class 2606 OID 21722)
-- Name: component_cable component_cable_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_cable
    ADD CONSTRAINT component_cable_pkey PRIMARY KEY (id);


--
-- TOC entry 5105 (class 2606 OID 21724)
-- Name: component_collection_point component_collection_point_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_collection_point
    ADD CONSTRAINT component_collection_point_pkey PRIMARY KEY (id);


--
-- TOC entry 5109 (class 2606 OID 21726)
-- Name: component_connector component_connector_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_connector
    ADD CONSTRAINT component_connector_pkey PRIMARY KEY (id);


--
-- TOC entry 5112 (class 2606 OID 21728)
-- Name: component_continuous component_continuous_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_continuous
    ADD CONSTRAINT component_continuous_pkey PRIMARY KEY (id);


--
-- TOC entry 5115 (class 2606 OID 21730)
-- Name: component_discrete component_discrete_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_discrete
    ADD CONSTRAINT component_discrete_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 2606 OID 21732)
-- Name: component_mooring_continuous component_mooring_continuous_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_continuous
    ADD CONSTRAINT component_mooring_continuous_pkey PRIMARY KEY (id);


--
-- TOC entry 5123 (class 2606 OID 21734)
-- Name: component_mooring_discrete component_mooring_discrete_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_discrete
    ADD CONSTRAINT component_mooring_discrete_pkey PRIMARY KEY (id);


--
-- TOC entry 5127 (class 2606 OID 21736)
-- Name: component_pile component_pile_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_pile
    ADD CONSTRAINT component_pile_pkey PRIMARY KEY (id);


--
-- TOC entry 5093 (class 2606 OID 21738)
-- Name: component component_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component
    ADD CONSTRAINT component_pkey PRIMARY KEY (id);


--
-- TOC entry 5131 (class 2606 OID 21740)
-- Name: component_rope component_rope_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_rope
    ADD CONSTRAINT component_rope_pkey PRIMARY KEY (id);


--
-- TOC entry 5134 (class 2606 OID 21742)
-- Name: component_shared component_shared_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_shared
    ADD CONSTRAINT component_shared_pkey PRIMARY KEY (id);


--
-- TOC entry 5138 (class 2606 OID 21744)
-- Name: component_transformer component_transformer_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_transformer
    ADD CONSTRAINT component_transformer_pkey PRIMARY KEY (id);


--
-- TOC entry 5140 (class 2606 OID 21746)
-- Name: component_type component_type_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_type
    ADD CONSTRAINT component_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5142 (class 2606 OID 21748)
-- Name: constants constants_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.constants
    ADD CONSTRAINT constants_pkey PRIMARY KEY (lock);


--
-- TOC entry 5144 (class 2606 OID 21750)
-- Name: equipment_cable_burial equipment_cable_burial_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_cable_burial
    ADD CONSTRAINT equipment_cable_burial_pkey PRIMARY KEY (id);


--
-- TOC entry 5146 (class 2606 OID 21752)
-- Name: equipment_divers equipment_divers_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_divers
    ADD CONSTRAINT equipment_divers_pkey PRIMARY KEY (id);


--
-- TOC entry 5148 (class 2606 OID 21754)
-- Name: equipment_drilling_rigs equipment_drilling_rigs_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_drilling_rigs
    ADD CONSTRAINT equipment_drilling_rigs_pkey PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 21756)
-- Name: equipment_excavating equipment_excavating_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_excavating
    ADD CONSTRAINT equipment_excavating_pkey PRIMARY KEY (id);


--
-- TOC entry 5152 (class 2606 OID 21758)
-- Name: equipment_hammer equipment_hammer_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_hammer
    ADD CONSTRAINT equipment_hammer_pkey PRIMARY KEY (id);


--
-- TOC entry 5154 (class 2606 OID 21760)
-- Name: equipment_mattress equipment_mattress_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_mattress
    ADD CONSTRAINT equipment_mattress_pkey PRIMARY KEY (id);


--
-- TOC entry 5156 (class 2606 OID 21762)
-- Name: equipment_rock_filter_bags equipment_rock_filter_bags_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_rock_filter_bags
    ADD CONSTRAINT equipment_rock_filter_bags_pkey PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 21764)
-- Name: equipment_rov equipment_rov_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_rov
    ADD CONSTRAINT equipment_rov_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 21766)
-- Name: equipment_soil_lay_rates equipment_soil_lay_rates_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_soil_lay_rates
    ADD CONSTRAINT equipment_soil_lay_rates_pkey PRIMARY KEY (equipment_type);


--
-- TOC entry 5162 (class 2606 OID 21768)
-- Name: equipment_soil_penet_rates equipment_soil_penet_rates_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_soil_penet_rates
    ADD CONSTRAINT equipment_soil_penet_rates_pkey PRIMARY KEY (equipment_type);


--
-- TOC entry 5164 (class 2606 OID 21770)
-- Name: equipment_split_pipe equipment_split_pipe_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_split_pipe
    ADD CONSTRAINT equipment_split_pipe_pkey PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 21772)
-- Name: equipment_vibro_driver equipment_vibro_driver_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.equipment_vibro_driver
    ADD CONSTRAINT equipment_vibro_driver_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 21774)
-- Name: operations_limit_cs operations_limit_cs_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_cs
    ADD CONSTRAINT operations_limit_cs_pkey PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 21776)
-- Name: operations_limit_hs operations_limit_hs_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_hs
    ADD CONSTRAINT operations_limit_hs_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 21778)
-- Name: operations_limit_tp operations_limit_tp_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_tp
    ADD CONSTRAINT operations_limit_tp_pkey PRIMARY KEY (id);


--
-- TOC entry 5174 (class 2606 OID 21780)
-- Name: operations_limit_ws operations_limit_ws_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_ws
    ADD CONSTRAINT operations_limit_ws_pkey PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 21782)
-- Name: operations_type operations_type_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_type
    ADD CONSTRAINT operations_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5178 (class 2606 OID 21784)
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 21786)
-- Name: ref_current_drag_coef_rect ref_current_drag_coef_rect_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_current_drag_coef_rect
    ADD CONSTRAINT ref_current_drag_coef_rect_pkey PRIMARY KEY (width_length);


--
-- TOC entry 5182 (class 2606 OID 21788)
-- Name: ref_drag_coef_cyl ref_drag_coef_cyl_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_drag_coef_cyl
    ADD CONSTRAINT ref_drag_coef_cyl_pkey PRIMARY KEY (reynolds_number);


--
-- TOC entry 5184 (class 2606 OID 21790)
-- Name: ref_drift_coef_float_rect ref_drift_coef_float_rect_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_drift_coef_float_rect
    ADD CONSTRAINT ref_drift_coef_float_rect_pkey PRIMARY KEY (wavenumber_draft);


--
-- TOC entry 5186 (class 2606 OID 21792)
-- Name: ref_holding_capacity_factors_plate_anchors ref_holding_capacity_factors_plate_anchors_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_holding_capacity_factors_plate_anchors
    ADD CONSTRAINT ref_holding_capacity_factors_plate_anchors_pkey PRIMARY KEY (relative_embedment_depth);


--
-- TOC entry 5188 (class 2606 OID 21794)
-- Name: ref_line_bcf ref_line_bcf_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_line_bcf
    ADD CONSTRAINT ref_line_bcf_pkey PRIMARY KEY (soil_friction_angle);


--
-- TOC entry 5190 (class 2606 OID 21796)
-- Name: ref_pile_deflection_coefficients ref_pile_deflection_coefficients_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_pile_deflection_coefficients
    ADD CONSTRAINT ref_pile_deflection_coefficients_pkey PRIMARY KEY (depth_coefficient);


--
-- TOC entry 5192 (class 2606 OID 21798)
-- Name: ref_pile_limiting_values_noncalcareous ref_pile_limiting_values_noncalcareous_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_pile_limiting_values_noncalcareous
    ADD CONSTRAINT ref_pile_limiting_values_noncalcareous_pkey PRIMARY KEY (soil_friction_angle);


--
-- TOC entry 5194 (class 2606 OID 21800)
-- Name: ref_pile_moment_coefficient_sam ref_pile_moment_coefficient_sam_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_pile_moment_coefficient_sam
    ADD CONSTRAINT ref_pile_moment_coefficient_sam_pkey PRIMARY KEY (depth_coefficient);


--
-- TOC entry 5196 (class 2606 OID 21802)
-- Name: ref_pile_moment_coefficient_sbm ref_pile_moment_coefficient_sbm_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_pile_moment_coefficient_sbm
    ADD CONSTRAINT ref_pile_moment_coefficient_sbm_pkey PRIMARY KEY (depth_coefficient);


--
-- TOC entry 5198 (class 2606 OID 21804)
-- Name: ref_rectangular_wave_inertia ref_rectangular_wave_inertia_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_rectangular_wave_inertia
    ADD CONSTRAINT ref_rectangular_wave_inertia_pkey PRIMARY KEY ("width/length");


--
-- TOC entry 5200 (class 2606 OID 21806)
-- Name: ref_subgrade_reaction_coefficient_cohesionless ref_subgrade_reaction_coefficient_cohesionless_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_subgrade_reaction_coefficient_cohesionless
    ADD CONSTRAINT ref_subgrade_reaction_coefficient_cohesionless_pkey PRIMARY KEY (allowable_deflection_diameter);


--
-- TOC entry 5202 (class 2606 OID 21808)
-- Name: ref_subgrade_reaction_coefficient_k1_cohesive ref_subgrade_reaction_coefficient_k1_cohesive_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_subgrade_reaction_coefficient_k1_cohesive
    ADD CONSTRAINT ref_subgrade_reaction_coefficient_k1_cohesive_pkey PRIMARY KEY (allowable_deflection_diameter);


--
-- TOC entry 5204 (class 2606 OID 21810)
-- Name: ref_superline_nylon ref_superline_nylon_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_superline_nylon
    ADD CONSTRAINT ref_superline_nylon_pkey PRIMARY KEY (extension);


--
-- TOC entry 5206 (class 2606 OID 21812)
-- Name: ref_superline_polyester ref_superline_polyester_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_superline_polyester
    ADD CONSTRAINT ref_superline_polyester_pkey PRIMARY KEY (extension);


--
-- TOC entry 5208 (class 2606 OID 21814)
-- Name: ref_superline_steelite ref_superline_steelite_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_superline_steelite
    ADD CONSTRAINT ref_superline_steelite_pkey PRIMARY KEY (extension);


--
-- TOC entry 5210 (class 2606 OID 21816)
-- Name: ref_wake_amplification_factor_cyl ref_wake_amplification_factor_cyl_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_wake_amplification_factor_cyl
    ADD CONSTRAINT ref_wake_amplification_factor_cyl_pkey PRIMARY KEY (kc_steady_drag_coefficient);


--
-- TOC entry 5212 (class 2606 OID 21818)
-- Name: ref_wind_drag_coef_rect ref_wind_drag_coef_rect_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.ref_wind_drag_coef_rect
    ADD CONSTRAINT ref_wind_drag_coef_rect_pkey PRIMARY KEY (width_length);


--
-- TOC entry 5214 (class 2606 OID 21820)
-- Name: soil_type_geotechnical_properties soil_type_geotechnical_properties_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.soil_type_geotechnical_properties
    ADD CONSTRAINT soil_type_geotechnical_properties_pkey PRIMARY KEY (fk_soil_type_id);


--
-- TOC entry 5010 (class 2606 OID 21822)
-- Name: soil_type soil_type_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.soil_type
    ADD CONSTRAINT soil_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5220 (class 2606 OID 21824)
-- Name: vehicle_helicopter vehicle_helicopter_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_helicopter
    ADD CONSTRAINT vehicle_helicopter_pkey PRIMARY KEY (id);


--
-- TOC entry 5216 (class 2606 OID 21826)
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (id);


--
-- TOC entry 5223 (class 2606 OID 21828)
-- Name: vehicle_shared vehicle_shared_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_shared
    ADD CONSTRAINT vehicle_shared_pkey PRIMARY KEY (id);


--
-- TOC entry 5225 (class 2606 OID 21830)
-- Name: vehicle_type vehicle_type_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_type
    ADD CONSTRAINT vehicle_type_pkey PRIMARY KEY (id);


--
-- TOC entry 5229 (class 2606 OID 21832)
-- Name: vehicle_vessel_anchor_handling vehicle_vessel_anchor_handling_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_anchor_handling
    ADD CONSTRAINT vehicle_vessel_anchor_handling_pkey PRIMARY KEY (id);


--
-- TOC entry 5233 (class 2606 OID 21834)
-- Name: vehicle_vessel_cable_laying vehicle_vessel_cable_laying_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cable_laying
    ADD CONSTRAINT vehicle_vessel_cable_laying_pkey PRIMARY KEY (id);


--
-- TOC entry 5237 (class 2606 OID 21836)
-- Name: vehicle_vessel_cargo vehicle_vessel_cargo_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cargo
    ADD CONSTRAINT vehicle_vessel_cargo_pkey PRIMARY KEY (id);


--
-- TOC entry 5241 (class 2606 OID 21838)
-- Name: vehicle_vessel_jackup vehicle_vessel_jackup_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_jackup
    ADD CONSTRAINT vehicle_vessel_jackup_pkey PRIMARY KEY (id);


--
-- TOC entry 5245 (class 2606 OID 21840)
-- Name: vehicle_vessel_tugboat vehicle_vessel_tugboat_pkey; Type: CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_tugboat
    ADD CONSTRAINT vehicle_vessel_tugboat_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 1259 OID 21841)
-- Name: bathymetry_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX bathymetry_fk_idx ON project.bathymetry USING btree (fk_site_id);


--
-- TOC entry 5017 (class 1259 OID 21842)
-- Name: bathymetry_layer_fk_bathymetry_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX bathymetry_layer_fk_bathymetry_idx ON project.bathymetry_layer USING btree (fk_bathymetry_id);


--
-- TOC entry 5018 (class 1259 OID 21843)
-- Name: bathymetry_layer_fk_soil_type_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX bathymetry_layer_fk_soil_type_idx ON project.bathymetry_layer USING btree (fk_soil_type_id);


--
-- TOC entry 5021 (class 1259 OID 21844)
-- Name: cable_corridor_bathymetry_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX cable_corridor_bathymetry_fk_idx ON project.cable_corridor_bathymetry USING btree (fk_site_id);


--
-- TOC entry 5024 (class 1259 OID 21845)
-- Name: cable_corridor_bathymetry_fk_soil_type_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX cable_corridor_bathymetry_fk_soil_type_idx ON project.cable_corridor_bathymetry_layer USING btree (fk_soil_type_id);


--
-- TOC entry 5025 (class 1259 OID 21846)
-- Name: cable_corridor_bathymetry_layer_fk_bathymetry_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX cable_corridor_bathymetry_layer_fk_bathymetry_idx ON project.cable_corridor_bathymetry_layer USING btree (fk_bathymetry_id);


--
-- TOC entry 5028 (class 1259 OID 21847)
-- Name: cable_corridor_constraint_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX cable_corridor_constraint_fk_idx ON project.cable_corridor_constraint USING btree (fk_site_id);


--
-- TOC entry 5031 (class 1259 OID 21848)
-- Name: constraint_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX constraint_fk_idx ON project."constraint" USING btree (fk_site_id);


--
-- TOC entry 5036 (class 1259 OID 21849)
-- Name: device_floating_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX device_floating_fk_idx ON project.device_floating USING btree (fk_device_id);


--
-- TOC entry 5039 (class 1259 OID 21850)
-- Name: device_shared_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX device_shared_fk_idx ON project.device_shared USING btree (fk_device_id);


--
-- TOC entry 5042 (class 1259 OID 21851)
-- Name: device_tidal_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX device_tidal_fk_idx ON project.device_tidal USING btree (fk_device_id);


--
-- TOC entry 5045 (class 1259 OID 21852)
-- Name: device_tidal_power_performance_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX device_tidal_power_performance_fk_idx ON project.device_tidal_power_performance USING btree (fk_device_id);


--
-- TOC entry 5048 (class 1259 OID 21853)
-- Name: device_wave_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX device_wave_fk_idx ON project.device_wave USING btree (fk_device_id);


--
-- TOC entry 5051 (class 1259 OID 21854)
-- Name: lease_area_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX lease_area_fk_idx ON project.lease_area USING btree (fk_site_id);


--
-- TOC entry 5056 (class 1259 OID 21855)
-- Name: sub_systems_access_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_access_fk_idx ON project.sub_systems_access USING btree (fk_sub_system_id);


--
-- TOC entry 5059 (class 1259 OID 21856)
-- Name: sub_systems_economic_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_economic_fk_idx ON project.sub_systems_economic USING btree (fk_sub_system_id);


--
-- TOC entry 5011 (class 1259 OID 21857)
-- Name: sub_systems_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_fk_idx ON project.sub_systems USING btree (fk_device_id);


--
-- TOC entry 5062 (class 1259 OID 21858)
-- Name: sub_systems_inspection_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_inspection_fk_idx ON project.sub_systems_inspection USING btree (fk_sub_system_id);


--
-- TOC entry 5065 (class 1259 OID 21859)
-- Name: sub_systems_install_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_install_fk_idx ON project.sub_systems_install USING btree (fk_sub_system_id);


--
-- TOC entry 5068 (class 1259 OID 21860)
-- Name: sub_systems_maintenance_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_maintenance_fk_idx ON project.sub_systems_maintenance USING btree (fk_sub_system_id);


--
-- TOC entry 5071 (class 1259 OID 21861)
-- Name: sub_systems_operation_weightings_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_operation_weightings_fk_idx ON project.sub_systems_operation_weightings USING btree (fk_sub_system_id);


--
-- TOC entry 5074 (class 1259 OID 21862)
-- Name: sub_systems_replace_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX sub_systems_replace_fk_idx ON project.sub_systems_replace USING btree (fk_sub_system_id);


--
-- TOC entry 5077 (class 1259 OID 21863)
-- Name: time_series_energy_tidal_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX time_series_energy_tidal_fk_idx ON project.time_series_energy_tidal USING btree (fk_bathymetry_id);


--
-- TOC entry 5080 (class 1259 OID 21864)
-- Name: time_series_energy_wave_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX time_series_energy_wave_fk_idx ON project.time_series_energy_wave USING btree (fk_site_id);


--
-- TOC entry 5083 (class 1259 OID 21865)
-- Name: time_series_om_tidal_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX time_series_om_tidal_fk_idx ON project.time_series_om_tidal USING btree (fk_site_id);


--
-- TOC entry 5086 (class 1259 OID 21866)
-- Name: time_series_om_wave_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX time_series_om_wave_fk_idx ON project.time_series_om_wave USING btree (fk_site_id);


--
-- TOC entry 5089 (class 1259 OID 21867)
-- Name: time_series_om_wind_fk_idx; Type: INDEX; Schema: project; Owner: -
--

CREATE INDEX time_series_om_wind_fk_idx ON project.time_series_om_wind USING btree (fk_site_id);


--
-- TOC entry 5094 (class 1259 OID 21868)
-- Name: component_anchor_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_anchor_fk_idx ON reference.component_anchor USING btree (fk_component_discrete_id);


--
-- TOC entry 5095 (class 1259 OID 21869)
-- Name: component_anchor_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_anchor_fk_type_idx ON reference.component_anchor USING btree (fk_component_type_id);


--
-- TOC entry 5098 (class 1259 OID 21870)
-- Name: component_cable_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_cable_fk_idx ON reference.component_cable USING btree (fk_component_continuous_id);


--
-- TOC entry 5099 (class 1259 OID 21871)
-- Name: component_cable_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_cable_fk_type_idx ON reference.component_cable USING btree (fk_component_type_id);


--
-- TOC entry 5102 (class 1259 OID 21872)
-- Name: component_collection_point_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_collection_point_fk_idx ON reference.component_collection_point USING btree (fk_component_discrete_id);


--
-- TOC entry 5103 (class 1259 OID 21873)
-- Name: component_collection_point_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_collection_point_fk_type_idx ON reference.component_collection_point USING btree (fk_component_type_id);


--
-- TOC entry 5120 (class 1259 OID 21874)
-- Name: component_component_mooring_discrete_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_component_mooring_discrete_fk_type_idx ON reference.component_mooring_discrete USING btree (fk_component_type_id);


--
-- TOC entry 5106 (class 1259 OID 21875)
-- Name: component_connector_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_connector_fk_idx ON reference.component_connector USING btree (fk_component_discrete_id);


--
-- TOC entry 5107 (class 1259 OID 21876)
-- Name: component_connector_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_connector_fk_type_idx ON reference.component_connector USING btree (fk_component_type_id);


--
-- TOC entry 5110 (class 1259 OID 21877)
-- Name: component_continuous_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_continuous_fk_idx ON reference.component_continuous USING btree (fk_component_id);


--
-- TOC entry 5113 (class 1259 OID 21878)
-- Name: component_discrete_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_discrete_fk_idx ON reference.component_discrete USING btree (fk_component_id);


--
-- TOC entry 5116 (class 1259 OID 21879)
-- Name: component_mooring_continuous_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_mooring_continuous_fk_idx ON reference.component_mooring_continuous USING btree (fk_component_continuous_id);


--
-- TOC entry 5117 (class 1259 OID 21880)
-- Name: component_mooring_continuous_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_mooring_continuous_fk_type_idx ON reference.component_mooring_continuous USING btree (fk_component_type_id);


--
-- TOC entry 5121 (class 1259 OID 21881)
-- Name: component_mooring_discrete_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_mooring_discrete_fk_idx ON reference.component_mooring_discrete USING btree (fk_component_discrete_id);


--
-- TOC entry 5124 (class 1259 OID 21882)
-- Name: component_pile_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_pile_fk_idx ON reference.component_pile USING btree (fk_component_continuous_id);


--
-- TOC entry 5125 (class 1259 OID 21883)
-- Name: component_pile_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_pile_fk_type_idx ON reference.component_pile USING btree (fk_component_type_id);


--
-- TOC entry 5128 (class 1259 OID 21884)
-- Name: component_rope_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_rope_fk_idx ON reference.component_rope USING btree (fk_component_continuous_id);


--
-- TOC entry 5129 (class 1259 OID 21885)
-- Name: component_rope_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_rope_fk_type_idx ON reference.component_rope USING btree (fk_component_type_id);


--
-- TOC entry 5132 (class 1259 OID 21886)
-- Name: component_shared_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_shared_fk_idx ON reference.component_shared USING btree (fk_component_id);


--
-- TOC entry 5135 (class 1259 OID 21887)
-- Name: component_transformer_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_transformer_fk_idx ON reference.component_transformer USING btree (fk_component_discrete_id);


--
-- TOC entry 5136 (class 1259 OID 21888)
-- Name: component_transformer_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX component_transformer_fk_type_idx ON reference.component_transformer USING btree (fk_component_type_id);


--
-- TOC entry 5217 (class 1259 OID 21889)
-- Name: vehicle_helicopter_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_helicopter_fk_idx ON reference.vehicle_helicopter USING btree (fk_vehicle_id);


--
-- TOC entry 5218 (class 1259 OID 21890)
-- Name: vehicle_helicopter_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_helicopter_fk_type_idx ON reference.vehicle_helicopter USING btree (fk_vehicle_type_id);


--
-- TOC entry 5221 (class 1259 OID 21891)
-- Name: vehicle_shared_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_shared_fk_idx ON reference.vehicle_shared USING btree (fk_vehicle_id);


--
-- TOC entry 5226 (class 1259 OID 21892)
-- Name: vehicle_vessel_anchor_handling_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_anchor_handling_fk_idx ON reference.vehicle_vessel_anchor_handling USING btree (fk_vehicle_id);


--
-- TOC entry 5227 (class 1259 OID 21893)
-- Name: vehicle_vessel_anchor_handling_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_anchor_handling_fk_type_idx ON reference.vehicle_vessel_anchor_handling USING btree (fk_vehicle_type_id);


--
-- TOC entry 5230 (class 1259 OID 21894)
-- Name: vehicle_vessel_cable_laying_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_cable_laying_fk_idx ON reference.vehicle_vessel_cable_laying USING btree (fk_vehicle_id);


--
-- TOC entry 5231 (class 1259 OID 21895)
-- Name: vehicle_vessel_cable_laying_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_cable_laying_fk_type_idx ON reference.vehicle_vessel_cable_laying USING btree (fk_vehicle_type_id);


--
-- TOC entry 5234 (class 1259 OID 21896)
-- Name: vehicle_vessel_cargo_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_cargo_fk_idx ON reference.vehicle_vessel_cargo USING btree (fk_vehicle_id);


--
-- TOC entry 5235 (class 1259 OID 21897)
-- Name: vehicle_vessel_cargo_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_cargo_fk_type_idx ON reference.vehicle_vessel_cargo USING btree (fk_vehicle_type_id);


--
-- TOC entry 5238 (class 1259 OID 21898)
-- Name: vehicle_vessel_jackup_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_jackup_fk_idx ON reference.vehicle_vessel_jackup USING btree (fk_vehicle_id);


--
-- TOC entry 5239 (class 1259 OID 21899)
-- Name: vehicle_vessel_jackup_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_jackup_fk_type_idx ON reference.vehicle_vessel_jackup USING btree (fk_vehicle_type_id);


--
-- TOC entry 5242 (class 1259 OID 21900)
-- Name: vehicle_vessel_tugboat_fk_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_tugboat_fk_idx ON reference.vehicle_vessel_tugboat USING btree (fk_vehicle_id);


--
-- TOC entry 5243 (class 1259 OID 21901)
-- Name: vehicle_vessel_tugboat_fk_type_idx; Type: INDEX; Schema: reference; Owner: -
--

CREATE INDEX vehicle_vessel_tugboat_fk_type_idx ON reference.vehicle_vessel_tugboat USING btree (fk_vehicle_type_id);


--
-- TOC entry 5247 (class 2606 OID 21902)
-- Name: bathymetry bathymetry_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry
    ADD CONSTRAINT bathymetry_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5248 (class 2606 OID 21907)
-- Name: bathymetry_layer bathymetry_layer_fk_bathymetry_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry_layer
    ADD CONSTRAINT bathymetry_layer_fk_bathymetry_id_fkey FOREIGN KEY (fk_bathymetry_id) REFERENCES project.bathymetry(id);


--
-- TOC entry 5249 (class 2606 OID 21912)
-- Name: bathymetry_layer bathymetry_layer_fk_soil_type_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.bathymetry_layer
    ADD CONSTRAINT bathymetry_layer_fk_soil_type_id_fkey FOREIGN KEY (fk_soil_type_id) REFERENCES reference.soil_type(id);


--
-- TOC entry 5250 (class 2606 OID 21917)
-- Name: cable_corridor_bathymetry cable_corridor_bathymetry_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry
    ADD CONSTRAINT cable_corridor_bathymetry_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5251 (class 2606 OID 21922)
-- Name: cable_corridor_bathymetry_layer cable_corridor_bathymetry_layer_fk_bathymetry_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry_layer
    ADD CONSTRAINT cable_corridor_bathymetry_layer_fk_bathymetry_id_fkey FOREIGN KEY (fk_bathymetry_id) REFERENCES project.cable_corridor_bathymetry(id);


--
-- TOC entry 5252 (class 2606 OID 21927)
-- Name: cable_corridor_bathymetry_layer cable_corridor_bathymetry_layer_fk_soil_type_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_bathymetry_layer
    ADD CONSTRAINT cable_corridor_bathymetry_layer_fk_soil_type_id_fkey FOREIGN KEY (fk_soil_type_id) REFERENCES reference.soil_type(id);


--
-- TOC entry 5253 (class 2606 OID 21932)
-- Name: cable_corridor_constraint cable_corridor_constraint_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.cable_corridor_constraint
    ADD CONSTRAINT cable_corridor_constraint_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5254 (class 2606 OID 21937)
-- Name: constraint constraint_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project."constraint"
    ADD CONSTRAINT constraint_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5255 (class 2606 OID 21942)
-- Name: device_floating device_floating_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_floating
    ADD CONSTRAINT device_floating_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5256 (class 2606 OID 21947)
-- Name: device_shared device_shared_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_shared
    ADD CONSTRAINT device_shared_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5257 (class 2606 OID 21952)
-- Name: device_tidal device_tidal_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal
    ADD CONSTRAINT device_tidal_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5258 (class 2606 OID 21957)
-- Name: device_tidal_power_performance device_tidal_power_performance_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_tidal_power_performance
    ADD CONSTRAINT device_tidal_power_performance_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5259 (class 2606 OID 21962)
-- Name: device_wave device_wave_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.device_wave
    ADD CONSTRAINT device_wave_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5260 (class 2606 OID 21967)
-- Name: lease_area lease_area_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.lease_area
    ADD CONSTRAINT lease_area_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5261 (class 2606 OID 21972)
-- Name: sub_systems_access sub_systems_access_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_access
    ADD CONSTRAINT sub_systems_access_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5262 (class 2606 OID 21977)
-- Name: sub_systems_economic sub_systems_economic_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_economic
    ADD CONSTRAINT sub_systems_economic_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5246 (class 2606 OID 21982)
-- Name: sub_systems sub_systems_fk_device_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems
    ADD CONSTRAINT sub_systems_fk_device_id_fkey FOREIGN KEY (fk_device_id) REFERENCES project.device(id);


--
-- TOC entry 5263 (class 2606 OID 21987)
-- Name: sub_systems_inspection sub_systems_inspection_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_inspection
    ADD CONSTRAINT sub_systems_inspection_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5264 (class 2606 OID 21992)
-- Name: sub_systems_install sub_systems_install_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_install
    ADD CONSTRAINT sub_systems_install_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5265 (class 2606 OID 21997)
-- Name: sub_systems_maintenance sub_systems_maintenance_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_maintenance
    ADD CONSTRAINT sub_systems_maintenance_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5266 (class 2606 OID 22002)
-- Name: sub_systems_operation_weightings sub_systems_operation_weightings_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_operation_weightings
    ADD CONSTRAINT sub_systems_operation_weightings_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5267 (class 2606 OID 22007)
-- Name: sub_systems_replace sub_systems_replace_fk_sub_system_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.sub_systems_replace
    ADD CONSTRAINT sub_systems_replace_fk_sub_system_id_fkey FOREIGN KEY (fk_sub_system_id) REFERENCES project.sub_systems(id);


--
-- TOC entry 5268 (class 2606 OID 22012)
-- Name: time_series_energy_tidal time_series_energy_tidal_fk_bathymetry_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_tidal
    ADD CONSTRAINT time_series_energy_tidal_fk_bathymetry_id_fkey FOREIGN KEY (fk_bathymetry_id) REFERENCES project.bathymetry(id);


--
-- TOC entry 5269 (class 2606 OID 22017)
-- Name: time_series_energy_wave time_series_energy_wave_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_energy_wave
    ADD CONSTRAINT time_series_energy_wave_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5270 (class 2606 OID 22022)
-- Name: time_series_om_tidal time_series_om_tidal_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_tidal
    ADD CONSTRAINT time_series_om_tidal_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5271 (class 2606 OID 22027)
-- Name: time_series_om_wave time_series_om_wave_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wave
    ADD CONSTRAINT time_series_om_wave_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5272 (class 2606 OID 22032)
-- Name: time_series_om_wind time_series_om_wind_fk_site_id_fkey; Type: FK CONSTRAINT; Schema: project; Owner: -
--

ALTER TABLE ONLY project.time_series_om_wind
    ADD CONSTRAINT time_series_om_wind_fk_site_id_fkey FOREIGN KEY (fk_site_id) REFERENCES project.site(id);


--
-- TOC entry 5273 (class 2606 OID 22037)
-- Name: component_anchor component_anchor_fk_component_discrete_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_anchor
    ADD CONSTRAINT component_anchor_fk_component_discrete_id_fkey FOREIGN KEY (fk_component_discrete_id) REFERENCES reference.component_discrete(id);


--
-- TOC entry 5274 (class 2606 OID 22042)
-- Name: component_anchor component_anchor_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_anchor
    ADD CONSTRAINT component_anchor_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5275 (class 2606 OID 22047)
-- Name: component_cable component_cable_fk_component_continuous_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_cable
    ADD CONSTRAINT component_cable_fk_component_continuous_id_fkey FOREIGN KEY (fk_component_continuous_id) REFERENCES reference.component_continuous(id);


--
-- TOC entry 5276 (class 2606 OID 22052)
-- Name: component_cable component_cable_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_cable
    ADD CONSTRAINT component_cable_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5277 (class 2606 OID 22057)
-- Name: component_collection_point component_collection_point_fk_component_discrete_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_collection_point
    ADD CONSTRAINT component_collection_point_fk_component_discrete_id_fkey FOREIGN KEY (fk_component_discrete_id) REFERENCES reference.component_discrete(id);


--
-- TOC entry 5278 (class 2606 OID 22062)
-- Name: component_collection_point component_collection_point_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_collection_point
    ADD CONSTRAINT component_collection_point_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5279 (class 2606 OID 22067)
-- Name: component_connector component_connector_fk_component_discrete_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_connector
    ADD CONSTRAINT component_connector_fk_component_discrete_fkey FOREIGN KEY (fk_component_discrete_id) REFERENCES reference.component_discrete(id);


--
-- TOC entry 5280 (class 2606 OID 22072)
-- Name: component_connector component_connector_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_connector
    ADD CONSTRAINT component_connector_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5281 (class 2606 OID 22077)
-- Name: component_continuous component_continuous_fk_component_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_continuous
    ADD CONSTRAINT component_continuous_fk_component_id_fkey FOREIGN KEY (fk_component_id) REFERENCES reference.component(id);


--
-- TOC entry 5282 (class 2606 OID 22082)
-- Name: component_discrete component_discrete_fk_component_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_discrete
    ADD CONSTRAINT component_discrete_fk_component_id_fkey FOREIGN KEY (fk_component_id) REFERENCES reference.component(id);


--
-- TOC entry 5283 (class 2606 OID 22087)
-- Name: component_mooring_continuous component_mooring_continuous_fk_component_continuous_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_continuous
    ADD CONSTRAINT component_mooring_continuous_fk_component_continuous_id_fkey FOREIGN KEY (fk_component_continuous_id) REFERENCES reference.component_continuous(id);


--
-- TOC entry 5284 (class 2606 OID 22092)
-- Name: component_mooring_continuous component_mooring_continuous_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_continuous
    ADD CONSTRAINT component_mooring_continuous_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5285 (class 2606 OID 22097)
-- Name: component_mooring_discrete component_mooring_discrete_fk_component_discrete_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_discrete
    ADD CONSTRAINT component_mooring_discrete_fk_component_discrete_id_fkey FOREIGN KEY (fk_component_discrete_id) REFERENCES reference.component_discrete(id);


--
-- TOC entry 5286 (class 2606 OID 22102)
-- Name: component_mooring_discrete component_mooring_discrete_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_mooring_discrete
    ADD CONSTRAINT component_mooring_discrete_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5287 (class 2606 OID 22107)
-- Name: component_pile component_pile_fk_component_continuous_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_pile
    ADD CONSTRAINT component_pile_fk_component_continuous_id_fkey FOREIGN KEY (fk_component_continuous_id) REFERENCES reference.component_continuous(id);


--
-- TOC entry 5288 (class 2606 OID 22112)
-- Name: component_pile component_pile_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_pile
    ADD CONSTRAINT component_pile_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5289 (class 2606 OID 22117)
-- Name: component_rope component_rope_fk_component_continuous_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_rope
    ADD CONSTRAINT component_rope_fk_component_continuous_id_fkey FOREIGN KEY (fk_component_continuous_id) REFERENCES reference.component_continuous(id);


--
-- TOC entry 5290 (class 2606 OID 22122)
-- Name: component_rope component_rope_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_rope
    ADD CONSTRAINT component_rope_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5291 (class 2606 OID 22127)
-- Name: component_shared component_shared_fk_component_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_shared
    ADD CONSTRAINT component_shared_fk_component_id_fkey FOREIGN KEY (fk_component_id) REFERENCES reference.component(id);


--
-- TOC entry 5292 (class 2606 OID 22132)
-- Name: component_transformer component_transformer_fk_component_discrete_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_transformer
    ADD CONSTRAINT component_transformer_fk_component_discrete_id_fkey FOREIGN KEY (fk_component_discrete_id) REFERENCES reference.component_discrete(id);


--
-- TOC entry 5293 (class 2606 OID 22137)
-- Name: component_transformer component_transformer_fk_component_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.component_transformer
    ADD CONSTRAINT component_transformer_fk_component_type_id_fkey FOREIGN KEY (fk_component_type_id) REFERENCES reference.component_type(id);


--
-- TOC entry 5294 (class 2606 OID 22142)
-- Name: operations_limit_cs operations_limit_cs_fk_operations_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_cs
    ADD CONSTRAINT operations_limit_cs_fk_operations_id_fkey FOREIGN KEY (fk_operations_id) REFERENCES reference.operations_type(id);


--
-- TOC entry 5295 (class 2606 OID 22147)
-- Name: operations_limit_hs operations_limit_hs_fk_operations_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_hs
    ADD CONSTRAINT operations_limit_hs_fk_operations_id_fkey FOREIGN KEY (fk_operations_id) REFERENCES reference.operations_type(id);


--
-- TOC entry 5296 (class 2606 OID 22152)
-- Name: operations_limit_tp operations_limit_tp_fk_operations_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_tp
    ADD CONSTRAINT operations_limit_tp_fk_operations_id_fkey FOREIGN KEY (fk_operations_id) REFERENCES reference.operations_type(id);


--
-- TOC entry 5297 (class 2606 OID 22157)
-- Name: operations_limit_ws operations_limit_ws_fk_operations_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.operations_limit_ws
    ADD CONSTRAINT operations_limit_ws_fk_operations_id_fkey FOREIGN KEY (fk_operations_id) REFERENCES reference.operations_type(id);


--
-- TOC entry 5298 (class 2606 OID 22162)
-- Name: soil_type_geotechnical_properties soil_type_geotechnical_properties_fk_soil_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.soil_type_geotechnical_properties
    ADD CONSTRAINT soil_type_geotechnical_properties_fk_soil_type_id_fkey FOREIGN KEY (fk_soil_type_id) REFERENCES reference.soil_type(id);


--
-- TOC entry 5299 (class 2606 OID 22167)
-- Name: vehicle_helicopter vehicle_helicopter_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_helicopter
    ADD CONSTRAINT vehicle_helicopter_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5300 (class 2606 OID 22172)
-- Name: vehicle_helicopter vehicle_helicopter_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_helicopter
    ADD CONSTRAINT vehicle_helicopter_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


--
-- TOC entry 5301 (class 2606 OID 22177)
-- Name: vehicle_shared vehicle_shared_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_shared
    ADD CONSTRAINT vehicle_shared_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5302 (class 2606 OID 22182)
-- Name: vehicle_vessel_anchor_handling vehicle_vessel_anchor_handling_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_anchor_handling
    ADD CONSTRAINT vehicle_vessel_anchor_handling_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5303 (class 2606 OID 22187)
-- Name: vehicle_vessel_anchor_handling vehicle_vessel_anchor_handling_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_anchor_handling
    ADD CONSTRAINT vehicle_vessel_anchor_handling_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


--
-- TOC entry 5304 (class 2606 OID 22192)
-- Name: vehicle_vessel_cable_laying vehicle_vessel_cable_laying_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cable_laying
    ADD CONSTRAINT vehicle_vessel_cable_laying_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5305 (class 2606 OID 22197)
-- Name: vehicle_vessel_cable_laying vehicle_vessel_cable_laying_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cable_laying
    ADD CONSTRAINT vehicle_vessel_cable_laying_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


--
-- TOC entry 5306 (class 2606 OID 22202)
-- Name: vehicle_vessel_cargo vehicle_vessel_cargo_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cargo
    ADD CONSTRAINT vehicle_vessel_cargo_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5307 (class 2606 OID 22207)
-- Name: vehicle_vessel_cargo vehicle_vessel_cargo_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_cargo
    ADD CONSTRAINT vehicle_vessel_cargo_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


--
-- TOC entry 5308 (class 2606 OID 22212)
-- Name: vehicle_vessel_jackup vehicle_vessel_jackup_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_jackup
    ADD CONSTRAINT vehicle_vessel_jackup_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5309 (class 2606 OID 22217)
-- Name: vehicle_vessel_jackup vehicle_vessel_jackup_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_jackup
    ADD CONSTRAINT vehicle_vessel_jackup_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


--
-- TOC entry 5310 (class 2606 OID 22222)
-- Name: vehicle_vessel_tugboat vehicle_vessel_tugboat_fk_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_tugboat
    ADD CONSTRAINT vehicle_vessel_tugboat_fk_vehicle_id_fkey FOREIGN KEY (fk_vehicle_id) REFERENCES reference.vehicle(id);


--
-- TOC entry 5311 (class 2606 OID 22227)
-- Name: vehicle_vessel_tugboat vehicle_vessel_tugboat_fk_vehicle_type_id_fkey; Type: FK CONSTRAINT; Schema: reference; Owner: -
--

ALTER TABLE ONLY reference.vehicle_vessel_tugboat
    ADD CONSTRAINT vehicle_vessel_tugboat_fk_vehicle_type_id_fkey FOREIGN KEY (fk_vehicle_type_id) REFERENCES reference.vehicle_type(id);


-- Completed on 2025-03-18 12:25:57 UTC

--
-- PostgreSQL database dump complete
--

