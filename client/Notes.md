# Notes

- Use generic file for mocked props

## ActiveRoutes

It exports both default and named

## AddressBook

`
Warning: Failed prop type: Property `contacts` of component `AddressBook` has invalid PropType notation inside arrayOf.
        in AddressBook
`

## Alert

Tested without mock for 'react-sticky' as this mock:

```javascript
jest.mock('react-sticky', () => {
  const Identity = (props) => <div>{props.children}</div>

  return {
    Sticky: Identity,
    StickyContainer: Identity
  }
})
```

leads to:

`
Warning: Functions are not valid as a React child. This may happen if you return a Component instead of <Component /> from render. Or maybe you meant to call this function rather than return it.
        in div (created by Identity)
        in Identity (created by Alert)
        in div (created by Identity)
        in Identity (created by Alert)
        in Alert (created by WrapperComponent)
        in WrapperComponent

`

## BlogPostHighlights

- Uses default export

- Component is build with three smaller components. These components should be outside of the component, so they can be exported and tested.