import { HttpErrorResponse, provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { PgmApiRepository } from './pgm-api.repository';
import { ApiProblemError, problemDetailsInterceptor } from './problem-details.interceptor';

describe('PgmApiRepository (contrato BFF /api/v1)', () => {
  let repo: PgmApiRepository;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(withInterceptors([problemDetailsInterceptor])), provideHttpClientTesting()],
    });
    repo = TestBed.inject(PgmApiRepository);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('traduce los criterios de búsqueda a los query params del contrato (texto → q)', () => {
    repo.buscarClientes({ texto: ' García ', documento: '', localidad: 'Madrid' }).subscribe();
    const req = http.expectOne((r) => r.url === '/api/v1/clientes/search');
    expect(req.request.params.get('q')).toBe('García');
    expect(req.request.params.has('documento')).toBe(false);
    expect(req.request.params.get('localidad')).toBe('Madrid');
    req.flush({ items: [], total: 0 });
  });

  it('solo habla con el BFF: ficha, pólizas, recibos, lanzaderas y KPIs cuelgan de /api/v1', () => {
    repo.fichaCliente('C-1001').subscribe();
    repo.poliza('P-1').subscribe();
    repo.recibo('R-1').subscribe();
    repo.lanzaderas('SALUD').subscribe();
    repo.kpis().subscribe();
    http.expectOne('/api/v1/clientes/C-1001/ficha').flush({});
    http.expectOne('/api/v1/polizas/P-1').flush({});
    http.expectOne('/api/v1/recibos/R-1').flush({});
    http.expectOne((r) => r.url === '/api/v1/lanzaderas' && r.params.get('ramo') === 'SALUD').flush({ items: [], total: 0 });
    http.expectOne('/api/v1/cuadro-mando/kpis').flush({ items: [], total: 0 });
  });

  it('convierte los errores RFC 9457 del BFF en ApiProblemError', (done) => {
    repo.fichaCliente('C-404').subscribe({
      error: (e: unknown) => {
        expect(e).toBeInstanceOf(ApiProblemError);
        expect((e as ApiProblemError).problem.status).toBe(404);
        expect((e as Error).message).toBe('No existe el cliente C-404');
        done();
      },
    });
    http.expectOne('/api/v1/clientes/C-404/ficha').flush(
      { type: 'https://pgm.mapfre.es/problems/recurso-no-encontrado', title: 'Recurso no encontrado', status: 404, detail: 'No existe el cliente C-404' },
      { status: 404, statusText: 'Not Found' },
    );
  });

  it('señala BFF no disponible cuando falla la conexión', (done) => {
    repo.contexto().subscribe({
      error: (e: ApiProblemError) => {
        expect(e.problem.title).toBe('BFF no disponible');
        done();
      },
    });
    http.expectOne('/api/v1/contexto').error(new ProgressEvent('error'), { status: 0 } as Partial<HttpErrorResponse>);
  });
});
