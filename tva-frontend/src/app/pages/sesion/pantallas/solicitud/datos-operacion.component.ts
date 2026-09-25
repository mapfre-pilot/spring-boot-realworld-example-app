/** Sección Datos de la operación (caja DATOS_DEL_SEGURO) — presentacional. */
import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  inject,
  input,
  output,
  signal,
} from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

import { Aviso, FormulariosSolicitud } from '@tva/core';
import { CampoSelectComponent, Opcion } from '../../../../ui/campo-select.component';
import { CampoTextoComponent } from '../../../../ui/campo-texto.component';
import { SeccionComponent } from '../../../../ui/seccion.component';

@Component({
  selector: 'app-datos-operacion',
  imports: [
    ReactiveFormsModule,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    MatSlideToggleModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './datos-operacion.component.html',
})
export class DatosOperacionComponent implements OnInit {
  readonly form = input.required<FormulariosSolicitud['operacion']>();
  readonly tiposDuracion = input.required<Opcion[]>();
  readonly periodicidades = input.required<Opcion[]>();
  readonly valida = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly continuar = output<void>();

  private readonly destroyRef = inject(DestroyRef);
  readonly valor = signal<Partial<ReturnType<FormulariosSolicitud['operacion']['getRawValue']>>>(
    {}
  );

  ngOnInit(): void {
    const f = this.form();
    this.valor.set(f.value);
    f.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(v => this.valor.set(v ?? {}));
  }
}
