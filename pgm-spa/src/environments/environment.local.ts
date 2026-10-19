/** Perfil local: sin OIDC; el dev-server (proxy.conf.json) o nginx reenvía /api al BFF local. */
export const environment = {
  production: false,
  bffUrl: '',
  auth: {
    enabled: false,
    tenantId: '',
    clientId: '',
    scopes: [] as string[],
  },
};
