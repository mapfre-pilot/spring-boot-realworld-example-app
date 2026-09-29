/** Constantes de presentación de sesion. */
import { Pantalla } from '@tva/core';

export const PASOS: Record<string, Pantalla[]> = {
  VA: [
    Pantalla.SEGUROS_AHORRO,
    Pantalla.CAPTURA_DATOS_SOLICITUD,
    Pantalla.CAPTURA_TOMADOR1,
    Pantalla.CAPTURA_TOMADOR2,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
  VIA: [
    Pantalla.SELECCION_PRODUCTO_AHORRO,
    Pantalla.MODALIDAD_CAMPANIA,
    Pantalla.CAPTURA_DATOS_SOLICITUD,
    Pantalla.CAPTURA_TOMADOR1,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
  R2C: [
    Pantalla.R2C_CAPTURA,
    Pantalla.R2C_PRECIOS,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
};
