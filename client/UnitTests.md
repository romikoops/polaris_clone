# Unit tests

## Small rules

- try to sort property keys alphabetically

- skip empty lines between mock declaration, if they are more than 2

- empty line before return can be skipped inside `jest.mock` declaration

```javascript
jest.mock('../Checkbox/Checkbox', () => {
  return {
    Checkbox: ({ children }) => <div>{children}</div>
  }
})
```

## Shallow rendering

Use the following pattern:

`
const createShallow = propsInput => shallow(<Component {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.ready is true', () => {
  const props = {
    ...propsBase,
    ready: true
  }
  expect(createShallow(props)).toMatchSnapshot()
})
`

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
