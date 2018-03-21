# Notes

- Use generic file for mocked props

## ActiveRoutes

- It exports both default and named

- Test should mock Carousel component

## AddressBook

Test is running with this warning:

`
Warning: Failed prop type: Property `contacts` of component `AddressBook` has invalid PropType notation inside arrayOf.
        in AddressBook
`

- Test complete

## Admin

- Waiting for all other unit tests to be ready

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

## AlertModalBody

- Test complete

## AvailableRoutes

- Not suitable for unit testing

## BestRoutesBox

- Uses default export

- Component is build with three smaller components. These components should be outside of the component, so they can be exported and tested.

## BlogPostHighlights

- Basic test only

## Button

- Test complete
