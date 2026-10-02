export type TipoCampoConfiguracion = 'texto' | 'modo' | 'entero' | 'secreto';

/** Campo de configuración de un conector. Los secretos llegan con `valor: null`. */
export interface CampoConfiguracion {
  nombre: string;
  grupo: string;
  grupoEtiqueta: string;
  etiqueta: string;
  tipo: TipoCampoConfiguracion;
  valor: string | null;
  configurado: boolean;
  origen: 'bd' | 'entorno';
}

export interface CambioConfiguracion {
  valores: Record<string, string>;
  restablecer: string[];
}

export interface ResultadoPruebaConfiguracion {
  ok: boolean;
  salida: string;
}
