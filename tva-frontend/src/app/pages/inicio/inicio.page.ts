/** Inicio — réplica de ``TVA_Utilidades_Inicio`` / Web API de inicio (§12.4.1). */
import { HttpErrorResponse } from '@angular/common/http';
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormArray, FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { Router } from '@angular/router';

import {
  AuthService,
  crearFormularioInicio,
  crearGrupoInversion,
  IniciarSesionUsecase,
  InicioRequest,
  InvestmentOption,
  ObtenerProductosUsecase,
  Producto,
  WebApiError,
  nuumaDe,
} from '@tva/core';
import { CabeceraComponent } from '../../shared/ui/layout/cabecera.component';
import { CampoSelectComponent, Opcion } from '../../shared/ui/formularios/campo-select.component';
import { CampoTextoComponent } from '../../shared/ui/formularios/campo-texto.component';
import { MATERIAL } from '../../shared/ui/material';
import { DESCRIPCIONES_MODO, FRECUENCIAS, MODOS, OPERACIONES } from './inicio.const';

@Component({
  selector: 'app-inicio-page',
  imports: [
    ...MATERIAL,
    MatProgressSpinnerModule,
    ReactiveFormsModule,
    CabeceraComponent,
    CampoTextoComponent,
    CampoSelectComponent,
  ],
  styleUrl: './inicio.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './inicio.page.html',
})
export class InicioPage implements OnInit {
  private readonly iniciarSesion = inject(IniciarSesionUsecase);
  private readonly obtenerProductos = inject(ObtenerProductosUsecase);
  private readonly router = inject(Router);
  private readonly auth = inject(AuthService);
  private readonly fb = inject(FormBuilder);

  protected readonly modos = MODOS;
  protected readonly operaciones = OPERACIONES;
  protected readonly frecuencias = FRECUENCIAS;
  protected readonly productos = signal<Producto[]>([]);
  protected readonly opcionesProductos = computed<Opcion[]>(() =>
    this.productos().map(p => ({
      valor: p.commercialProductCode,
      etiqueta: `${p.commercialProductCode} - ${p.commercialProductDesc}`,
    }))
  );
  protected readonly cargando = signal(false);
  readonly errores = signal<string[]>([]);
  protected readonly sesionIniciada = signal<string | null>(null);

  protected readonly nuumaControl = this.fb.nonNullable.control({ value: '', disabled: true });

  readonly form = crearFormularioInicio(this.fb.nonNullable);

  protected get pistaModo(): string {
    return DESCRIPCIONES_MODO[this.form.controls.indFunctionMode.value];
  }

  protected get pistaTomadores(): string {
    return this.form.controls.indFunctionMode.value === 'R2C' ? 'R2C requiere 2 tomadores' : '';
  }

  get investment(): FormArray<FormGroup> {
    return this.form.controls.investment;
  }

  ngOnInit(): void {
    this.obtenerProductos.execute().subscribe(r => this.productos.set(r.products ?? []));
    const user = this.auth.usuario();
    this.form.controls.username.setValue(
      user ? (user.includes('@') ? user : `${user}@mapfre.net`) : ''
    );
    this.form.controls.username.valueChanges.subscribe(v => this.nuumaControl.setValue(nuumaDe(v)));
    this.nuumaControl.setValue(nuumaDe(this.form.controls.username.value));
    this.form.controls.indFunctionMode.valueChanges.subscribe(modo => {
      const prop = this.form.controls.proposalId;
      if (modo === 'VA') {
        prop.enable();
        prop.addValidators(Validators.required);
      } else {
        prop.disable();
        prop.clearValidators();
      }
      prop.updateValueAndValidity();
      const ntom = this.form.controls.numTomadores;
      if (modo === 'R2C') {
        ntom.setValue(2);
        ntom.disable();
      } else {
        ntom.enable();
      }
    });
  }

  protected controlEn(i: number, nombre: string) {
    return this.investment.at(i).get(nombre) as never;
  }

  protected ayuda(i: number): string {
    const code = this.investment.at(i).get('commercialProductCode')?.value;
    return (
      this.productos().find(p => p.commercialProductCode === code)?.commercialProductDesc ?? ''
    );
  }

  nuevaOpcion(): void {
    this.investment.push(crearGrupoInversion(this.fb.nonNullable));
  }

  borrarOpcion(i: number): void {
    this.investment.removeAt(i);
  }

  iniciar(): void {
    this.errores.set([]);
    this.sesionIniciada.set(null);
    const v = this.form.getRawValue();
    const body: InicioRequest = {
      indFunctionMode: v.indFunctionMode,
      proposalId: v.proposalId || undefined,
      companyId: v.companyId,
      distributionChannel: v.distributionChannel,
      username: v.username,
      policyHolders: Array.from({ length: Number(v.numTomadores) || 1 }, () =>
        v.perfilado
          ? {
              testData: {
                convenience: {
                  profileCode: 'ME',
                  profileDesc: 'Medios',
                  signatureStatus: 'FI',
                  expirationDate: '2028-01-17',
                },
              },
            }
          : {}
      ),
      investment: v.indFunctionMode === 'VA' ? (v.investment as InvestmentOption[]) : undefined,
    };
    this.cargando.set(true);
    this.iniciarSesion.execute(body).subscribe({
      next: r => {
        this.cargando.set(false);
        this.sesionIniciada.set(r.claveSesion);
        void this.router.navigate(['/sesion', r.claveSesion]);
      },
      error: (err: HttpErrorResponse) => {
        this.cargando.set(false);
        const apiErr = err.error as WebApiError;
        this.errores.set(
          apiErr?.errors?.map(e => e.message) ?? [apiErr?.message ?? `Error ${err.status}`]
        );
      },
    });
  }
}
