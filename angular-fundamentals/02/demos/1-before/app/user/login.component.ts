import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { AuthService } from './auth.service';

@Component({
    templateUrl: 'app/user/login.component.html'
})
export class LoginComponent {

    constructor(private authService:AuthService, private router:Router) {}

    login(formValues) {
        this.authService.loginUser(formValues.userName, formValues.password);
        this.router.navigate(['events']);
    }

    cancel(){
        this.router.navigate(['events']);        
    }
}