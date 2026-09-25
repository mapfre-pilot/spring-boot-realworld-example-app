import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { AppianEmbedScriptService } from '@tva/core';
import { AppianTaskDialogComponent } from './appian-task-dialog.component';

describe('AppianTaskDialogComponent', () => {
  const script = { cargar: jest.fn(), disponible: jest.fn() };
  const create = createComponentFactory({
    component: AppianTaskDialogComponent,
    providers: [{ provide: AppianEmbedScriptService, useValue: script }],
    detectChanges: false,
  });

  function setup(data: { modo: 'mock' | 'real'; titulo?: string; taskId?: string }) {
    const ref = { close: jest.fn() };
    const s: Spectator<AppianTaskDialogComponent> = create({
      providers: [
        { provide: MAT_DIALOG_DATA, useValue: { titulo: 't', taskId: 'x', ...data } },
        { provide: MatDialogRef, useValue: ref },
      ],
    });
    s.detectChanges();
    return { s, ref };
  }

  it('modo mock: Simular completado → SUBMIT', () => {
    const { s, ref } = setup({ modo: 'mock' });
    expect(s.component.estado()).toBe('mock');
    const btn = Array.from(s.element.querySelectorAll('button')).find(b =>
      b.textContent?.includes('Simular completado')
    ) as HTMLButtonElement;
    btn.click();
    expect(ref.close).toHaveBeenCalledWith('SUBMIT');
  });

  it('modo mock: Cancelar → DISMISS', () => {
    const { s, ref } = setup({ modo: 'mock' });
    const btn = Array.from(s.element.querySelectorAll('button')).find(b =>
      b.textContent?.includes('Cancelar')
    ) as HTMLButtonElement;
    btn.click();
    expect(ref.close).toHaveBeenCalledWith('DISMISS');
  });

  it('modo real: task-body aparece → estado tarea', async () => {
    script.cargar.mockResolvedValue(undefined);
    const { s } = setup({ modo: 'real' });
    await Promise.resolve();
    const body = document.createElement('div');
    body.id = 'task-body';
    document.body.appendChild(body);
    await new Promise(r => setTimeout(r, 50));
    expect(s.component.estado()).toBe('tarea');
    document.body.removeChild(body);
  });

  it('modo real: timeout sin tarea → error', async () => {
    jest.useFakeTimers();
    script.cargar.mockResolvedValue(undefined);
    const { s } = setup({ modo: 'real' });
    await Promise.resolve();
    jest.advanceTimersByTime(16000);
    await Promise.resolve();
    expect(['error', 'cargando']).toContain(s.component.estado());
    jest.useRealTimers();
  });
});
