export interface Parametro {
  clave: string;
  valor: string;
  tipo: 'str' | 'int' | 'bool' | 'json';
  descripcion: string;
  entorno: string | null;
  actualizado: string;
}

export interface Traza {
  id: number;
  clave_sesion: string;
  tipo_contenido: string;
  clase: 'INFO' | 'ERROR' | 'AVISO';
  mensaje: string;
  datos: Record<string, unknown>;
  creado: string;
}
