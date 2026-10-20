/** Entorno corporativo: la SPA se sirve detrás de nginx, que reenvía /api al BFF; OIDC Entra ID activo. */
export const environment = {
  production: true,
  bffUrl: '',
  /** Texto de la franja de entorno (vacío en PRO: sin franja). */
  entorno: '',
  auth: {
    enabled: true,
    tenantId: '93ad25dd-8cdc-4066-9727-31a8a3024f80',
    clientId: 'c4d0e5f0-4a24-4b89-a577-bd2c809f972a',
    scopes: ['openid', 'profile', 'api://c4d0e5f0-4a24-4b89-a577-bd2c809f972a/pgm.acceso'],
  },
};
