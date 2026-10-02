--changeset tva:001-tva-schema
-- DDL de las tablas TVA (PostgreSQL). Equivalente a `manage.py sqlmigrate tva 0001`
-- pero adaptado a PostgreSQL: UUID nativo, JSONB, timestamptz y BOOLEAN reales.

CREATE TABLE tva_sesion (
    clave            uuid        NOT NULL PRIMARY KEY,
    usuario          varchar(128) NOT NULL,
    modalidad        varchar(8)  NOT NULL,
    canal            varchar(8)  NOT NULL,
    pantalla_actual  varchar(64) NOT NULL,
    version_esquema  integer     NOT NULL DEFAULT 1 CHECK (version_esquema >= 0),
    estado           jsonb       NOT NULL DEFAULT '{}'::jsonb,
    abierta          boolean     NOT NULL DEFAULT true,
    creado           timestamptz NOT NULL DEFAULT now(),
    actualizado      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_tva_sesion_usuario ON tva_sesion (usuario);

CREATE TABLE tva_traza (
    id              bigserial    PRIMARY KEY,
    sesion_id       uuid         NULL REFERENCES tva_sesion (clave) DEFERRABLE INITIALLY DEFERRED,
    clave_sesion    varchar(64)  NOT NULL DEFAULT '',
    tipo_contenido  varchar(64)  NOT NULL DEFAULT '',
    clase           varchar(8)   NOT NULL DEFAULT 'INFO',
    mensaje         text         NOT NULL DEFAULT '',
    datos           jsonb        NOT NULL DEFAULT '{}'::jsonb,
    creado          timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX idx_tva_traza_clave_sesion ON tva_traza (clave_sesion);
CREATE INDEX idx_tva_traza_sesion ON tva_traza (sesion_id);

CREATE TABLE tva_parametro (
    id           bigserial   PRIMARY KEY,
    clave        varchar(128) NOT NULL UNIQUE,
    valor        text         NOT NULL DEFAULT '',
    tipo         varchar(8)   NOT NULL DEFAULT 'str',
    descripcion  text         NOT NULL DEFAULT '',
    entorno      varchar(16)  NULL,
    actualizado  timestamptz  NOT NULL DEFAULT now()
);
--rollback DROP TABLE tva_traza; DROP TABLE tva_sesion; DROP TABLE tva_parametro;
