# Unit tests

## Small rules

- try to sort property keys alphabetically

## Naming conventions

### dom

Name your wrapper `dom` if you can't think for a better name. 

Otherwise try to specify in the name how this wrapper defers from `propsBase` wrapper.

`
const withButton = createWrapper(props)
const dom = createWrapper(props)
`

### props & propsBase

Each unit test should have `propsBase` that is used to build **Enzyme.mount** `wrapper`.

Every test case that needs a different properties should declare them as `props`

`
const propsBase = {
  a: 1,
  b: 2
}

test('foo', () => {
  const props = {
    ...propsBase,
    b: 3
  }
})
`
