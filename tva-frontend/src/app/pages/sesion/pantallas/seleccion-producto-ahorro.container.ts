/** SELECCION_PRODUCTO_AHORRO (VIA): elige un producto de ahorro. */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatRadioModule } from '@angular/material/radio';

import { Producto } from '../../../core/models/models';
import { TvaApiService } from '../../../core/api/tva-api.service';
import { SesionStore } from '../../../core/state/sesion.store';
import { BotoneraComponent } from '../../../shared/ui/botonera.component';
import { CajaComponent } from '../../../shared/ui/caja.component';

@Component({
  selector: 'app-seleccion-producto-ahorro',
  imports: [MatRadioModule, ReactiveFormsModule, CajaComponent, BotoneraComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Seleccione el producto de ahorro">
      <form [formGroup]="form">
        <mat-radio-group formControlName="producto">
          @for (p of productos(); track p.productCode) {
            <mat-radio-button [value]="p.productCode">{{ p.productDesc }}</mat-radio-button>
          }
        </mat-radio-group>
      </form>
    </app-caja>
    <app-botonera (siguiente)="avanzar()" (anterior)="anterior()" />
  `,
  styles: `
    mat-radio-button {
      display: block;
      margin: 4px 0;
    }
  `,
})
export class SeleccionProductoAhorroContainer implements OnInit {
  private readonly api = inject(TvaApiService);
  private readonly store = inject(SesionStore);

  readonly productos = signal<Producto[]>([]);
  readonly form = inject(FormBuilder).nonNullable.group({ producto: ['', Validators.required] });

  ngOnInit(): void {
    this.api.productos().subscribe(r => this.productos.set((r.products ?? []) as Producto[]));
  }

  avanzar(): void {
    this.store
      .ejecutar('seleccionar-modalidad', { producto: this.form.value.producto })
      .subscribe();
  }

  anterior(): void {
    this.store.ejecutar('anterior').subscribe();
  }
}
