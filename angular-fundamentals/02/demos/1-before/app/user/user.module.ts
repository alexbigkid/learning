import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { RouterModule } from "@angular/router";

import { UserRoutes } from './user.routes';
import { ProfileComponent } from "./profile.component";
import { LoginComponent } from "./login.component";

@NgModule({
    imports: [
        CommonModule,
        UserRoutes
    ],
    declarations: [
        ProfileComponent,
        LoginComponent
    ],
    providers: [

    ]
})
export class UserModule {

}