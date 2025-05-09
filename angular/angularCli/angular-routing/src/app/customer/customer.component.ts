import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-customer',
  templateUrl: './customer.component.html',
  styleUrls: ['./customer.component.css']
})
export class CustomerComponent implements OnInit {
  customers: any[];
  hasPermissions = true;
  constructor() { }

  ngOnInit() {
    if (this.hasPermissions) {
      this.getCustomers()
        .then(custmers => this.customers = custmers)
        .catch(e => console.log(e.message));
    } else {
      this.customers = [];
    }
  }

  async getCustomers() {
    return [
      {name: 'john', email: 'john@hunterindustries.com'},
      {name: 'joanna', email: 'joanna@hunterindustries.com'}
    ];
  }

}
