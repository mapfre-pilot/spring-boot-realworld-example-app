import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Lanzadera, Ramo } from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';

export type PaginaSite = 'gestion-cartera' | 'prestaciones' | 'nueva-produccion';

export const PESTANAS_GESTION_CARTERA = [
  'Agropecuario',
  'Automóviles',
  'Empresas',
  'Patrimoniales',
  'Salud',
  'Vida',
] as const;
export const PESTANAS_PRESTACIONES = ['Automóviles', 'Salud'] as const;
export const PESTANAS_NUEVA_PRODUCCION = [
  'Agropecuario',
  'Ahorro',
  'Automóviles',
  'Empresas',
  'Patrimoniales',
  'Salud',
  'Vida',
] as const;
export const PESTANAS_MODALIDAD_SALUD = ['Particulares'] as const;
export const PESTANAS_MODALIDAD_VIDA = ['Particulares', 'Colectivos'] as const;

interface AccesoSite {
  etiqueta: string;
  lanzadera: string | null;
}

interface TarjetaSite {
  interfaz: string;
  titulo: string;
  accesos: AccesoSite[];
  subpestana?: 'Particulares' | 'Colectivos';
}

const contenidoSite: Record<PaginaSite, Record<string, TarjetaSite[]>> = {
  'gestion-cartera': {
    Agropecuario: [
      { interfaz: 'PGM_GestiondeCartera_Agropecuario', titulo: 'Agroseguro', accesos: [{ etiqueta: 'SAC', lanzadera: null }] },
    ],
    Automóviles: [
      { interfaz: 'PGM_GestiondeCartera_Autos', titulo: 'Turismos y motos', accesos: [{ etiqueta: 'NSE - Automóviles', lanzadera: 'NSE' }, { etiqueta: 'Suplementos pólizas acuerdos especiales', lanzadera: null }, { etiqueta: 'wAutemis', lanzadera: null }] },
      { interfaz: 'PGM_GestiondeCartera_Autos', titulo: 'Camiones, autobuses y vehículos industriales', accesos: [{ etiqueta: 'camiones', lanzadera: null }] },
      { interfaz: 'PGM_GestiondeCartera_Autos', titulo: 'Flotas', accesos: [{ etiqueta: 'Flotas', lanzadera: null }] },
      { interfaz: 'PGM_GestiondeCartera_Autos', titulo: 'Verificación digital', accesos: [{ etiqueta: 'Validación de fotografías', lanzadera: null }] },
    ],
    Empresas: [
      { interfaz: 'PGM_GestionDeCartera_Empresas', titulo: 'Multirriesgo empresarial y comercios', accesos: [{ etiqueta: 'Suplementos', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_GestionDeCartera_Empresas', titulo: 'Responsabilidad civil', accesos: [{ etiqueta: 'Suplementos (excepto pólizas emitidas antes del año 2023)', lanzadera: 'NSE' }] },
      { interfaz: 'PGM_GestionDeCartera_Empresas', titulo: 'Autoemprendedores', accesos: [{ etiqueta: 'Suplementos', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_GestionDeCartera_Empresas', titulo: 'CiberON Autónomos y Pymes', accesos: [{ etiqueta: 'NSE - CiberOn', lanzadera: 'NSE' }] },
    ],
    Patrimoniales: [
      { interfaz: 'PGM_GestionDeCartera_Patrimoniales', titulo: 'Home', accesos: [{ etiqueta: 'NSE - Ptrimoniales', lanzadera: 'NSE_HOGAR' }] },
      { interfaz: 'PGM_GestionDeCartera_Patrimoniales', titulo: 'Comunidades', accesos: [{ etiqueta: 'NSE - Comunidades', lanzadera: 'NSE_HOGAR' }] },
      { interfaz: 'PGM_GestionDeCartera_Patrimoniales', titulo: 'Decesos', accesos: [{ etiqueta: 'Suplementos', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_GestionDeCartera_Patrimoniales', titulo: 'Animales de compañía, protección de alquileres, defensa jurídica y BiciMás', accesos: [{ etiqueta: 'Suplementos', lanzadera: 'CITRIX' }] },
    ],
    Salud: [
      { interfaz: 'PGM_GestionDeCartera_Salud', titulo: 'Gesalud', accesos: [{ etiqueta: 'Gesalud', lanzadera: 'GESALUD' }] },
    ],
    Vida: [
      { interfaz: 'PGM_GestionDeCartera_Vida', titulo: 'GESVIDA', accesos: [{ etiqueta: 'GESVIDA', lanzadera: 'GESVIDA' }] },
    ],
  },
  prestaciones: {
    Automóviles: [
      { interfaz: 'PGM_PrestacionesYSiniestros_Autos', titulo: 'Buscador de talleres', accesos: [{ etiqueta: 'Buscador de talleres', lanzadera: null }] },
      { interfaz: 'PGM_PrestacionesYSiniestros_Autos', titulo: 'Automóviles', accesos: [{ etiqueta: 'Comunicación y gestión · Atenaus', lanzadera: null }] },
    ],
    Salud: [
      { interfaz: 'PGM_PrestacionesYSiniestros_Salud', titulo: 'Gesalud', accesos: [{ etiqueta: 'Gesalud', lanzadera: 'GESALUD' }] },
    ],
  },
  'nueva-produccion': {
    Agropecuario: [
      { interfaz: 'PGM_NuevaProduccion_Agropecuario', titulo: 'Agroseguro', accesos: [{ etiqueta: 'Cálculo del Seguro Agrario Combinado (SAC)', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Agropecuario', titulo: 'Caza, pesca, maquinaria agrícola y otros', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'CITRIX' }] },
    ],
    Ahorro: [
      { interfaz: 'PGM_NuevaProduccion_Ahorro', titulo: 'Ahorro', accesos: [{ etiqueta: 'Tarificación y emisión · GESVIDA', lanzadera: 'GESVIDA' }] },
      { interfaz: 'PGM_NuevaProduccion_Ahorro', titulo: 'Campañas', accesos: [{ etiqueta: 'WEBVIDA', lanzadera: 'GESVIDA' }] },
      { interfaz: 'PGM_NuevaProduccion_Ahorro', titulo: 'Rentas', accesos: [{ etiqueta: 'Tarificación y solicitud · GESVIDA', lanzadera: 'GESVIDA' }] },
      { interfaz: 'PGM_NuevaProduccion_Ahorro', titulo: 'Solicitud de seguro', accesos: [{ etiqueta: 'Descarga de documento', lanzadera: null }] },
    ],
    Automóviles: [
      { interfaz: 'PGM_NuevaProduccion_Autos', titulo: 'Turismos y motos', accesos: [{ etiqueta: 'NSE - Automóviles', lanzadera: 'NSE' }, { etiqueta: 'NSEi - Automóviles', lanzadera: null }, { etiqueta: 'wAutemis', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Autos', titulo: 'Camiones, autobuses y vehículos industriales', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Autos', titulo: 'Flotas', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Autos', titulo: 'Verificación digital', accesos: [{ etiqueta: 'Validación de fotografías', lanzadera: null }] },
    ],
    Empresas: [
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Multirriesgo empresarial y comercios', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Responsabilidad civil', accesos: [{ etiqueta: 'NSE - RC', lanzadera: 'NSE' }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Autoemprendedores', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'CiberON Autónomos y Pymes', accesos: [{ etiqueta: 'NSE - CiberOn', lanzadera: 'NSE' }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Mercancías', accesos: [{ etiqueta: 'Tarificación y solicitud', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Todo riesgo construcción', accesos: [{ etiqueta: 'Tarificador Construcción', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Tarificador decenal', accesos: [{ etiqueta: 'Tarificador decenal', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Embarcaciones de recreo: motor y vela', accesos: [{ etiqueta: 'Cotizador embarcaciones', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Empresas', titulo: 'Drones', accesos: [{ etiqueta: 'Cotizador Drones', lanzadera: null }] },
    ],
    Patrimoniales: [
      { interfaz: 'PGM_NuevaProduccion_Patrimoniales', titulo: 'Hogar', accesos: [{ etiqueta: 'NSE - Patrimoniales', lanzadera: 'NSE_HOGAR' }] },
      { interfaz: 'PGM_NuevaProduccion_Patrimoniales', titulo: 'Comunidades', accesos: [{ etiqueta: 'NSE - Comunidades', lanzadera: 'NSE_HOGAR' }] },
      { interfaz: 'PGM_NuevaProduccion_Patrimoniales', titulo: 'Decesos', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'CITRIX' }] },
      { interfaz: 'PGM_NuevaProduccion_Patrimoniales', titulo: 'Viajes', accesos: [{ etiqueta: 'URL - Viajes', lanzadera: null }] },
      { interfaz: 'PGM_NuevaProduccion_Patrimoniales', titulo: 'Animales de compañía, protección de alquileres, defensa jurídica y BiciMás', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'CITRIX' }] },
    ],
    Salud: [
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Asistencia sanitaria', accesos: [{ etiqueta: 'Completa sin copago - Supra · GESALUD', lanzadera: 'GESALUD' }, { etiqueta: 'Completa con copago - Plus · GESALUD', lanzadera: 'GESALUD' }, { etiqueta: 'Salud Tú e-liges - Copago · GESALUD', lanzadera: 'GESALUD' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Dental', accesos: [{ etiqueta: 'GESALUD', lanzadera: 'GESALUD' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Básica - Salud elección', accesos: [{ etiqueta: 'GESALUD', lanzadera: 'GESALUD' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Sistema gestión salud', accesos: [{ etiqueta: 'Recuperar operaciones incompletas', lanzadera: null }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Reembolso y gastos', accesos: [{ etiqueta: 'Contratación seguros individuales', lanzadera: null }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Indemnización', accesos: [{ etiqueta: 'Incapacidad y/o Hospitalización', lanzadera: null }, { etiqueta: 'Indemnización por enfermedad o accidente (póliza baremada)', lanzadera: null }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Asistencia Sanitaria y reembolso', accesos: [{ etiqueta: 'Contratación seguros individuales', lanzadera: null }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Salud_v2', titulo: 'Operaciones pendientes', accesos: [{ etiqueta: 'Borradores - Tarificaciones de productos de salud', lanzadera: null }, { etiqueta: 'Recuperar operaciones incompletas', lanzadera: null }], subpestana: 'Particulares' },
    ],
    Vida: [
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Accidentes', accesos: [{ etiqueta: 'Tarificación y emisión', lanzadera: 'GESVIDA' }, { etiqueta: 'WEBVIDA', lanzadera: 'GESVIDA' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Riesgo', accesos: [{ etiqueta: 'PGM CV', lanzadera: 'PORTAL_INTERNO' }, { etiqueta: 'Tarificador Vida Riesgo', lanzadera: 'GESVIDA' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Solución Global', accesos: [{ etiqueta: 'Tarificador Solución Global', lanzadera: 'GESVIDA' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Ahorro', accesos: [{ etiqueta: 'Tarificación y emisión · GESVIDA', lanzadera: 'GESVIDA' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Rentas', accesos: [{ etiqueta: 'Tarificación y solicitud · GESVIDA', lanzadera: 'GESVIDA' }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Solicitud de seguro', accesos: [{ etiqueta: 'Descarga de documento', lanzadera: null }], subpestana: 'Particulares' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Proyecto (Riesgo)', accesos: [{ etiqueta: 'Tarificación de productos de riesgo', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Gestión de proyectos (Riesgo)', accesos: [{ etiqueta: 'Búsqueda y recuperación de proyectos', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Solicitud (Riesgo)', accesos: [{ etiqueta: 'Solicitud de emisión', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Gestión de solicitudes (Riesgo)', accesos: [{ etiqueta: 'Búsqueda y recuperación de solicitudes', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Proyecto (Resto de modalidades)', accesos: [{ etiqueta: 'Tarificación de otras modalidades', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
      { interfaz: 'PGM_NuevaProduccion_Vida', titulo: 'Proyecto (Vida - Convenios)', accesos: [{ etiqueta: 'Convenios proyectos', lanzadera: 'GESVIDA' }], subpestana: 'Colectivos' },
    ],
  },
};

@Component({
  selector: 'pgm-lanzaderas-ramo',
  imports: [EstadoComponent],
  template: `
    <h1>{{ titulo() }}</h1>
    <p class="muted" style="margin-top:-0.5rem">{{ descripcion() }}</p>
    <nav class="tabs" role="tablist" [attr.aria-label]="titulo()">
      @for (tab of pestanas(); track tab) {
        <button role="tab" [attr.aria-selected]="pestana() === tab" [class.activa]="pestana() === tab" (click)="seleccionar(tab)">
          {{ tab }}
        </button>
      }
    </nav>
    @if (pagina() === 'nueva-produccion' && pestana() === 'Vida') {
      <nav class="tabs subtabs" role="tablist" aria-label="Modalidad">
        @for (tab of pestanasVida; track tab) {
          <button role="tab" [attr.aria-selected]="subpestana() === tab" [class.activa]="subpestana() === tab" (click)="subpestana.set(tab)">
            {{ tab }}
          </button>
        }
      </nav>
    }
    @if (pagina() === 'nueva-produccion' && pestana() === 'Salud') {
      <nav class="tabs subtabs" role="tablist" aria-label="Modalidad">
        @for (tab of pestanasSalud; track tab) {
          <button role="tab" aria-selected="true" class="activa">{{ tab }}</button>
        }
      </nav>
    }
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    <section class="site-tarjetas">
      @for (tarjeta of tarjetas(); track tarjeta.interfaz + tarjeta.titulo + (tarjeta.subpestana ?? '')) {
        <article class="card site-tarjeta" [attr.data-interfaz-appian]="tarjeta.interfaz">
          <h2>{{ tarjeta.titulo }}</h2>
          <div class="site-accesos">
            @for (acceso of tarjeta.accesos; track acceso.etiqueta) {
              @if (estadoAcceso(acceso.lanzadera).url; as url) {
                <a [href]="url" target="_blank" rel="noopener noreferrer">{{ acceso.etiqueta }}</a>
              } @else {
                <span class="deshabilitado" [title]="estadoAcceso(acceso.lanzadera).motivo">
                  {{ acceso.etiqueta }} — {{ estadoAcceso(acceso.lanzadera).motivo }}
                </span>
              }
            }
          </div>
        </article>
      }
    </section>
  `,
  styles: `
    .site-tarjetas { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1rem; }
    .site-tarjeta h2 { margin-top: 0; }
    .site-accesos { display: flex; flex-direction: column; gap: .65rem; }
    .site-accesos a { color: var(--pgm-azul); font-weight: 600; }
    .deshabilitado { color: var(--pgm-texto-2); cursor: not-allowed; }
    .subtabs { margin-top: -.25rem; }
  `,
})
export class LanzaderasRamoComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly titulo = input.required<string>();
  readonly descripcion = input('');
  readonly pagina = input.required<PaginaSite>();
  readonly ramoInicial = input<Ramo | null>(null);
  readonly pestana = signal('');
  readonly subpestana = signal<'Particulares' | 'Colectivos'>('Particulares');
  readonly pestanasSalud = PESTANAS_MODALIDAD_SALUD;
  readonly pestanasVida = PESTANAS_MODALIDAD_VIDA;
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly pestanas = computed(() => ({
    'gestion-cartera': PESTANAS_GESTION_CARTERA,
    prestaciones: PESTANAS_PRESTACIONES,
    'nueva-produccion': PESTANAS_NUEVA_PRODUCCION,
  })[this.pagina()]);
  readonly tarjetas = computed(() => {
    const all = contenidoSite[this.pagina()][this.pestana()] ?? [];
    return all.filter((tarjeta) => !tarjeta.subpestana || tarjeta.subpestana === this.subpestana());
  });

  constructor() {
    effect(() => {
      const tabs = this.pestanas();
      const ramo = this.ramoInicial();
      const inicial = ramo ? this.etiquetaRamo(ramo) : null;
      this.pestana.set(tabs.includes(inicial as never) ? (inicial as string) : tabs[0]);
      this.cargar();
    });
  }

  seleccionar(tab: string): void {
    this.pestana.set(tab);
    this.subpestana.set('Particulares');
  }

  estadoAcceso(codigo: string | null): { url: string | null; motivo: string } {
    if (!codigo) return { url: null, motivo: 'Lanzadera no configurada en este entorno.' };
    const acceso = this.lanzaderas().find((item) => item.codigo === codigo);
    if (!acceso?.url) return { url: null, motivo: 'Lanzadera no configurada en este entorno.' };
    try {
      if (new URL(acceso.url).hostname.endsWith('.invalid')) {
        return { url: null, motivo: 'URL pendiente de configuración para este entorno.' };
      }
    } catch {
      return { url: null, motivo: 'URL pendiente de configuración para este entorno.' };
    }
    if (acceso.requiereNuuma && !this.store.nuuma()) {
      return { url: null, motivo: 'Requiere un usuario con NUUMA configurado.' };
    }
    return { url: acceso.url, motivo: '' };
  }

  private etiquetaRamo(ramo: Ramo): string {
    return ({
      RIESGO: 'Vida',
      VIDA: 'Vida',
      AUTOS: 'Automóviles',
      HOGAR: 'Patrimoniales',
      SALUD: 'Salud',
      AHORRO: 'Ahorro',
    } as Record<string, string>)[ramo] ?? ramo;
  }

  async cargar(): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    try {
      this.lanzaderas.set((await firstValueFrom(this.repo.lanzaderas())).items);
    } catch (e) {
      this.error.set((e as Error).message);
      this.lanzaderas.set([]);
    } finally {
      this.cargando.set(false);
    }
  }
}

@Component({
  selector: 'pgm-gestion-cartera-page',
  imports: [LanzaderasRamoComponent],
  template: `<pgm-lanzaderas-ramo
    titulo="Gestión de Cartera"
    descripcion="Suplementos, anulaciones, rehabilitaciones y consultas de cartera por ramo."
    pagina="gestion-cartera"
  />`,
})
export class GestionCarteraPageComponent {}

@Component({
  selector: 'pgm-prestaciones-page',
  imports: [LanzaderasRamoComponent],
  template: `<pgm-lanzaderas-ramo
    titulo="Prestaciones y Siniestros"
    descripcion="Apertura y seguimiento de siniestros y prestaciones por ramo."
    pagina="prestaciones"
  />`,
})
export class PrestacionesPageComponent {}
