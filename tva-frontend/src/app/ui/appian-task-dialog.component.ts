/** Diálogo con la tarea embebida de Appian (`<appian-task>`) — submit/error → resultado del pop-up. */
import {
  ChangeDetectionStrategy,
  Component,
  DOCUMENT,
  ElementRef,
  Injector,
  OnDestroy,
  viewChild,
  afterNextRender,
  inject,
  signal,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { AppianEmbedScriptService } from '@tva/core';

export interface AppianTaskDialogData {
  titulo: string;
  taskId: string;
  modo: 'mock' | 'real';
}

interface AppianTaskElement extends HTMLElement {
  destroy(): void;
}

@Component({
  selector: 'app-appian-task-dialog',
  imports: [MatDialogModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <h2 mat-dialog-title class="dialogo-titulo">
      {{ data.titulo }}
      <button mat-icon-button class="cerrar" aria-label="Cerrar" (click)="ref.close('DISMISS')">
        <mat-icon>close</mat-icon>
      </button>
    </h2>
    <mat-dialog-content>
      @if (estado() === 'cargando' || estado() === 'login') {
        <div class="cargando">
          <mat-spinner diameter="40" />
          <p>
            @if (estado() === 'login') {
              Complete el inicio de sesión en la pestaña abierta; la tarea aparecerá aquí.
            } @else {
              Cargando tarea de Appian…
            }
          </p>
        </div>
      }
      @if (estado() === 'mock') {
        <p>Appian en modo simulado (stub local).</p>
        <button mat-flat-button color="primary" (click)="ref.close('SUBMIT')">
          Simular completado
        </button>
        <button mat-button (click)="ref.close('DISMISS')">Cancelar</button>
      }
      @if (estado() === 'error') {
        <p>{{ mensajeError() }}</p>
        <button mat-stroked-button (click)="reintentar()">Reintentar</button>
        <button mat-button (click)="ref.close('ERROR')">Cerrar</button>
      }
      <div #contenedor></div>
    </mat-dialog-content>
  `,
  styles: `
    .dialogo-titulo {
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-top: 4px solid var(--tva-primary, #d81e05);
      padding-top: 16px;
      font-size: 16px;
      font-weight: 600;
    }
    mat-dialog-content {
      min-height: 480px;
      overflow: auto;
    }
    mat-dialog-content appian-task,
    mat-dialog-content iframe {
      width: 100%;
    }
    .cargando {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 320px;
      text-align: center;
    }
    .cerrar {
      margin-left: auto;
    }
    mat-spinner {
      margin-bottom: 16px;
    }
  `,
})
export class AppianTaskDialogComponent implements OnDestroy {
  readonly data = inject<AppianTaskDialogData>(MAT_DIALOG_DATA);
  readonly ref = inject(MatDialogRef<AppianTaskDialogComponent>);
  private readonly script = inject(AppianEmbedScriptService);
  private readonly doc = inject(DOCUMENT);
  private readonly injector = inject(Injector);
  private observer?: MutationObserver;
  private tarea?: AppianTaskElement;

  private readonly contenedor = viewChild.required<ElementRef<HTMLElement>>('contenedor');

  readonly estado = signal<'cargando' | 'login' | 'tarea' | 'error' | 'mock'>('cargando');
  readonly mensajeError = signal('Appian no responde');

  constructor() {
    afterNextRender(() => this.iniciar(), { injector: this.injector });
  }

  private async iniciar(): Promise<void> {
    if (this.data.modo === 'mock') {
      this.estado.set('mock');
      return;
    }
    try {
      await this.script.cargar();
    } catch {
      this.estado.set('error');
      this.mensajeError.set('No se pudo cargar el script de Appian');
      return;
    }
    const el = this.doc.createElement('appian-task') as AppianTaskElement;
    el.setAttribute('id', 'appian-task');
    el.setAttribute('taskId', this.data.taskId);
    el.addEventListener('submit', () => this.ref.close('SUBMIT'));
    el.addEventListener('error', () => this.ref.close('ERROR'));
    this.contenedor().nativeElement.appendChild(el);
    this.tarea = el;
    this.esperarTarea();
  }

  /** Espera a #appianLoginIframe (login en pestaña nueva) o #task-body (lista). */
  private esperarTarea(): void {
    let vistoLogin = false;
    let timeoutId: ReturnType<typeof setTimeout>;
    const timeout = () =>
      setTimeout(
        () => {
          this.observer?.disconnect();
          if (this.estado() !== 'tarea') {
            this.estado.set('error');
            this.mensajeError.set('Appian no responde');
          }
        },
        vistoLogin ? 5 * 60 * 1000 : 15000
      );
    timeoutId = timeout();
    this.observer = new MutationObserver(() => {
      const login = this.doc.getElementById('appianLoginIframe') as HTMLIFrameElement | null;
      if (login && !vistoLogin) {
        vistoLogin = true;
        this.estado.set('login');
        clearTimeout(timeoutId);
        timeoutId = timeout();
        window.open(login.src, '_blank');
        return;
      }
      if (this.doc.getElementById('task-body')) {
        this.observer?.disconnect();
        clearTimeout(timeoutId);
        this.estado.set('tarea');
      }
    });
    this.observer.observe(this.doc.documentElement, { childList: true, subtree: true });
  }

  reintentar(): void {
    this.observer?.disconnect();
    this.tarea?.destroy?.();
    this.tarea?.remove();
    this.tarea = undefined;
    this.estado.set('cargando');
    this.iniciar();
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
    this.tarea?.destroy?.();
  }
}
