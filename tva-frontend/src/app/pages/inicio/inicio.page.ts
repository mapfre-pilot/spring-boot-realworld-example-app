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
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { Router } from '@angular/router';

import {
  AuthService,
  IniciarSesionUsecase,
  InicioRequest,
  InvestmentOption,
  ObtenerProductosUsecase,
  Producto,
  WebApiError,
  nuumaDe,
} from '@tva/core';
import { CabeceraComponent } from '../../ui/cabecera.component';
import { CampoSelectComponent, Opcion } from '../../ui/campo-select.component';
import { CampoTextoComponent } from '../../ui/campo-texto.component';

const MODOS: Opcion[] = [
  { valor: 'VA', etiqueta: 'Venta Asesorada' },
  { valor: 'VIA', etiqueta: 'Venta Informada Ahorro' },
  { valor: 'R2C', etiqueta: 'Rentas' },
];
const OPERACIONES: Opcion[] = [
  { valor: 'S', etiqueta: 'Suscripción' },
  { valor: 'AE', etiqueta: 'Aportación extraordinaria' },
];
const FRECUENCIAS: Opcion[] = [
  { valor: 'M', etiqueta: 'Mensual' },
  { valor: 'T', etiqueta: 'Trimestral' },
  { valor: 'S', etiqueta: 'Semestral' },
  { valor: 'A', etiqueta: 'Anual' },
];

@Component({
  selector: 'app-inicio-page',
  imports: [
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    MatCheckboxModule,
    MatIconModule,
    CabeceraComponent,
    CampoTextoComponent,
    CampoSelectComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './inicio.page.html',
  styles: `
    .pagina {
      max-width: 1100px;
      margin: 24px auto;
      padding: 0 16px;
    }
    .tabla {
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
    }
    .tabla td {
      padding: 2px;
    }
    .checks {
      display: flex;
      gap: 24px;
      margin: 8px 0;
    }
    .errores {
      color: #d81e05;
      margin: 12px 0;
    }
    .ok {
      color: #137333;
    }
  `,
})
export class InicioPage implements OnInit {
  private readonly iniciarSesion = inject(IniciarSesionUsecase);
  private readonly obtenerProductos = inject(ObtenerProductosUsecase);
  private readonly router = inject(Router);
  private readonly auth = inject(AuthService);
  private readonly fb = inject(FormBuilder);

  readonly modos = MODOS;
  readonly operaciones = OPERACIONES;
  readonly frecuencias = FRECUENCIAS;
  readonly productos = signal<Producto[]>([]);
  readonly opcionesProductos = computed<Opcion[]>(() =>
    this.productos().map(p => ({
      valor: p.commercialProductCode,
      etiqueta: `${p.commercialProductCode} - ${p.commercialProductDesc}`,
    }))
  );
  readonly cargando = signal(false);
  readonly errores = signal<string[]>([]);
  readonly sesionIniciada = signal<string | null>(null);

  readonly nuumaControl = this.fb.nonNullable.control({ value: '', disabled: true });

  readonly form = this.fb.nonNullable.group({
    indFunctionMode: ['VIA' as InicioRequest['indFunctionMode'], Validators.required],
    proposalId: [{ value: '', disabled: true }],
    companyId: ['0511'],
    numTomadores: [1],
    distributionChannel: ['500'],
    username: ['', Validators.required],
    tomador: [true],
    perfilado: [false],
    inversion: [true],
    investment: this.fb.array<FormGroup>([]),
  });

  get investment(): FormArray<FormGroup> {
    return this.form.controls.investment;
  }

  ngOnInit(): void {
    this.obtenerProductos.execute().subscribe(r => this.productos.set(r.products ?? []));
    const user = this.auth.usuario();
    this.form.controls.username.setValue(user ? `${user}@mapfre.net` : '');
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
    });
  }

  controlEn(i: number, nombre: string) {
    return this.investment.at(i).get(nombre) as never;
  }

  ayuda(i: number): string {
    const code = this.investment.at(i).get('commercialProductCode')?.value;
    return (
      this.productos().find(p => p.commercialProductCode === code)?.commercialProductDesc ?? ''
    );
  }

  nuevaOpcion(): void {
    this.investment.push(
      this.fb.group({
        commercialProductCode: [''],
        investmentPreferenceCode: [''],
        operationTypeCode: ['S'],
        policyId: [null],
        uniqueContributionAmn: [null],
        periodicContributionAmn: [null],
        contributionFrequencyCode: [null],
        insuranceOfferInd: [false],
      })
    );
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
