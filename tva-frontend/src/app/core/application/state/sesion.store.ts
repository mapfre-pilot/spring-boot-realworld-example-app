import { Injectable, computed, signal } from '@angular/core';

import { AccionResponse, Aviso, Boton, Modalidad, Pantalla, Sesion } from '../../domain';

/** Mapeo id de botón de la botonera → acción del backend (§12.4.3). */
export const ACCION_POR_BOTON: Record<string, string> = {
  cancelar: 'cancelar',
  administracion: 'administracion',
  volver: 'volver-administracion',
  atras: 'anterior',
  recalcular: 'recalcular-rentas',
  'guardar-y-volver': 'guardar-solicitud',
  'doc-precontractual': 'doc-precontractual',
  contratar: 'contratar',
  continuar: 'continuar-tomador',
  siguiente: 'siguiente',
  firmar: 'firmar',
};

/** Store de solo estado: los casos de uso ejecutan la lógica y llaman a aplicarRespuesta(). */
@Injectable({ providedIn: 'root' })
export class SesionStore {
  readonly sesion = signal<Sesion | null>(null);
  readonly cargando = signal(false);
  readonly botones = signal<Boton[]>([]);
  /** Datos que envía la próxima acción de botonera (los rellenan los containers). */
  readonly datosPendientes = signal<Record<string, unknown>>({});
  readonly pantallaActual = computed<Pantalla | null>(() => this.sesion()?.pantalla_actual ?? null);
  readonly avisos = computed<Aviso[]>(() => this.sesion()?.estado?.avisos ?? []);
  readonly modalidad = computed<Modalidad | null>(() => this.sesion()?.modalidad ?? null);
  readonly claveSesion = computed(() => this.sesion()?.clave ?? null);

  /** Aplica una respuesta del backend (Sesion completa o AccionResponse incremental). */
  aplicarRespuesta(res: AccionResponse | Sesion): void {
    if ('pantallaActual' in res) {
      const s = this.sesion();
      if (s) {
        this.sesion.set({
          ...s,
          pantalla_actual: res.pantallaActual,
          estado: { ...res.estado, avisos: res.avisos },
        });
      }
      this.botones.set(res.botones ?? []);
      return;
    }
    this.sesion.set(res);
    this.botones.set(res.botones ?? []);
  }

  limpiar(): void {
    this.sesion.set(null);
    this.botones.set([]);
    this.datosPendientes.set({});
  }
}
