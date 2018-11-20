# Coding style options

## Camel case

`
Source: 'XML HTTP request'
`

`
Output: 'XmlHttpRequest'
`

## Single vs multiline

multiline if more than one attribute and longer than 90 chars

`
<div className={CONTAINER} onClick={onClick}>
`

`
<div 
  className={CONTAINER}
  onClick={onClick}
  style={style}
>
`

## Handle long classNames

Refactor using constants.

## No static methods

It makes testing harder or imposible

## Handle long template strings


`
const WIDE = 'flex-100 flex-layout-center-center'
const CENTERED = `{styles.container} ${styles.centered}`
const BLUE = `{styles.base} {styles.blueBackground}`
const CONTAINER = `${WIDE} ${CENTERED} ${BLUE}`
`

Rejected alternativeCase #1:

`
const CONTAINER = 'flex-100 flex-layout-center-center' +
  `{styles.container} ${styles.centered}` +
  `{styles.base} {styles.blueBackground}`
`

Rejected alternativeCase #2:

`
const wide = 'flex-100 flex-layout-center-center'
const centered = `{styles.container} ${styles.centered}`
const blue = `{styles.base} {styles.blueBackground}`
const CONTAINER = `${wide} ${centered} ${blue}`
`

## Prefer generic over descriptive counter

Use the following:

`
// BookingConfirmation
prepCargoItemGroups (cargos) {
    let groupCount = 1
    cargos.forEach((c) => {
      if (!cargoGroups[c.id]) {
        cargoGroups[c.id] = {
          groupAlias: groupCount,
          items: []
        }
        groupCount += 1
      }
    })
`

instead of:

`
// BookingConfirmation
prepCargoItemGroups (cargos) {
    let counter = 1
    cargos.forEach((c) => {
      if (!cargoGroups[c.id]) {
        cargoGroups[c.id] = {
          groupAlias: groupCount,
          items: []
        }
        counter += 1
      }
    })
`

## Usage of generic variable names

Generic variable names are fine as long as the context is clear.

`
cargos.forEach(c => {
  ...
})
`

## Blank lines around if/else

> No Blank Lines

`
let result
if(counter > 2){
  return 5
}else if(counter % 2 === 0){
  barFn()
  result = 2
}else{
  result = 7
}
fooFn()
return result
`

### Rejected: after if/else

`
let result
if(counter > 2){

  return 5
}else if(counter % 2 === 0){

  barFn()
  result = 2
}else{

  result = 7
}
fooFn()
return result
`

### Rejected: before and after if/else

`
let result

if(counter > 2){

  return 5
}else if(counter % 2 === 0){

  barFn()
  result = 2
}else{

  result = 7
}

fooFn()
return result
`

## Alphabetical order of object properties

`
cargoGroups[singleCargo.id] = {
  ...base,
  cargo_group_id: singleCargo.id,
  gross_weight: gross,
  groupAlias: i,
  hsCodes: singleCargo.hs_codes,
  hsText: singleCargo.customs_text,
  items: [],
  payload_in_kg: payload,
  tare_weight: tare,
}
`

## Redundant creation of new variables

`
requestShipment () {
  const { shipmentData, shipmentDispatch } = this.props
  const { shipment } = shipmentData
  shipmentDispatch.requestShipment(shipment.id)
}
`

instead of:

`
requestShipment () {
  this.props.shipmentDispatch.requestShipment(
    this.props.shipmentData.shipment.id
  )
}
`

## Blank line before return or the last statement

`
fileFn (file) {
  const { shipmentData, shipmentDispatch } = this.props
  const { shipment } = shipmentData
  const type = file.doc_type
  const url = `/shipments/${shipment.id}/upload/${type}`

  shipmentDispatch.uploadDocument(file, type, url)
}
`

## Multiline for object destructuring

When we have three or more variables

`
const {
  theme, shipmentData, shipmentDispatch, tenant
} = this.props
`

`
const {
  shipmentData,
  shipmentDispatch,
  tenant,
  theme,
} = this.props
`

Multiline requires alphabetical sort of the properties.

## One line if statement

> One line

`
if (!shipmentData) return <h1>Loading</h1>
`

instead of:

`
if (!shipmentData){
  return <h1>Loading</h1>
}
`

## Move constant-like variables outside component

Instead of declaration inside `render()`:

