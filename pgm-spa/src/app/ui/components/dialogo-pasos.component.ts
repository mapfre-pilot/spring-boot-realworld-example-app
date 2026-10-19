import { Component, input, output, signal } from '@angular/core';

/** Diálogo modal multipaso (patrón de los diálogos de PGM: Vto./Ppto., Plan de pagos, Tarificación…). */
@Component({
  selector: 'pgm-dialogo-pasos',
  template: `
    @if (abierto()) {
      <button class="fondo" type="button" aria-label="Cerrar diálogo" (click)="cerrar.emit()"></button>
      <div class="dialogo card" role="dialog" aria-modal="true">
        <div class="row">
          <h2>{{ titulo() }}</h2>
          <span class="spacer"></span>
          <button class="btn-enlace" (click)="cerrar.emit()" aria-label="Cerrar">✕</button>
        </div>
        <ol class="pasos">
          @for (p of pasos(); track p; let i = $index) {
            <li [class.activo]="i === paso()" [class.hecho]="i < paso()">{{ p }}</li>
          }
        </ol>
        <div class="contenido"><ng-content /></div>
        <div class="row acciones">
          <button class="btn btn-secundario" [disabled]="paso() === 0" (click)="ir(-1)">Anterior</button>
          <span class="spacer"></span>
          @if (paso() < pasos().length - 1) {
            <button class="btn" [disabled]="!puedeAvanzar()" (click)="ir(1)">Siguiente</button>
          } @else {
            <button class="btn" [disabled]="!puedeAvanzar()" (click)="finalizar.emit()">{{ textoFinal() }}</button>
          }
        </div>
      </div>
    }
  `,
  styles: `
    .fondo { position: fixed; inset: 0; background: rgba(0,0,0,.4); z-index: 20; border: none; padding: 0; cursor: default; }
    .dialogo { position: fixed; top: 10vh; left: 50%; transform: translateX(-50%); width: min(720px, 92vw); z-index: 21; display: grid; gap: 1rem; }
    .pasos { display: flex; gap: 1rem; list-style: none; padding: 0; margin: 0; counter-reset: paso; }
    .pasos li { counter-increment: paso; color: var(--pgm-gris-3); }
    .pasos li::before { content: counter(paso); display: inline-grid; place-items: center; width: 22px; height: 22px; border-radius: 50%; border: 1px solid currentColor; margin-right: .4rem; font-size: .8rem; }
    .pasos li.activo { color: var(--pgm-rojo); font-weight: 600; }
    .pasos li.hecho { color: var(--pgm-ok); }
    .acciones { border-top: 1px solid var(--pgm-gris-2); padding-top: .75rem; }
  `,
})
export class DialogoPasosComponent {
  readonly abierto = input(false);
  readonly titulo = input('');
  readonly pasos = input.required<string[]>();
  readonly puedeAvanzar = input(true);
  readonly textoFinal = input('Finalizar');
  readonly cerrar = output<void>();
  readonly finalizar = output<void>();
  readonly cambioPaso = output<number>();
  readonly paso = signal(0);

  ir(d: number): void {
    this.paso.set(Math.min(this.pasos().length - 1, Math.max(0, this.paso() + d)));
    this.cambioPaso.emit(this.paso());
  }

  reiniciar(): void {
    this.paso.set(0);
  }
}
