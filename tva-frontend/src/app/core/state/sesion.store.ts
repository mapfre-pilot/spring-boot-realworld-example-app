import { Injectable, computed, inject, signal } from '@angular/core';
import { Observable, tap } from 'rxjs';

import {
  AccionResponse,
  Aviso,
  Boton,
  EstadoSesion,
  Modalidad,
  Pantalla,
  Sesion,
} from '../models/models';
import { TvaApiService } from '../api/tva-api.service';

/** Mapeo id de botón de la botonera → acción del backend (§12.4.3). */
export const ACCION_POR_BOTON: Record<string, string> = {
  cancelar: 'cancelar',
  administracion: 'administracion',
  atras: 'anterior',
  recalcular: 'recalcular-rentas',
  'guardar-y-volver': 'guardar-solicitud',
  'doc-precontractual': 'doc-precontractual',
  contratar: 'contratar',
  continuar: 'continuar-tomador',
  siguiente: 'siguiente',
  firmar: 'firmar',
};

@Injectable({ providedIn: 'root' })
export class SesionStore {
  private readonly api = inject(TvaApiService);

  readonly sesion = signal<Sesion | null>(null);
  readonly cargando = signal(false);
  readonly botones = signal<Boton[]>([]);
  /** Datos que envía la próxima acción de botonera (los rellenan los containers). */
  readonly datosPendientes = signal<Record<string, unknown>>({});
  readonly pantallaActual = computed<Pantalla | null>(() => this.sesion()?.pantalla_actual ?? null);
  readonly avisos = computed<Aviso[]>(() => this.sesion()?.estado?.avisos ?? []);
  readonly modalidad = computed<Modalidad | null>(() => this.sesion()?.modalidad ?? null);
  readonly claveSesion = computed(() => this.sesion()?.clave ?? null);

  cargar(clave: string): Observable<Sesion> {
    this.cargando.set(true);
    return this.api.getSesion(clave).pipe(
      tap({
        next: s => {
          this.sesion.set(s);
          this.botones.set(s.botones ?? []);
          this.cargando.set(false);
        },
        error: () => this.cargando.set(false),
      })
    );
  }

  /** Ejecuta la acción de un botón de la botonera o una acción directa. */
  ejecutar(
    accion: string,
    datos: Record<string, unknown> | null = null
  ): Observable<AccionResponse> {
    const clave = this.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    const payload = datos ?? this.datosPendientes();
    return this.api.accion(clave, ACCION_POR_BOTON[accion] ?? accion, payload).pipe(
      tap(res => {
        const s = this.sesion();
        if (s) {
          this.sesion.set({
            ...s,
            pantalla_actual: res.pantallaActual,
            estado: { ...res.estado, avisos: res.avisos },
          });
        }
        this.botones.set(res.botones ?? []);
        this.datosPendientes.set({});
      })
    );
  }

  /** POST validar-seccion para una sección concreta (§12.4.4). */
  validarSeccion(
    caja: string,
    seccion: string,
    datos: Record<string, unknown>
  ): Observable<AccionResponse> {
    const clave = this.claveSesion();
    if (!clave) throw new Error('Sin sesión cargada');
    return this.api.validarSeccion(clave, caja, seccion, datos).pipe(
      tap(res => {
        const s = this.sesion();
        if (s) {
          this.sesion.set({
            ...s,
            pantalla_actual: res.pantallaActual,
            estado: { ...res.estado, avisos: res.avisos },
          });
        }
        this.botones.set(res.botones ?? []);
      })
    );
  }

  guardarEstado(patch: Record<string, unknown>): Observable<Sesion> {
    const s = this.sesion();
    if (!s) throw new Error('Sin sesión cargada');
    const nuevo = { ...s.estado, ...patch } as EstadoSesion;
    return this.api
      .putEstado(s.clave, nuevo as unknown as Record<string, unknown>)
      .pipe(tap(res => this.sesion.set(res)));
  }

  limpiar(): void {
    this.sesion.set(null);
    this.botones.set([]);
    this.datosPendientes.set({});
  }
}
