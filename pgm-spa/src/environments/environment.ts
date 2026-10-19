/** Entorno corporativo: la SPA se sirve detrás de nginx, que reenvía /api al BFF; OIDC Entra ID activo. */
export const environment = {
  production: true,
  bffUrl: '',
  auth: {
    enabled: true,
    tenantId: '__ENTRA_TENANT_ID__',
    clientId: '__ENTRA_CLIENT_ID__',
    scopes: ['openid', 'profile', '__BFF_SCOPE__'],
  },
};
