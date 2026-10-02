import { provideRouter } from '@angular/router';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { AppComponent } from './app.component';

describe('AppComponent', () => {
  const create = createComponentFactory({
    component: AppComponent,
    providers: [provideRouter([])],
  });

  it('renderiza el outlet de rutas', () => {
    const s: Spectator<AppComponent> = create();
    expect(s.component).toBeTruthy();
    expect(s.query('router-outlet')).toBeTruthy();
  });
});
