#End 2 End Testing (Protractor)
To run the end-2-end tests against the application you use [Protractor](https://github.com/angular/protractor).

## Starting the Web Server
In either case you will need the application to be running via the web-server.
From the root folder of the repository run:

```
npm start
```

The application should now be available at `http://localhost:8000/`

## Testing with Protractor

As a one-time setup, download webdriver.
```
npm run update-webdriver
```

Start the Protractor test runner using the e2e configuration:

```
npm run protractor
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
