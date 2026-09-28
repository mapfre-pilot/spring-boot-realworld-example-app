/** R2C_CAPTURA: datos de la renta + 2 tomadores — validar-seccion (TVA_SimuladorRentas_Captura_Validacion). */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import { SesionStore, ValidarSeccionUsecase } from '@tva/core';
import { CajaComponent } from '../../../../shared/ui/contenedores/caja.component';
import { CampoSelectComponent } from '../../../../shared/ui/formularios/campo-select.component';
import { CampoTextoComponent } from '../../../../shared/ui/formularios/campo-texto.component';
import { SeccionComponent } from '../../../../shared/ui/contenedores/seccion.component';
import { PERIODICIDADES_RENTA } from './r2c.const';

@Component({
  selector: 'app-r2c-captura',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
  ],
  templateUrl: './r2c-captura.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class R2cCapturaContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly fb = inject(FormBuilder);
  private readonly validarSeccion = inject(ValidarSeccionUsecase);
  protected readonly periodicidades = PERIODICIDADES_RENTA;
  protected readonly avisos = this.store.avisos;
  protected readonly valida = signal(false);

  protected readonly rentas = this.fb.nonNullable.group({
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
    this.validarSeccion
      .execute('R2C_CAPTURA', 'captura', {
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
