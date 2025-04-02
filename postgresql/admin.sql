CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION postgis;

CREATE FUNCTION public.db_to_csv(path text) RETURNS void
    LANGUAGE plpgsql
    AS $$declare
    tables RECORD;
    statement TEXT;
begin
FOR tables IN 
    SELECT (table_schema || '.' || table_name) AS schema_table
    FROM information_schema.tables t INNER JOIN information_schema.schemata s 
    ON s.schema_name = t.table_schema 
    WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema')
    AND t.table_type NOT IN ('VIEW')
    ORDER BY schema_table
LOOP
    statement := 'COPY ' || tables.schema_table || ' TO ''' || path || '/' || tables.schema_table || '.csv' ||''' DELIMITER '';'' CSV HEADER';
    EXECUTE statement;
END LOOP;
return;
end;
$$;

CREATE FUNCTION public.db_from_csv(path text, VARIADIC tables text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$declare
    statement TEXT;
begin
FOR i IN
    array_lower(tables, 1)..array_upper(tables, 1)
LOOP
    statement := 'COPY ' || tables[i] || ' FROM ''' || path || '/' || tables[i] || '.csv' ||''' DELIMITER '';'' CSV HEADER';
    EXECUTE statement;
END LOOP;
return;
end;
$$;
