import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { MatSnackBar } from '@angular/material/snack-bar';

import { errorInterceptor } from './api-error.interceptor';

describe('errorInterceptor', () => {
  const snack = { open: jest.fn() };
  beforeEach(() => {
    snack.open.mockClear();
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(withInterceptors([errorInterceptor])),
        provideHttpClientTesting(),
        { provide: MatSnackBar, useValue: snack },
      ],
    });
  });

  it('muestra el mensaje del ApiError en un snack de error', () => {
    TestBed.inject(HttpClient)
      .get('/x')
      .subscribe({ error: () => void 0 });
    TestBed.inject(HttpTestingController)
      .expectOne('/x')
      .flush({ error: { mensaje: 'boom' } }, { status: 400, statusText: 'Bad' });
    expect(snack.open).toHaveBeenCalledWith(
      'boom',
      'Cerrar',
      expect.objectContaining({ panelClass: 'snack-error' })
    );
  });

  it('usa Error <status> cuando no hay mensaje y no abre snack en errores <400', () => {
    const http = TestBed.inject(HttpClient);
    const ctrl = TestBed.inject(HttpTestingController);
    http.get('/y').subscribe({ error: () => void 0 });
    ctrl.expectOne('/y').flush({}, { status: 500, statusText: 'ISE' });
    expect(snack.open).toHaveBeenCalledWith('Error 500', 'Cerrar', expect.anything());
  });
});
