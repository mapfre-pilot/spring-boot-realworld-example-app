/** Carga perezosa del script `embeddedBootstrap.nocache.js` de Appian (una sola vez). */
import { DOCUMENT, inject, Injectable } from '@angular/core';

import { EnvironmentService } from '../config/environment.service';

@Injectable({ providedIn: 'root' })
export class AppianEmbedScriptService {
  private readonly env = inject(EnvironmentService);
  private readonly doc = inject(DOCUMENT);
  private carga?: Promise<void>;

  cargar(): Promise<void> {
    if (this.carga) return this.carga;
    this.carga = new Promise((resolve, reject) => {
      const cfg = this.env.config['appianEmbed'] as
        | { baseUrl?: string; themeIdentifier?: string; signIn?: string }
        | undefined;
      if (this.doc.getElementById('appianEmbedded')) return resolve();
      const script = this.doc.createElement('script');
      script.setAttribute('id', 'appianEmbedded');
      script.setAttribute(
        'src',
        `${cfg?.baseUrl ?? ''}/tempo/ui/sail-client/embeddedBootstrap.nocache.js`
      );
      script.setAttribute('data-themeidentifier', cfg?.themeIdentifier ?? '');
      script.setAttribute('data-signin', cfg?.signIn ?? '');
      script.onload = () => resolve();
      script.onerror = () => reject(new Error('No se pudo cargar el script de Appian'));
      this.doc.body.appendChild(script);
    });
    return this.carga;
  }

  disponible(): boolean {
    return !!this.doc.getElementById('appianEmbedded');
  }
}
