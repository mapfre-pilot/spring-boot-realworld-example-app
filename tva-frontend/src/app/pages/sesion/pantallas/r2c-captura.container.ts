/** R2C_CAPTURA: datos de la renta + 2 tomadores — validar-seccion (TVA_SimuladorRentas_Captura_Validacion). */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import { SesionStore } from '../../../core/state/sesion.store';
import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent, Opcion } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';
import { SeccionComponent } from '../../../shared/ui/seccion.component';

const PERIODICIDADES_RENTA: Opcion[] = [
  { valor: 'MENSUAL', etiqueta: 'Mensual' },
  { valor: 'TRIMESTRAL', etiqueta: 'Trimestral' },
  { valor: 'SEMESTRAL', etiqueta: 'Semestral' },
  { valor: 'ANUAL', etiqueta: 'Anual' },
];

@Component({
  selector: 'app-r2c-captura',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Datos de la renta">
      <app-seccion
        titulo="Captura"
        [valida]="valida()"
        [expandida]="true"
        [avisos]="avisos()"
        seccion="R2C_CAPTURA/captura"
        (continuar)="continuar()">
        <form [formGroup]="rentas" class="formulario">
          <app-campo-texto
            [control]="rentas.controls.importeTotalPrima"
            etiqueta="Importe total de la prima (€)"
            tipo="number" />
          <app-campo-select
            [control]="rentas.controls.periodicidadRenta"
            etiqueta="Periodicidad de la renta"
            [opciones]="periodicidades" />
        </form>
        @for (t of tomadores; track $index; let i = $index) {
          <form [formGroup]="t" class="formulario">
            <h4>Tomador {{ i + 1 }}</h4>
            <app-campo-texto [control]="t.controls.documentId" etiqueta="Nº de DNI" />
            <app-campo-texto
              [control]="t.controls.fechaNacimiento"
              etiqueta="Fecha de nacimiento"
              tipo="date" />
            <app-campo-texto
              [control]="t.controls.participationPerc"
              etiqueta="% de participación"
              tipo="number" />
          </form>
        }
      </app-seccion>
    </app-caja>
  `,
  styles: `
    .formulario {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
      margin-bottom: 12px;
    }
    h4 {
      grid-column: 1 / -1;
      margin: 4px 0;
    }
  `,
})
export class R2cCapturaContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly fb = inject(FormBuilder);
  readonly periodicidades = PERIODICIDADES_RENTA;
  readonly avisos = this.store.avisos;
  readonly valida = signal(false);

  readonly rentas = this.fb.nonNullable.group({
    importeTotalPrima: [null as number | null, Validators.required],
    periodicidadRenta: ['', Validators.required],
  });

  readonly tomadores = [
    this.fb.nonNullable.group({
      documentId: ['', Validators.required],
      fechaNacimiento: ['', Validators.required],
      participationPerc: [null as number | null, Validators.required],
    }),
    this.fb.nonNullable.group({
      documentId: ['', Validators.required],
      fechaNacimiento: ['', Validators.required],
      participationPerc: [null as number | null, Validators.required],
    }),
  ];

  ngOnInit(): void {
    const est = this.store.sesion()?.estado as Record<string, unknown> | undefined;
    const r = (est?.['rentas'] as Record<string, unknown> | undefined) ?? {};
    this.rentas.patchValue(r as never);
    const ts =
      (est?.['tomadores'] as { datosPersonales?: Record<string, unknown> }[] | undefined) ?? [];
    ts.slice(0, 2).forEach((t, i) =>
      this.tomadores[i].patchValue((t.datosPersonales ?? {}) as never)
    );
  }

  continuar(): void {
    this.store
      .validarSeccion('R2C_CAPTURA', 'captura', {
        rentas: this.rentas.getRawValue(),
        tomadores: this.tomadores.map(t => t.getRawValue()),
      })
      .subscribe(res => {
        const ref = 'R2C_CAPTURA/captura';
        const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
        this.valida.set(!hayErrores);
      });
  }
}
