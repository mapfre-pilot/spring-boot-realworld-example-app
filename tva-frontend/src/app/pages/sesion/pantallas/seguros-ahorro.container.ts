/** SEGUROS_AHORRO (VA): catálogo del taller con selección múltiple. */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';

import { Producto } from '../../../core/models/models';
import { TvaApiService } from '../../../core/api/tva-api.service';
import { SesionStore } from '../../../core/state/sesion.store';
import { BotoneraComponent } from '../../../shared/ui/botonera.component';
import { CajaComponent } from '../../../shared/ui/caja.component';

@Component({
  selector: 'app-seguros-ahorro',
  imports: [
    MatCardModule,
    MatCheckboxModule,
    ReactiveFormsModule,
    CajaComponent,
    BotoneraComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Seguros de ahorro del taller">
      @if (productos().length === 0) {
        <p>Cargando catálogo…</p>
      }
      <form [formGroup]="form">
        @for (p of productos(); track p.productCode) {
          <mat-checkbox [formControlName]="p.productCode">
            {{ p.productDesc }} ({{ p.productCode }})
          </mat-checkbox>
        }
      </form>
    </app-caja>
    <app-botonera (siguiente)="avanzar()" (anterior)="anterior()" />
  `,
  styles: `
    mat-checkbox {
      display: block;
      margin: 4px 0;
    }
  `,
})
export class SegurosAhorroContainer implements OnInit {
  private readonly api = inject(TvaApiService);
  private readonly store = inject(SesionStore);
  private readonly fb = inject(FormBuilder);

  readonly productos = signal<Producto[]>([]);
  readonly form = this.fb.group<Record<string, boolean>>({});

  ngOnInit(): void {
    this.api.productos().subscribe(r => {
      const ps = (r.products ?? []) as Producto[];
      this.productos.set(ps);
      for (const p of ps) this.form.addControl(p.productCode, this.fb.control(false));
    });
  }

  avanzar(): void {
    const seleccion = Object.entries(this.form.value)
      .filter(([, v]) => v)
      .map(([k]) => k);
    this.store
      .ejecutar('seleccionar-modalidad', {
        productCode: seleccion[0] ?? '',
        productosSeleccionados: seleccion,
      })
      .subscribe();
  }

  anterior(): void {
    this.store.ejecutar('anterior').subscribe();
  }
}
