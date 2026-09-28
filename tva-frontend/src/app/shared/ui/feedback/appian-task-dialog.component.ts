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
  templateUrl: './appian-task-dialog.component.html',
  styleUrl: './appian-task-dialog.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
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
