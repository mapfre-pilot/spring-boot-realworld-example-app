import { PESTANAS_FICHA_PRINCIPALES, PESTANAS_POSICION } from './ficha-cliente-page.component';
import {
  PESTANAS_COMUNICACIONES,
  PESTANAS_MAS_DATOS,
} from '../components/acciones-cliente.component';
import { PESTANAS_GESTION_COMERCIAL } from '../components/gestion-comercial-cliente.component';
import {
  dispatchPestanasPoliza,
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

  it('aplica el dispatcher por ramo y número, respetando el orden SAIL', () => {
    expect(dispatchPestanasPoliza('AUTOS SANTANDER', 'AUT-000100', 'AUT-000100').pestanas).toEqual([
      'Vehículos',
      'Coberturas',
      'Intervinientes',
      'Recibos',
      'Prestaciones',
    ]);
    expect(dispatchPestanasPoliza('RIESGO', 'VID-000103', 'VID-000103').pestanas).toEqual([
      'Intervinientes',
      'Estructura comercial',
      'Coberturas',
      'Recibos',
      'Prestaciones',
      'Documentos',
    ]);
    expect(dispatchPestanasPoliza('RIESGO', 'RIE-0000011', null)).toEqual({
      tipoDetalle: 'VIDA',
      pestanas: ['Recibos', 'Prestaciones'],
    });
    expect(dispatchPestanasPoliza('RIESGO', 'RIE-00000011', 'RIE-00000011')).toEqual({
      tipoDetalle: 'GENERICA',
      pestanas: ['Recibos', 'Prestaciones'],
    });
    expect(dispatchPestanasPoliza('HOGAR', 'HOG-000101', 'HOG-000101')).toEqual({
      tipoDetalle: 'HOGAR',
      pestanas: [],
    });
    expect(dispatchPestanasPoliza('DECESOS', 'DEC-000201', 'DEC-000201')).toEqual({
      tipoDetalle: 'GENERICA',
      pestanas: ['Recibos', 'Prestaciones'],
    });
    expect(dispatchPestanasPoliza('SALUD', 'SAL-000102', 'SAL-000102').pestanas).toEqual([
      'Intervinientes',
      'Coberturas',
      'Recibos',
      'Prestaciones',
    ]);
  });

  it('aplica los casos sin idPoliza y la condición de primas periódicas', () => {
    expect(dispatchPestanasPoliza('SALUD', 'SAL-000102', null).pestanas).toEqual([
      'Recibos',
      'Prestaciones',
    ]);
    expect(dispatchPestanasPoliza('AUTOS', 'AUT-000100', null).pestanas).toEqual([
      'Recibos',
      'Prestaciones',
    ]);
    expect(
      dispatchPestanasPoliza('RIESGO', 'VID-000103', 'VID-000103', true).pestanas,
    ).toContain('Primas');
    expect(
      dispatchPestanasPoliza('RIESGO', 'VID-000103', 'VID-000103', false).pestanas,
    ).not.toContain('Primas');
  });
});
