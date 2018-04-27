# End-to-end tests

## Helpers

Declared in `_modules/init.js`

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