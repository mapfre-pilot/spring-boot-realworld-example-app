import { Component, computed, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Lanzadera } from '../../domain/models/api.models';
import { AccesoComponent } from '../components/acceso.component';
import { EstadoComponent } from '../components/estado.component';

/** /utilidades — accesos transversales (Portal Interno, SGC 3.0, SGO, Citrix) y contexto técnico del usuario. */
@Component({
  selector: 'pgm-utilidades-page',
  imports: [EstadoComponent, AccesoComponent],
  template: `
    <section>
      <h1>Accesos directos</h1>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
      <div class="accesos">
        @for (l of transversales(); track l.codigo) {
          <pgm-acceso [l]="l" [bloqueado]="l.requiereNuuma && !store.nuuma()" />
        } @empty {
          @if (!cargando()) {
            <div class="vacio">Sin utilidades disponibles</div>
          }
        }
      </div>
    </section>
    <section class="card">
      <h2>Mi contexto de usuario</h2>
      @if (store.contexto(); as c) {
        <dl class="datos">
          <dt>Usuario</dt>
          <dd>{{ c.usuario }} · {{ c.nombre }}</dd>
          <dt>Perfiles (Entra ID)</dt>
          <dd>
            @for (p of c.perfiles; track p) {
              <span class="chip">{{ p }}</span
              >&nbsp;
            }
          </dd>
          <dt>Perfil SGC 3.0</dt>
          <dd>{{ c.perfilSgc30 ?? '—' }}</dd>
          <dt>Estructura comercial</dt>
          <dd>
            @if (c.estructura; as e) {
              NUUMA {{ e.nuuma }} · {{ e.oficina }} · {{ e.delegacion }} · {{ e.territorial }}
            } @else {
              —
            }
          </dd>
          <dt>Visibilidades</dt>
          <dd>
            @for (v of visibilidades(); track v.clave) {
              <span class="chip" [class.chip-ok]="v.valor" [class.chip-error]="!v.valor">{{
                v.clave
              }}</span
              >&nbsp;
            }
          </dd>
        </dl>
      }
    </section>
  `,
})
export class UtilidadesPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly cargando = signal(true);
  readonly error = signal<string | null>(null);
  readonly transversales = computed(() => this.lanzaderas().filter((l) => !l.ramo));
  readonly visibilidades = computed(() =>
    Object.entries(this.store.contexto()?.visibilidades ?? {}).map(([clave, valor]) => ({
      clave,
      valor,
    })),
  );

  constructor() {
    void firstValueFrom(this.repo.lanzaderas())
      .then((r) => this.lanzaderas.set(r.items))
      .catch((e: Error) => this.error.set(e.message))
      .finally(() => this.cargando.set(false));
  }
}
