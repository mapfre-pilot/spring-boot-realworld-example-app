# Liquibase SMK

Changelogs para las tablas de `SMK Pruebas de Humo` en `jdbc/Appian`.

## Estructura

- `db.changelog-master.xml`: entrada principal, en orden `SMK_TEST`, `SMK_EJECUCION`, `SMK_RESULTADO`, `SMK_PROGRAMACION` y carga inicial del catálogo.
- `changes/01_smk_test.xml` … `04_smk_programacion.xml`: tablas, restricciones e índices.
- `changes/05_smk_catalogo_data.xml`: carga de `data/smk_test.csv` sólo cuando `SMK_TEST` está vacía.
- `changes/data/smk_test.csv`: catálogo inicial generado desde `deploy/02_catalogo_smk.sql`.

## Ejecución

Desde la raíz del repositorio, contra la URL JDBC de `jdbc/Appian` del entorno destino:

```bash
liquibase --changelog-file=deploy/liquibase/db.changelog-master.xml \
  --url="jdbc:mariadb://<host>:<puerto>/<base>" \
  --username=<usuario> --password=<password> update
```

Configurar el driver y credenciales según la instalación de Liquibase. El *changeSet* de datos sólo se ejecuta sobre una tabla `SMK_TEST` vacía; después, el catálogo se gestiona desde el site mediante **Sincronizar catálogo**. `01_ddl_smk.sql` y `02_catalogo_smk.sql` se mantienen como fallback.
