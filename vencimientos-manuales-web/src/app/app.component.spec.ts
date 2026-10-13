import { AppComponent } from './app.component';

describe('AppComponent', () => {
  it('identifica la aplicación de Vida 372', () => {
    expect(new AppComponent().title).toEqual('vencimientos-manuales-web');
  });
});
