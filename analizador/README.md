# appian_static_analyzer v3.0.0

Uso en GitHub Actions (solo zip + Health Check):

    python3 src/appian_static_analyzer.py paquete.zip \
        --health-check healthcheck.xlsx \
        --justifications justificaciones.json \
        --gate -o informe.json --verdict-json verdict.json --markdown resumen.md
    # exit: 0 APTO | 3 APTO_CON_CONDICIONES | 1 NO_APTO | 2 ERROR (entrada/cobertura)
    cat resumen.md >> "$GITHUB_STEP_SUMMARY"

Tests (los de regresión sobre exports reales se saltan si no existe fixtures/smk.zip y fixtures/adm.zip):

    python3 -m unittest discover -s tests -v

Ver CAMBIOS_v3.md para el detalle de reglas, formato del Health Check, justificaciones y configuración.
