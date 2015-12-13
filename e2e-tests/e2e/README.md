#End 2 End Testing (Protractor)
To run the end-2-end tests against the application you use [Protractor](https://github.com/angular/protractor).

## Testing with Protractor

As a one-time setup, download webdriver.
```
npm run update-webdriver
```

Start the Protractor test runner using the e2e configuration:

```
make e2e_test
```

## Devel tips

    {
      locator_:  {
        using: 'css selector',
        value: '[ng-click="getLanguage(lang)"]'
       },
      parentElementFinder_: null,
      opt_actionResult_: {
        then: [Function: then],
        cancel: [Function: cancel],
        isPending: [Function: isPending]
      },
      opt_index_: 1,
      click: [Function],
      sendKeys: [Function],
      getTagName: [Function],
      getCssValue: [Function],
      getAttribute: [Function],
      getText: [Function],
      getSize: [Function],
      getLocation: [Function],
      isEnabled: [Function],
      isSelected: [Function],
      submit: [Function],
      clear: [Function],
      isDisplayed: [Function],
      getOuterHtml: [Function],
      getInnerHtml: [Function],
      toWireValue: [Function]
    }
