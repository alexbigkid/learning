import { Ng2FundamentalsCompleteCliPage } from './app.po';

describe('ng2-fundamentals-complete-cli App', function() {
  let page: Ng2FundamentalsCompleteCliPage;

  beforeEach(() => {
    page = new Ng2FundamentalsCompleteCliPage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
