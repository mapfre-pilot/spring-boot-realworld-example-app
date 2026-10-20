/** Entorno corporativo: la SPA se sirve detrás de nginx, que reenvía /api al BFF; OIDC Entra ID activo. */
export const environment = {
  production: true,
  bffUrl: '',
  /** Texto de la franja de entorno (vacío en PRO: sin franja). */
  entorno: '',
  auth: {
    enabled: true,
    tenantId: '__ENTRA_TENANT_ID__',
    clientId: 'c4d0e5f0-4a24-4b89-a577-bd2c809f972a',
    scopes: ['openid', 'profile', '__BFF_SCOPE__'],
  },
};
