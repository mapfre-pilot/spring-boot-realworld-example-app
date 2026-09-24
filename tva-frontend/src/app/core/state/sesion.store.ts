import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { AccionResponse, Aviso, Modalidad, Pantalla, Sesion } from '../models/models';
import { TvaApiService } from '../api/tva-api.service';

@Injectable({ providedIn: 'root' })
export class SesionStore {
  private readonly api = inject(TvaApiService);

  readonly sesion = signal<Sesion | null>(null);
  readonly cargando = signal(false);
  readonly pantallaActual = computed<Pantalla | null>(() => this.sesion()?.pantalla_actual ?? null);
  readonly avisos = computed<Aviso[]>(
    () => (this.sesion()?.estado?.['avisos'] as Aviso[] | undefined) ?? []
  );
  readonly modalidad = computed<Modalidad | null>(() => this.sesion()?.modalidad ?? null);
  readonly claveSesion = computed(() => this.sesion()?.clave ?? null);

  cargar(clave: string): Observable<Sesion> {
    this.cargando.set(true);
    return this.api.getSesion(clave).pipe(
      tap({
        next: s => {
          this.sesion.set(s);
          this.cargando.set(false);
        },
        error: () => this.cargando.set(false),
      })
    );
  }

  ejecutar(accion: string, datos: Record<string, unknown> = {}): Observable<AccionResponse> {
    const clave = this.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.api.accion(clave, accion, datos).pipe(
      tap(res => {
        const s = this.sesion();
        if (s) {
          this.sesion.set({
            ...s,
            pantalla_actual: res.pantallaActual,
            estado: res.estado,
          });
        }
      })
    );
  }

  guardarEstado(patch: Record<string, unknown>): Observable<Sesion> {
    const s = this.sesion();
    if (!s) throw new Error('Sin sesión cargada');
    const nuevo = { ...s.estado, ...patch };
    return this.api.putEstado(s.clave, nuevo).pipe(tap(res => this.sesion.set(res)));
  }

  limpiar(): void {
    this.sesion.set(null);
  }
}
