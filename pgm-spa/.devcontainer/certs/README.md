# Certificados corporativos (opcional)
Si tu red inspecciona TLS (error `SSL certificate problem: unable to get local issuer certificate`), copia aquí la CA raíz
de MAPFRE en formato PEM/Base-64 con extensión `.crt` (Windows: `certmgr.msc` → Entidades de certificación raíz de confianza →
exportar → «X.509 codificado base 64 (.CER)» → renombrar a `.crt`). Se instala en el sistema, en el `cacerts` de Java y en Node.
