import { Component, input } from '@angular/core';
import { Cliente } from '../../domain/models/api.models';
import { IconoComponent } from './icono.component';

export const ETIQUETA_ESTADO: Record<Cliente['estado'], string> = {
  EN_VIGOR: 'Vigor',
  POTENCIAL: 'Potencial',
  ANULADO: 'Anulado',
};

/**
 * Indicadores de ficha y palancas visibles en la cabecera Appian.
 */
@Component({
  selector: 'pgm-indicadores-cliente',
  imports: [IconoComponent],
  template: `
    @if (vista() === 'chips') {
      <div class="row">
        <span
          class="pill-estado"
          [class.potencial]="c().estado === 'POTENCIAL'"
          [class.anulado]="c().estado === 'ANULADO'"
        >
          <pgm-icono nombre="usuario" [tam]="15" /> {{ etiquetaEstado[c().estado] }}
        </span>
        <span class="chip">{{ etiquetaTipologia[c().tipologia] }}</span>
        @if (c().vip) {
          <span class="chip chip-rojo">VIP</span>
        }
        @if (c().robinson) {
          <span class="chip chip-aviso">Robinson</span>
        }
        @if (c().exclusivoCorredor) {
          <span class="chip chip-aviso">Exclusivo corredor</span>
        }
        @if (esMenor()) {
          <span class="chip chip-aviso">Menor</span>
        }
      </div>
    } @else {
      <div class="palancas">
        @for (p of palancas; track p.clave) {
          <div class="palanca" [class.activa]="c().palancas[p.clave]">
            <div class="titulo">
              @if (c().palancas[p.clave]) {
                <pgm-icono nombre="check" [tam]="16" [trazo]="2.4" />
              } @else if (p.clave === 'rgpdFirmado') {
                <span class="aviso"><pgm-icono nombre="aviso" [tam]="16" [trazo]="2.2" /></span>
              } @else {
                <pgm-icono nombre="mas" [tam]="16" [trazo]="2.4" />
              }
              <strong>{{ p.texto }}</strong>
            </div>
            <div class="estado">{{ c().palancas[p.clave] ? p.si : p.no }}</div>
          </div>
        }
        <div class="palanca">
          <div class="titulo"><strong>ClubMAPFRE</strong></div>
          <div class="estado">No disponible</div>
        </div>
      </div>
    }
  `,
  styles: `
    .palancas {
      display: grid;
      grid-template-columns: repeat(3, minmax(160px, 1fr));
      gap: 1.25rem 1.5rem;
    }
    .titulo {
      display: flex;
      align-items: center;
      gap: 0.4rem;
      color: #8a9299;
    }
    .titulo strong {
      color: var(--pgm-texto);
      font-weight: 600;
    }
    .palanca.activa .titulo {
      color: var(--pgm-ok);
    }
    .aviso {
      color: var(--pgm-aviso);
      display: inline-flex;
    }
    .estado {
      font-size: 0.85rem;
      color: var(--pgm-texto-2);
      margin-top: 0.15rem;
    }
  `,
})
export class IndicadoresClienteComponent {
  readonly c = input.required<Cliente>();
  readonly vista = input<'chips' | 'palancas'>('chips');
  readonly etiquetaEstado = ETIQUETA_ESTADO;
  readonly etiquetaTipologia: Record<Cliente['tipologia'], string> = {
    PARTICULAR: 'Particular',
    AUTONOMO: 'Autónomo',
    EMPRESA: 'Empresa',
  };
  readonly palancas: { clave: keyof Cliente['palancas']; texto: string; si: string; no: string }[] =
    [
      {
        clave: 'dniDigitalizado',
        texto: 'DNI',
        si: 'Documentación digitalizada',
        no: 'Cliente sin documentación digitalizada',
      },
      { clave: 'rgpdFirmado', texto: 'RGPD', si: 'RGPD firmado', no: 'RGPD no firmado' },
      { clave: 'altaAci', texto: 'ACI', si: 'Alta en ACI', no: 'Potencial' },
      { clave: 'enFamilia', texto: 'En Familia', si: 'Con unidad familiar', no: 'Sin familia' },
      { clave: 'planPagos', texto: 'Plan de pagos', si: 'Contratado', no: 'Potencial' },
    ];

  esMenor(): boolean {
    const f = this.c().fechaNacimiento;
    if (!f) return false;
    const edad = (Date.now() - new Date(f).getTime()) / (365.25 * 24 * 3600 * 1000);
    return edad < 18;
  }
}