`
const defaultTerms = [
  'You verify that all the information provided above is true',
  `You agree to our Terms and Conditions and the General Conditions of the
                      Nordic Association of Freight Forwarders (NSAB) and those of 
                      {tenant.name}`,
  'You agree to pay the price of the shipment as stated above upon arrival of the invoice'
]
`

move it outside component:

`
const getDefaultTerms = tenant => [
  'You verify that all the information provided above is true',
  `You agree to our Terms and Conditions and the General Conditions of the
                      Nordic Association of Freight Forwarders (NSAB) and those of 
                      {tenant.name}`,
  'You agree to pay the price of the shipment as stated above upon arrival of the invoice'
]
...

// inside render()
const defaultTerms = getDefaultTerms(tenant)
...

`

## Blank line after ternary assignments

`
const terms = tenant.scope.terms.length > 0 ? tenant.scope.terms : defaultTerms

const textStyle = theme
  ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  : { color: 'black' }

const createdDate = shipment
  ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
  : moment().format('DD-MM-YYYY | HH:mm A')
`

instead of:

`
const terms = tenant.scope.terms.length > 0 ? tenant.scope.terms : defaultTerms
const textStyle = theme
  ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  : { color: 'black' }
const createdDate = shipment
  ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
  : moment().format('DD-MM-YYYY | HH:mm A')
`

## Sparingly usage of readability blank line

Within method bodies, sparingly to create logical groupings of statements. (https://google.github.io/styleguide/jsguide.html)

Case 1:

`
const { acceptTerms, collapser } = this.state
const hubsObj = { startHub: addresses.startHub, endHub: addresses.endHub }
const terms = getTerms(tenant)
const textStyle = getTextStyle(theme)
const createdDate = getCreatedDate(shipment)
`

`
// with readability blank line
const { acceptTerms, collapser } = this.state
const hubsObj = { startHub: addresses.startHub, endHub: addresses.endHub }

const terms = getTerms(tenant)
const textStyle = getTextStyle(theme)
const createdDate = getCreatedDate(shipment)
`

Case 2:

`
const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
const { docView, missingDocs } = getDocs({
  documents,
  theme,
  dispatchFn: this.fileFn,
  deleteFn: this.deleteDoc,
})
const termBullets = getTermBullets(terms)
`

`
// with readability blank line
const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
const { docView, missingDocs } = getDocs({
  documents,
  theme,
  dispatchFn: this.fileFn,
  deleteFn: this.deleteDoc,
})

const termBullets = getTermBullets(terms)
`

## Unnecessary creation of closure

> https://ryanfunduk.com/articles/never-bind-in-render/

Despite the suggestion that it may have performance penalty, we are using this case:

`
<RoundButton
  theme={theme}
  text="Finish Booking Request"
  handleNext={() => this.requestShipment()}
  active
/>
`

instead of:
`
<RoundButton
  theme={theme}
  text="Finish Booking Request"
  handleNext={this.requestShipment}
  active
/>
`

## Use strict naming pattern for looping over lists

> notifyee

`
notifyees.map(notifyee => (
`

instead of:

`
notifyees.map(singleNotifyee => (
`

## Avoid ternary operator inside the render()

`
const mainPanel = `${collapser.overview ? styles.collapsed : ''} ${styles.main_panel}`
...
<div className={mainPanel}>
`

instead of:

`
<div className={`${collapser.overview ? styles.collapsed : ''} ${styles.main_panel}`}>
`

## Use shorter names if that can turn multiple multiline statements to single line

`
<div className={COLLAPSER} onClick={() => this.collapser('overview')}>
`

instead of:
`
<div 
  className={COLLAPSER}
  onClick={() => this.handleCollapser('overview')}
>
`

> Use this rule only if it actually influence readability. Otherwise use more descriptive `handleCollapser`

## Simpler render() with additional variables

`
const status = shipmentStatii[shipment.status]
...
<p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
  {status}
</p>
`

instead of:
`
<p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
  {shipmentStatii[shipment.status]}
</p>
`

## Blank lines between inner DOM elements

```html
<div className={mainPanel}>
  <div className={INNER_WRAPPER}>
    <div className={INNER_WRAPPER_CELL}>
      <h4 className="flex-none">Shipment Reference:</h4>
      <h4 className="clip flex-none offset-5" style={textStyle}>
        {shipment.imc_reference}
      </h4>
    </div>

    <div className={INNER_WRAPPER_CELL}>
      <p className={SUBTITLE_NORMAL}>Status:</p>
      <p className={SUBTITLE}>
        {status}
      </p>
    </div>

    <div className={INNER_WRAPPER_CELL}>
      <p className={SUBTITLE_NORMAL}>Created at:</p>
      <p className={SUBTITLE}>
        {createdDate}
      </p>
    </div>
  </div>
</div>
```

instead of:

```html
<div className={mainPanel}>
  <div className={INNER_WRAPPER}>
    <div className={INNER_WRAPPER_CELL}>
      <h4 className="flex-none">Shipment Reference:</h4>
      <h4 className="clip flex-none offset-5" style={textStyle}>
        {shipment.imc_reference}
      </h4>
    </div>
    <div className={INNER_WRAPPER_CELL}>
      <p className={SUBTITLE_NORMAL}>Status:</p>
      <p className={SUBTITLE}>
        {status}
      </p>
    </div>
    <div className={INNER_WRAPPER_CELL}>
      <p className={SUBTITLE_NORMAL}>Created at:</p>
      <p className={SUBTITLE}>
        {createdDate}
      </p>
    </div>
  </div>
</div>
```

## Use factory function to reduce repeated DOM element declaration

`TextHeading` is used multiple times(more than 3) with only `text` as different property.
In this case we lean towards:

`
{TextHeadingFactory('Cargo Details')}
`

instead of:
`
<TextHeading theme={theme} color="white" size={3} text="Cargo Details" />
`

## Avoid long string, prefer using functions

`
const price = getTotalPrice(shipment)
...
<h3 className="flex-none letter_3">
  {totalPrice}
</h3>
...
function getTotalPrice(shipment){
  const currency = shipment.total_price.currency
  const price = parseFloat(shipment.total_price.value).toFixed(2)

  return `${currency} ${price} `
}
`

instead of:

`
<h3 className="flex-none letter_3">{`${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)} `}</h3>
`

