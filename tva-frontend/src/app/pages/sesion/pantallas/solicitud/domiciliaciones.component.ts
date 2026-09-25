/** Sección Domiciliaciones (IBAN recibos/prestaciones) — presentacional. */
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
import { CampoTextoComponent } from '../../../../ui/campo-texto.component';
import { SeccionComponent } from '../../../../ui/seccion.component';

@Component({
  selector: 'app-domiciliaciones',
  imports: [ReactiveFormsModule, SeccionComponent, CampoTextoComponent, MatSlideToggleModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './domiciliaciones.component.html',
})
export class DomiciliacionesComponent implements OnInit {
  readonly form = input.required<FormulariosSolicitud['domiciliaciones']>();
  readonly valida = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly continuar = output<void>();

  private readonly destroyRef = inject(DestroyRef);
  readonly requierePrestaciones = signal(false);

  ngOnInit(): void {
    const c = this.form().controls.requierePrestaciones;
    this.requierePrestaciones.set(c.value);
    c.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(v => this.requierePrestaciones.set(v));
  }
}
