import json
import os

import psycopg
import pytest
from psycopg.rows import dict_row


@pytest.fixture(scope="module")
def db_examples_name():
    name = os.environ.get("DTOCEAN_DB_EXAMPLES_NAME")
    if not name:
        name = "dtocean_examples"
    return name


@pytest.fixture(scope="module")
def db_template_name():
    name = os.environ.get("DTOCEAN_DB_TEMPLATE_NAME")
    if not name:
        name = "dtocean_template"
    return name


@pytest.fixture(scope="module")
def dtocean_user_name():
    name = os.environ.get("DTOCEAN_USER_NAME")
    if not name:
        name = "dtocean_user"
    return name


@pytest.fixture(scope="module")
def dtocean_user_pwd():
    pwd = os.environ.get("DTOCEAN_USER_PASSWORD")
    if not pwd:
        pytest.skip("DTOCEAN_USER_PASSWORD environment variable must be set")
    return pwd


@pytest.fixture(scope="module")
def postgres_port():
    port = os.environ.get("POSTGRES_PORT")
    if not port:
        port = "5432"
    return port


@pytest.mark.parametrize(
    "db_name_fix",
    ["db_examples_name", "db_template_name"],
)
def test_db_comment(
    request,
    postgres_port,
    dtocean_user_name,
    dtocean_user_pwd,
    db_name_fix,
):
    db_name = request.getfixturevalue(db_name_fix)

    with psycopg.connect(
        f"host=localhost "
        f"port={postgres_port} "
        f"dbname={db_name} "
        f"user={dtocean_user_name} "
        f"password={dtocean_user_pwd}"
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(f"""
    SELECT pg_catalog.shobj_description(d.oid, 'pg_database') AS "Description"
        FROM   pg_catalog.pg_database d
        WHERE  datname = '{db_name}';
    """)
            result = cur.fetchone()

    assert len(result) == 1
    meta = json.loads(result[0])
    assert "version" in meta


@pytest.mark.parametrize(
    "db_name_fix",
    ["db_examples_name", "db_template_name"],
)
def test_table_ownership(
    request,
    postgres_port,
    dtocean_user_name,
    dtocean_user_pwd,
    db_name_fix,
):
    with psycopg.connect(
        f"host=localhost "
        f"port={postgres_port} "
        f"dbname={request.getfixturevalue(db_name_fix)} "
        f"user={dtocean_user_name} "
        f"password={dtocean_user_pwd}",
        row_factory=dict_row,
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(f"""
                SELECT *
                    FROM pg_tables 
                    WHERE tableowner = '{dtocean_user_name}';
                """)
            result = cur.fetchall()

    owners = [x["tableowner"] for x in result]
    assert set(owners) == set([dtocean_user_name])


@pytest.mark.parametrize(
    "db_name_fix,schemas,n_tables",
    [
        ("db_examples_name", ("project", "reference"), 88),
        ("db_template_name", ("reference",), 61),
    ],
)
def test_n_tables(
    request,
    postgres_port,
    dtocean_user_name,
    dtocean_user_pwd,
    db_name_fix,
    schemas,
    n_tables,
):
    schemas_quoted = [f"'{x}'" for x in schemas]
    with psycopg.connect(
        f"host=localhost "
        f"port={postgres_port} "
        f"dbname={request.getfixturevalue(db_name_fix)} "
        f"user={dtocean_user_name} "
        f"password={dtocean_user_pwd}",
        row_factory=dict_row,
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(f"""
        WITH tbl AS (
            SELECT Table_Schema, Table_Name
            FROM   information_schema.Tables
            WHERE  Table_Name NOT LIKE 'pg_%'
                AND Table_Schema IN ({",".join(schemas_quoted)})
                AND table_type != 'VIEW'
        )
        SELECT  Table_Schema AS Schema_Name
        ,       Table_Name
        FROM    tbl
        """)
            result = cur.fetchall()

    assert len(result) == n_tables


@pytest.mark.parametrize(
    "db_name_fix,schemas",
    [
        ("db_examples_name", ("project", "reference")),
        ("db_template_name", ("reference",)),
    ],
)
def test_non_empty_tables(
    request,
    postgres_port,
    dtocean_user_name,
    dtocean_user_pwd,
    db_name_fix,
    schemas,
):
    schemas_quoted = [f"'{x}'" for x in schemas]
    with psycopg.connect(
        f"host=localhost "
        f"port={postgres_port} "
        f"dbname={request.getfixturevalue(db_name_fix)} "
        f"user={dtocean_user_name} "
        f"password={dtocean_user_pwd}",
        row_factory=dict_row,
    ) as conn:
        with conn.cursor() as cur:
            cur.execute(f"""
        WITH tbl AS (
            SELECT Table_Schema, Table_Name
            FROM   information_schema.Tables
            WHERE  Table_Name NOT LIKE 'pg_%'
                AND Table_Schema IN ({",".join(schemas_quoted)})
                AND table_type != 'VIEW'
        )
        SELECT  Table_Schema AS Schema_Name
        ,       Table_Name
        ,       (xpath('/row/c/text()', query_to_xml(format(
                'SELECT count(*) AS c FROM %I.%I', Table_Schema, Table_Name
                ), FALSE, TRUE, '')))[1]::text::int AS Records_Count
        FROM    tbl
        ORDER   BY Records_Count DESC;
                """)
            result = cur.fetchall()

    known_empty = ["device_wave", "cable_corridor_constraint"]
    count = [
        x["records_count"] for x in result if x["table_name"] not in known_empty
    ]

    assert all(x > 0 for x in count)