## Prefer positive over negative `if` evaluations

`
if (bool) {
  this.calcInsurance(false, true)
} else {
  this.setState({ insurance: { bool: false, val: 0 } })
}
`

instead of:

`
if (!bool) {
  this.setState({ insurance: { bool: false, val: 0 } })
} else if (bool) {
  this.calcInsurance(false, true)
}
`

## Deconstructing `state` before `setState`

`
handleInvalidSubmit () {
  const { shipper, consignee } = this.state
  this.setState({ finishBookingAttempted: true })
}
`

instead of:

`
handleInvalidSubmit () {
  this.setState({ finishBookingAttempted: true })
  const { shipper, consignee } = this.state
}
`

> Sort first by complexety, then alphabetically

Before:

```
this.state = {
  acceptTerms: false,
  consignee: {},
  shipper: {},
  notifyees: [],
  insurance: {
    bool: null,
    val: 0
  },
  incotermText: '',
  customs: {
    import: {
      bool: false,
      val: 0
    },
    export: {
      bool: false,
      val: 0
    },
    total: {
      val: 0
    }
  },
  hsCodes: {},
  hsTexts: {},
  totalGoodsValue: { value: 0, currency: 'EUR' },
  cargoNotes: '',
  finishBookingAttempted: false,
  customsCredit: false
}
```

After:

```
this.state = {
  acceptTerms: false,
  cargoNotes: '',
  consignee: {},
  customsCredit: false,
  finishBookingAttempted: false,
  hsCodes: {},
  hsTexts: {},
  incotermText: '',
  notifyees: [],
  shipper: {},
  totalGoodsValue: { value: 0, currency: 'EUR' },
  insurance: {
    bool: null,
    val: 0
  },
  customs: {
    import: {
      bool: false,
      val: 0
    },
    export: {
      bool: false,
      val: 0
    },
    total: {
      val: 0
    }
  },
}
```

## Use `trim` method when 4 or more parts in class-name

Before:
```
<div className={`${defaults.content_width} content-width ${ROW('none')} ${ALIGN_START_CENTER}`)}>
```

After:
```
import {trim} from '../../classNames'

...

<div className={trim(`
    ${defaults.content_width}
    content-width
    ${ROW('none')} 
    ${ALIGN_START_CENTER}
  `)}
>
```