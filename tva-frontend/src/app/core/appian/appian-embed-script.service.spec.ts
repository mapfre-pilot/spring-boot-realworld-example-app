import { DOCUMENT } from '@angular/core';
import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';

import { EnvironmentService } from '@mapfre-tech/ngx-multienvironment/core';

import { AppianEmbedScriptService } from './appian-embed-script.service';

describe('AppianEmbedScriptService', () => {
  const env = {
    config: {
      appianEmbed: {
        baseUrl: 'https://appian.test/suite',
        themeIdentifier: 'mapfre',
        signIn: 'appiantestmapfrenopro',
      },
    },
  };
  const create = createServiceFactory({
    service: AppianEmbedScriptService,
    providers: [{ provide: EnvironmentService, useValue: env }],
  });

  it('añade el script una sola vez con los atributos correctos', async () => {
    const s: SpectatorService<AppianEmbedScriptService> = create();
    const doc = TestBed_doc(s);
    const p1 = s.service.cargar();
    const script = doc.getElementById('appianEmbedded') as HTMLScriptElement;
    expect(script).toBeTruthy();
    expect(script.src).toContain('embeddedBootstrap.nocache.js');
    expect(script.getAttribute('data-themeidentifier')).toBe('mapfre');
    script.onload?.(new Event('load'));
    await p1;
    await s.service.cargar();
    expect(doc.querySelectorAll('#appianEmbedded')).toHaveLength(1);
    expect(s.service.disponible()).toBe(true);
  });
});

import { TestBed } from '@angular/core/testing';
function TestBed_doc(s: { service: unknown }): Document {
  return TestBed.inject(DOCUMENT);
}
