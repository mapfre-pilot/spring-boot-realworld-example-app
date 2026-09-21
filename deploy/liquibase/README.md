# Liquibase SMK

Changelogs para las tablas de `SMK Pruebas de Humo` en PostgreSQL/Aurora, mediante el Connected System `SMK Database AWS`, esquema `smk_pruebashumo`.

## Estructura

- `db.changelog-master.xml`: entrada principal, en orden `smk_test`, `smk_ejecucion`, `smk_resultado`, `smk_programacion` y carga inicial del catálogo.
- `changes/01_smk_test.xml` … `04_smk_programacion.xml`: tablas, restricciones e índices.
- `changes/05_smk_catalogo_data.xml`: carga de `data/smk_test.csv` sólo cuando `smk_test` está vacía.
- `changes/data/smk_test.csv`: catálogo inicial de 124 entradas generado desde `sail/SMK_catalogoBase.sail`.

## Ejecución

Desde la raíz del repositorio, contra la URL JDBC PostgreSQL del entorno destino:

```bash
liquibase --changelog-file=deploy/liquibase/db.changelog-master.xml \
  --url="jdbc:postgresql://<host>:5432/<base>?currentSchema=smk_pruebashumo" \
  --default-schema-name=smk_pruebashumo \
  --username=<usuario> --password=<password> update
```

En cada entorno, el esquema `smk_pruebashumo` y el usuario de BD del Connected System `SMK Database AWS` deben existir previamente; los crea/prepara el DBA. Liquibase crea las tablas y luego se importan los record types apuntando a ese CS. El *changeSet* de datos sólo se ejecuta sobre una tabla `smk_test` vacía; después, el catálogo se gestiona desde el site mediante **Sincronizar catálogo**. `01_ddl_smk.sql` y `02_catalogo_smk.sql` se mantienen como fallback legado de MariaDB/`jdbc-Appian`, no como destino actual.
