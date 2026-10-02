--liquibase formatted sql

--changeset tva:002-tva-configuracion
-- Configuración de conectores editada desde Administración (secretos cifrados con Fernet).
CREATE TABLE tva_configuracion (
    id               bigserial    PRIMARY KEY,
    nombre           varchar(64)  NOT NULL UNIQUE,
    valor            text         NOT NULL DEFAULT '',
    secreto          boolean      NOT NULL DEFAULT false,
    actualizado      timestamptz  NOT NULL DEFAULT now(),
    actualizado_por  varchar(128) NOT NULL DEFAULT ''
);
--rollback DROP TABLE tva_configuracion;
