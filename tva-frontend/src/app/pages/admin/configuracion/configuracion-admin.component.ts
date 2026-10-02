/**
 * Configuración de conectores (modo mock/real, URLs, usuarios y secretos).
 * Los secretos nunca se reciben del backend: solo se indica si están configurados
 * y un campo vacío conserva el valor actual.
 */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';

import {
  CampoConfiguracion,
  GuardarConfiguracionUsecase,
  ObtenerConfiguracionUsecase,
  ProbarConfiguracionUsecase,
  ResultadoPruebaConfiguracion,
} from '@tva/core';

interface GrupoConfiguracion {
  grupo: string;
  etiqueta: string;
  campos: CampoConfiguracion[];
}

const GRUPOS_CON_NIF = ['misv', 'ric'];

@Component({
  selector: 'app-configuracion-admin',
  imports: [
    MatButtonModule,
    MatExpansionModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
  ],
  templateUrl: './configuracion-admin.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConfiguracionAdminComponent implements OnInit {
  private readonly obtener = inject(ObtenerConfiguracionUsecase);
  private readonly guardarUsecase = inject(GuardarConfiguracionUsecase);
  private readonly probarUsecase = inject(ProbarConfiguracionUsecase);

  protected readonly campos = signal<CampoConfiguracion[]>([]);
  protected readonly cambios = signal<Record<string, string>>({});
  protected readonly nifs = signal<Record<string, string>>({});
  protected readonly resultados = signal<Record<string, ResultadoPruebaConfiguracion>>({});
  protected readonly gruposConNif = GRUPOS_CON_NIF;

  protected readonly grupos = computed<GrupoConfiguracion[]>(() => {
    const grupos = new Map<string, GrupoConfiguracion>();
    for (const campo of this.campos()) {
      const g = grupos.get(campo.grupo) ?? {
        grupo: campo.grupo,
        etiqueta: campo.grupoEtiqueta,
        campos: [],
      };
      g.campos.push(campo);
      grupos.set(campo.grupo, g);
    }
    return [...grupos.values()];
  });

  ngOnInit(): void {
    this.obtener.execute().subscribe(c => this.campos.set(c));
  }

  protected valor(campo: CampoConfiguracion): string {
    return this.cambios()[campo.nombre] ?? campo.valor ?? '';
  }

  protected modo(grupo: GrupoConfiguracion): string {
    const campo = grupo.campos.find(c => c.tipo === 'modo');
    return campo ? this.valor(campo) : '';
  }

  protected cambiar(nombre: string, valor: string): void {
    this.cambios.update(c => ({ ...c, [nombre]: valor }));
  }

  protected cambiarNif(grupo: string, nif: string): void {
    this.nifs.update(n => ({ ...n, [grupo]: nif }));
  }

  protected pendientes(grupo: GrupoConfiguracion): string[] {
    return grupo.campos.map(c => c.nombre).filter(n => n in this.cambios());
  }

  protected guardar(grupo: GrupoConfiguracion): void {
    const nombres = this.pendientes(grupo);
    const valores = Object.fromEntries(nombres.map(n => [n, this.cambios()[n]]));
    this.enviar(nombres, { valores, restablecer: [] });
  }

  protected restablecer(grupo: GrupoConfiguracion): void {
    const restablecer = grupo.campos.filter(c => c.origen === 'bd').map(c => c.nombre);
    this.enviar(
      grupo.campos.map(c => c.nombre),
      { valores: {}, restablecer }
    );
  }

  protected probar(grupo: string): void {
    this.probarUsecase
      .execute(grupo, this.nifs()[grupo])
      .subscribe(r => this.resultados.update(rs => ({ ...rs, [grupo]: r })));
  }

  private enviar(
    nombres: string[],
    cambio: { valores: Record<string, string>; restablecer: string[] }
  ): void {
    this.guardarUsecase.execute(cambio).subscribe(c => {
      this.campos.set(c);
      this.cambios.update(cs =>
        Object.fromEntries(Object.entries(cs).filter(([n]) => !nombres.includes(n)))
      );
    });
  }
}
