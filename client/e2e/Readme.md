# End-to-end tests

## Scripts

- `dev` - will save steps screenshots and will display additional logging
- `dev:headless` - same as `dev` but with enabled headless mode
- `dev:fast` - will save steps screenshots
- `dev:all` - will save steps screenshots in headless mode

## How to run e2e tests with Docker

1. Build with `docker build -t e2e .` or `yarn build`

2. Start with `docker-compose up --remove-orphans` or `yarn docker`

3. If test was successful, You should find multiple screens in `./client/e2e/_screens` folder.

## How to run e2e tests locally

1. Have a running `Rails`(***rails server***) and `Webpack`(***npm start***)

2. Install e2e dependencies in folder `./client/e2e/` with yarn not `npm` - `yarn install`

3. Run `yarn test`(again with `yarn`) for running test with artificial delay of **200ms**.

## Visual regression testing

Created in order to confirm that refactored component has the same visual representation as the origin component.
We are using method `shouldMatchScreenshot` declared in `./_modules/init.js`.

```javascript
/**
 * ./Order/steps/clickReviewBooking.js
 */
export default async function clickReviewBooking (puppeteer) {
  expect(await puppeteer.clickWithText('p', 'Review Booking')).toBeTruthy()
  expect(await puppeteer.page.waitForSelector('i.fa-ship')).toBeTruthy()

  await puppeteer.shouldMatchScreenshot('review.booking', 110)
}
```

Images are saved in `./node_modules`.
The number `110` presents allowed 110 pixels difference allowed. It is optional and if omitted, value `0` will be assumed.

The first time this code runs, it will create origin image.

Every other time this code runs, it will create image and compare it to the origin image. In any case, you will receive log information about the difference in pixels between the two images.

If there is more than `110` pixels, diff image will be created and opened with your default image viewer. You will see in purple those areas, where two images differ.

---

! Important

In the example above, we are using `shouldMatchScreenshot` within a step declaration. This declaration is used by both `./Order/step/orderExportFCL.js` and `./Order/step/orderExportLCL.js`. So in this case, we can use `shouldMatchScreenshot` only if we use `test.only` in one of the two tests written in `./Order/test.js`.

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