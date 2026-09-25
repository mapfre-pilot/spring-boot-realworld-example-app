/** SEGUROS_AHORRO (VA): lista de insurancesApplication de la propuesta. */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { JsonPipe } from '@angular/common';
import { MatCardModule } from '@angular/material/card';

import { EstadoSesion, Producto, ObtenerProductosUsecase, SesionStore } from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';

@Component({
  selector: 'app-seguros-ahorro',
  imports: [MatCardModule, CajaComponent, JsonPipe],
  templateUrl: './seguros-ahorro.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SegurosAhorroContainer implements OnInit {
  private readonly obtenerProductos = inject(ObtenerProductosUsecase);
  private readonly store = inject(SesionStore);
  readonly productos = signal<Producto[]>([]);
  readonly applications = computed<Record<string, unknown>[]>(() => {
    const estado = (this.store.sesion()?.estado ?? {}) as EstadoSesion;
    const prop = estado.responseProposal ?? {};
    const contracting = (prop['contractingProposal'] ?? {}) as Record<string, unknown>;
    return (contracting['insurancesApplication'] as Record<string, unknown>[] | undefined) ?? [];
  });

  ngOnInit(): void {
    this.obtenerProductos.execute().subscribe(r => this.productos.set(r.products ?? []));
  }
}
