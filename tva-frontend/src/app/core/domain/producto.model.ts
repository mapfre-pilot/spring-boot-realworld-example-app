export interface Producto {
  code?: string;
  commercialProductCode: string;
  commercialProductDesc: string;
  unitLinkedInd?: boolean;
  garantias?: {
    codigo: string;
    descripcion: string;
    obligatoria: boolean;
    seleccionada?: boolean;
  }[];
  periodicidades?: string[];
  primaMinima?: number;
  primaMaxima?: number;
  opcionesInversion?: {
    investmentPreferenceCode: string;
    descripcion: string;
    seleccionada?: boolean;
  }[];
  requiereAsegurado?: boolean;
}
