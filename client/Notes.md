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

[X] Test complete

## AvailableRoutes

- Not suitable for unit testing

## BestRoutesBox

- Uses default export

- Component is build with three smaller components. These components should be outside of the component, so they can be exported and tested.

## BlogPostHighlights

- Basic test only

## Button

[X] Test complete

## BookingConfirmation

`
const {
  shipment,
  schedules,
  locations,
  shipper,
  consignee,
  notifyees,
  cargoItems,
  containers,
  documents
} = shipmentData
`

while prop-types defines `shipmentData` like this

`
PropTypes.shipmentData = PropTypes.shape({
  contacts: PropTypes.array,
  shipment: PropTypes.object,
  documents: PropTypes.array,
  cargoItems: PropTypes.array,
  containers: PropTypes.array,
  schedules: PropTypes.array
})
`

- Too big therefore only single basic test

## BookingDetails

props.shipmentData has additional properties not declared in its PropType:

- cargoItemTypes

- hubs

[X] Test complete

## CacheClearer

- Component is exported already wrapped, so no test at this moment

## CardLink

- Not very sure what to test, so there is only one test with component's text content.

## CardLinkRow

- Basic test as the component is just a wrapper around list of CardLink components.

## CargoItemDetails

[X] Test complete

## Carousel

[X] Test complete

## Checkbox

[X] Test complete

## Contact

- ! Uses default export

- props.contact.data is PropType `contact` but it is not declared as such

- props.contact.location is PropType `location` but it is not declared as such

[X] Test complete

## ContactCard

- props.contactData.contact is very similar to PropType `user` but is using `firstName` instead of `first_name`

[X] Test complete

## ContainerDetails

[X] Test complete

## FlashMessages

Should it be tested? (no)

## FloatingMenu 

Require `PropTypes.oneOfType([ PropTypes.node, PropTypes.func ])`

## FormsyInput

The whole exported component is wrapped in library

## Header

Besides too large, the base component is not exported

## HsCodeViewer

Basic test as underlying list of elements should be tested separately.

## LandingTop

tenant PropType uses additional property path `data.name`

[X] Test complete

## LoadingBox

Should it be tested as there is no behaviour, no props defining content, rather just static rendering. In this case snapshot testing looks like better test solution.

## LoginRegistrationWrapper

[X] Test complete

## Maps

Cannot proceed with test due to

`gMaps.places.Autocomplete is not a constructor`

## NavDropdown

Line 37: missing key as div property

`
    return <div onClick={op.select}>{op.key}</div>
`

should be:
`
    return <div key={op.key} onClick={op.select}>{op.key}</div>
`

[X] Test complete

## NavSidebar

[X] Test complete

## Price

[X] Test complete

## QuantityInput

[X] Test complete

## RoundButton

[X] Test complete

## RouteFilterBox

Fat component, so only snapshot testing

Line 132:

`
Failed prop type: The prop `name` is marked as required in `Checkbox`, but its value is `undefined`
`

## RouteHubBox

Fat component, so only snapshot testing

!! Mismatch in PropTypes:

`hubs` is declared as `hubs: PropTypes.arrayOf(PropTypes.hub)` but then we have this evaluation:

`
const { theme, hubs, route } = this.props
const { startHub, endHub } = hubs
`

## RouteOption

Fat component, so only snapshot testing

## RouteResult

Fat component, so only snapshot testing

!! PropTypes.schedule has additional undeclared properties

## RouteSelector

Fat component, so only snapshot testing

Line 77 causes:

`
Failed prop type: Invalid prop `routeSelected` of type `function` supplied to `RouteOption`, expected `boolean`.
`

## ShipmentCargoItems

Really fat component, so only basic snapshot testing

## ShipmentContactForm

Basic snapshot testing with lots of warnings

## ShipmentContactBox

Snapshot testing

!! Create unneccessary closures

`
<ContactCard
  ...
  select={() => this.setContactForEdit(notifyee, 'notifyee', i)}
  ...
  removeFunc={() => this.props.removeNotifyee(i)}
/>
`

## ShipmentContainers

Not full PropType for `container` as these three properties are used without declaring:

- payload_in_kg

- tareWeight

- quantity

? What is the reason for different cases of variables ?

[X] Test complete

## ShipmentDetails

Basic snapshot test

- Forced to use emtpy object as `shipmentData`

- prop.prevRequest.shipment

## ShipmentLocationBox

Basic snapshot test
