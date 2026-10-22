import {
  calcularContadoresResumen,
  PESTANAS_FICHA_PRINCIPALES,
  PESTANAS_POSICION,
  ORDEN_CABECERA_CLIENTE_SAIL,
} from './ficha-cliente-page.component';
import {
  PESTANAS_COMUNICACIONES,
  PESTANAS_MAS_DATOS,
} from '../components/acciones-cliente.component';
import {
  COLUMNAS_VENCIMIENTOS_SAIL,
  PESTANAS_GESTION_COMERCIAL,
} from '../components/gestion-comercial-cliente.component';
import {
  dispatchPestanasPoliza,
  VISTAS_POLIZA_SAIL,
} from './poliza-page.component';
import { PESTANAS_PAGADOR, PESTANAS_RECIBO } from './recibo-page.component';
import {
  PESTANAS_GESTION_CARTERA,
  PESTANAS_MODALIDAD_SALUD,
  PESTANAS_MODALIDAD_VIDA,
  PESTANAS_NUEVA_PRODUCCION,
  PESTANAS_PRESTACIONES,
} from './lanzaderas-ramo-page.component';

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

  it('agrega RIESGO en Vida al cargar la posición y conserva Ahorro', () => {
    const contadores = calcularContadoresResumen(
      [
        { ramo: 'AUTOS', estado: 'EN_VIGOR' },
        { ramo: 'HOGAR', estado: 'EN_VIGOR' },
        { ramo: 'SALUD', estado: 'EN_VIGOR' },
        { ramo: 'RIESGO', estado: 'EN_VIGOR' },
        { ramo: 'RIESGO', estado: 'ANULADA' },
        { ramo: 'AHORRO', estado: 'EN_VIGOR' },
      ],
      [{ ramo: 'RIESGO' }],
      [{ ramo: 'AHORRO' }],
    );

    expect(contadores.AUTOS.polizas).toBe(1);
    expect(contadores.HOGAR.polizas).toBe(1);
    expect(contadores.SALUD.polizas).toBe(1);
    expect(contadores.VIDA).toEqual({ polizas: 1, vencimientos: 1, presupuestos: 0 });
    expect(contadores.AHORRO).toEqual({ polizas: 1, vencimientos: 0, presupuestos: 1 });
    expect('RIESGO' in contadores).toBe(false);
  });

  it('mantiene recibo y pagador', () => {
    expect(PESTANAS_RECIBO).toEqual(['Datos Generales', 'Desglose económico', 'Gestiones']);
    expect(PESTANAS_PAGADOR).toEqual(['Datos Personales', 'Contacto', 'Correspondencia']);
  });

  it('reproduce literales y orden de la cabecera de cliente viva', () => {
    expect(ORDEN_CABECERA_CLIENTE_SAIL).toEqual([
      'Métodos de contacto cliente',
      'Nuevo email',
      'Nuevo fijo',
      'Nuevo móvil',
      'Alertas urgentes',
      'Avisos e interacciones',
      'Refrescar ficha',
      'DNI',
      'RGPD',
      'ACI',
      'En Familia',
      'Plan de pagos',
      'ClubMAPFRE',
      'Descuento vinculación',
      'Total prima (Tomador/Titular)',
      'Posición bancaria',
    ]);
  });

  it('mantiene el orden literal de columnas de Vencimientos', () => {
    expect(COLUMNAS_VENCIMIENTOS_SAIL).toEqual([
      'Venc. / Oport.',
      'Clase de Vcto.',
      'Producto / Riesgo',
      'F. Venci. / Opor.',
      'Prima / Saldo',
      'Entidad competencia',
      'Usuario',
      'Comentarios',
      'Anexos',
    ]);
  });

  it('mantiene el orden de pestañas de las páginas del site', () => {
    expect(PESTANAS_GESTION_CARTERA).toEqual([
      'Agropecuario',
      'Automóviles',
      'Empresas',
      'Patrimoniales',
      'Salud',
      'Vida',
    ]);
    expect(PESTANAS_PRESTACIONES).toEqual(['Automóviles', 'Salud']);
    expect(PESTANAS_NUEVA_PRODUCCION).toEqual([
      'Agropecuario',
      'Ahorro',
      'Automóviles',
      'Empresas',
      'Patrimoniales',
      'Salud',
      'Vida',
    ]);
    expect(PESTANAS_MODALIDAD_SALUD).toEqual(['Particulares']);
    expect(PESTANAS_MODALIDAD_VIDA).toEqual(['Particulares', 'Colectivos']);
  });

  it('reproduce títulos y columnas literales de las cajas SAIL de póliza', () => {
    expect(VISTAS_POLIZA_SAIL.AUTOS['Coberturas'][0]).toMatchObject({
      titulo: 'Coberturas y garantias',
      columnas: ['Coberturas', 'Suma asegurada'],
    });
    expect(VISTAS_POLIZA_SAIL.VIDA['Intervinientes'].map((caja) => caja.titulo)).toEqual([
      'Tomador',
      'Asegurados',
      'Beneficiarios',
    ]);
    expect(VISTAS_POLIZA_SAIL.VIDA['Intervinientes'][2].columnas).toEqual([
      'Suceso',
      'Beneficiarios',
    ]);
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
