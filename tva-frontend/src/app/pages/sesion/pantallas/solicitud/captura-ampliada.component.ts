/** Captura ampliada (contacto, asegurado, beneficiarios, notas) — presentacional. */
import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  inject,
  input,
  model,
  output,
  signal,
} from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

import { Aviso, FormulariosSolicitud } from '@tva/core';
import { CajaComponent } from '../../../../shared/ui/contenedores/caja.component';
import {
  CampoSelectComponent,
  Opcion,
} from '../../../../shared/ui/formularios/campo-select.component';
import { CampoTextoComponent } from '../../../../shared/ui/formularios/campo-texto.component';
import { SeccionComponent } from '../../../../shared/ui/contenedores/seccion.component';
import { TIPOS_DIRECCION } from './solicitud.const';

@Component({
  selector: 'app-captura-ampliada',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    MatSlideToggleModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './captura-ampliada.component.html',
})
export class CapturaAmpliadaComponent implements OnInit {
  readonly datosContacto = input.required<FormulariosSolicitud['datosContacto']>();
  readonly asegurado = input.required<FormulariosSolicitud['asegurado']>();
  readonly beneficiarios = input.required<FormulariosSolicitud['beneficiarios']>();
  readonly nota = input.required<FormulariosSolicitud['nota']>();
  readonly tiposBeneficiario = input.required<Opcion[]>();
  readonly validez = input<Record<string, boolean>>({});
  readonly expandidaId = input.required<string>();
  readonly avisos = input<Aviso[]>([]);
  readonly ampliada = model.required<boolean>();
  readonly continuar = output<string>();

  protected readonly tiposDireccion = TIPOS_DIRECCION;
  private readonly destroyRef = inject(DestroyRef);
  protected readonly esTomador = signal(true);
  protected readonly beneficiarioTipo = signal('');

  ngOnInit(): void {
    const esT = this.asegurado().controls.esTomador;
    this.esTomador.set(esT.value);
    esT.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(v => this.esTomador.set(v));
    const bt = this.beneficiarios().controls.tipo;
    this.beneficiarioTipo.set(bt.value);
    bt.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(v => this.beneficiarioTipo.set(v));
  }
}
