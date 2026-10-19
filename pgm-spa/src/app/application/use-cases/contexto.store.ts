import { Injectable, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { ContextoUsuario, VisibilidadKey } from '../../domain/models/api.models';
import { PGM_REPOSITORY } from '../ports/pgm.repository';

/** Contexto del usuario (perfiles, estructura, visibilidades) tal y como lo entrega el BFF. */
@Injectable({ providedIn: 'root' })
export class ContextoStore {
  private readonly repo = inject(PGM_REPOSITORY);
  private readonly ctx = signal<ContextoUsuario | null>(null);
  private readonly fallo = signal<string | null>(null);

  readonly contexto = this.ctx.asReadonly();
  readonly error = this.fallo.asReadonly();
  readonly cargado = computed(() => this.ctx() !== null);
  readonly nombre = computed(() => this.ctx()?.nombre ?? '');
  readonly nuuma = computed(() => this.ctx()?.estructura?.nuuma ?? null);

  async cargar(): Promise<ContextoUsuario | null> {
    try {
      const c = await firstValueFrom(this.repo.contexto());
      this.ctx.set(c);
      this.fallo.set(null);
      return c;
    } catch (e) {
      this.fallo.set((e as Error).message);
      return null;
    }
  }

  puede(clave: VisibilidadKey): boolean {
    return this.ctx()?.visibilidades?.[clave] === true;
  }

  visible = (clave: VisibilidadKey) => computed(() => this.puede(clave));
}
