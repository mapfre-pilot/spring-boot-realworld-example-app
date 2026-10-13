import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import {
  HttpTestingController,
  provideHttpClientTesting,
} from '@angular/common/http/testing';
import { environment } from '../../../environments/environment';
import { VencimientosApiRepository } from './vencimientos-api.repository';

describe('VencimientosApiRepository', () => {
  let repository: VencimientosApiRepository;
  let http: HttpTestingController;
  const mockRandomUUID = jest.fn(() => 'test-idempotency-key');

  beforeEach(() => {
    Object.defineProperty(globalThis.crypto, 'randomUUID', {
      configurable: true,
      value: mockRandomUUID,
    });
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        VencimientosApiRepository,
      ],
    });
    repository = TestBed.inject(VencimientosApiRepository);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('consulta expedientes con los criterios paginados', () => {
    repository
      .searchExpedientes({ anio: '2024', numero: '123', page: 0, size: 20 })
      .subscribe();

    const request = http.expectOne(
      (candidate) =>
        candidate.url === `${environment.bffUrl}/api/v1/expedientes`
    );
    expect(request.request.method).toBe('GET');
    expect(request.request.params.get('anio')).toBe('2024');
    expect(request.request.params.get('numero')).toBe('123');
    expect(request.request.params.get('size')).toBe('20');
    request.flush({ content: [], page: 0, size: 20, totalElements: 0 });
  });

  it('envía el cálculo al BFF sin calcular importes en el cliente', () => {
    const body = {
      capital: { importe: 100 },
      prima: { importe: 0 },
      complementario: { importe: 0 },
      importeCapital: 100,
      beneficios: 0,
      anticipo: 0,
      interesesPendientes: 0,
      coaseguradoras: [],
    };
    repository.calculateLiquidation(body).subscribe();

    const request = http.expectOne(
      `${environment.bffUrl}/api/v1/calculos/liquidacion`
    );
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(body);
    request.flush({
      capital: { importe: 100, liquido: 100 },
      prima: { importe: 0, liquido: 0 },
      complementario: { importe: 0, liquido: 0 },
      liquidoCapital: 100,
      importesCoasegurados: [],
    });
  });

  it('consulta el listado provisional en su ruta paginada', () => {
    repository.listCarteras(0, 5).subscribe();
    const request = http.expectOne(
      (candidate) =>
        candidate.url === `${environment.bffUrl}/api/v1/carteras/listado`
    );
    expect(request.request.method).toBe('GET');
    expect(request.request.params.get('page')).toBe('0');
    expect(request.request.params.get('size')).toBe('5');
    request.flush({ content: [], page: 0, size: 5, totalElements: 0 });
  });

  it('consulta y actualiza el cuadro de coaseguro en el recurso del expediente', () => {
    const value = {
      coaseguradoras: [
        { codigo: 'A', porcentaje: 60 },
        { codigo: 'B', porcentaje: 40 },
      ],
    };
    repository.getCoaseguro('2024', '123').subscribe();
    const getRequest = http.expectOne(
      `${environment.bffUrl}/api/v1/expedientes/2024/123/coaseguro`
    );
    expect(getRequest.request.method).toBe('GET');
    getRequest.flush(value);

    repository.saveCoaseguro('2024', '123', value).subscribe();
    const putRequest = http.expectOne(
      `${environment.bffUrl}/api/v1/expedientes/2024/123/coaseguro`
    );
    expect(putRequest.request.method).toBe('PUT');
    expect(putRequest.request.body).toEqual(value);
    putRequest.flush(value);
  });

  it('emite finiquitos con el contrato tipado y clave de idempotencia', () => {
    const body = {
      anio: '2024',
      expedienteDesde: '100',
      expedienteHasta: '200',
      fechaEmision: '2024-10-01',
      tipoEmision: '01',
      lugarEnvio: '01',
    };
    repository.emitFiniquitos(body).subscribe();
    const request = http.expectOne(
      `${environment.bffUrl}/api/v1/finiquitos/emisiones`
    );
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(body);
    expect(request.request.headers.get('Idempotency-Key')).toBe(
      'test-idempotency-key'
    );
    request.flush({ id: 'print-local', estado: 'ACEPTADO' });
  });

  it('envía carga de fichero con el esquema JSON actual y clave de idempotencia', () => {
    repository.uploadFile({ tipoEmision: '01' }).subscribe();
    const request = http.expectOne(
      `${environment.bffUrl}/api/v1/cargas-fichero`
    );
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual({ tipoEmision: '01' });
    expect(request.request.headers.get('Idempotency-Key')).toBeTruthy();
    request.flush({ cargaId: 'carga-local', estado: 'ACEPTADO' });
  });

  it('envía la petición BDGI tipada con clave de idempotencia', () => {
    const body = {
      anioEjercicio: 2024,
      mesEjercicio: 10,
      fechaInicial: '2024-10-01',
      fechaFinal: '2024-10-31',
    };
    repository.requestBdgi(body).subscribe();
    const request = http.expectOne(
      `${environment.bffUrl}/api/v1/peticiones-bdgi`
    );
    expect(request.request.method).toBe('POST');
    expect(request.request.body).toEqual(body);
    expect(request.request.headers.get('Idempotency-Key')).toBeTruthy();
    request.flush({ solicitudId: 'solicitud-local', estado: 'ACEPTADO' });
  });
});
