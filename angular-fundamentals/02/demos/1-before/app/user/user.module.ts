import { NgModule } from "@angular/core";
import { CommonModule } from "@angular/common";
import { RouterModule } from "@angular/router";

import { UserRoutes } from './user.routes';
import { ProfileComponent } from "./profile.component";

@NgModule({
    imports: [
        CommonModule,
        UserRoutes
    ],
    declarations: [
        ProfileComponent
    ],
    providers: [

    ]
})
export class UserModule {

}