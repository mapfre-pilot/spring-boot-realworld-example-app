import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';

import { authInterceptor } from './auth.interceptor';
import { AuthService } from './auth.service';

describe('authInterceptor', () => {
  function setup(token: string | null) {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(withInterceptors([authInterceptor])),
        provideHttpClientTesting(),
        { provide: AuthService, useValue: { token: signal(token) } },
      ],
    });
    return { http: TestBed.inject(HttpClient), ctrl: TestBed.inject(HttpTestingController) };
  }

  it('añade Authorization Bearer cuando hay token', () => {
    const { http, ctrl } = setup('abc');
    http.get('/x').subscribe();
    const req = ctrl.expectOne('/x');
    expect(req.request.headers.get('Authorization')).toBe('Bearer abc');
    req.flush({});
  });

  it('no añade cabecera sin token', () => {
    const { http, ctrl } = setup(null);
    http.get('/x').subscribe();
    const req = ctrl.expectOne('/x');
    expect(req.request.headers.get('Authorization')).toBeNull();
    req.flush({});
  });
});
