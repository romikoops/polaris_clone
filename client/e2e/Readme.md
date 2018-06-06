# End-to-end tests

## Known issues

`TypeError: Cannot read property 'bindings' of null`

It happens when `npm install` is used instead of `yarn install`

---
`
TypeError: Cannot read property 'catchError' of undefined

      31 |   } catch (e) {
      32 |     console.log(e)
    > 33 |     const { screen } = await puppeteer.catchError({})
`

Fixable with reinstalling with `yarn` command. If that doesn't help, try closing any opened `Chrome` browsers.

---

`
** ERROR: directory is already being watched! **

        Directory: /Users/henry/imc-react-api/client/e2e/node_modules/puppeteer/.local-chromium/mac-549031/chrome-mac/Chromium.app/Contents/Versions/67.0.3391.0/Chromium Framework.framework/Versions/Current

        is already being watched through: /Users/henry/imc-react-api/client/e2e/node_modules/puppeteer/.local-chromium/mac-549031/chrome-mac/Chromium.app/Contents/Versions/67.0.3391.0/Chromium Framework.framework/Versions/A

        MORE INFO: https://github.com/guard/listen/wiki/Duplicate-directory-errors
`

The only solution is to move the entire frontend application into it’s own directory. We will do that as soon as we have somewhat stable test suite in the frontend.

https://github.com/guard/listen/issues/363#issuecomment-171867909

## How to run e2e tests

1. `yarn install`

2. Set include `testRegex: '.spec.jsx$'` in `/client/jest.config.js`

3. Run `yarn test` for standard e2e test settings

4. Or run `yarn dev` for e2e test with additional delay

## Helpers

They are declared in `_modules/init.js` file.

### click(selector: string, index?: number): boolean

`
// Click first button
await click('button')

// Click fifth button
await click('button', 4)
`

### focus(selector: string): void

### exists(selector: string): boolean

It checks if DOM element, defined with `selector`, exist.

### count(selector: string): number

It counts how many DOM elements are matched with `selector`.

### fill(selector: string, text: string): void

Fill input form defined by `selector` with `text`.
Includes delay of 50 ms between each keypress

### waitFor(selector: string, count?: number = 1): boolean

It waits for 3 seconds for `selector` to return at least `count` number of DOM elements.

### waitForSelectors(selectors: string[]): boolean

It waits for 3 seconds for all `selectors` to return a DOM element.

### $(selector: string, fn: Function, args: string[]): any

Wrapper around `page.$eval`

### $$(selector: string, fn: Function, args: string[]): any

Wrapper around `page.$$eval`

### url(): string

It returns the current URL address.

### onError(): string

It returns information about the latest operation and the latest selector.

Useful to determine where exactly is the failing test assertion.

## TODO

- Update method list in `Readme.md`