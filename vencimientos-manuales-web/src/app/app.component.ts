import { Component } from '@angular/core';
import { MainLayoutComponent } from './ui/components/main-layout.component';

@Component({
  standalone: true,
  imports: [MainLayoutComponent],
  selector: 'vida-root',
  template: '<vida-main-layout />',
})
export class AppComponent {
  title = 'vencimientos-manuales-web';
}
