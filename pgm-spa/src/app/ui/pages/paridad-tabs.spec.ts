import { PESTANAS_FICHA_PRINCIPALES, PESTANAS_POSICION } from './ficha-cliente-page.component';
import {
  PESTANAS_COMUNICACIONES,
  PESTANAS_MAS_DATOS,
} from '../components/acciones-cliente.component';
import { PESTANAS_GESTION_COMERCIAL } from '../components/gestion-comercial-cliente.component';
import {
  pestanasPoliza,
  PESTANAS_AUTOS_INFO_GENERAL,
  PESTANAS_AUTOS_RIESGO,
  PESTANAS_AUTOS_FIGURAS_TOMADOR,
  PESTANAS_AUTOS_OBSERVACIONES,
  PESTANAS_HOGAR_RIESGO,
  PESTANAS_HOGAR_FIGURAS,
  PESTANAS_HOGAR_VIVIENDA,
  PESTANAS_HOGAR_TOMADOR,
  PESTANAS_HOGAR_ASEGURADO,
  PESTANAS_HOGAR_OBSERVACIONES,
  PESTANAS_AUTOS_SECCIONES,
  PESTANAS_HOGAR_SECCIONES,
} from './poliza-page.component';
import { PESTANAS_PAGADOR, PESTANAS_RECIBO } from './recibo-page.component';

describe('barras de pestañas de paridad PGM', () => {
  it('mantiene el orden de ficha y posición', () => {
    expect(PESTANAS_FICHA_PRINCIPALES).toEqual([
      'Posición del cliente',
      'Gestión comercial',
      'Presupuestos',
    ]);
    expect(PESTANAS_POSICION).toEqual([
      'Productos',
      'Estados Anteriores',
      'Prestaciones',
      'Recibos',
    ]);
  });

  it('mantiene recibo y pagador', () => {
    expect(PESTANAS_RECIBO).toEqual(['Datos Generales', 'Desglose económico', 'Gestiones']);
    expect(PESTANAS_PAGADOR).toEqual(['Datos Personales', 'Contacto', 'Correspondencia']);
  });

  it('mantiene comunicaciones, más datos y gestión comercial', () => {
    expect(PESTANAS_COMUNICACIONES).toEqual(['Alertas', 'Interacciones', 'Reclamaciones']);
    expect(PESTANAS_MAS_DATOS).toEqual(['Más datos', 'Datos de contacto', 'Origen de los datos']);
    expect(PESTANAS_GESTION_COMERCIAL).toEqual([
      'Vencimientos',
      'Actividad Comercial',
      'Gestiones',
    ]);
  });

  it('mantiene las pestañas anidadas de Autos y Hogar', () => {
    expect(PESTANAS_AUTOS_SECCIONES).toEqual([
      'Inf. general',
      'Riesgo',
      'Figuras tomador',
      'Observaciones',
    ]);
    expect(PESTANAS_HOGAR_SECCIONES).toEqual([
      'Riesgo',
      'Figuras',
      'Vivienda',
      'Tomador/Asegurado',
      'Observaciones',
    ]);
    expect(PESTANAS_AUTOS_INFO_GENERAL).toEqual([
      'Inf. general',
      'Figuras',
      'Coberturas',
      'Bonus malus',
      'Autorizaciones',
      'Pago',
      'Recibos',
      'Prestaciones',
    ]);
    expect(PESTANAS_AUTOS_RIESGO).toEqual([
      'Características',
      'Carrozados específicos',
      'Equipamientos',
      'Estado del vehículo',
    ]);
    expect(PESTANAS_AUTOS_FIGURAS_TOMADOR).toEqual([
      'Datos Generales',
      'Domicilios',
      'Formas de contacto',
    ]);
    expect(PESTANAS_AUTOS_OBSERVACIONES).toEqual([
      'Cláusulas generales',
      'Observaciones nivel póliza',
    ]);
    expect(PESTANAS_HOGAR_RIESGO).toEqual([
      'Objeto asegurado',
      'Protecciones',
      'Observaciones objeto asegurado',
    ]);
    expect(PESTANAS_HOGAR_FIGURAS).toEqual([
      'Datos Generales',
      'Domicilios',
      'Formas de contacto',
    ]);
    expect(PESTANAS_HOGAR_VIVIENDA).toEqual([
      'Información Catastro',
      'Datos de la vivienda',
      'Forma aseguramiento',
    ]);
    expect(PESTANAS_HOGAR_TOMADOR).toEqual([
      'Datos Personales',
      'Domicilio',
      'Contacto',
      'Correspondencia',
    ]);
    expect(PESTANAS_HOGAR_ASEGURADO).toEqual(['Datos Personales', 'Domicilio']);
    expect(PESTANAS_HOGAR_OBSERVACIONES).toEqual([
      'Cláusulas generales',
      'Observaciones nivel póliza',
    ]);
  });

  it.each([
    ['AUTOS', ['Vehículos', 'Coberturas', 'Intervinientes', 'Recibos', 'Prestaciones']],
    ['SALUD', ['Intervinientes', 'Coberturas', 'Recibos', 'Prestaciones']],
    [
      'VIDA',
      [
        'Intervinientes',
        'Estructura comercial',
        'Coberturas',
        'Recibos',
        'Prestaciones',
        'Documentos',
      ],
    ],
    ['HOGAR', ['Inf. general', 'Figuras', 'Coberturas', 'Autorizaciones', 'Pagos']],
    [
      'CONSUMO_PROTEGIDO',
      [
        'Inf. General',
        'Inf. Objeto Asegurado',
        'Fig. Participantes',
        'Coberturas/Garantías/Prestaciones',
        'Observaciones y Cláusulas',
        'Autorizaciones',
        'Entorno ec',
      ],
    ],
    [
      'HIPOTECA_SEGURA',
      [
        'Inf. General',
        'Inf. Objeto Asegurado',
        'Fig. Participantes',
        'Coberturas/Garantías/Prestaciones',
        'Observaciones y Cláusulas',
        'Autorizaciones',
        'Entorno ec',
      ],
    ],
    ['GENERICA', ['Recibos', 'Prestaciones']],
  ])('expone las pestañas de póliza para %s con idPoliza', (tipo, esperadas) => {
    expect(pestanasPoliza(tipo as Parameters<typeof pestanasPoliza>[0], 'POL-1')).toEqual(
      esperadas,
    );
  });

  it('reduce la ficha de póliza sin idPoliza a recibos y prestaciones', () => {
    expect(pestanasPoliza('AUTOS', null)).toEqual(['Recibos', 'Prestaciones']);
    expect(pestanasPoliza('VIDA', null)).toEqual(['Recibos', 'Prestaciones']);
    expect(pestanasPoliza('CONSUMO_PROTEGIDO', null)).toEqual(['Recibos', 'Prestaciones']);
    expect(pestanasPoliza('HIPOTECA_SEGURA', null)).toEqual(['Recibos', 'Prestaciones']);
    expect(pestanasPoliza('VIDA', 'POL-1', true)).toContain('Primas');
    expect(pestanasPoliza('VIDA', 'POL-1', false)).not.toContain('Primas');
  });
});
