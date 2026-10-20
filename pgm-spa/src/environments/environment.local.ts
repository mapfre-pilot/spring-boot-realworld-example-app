/** Perfil local: sin OIDC; el dev-server (proxy.conf.json) o nginx reenvía /api al BFF local. */
export const environment = {
  production: false,
  bffUrl: '',
  /** Texto de la franja de entorno (vacío en PRO: sin franja). */
  entorno: 'Entorno LOCAL · datos sintéticos',
  auth: {
    enabled: false,
    tenantId: '',
    clientId: '',
    scopes: [] as string[],
  },
};
