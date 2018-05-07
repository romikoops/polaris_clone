# Coding style options

## Camel case

`
Source: 'XML HTTP request' Option1: 'XmlHttpRequest'	Option2: 'XMLHTTPRequest'
`


## Single vs multiline

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

## No static methods

It makes testing harder or imposible

## Handle long template strings

Case 1:

`
const CONTAINER = 'flex-100 flex-layout-center-center' +
  `{styles.container} ${styles.centered}` +
  `{styles.base} {styles.blueBackground}`
`

Case 2:

`
const WIDE = 'flex-100 flex-layout-center-center'
const CENTERED = `{styles.container} ${styles.centered}`
const BLUE = `{styles.base} {styles.blueBackground}`
const CONTAINER = `${WIDE} ${CENTERED} ${BLUE}`
`

Case 3:

`
const wide = 'flex-100 flex-layout-center-center'
const centered = `{styles.container} ${styles.centered}`
const blue = `{styles.base} {styles.blueBackground}`
const CONTAINER = `${wide} ${centered} ${blue}`
`

## Descriptive or generic counter

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

`
cargos.forEach(c => {

})
`

`
cargos.forEach(x => {

})
`

or disallow them completely:

`
cargos.forEach(singleCargo => {

})
`

## Blank lines around if/else

### No blank lines

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

### After if/else

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

### Before and after if/else

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
  items: [],
  payload_in_kg: payload,
  tare_weight: tare,
  gross_weight: gross,
  groupAlias: i,
  cargo_group_id: singleCargo.id,
  hsCodes: singleCargo.hs_codes,
  hsText: singleCargo.customs_text
}
`

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

`
fileFn (file) {
  const { shipmentData, shipmentDispatch } = this.props
  const { shipment } = shipmentData
  const type = file.doc_type
  const url = `/shipments/${shipment.id}/upload/${type}`

  shipmentDispatch.uploadDocument(file, type, url)
}
`

## One or multiline for object destructuring

When we have three or more variables

`
const {
  theme, shipmentData, shipmentDispatch, tenant
} = this.props
`

`
const {
  theme,
  shipmentData,
  shipmentDispatch,
  tenant,
} = this.props
`

Multiline give us option to extend and also to sort alphabetically:

`
const {
  shipmentData,
  shipmentDispatch,
  tenant,
  theme,
} = this.props
`

## One line if statement

`
if (!shipmentData) return <h1>Loading</h1>
`

`
if (!shipmentData){
  return <h1>Loading</h1>
}
`

## Move constant-like variables outside component

Inside `render()`:

`
const defaultTerms = [
  'You verify that all the information provided above is true',
  `You agree to our Terms and Conditions and the General Conditions of the
                      Nordic Association of Freight Forwarders (NSAB) and those of 
                      {tenant.name}`,
  'You agree to pay the price of the shipment as stated above upon arrival of the invoice'
]
`

`
// Outside component
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

`
const terms = tenant.scope.terms.length > 0 ? tenant.scope.terms : defaultTerms

const textStyle = theme
  ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  : { color: 'black' }

const createdDate = shipment
  ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
  : moment().format('DD-MM-YYYY | HH:mm A')
`

## Readability blank line

> Within method bodies, sparingly to create logical groupings of statements. (https://google.github.io/styleguide/jsguide.html)

Case 1:

`
const { acceptTerms, collapser } = this.state
const hubsObj = { startHub: locations.startHub, endHub: locations.endHub }
const terms = getTerms(tenant)
const textStyle = getTextStyle(theme)
const createdDate = getCreatedDate(shipment)
`

`
const { acceptTerms, collapser } = this.state
const hubsObj = { startHub: locations.startHub, endHub: locations.endHub }

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

https://ryanfunduk.com/articles/never-bind-in-render/

`
<RoundButton
  theme={theme}
  text="Finish Booking Request"
  handleNext={() => this.requestShipment()}
  active
/>
`

`
<RoundButton
  theme={theme}
  text="Finish Booking Request"
  handleNext={this.requestShipment}
  active
/>
`

## Use strict naming pattern for looping over lists

`
notifyees.map(notifyee => (
`

Arguably with prepending `single` there is less chance to mix `notifyees` and `notifyee`:

`
notifyees.map(singleNotifyee => (
`

## Avoid ternary operator inside the render()

`
<div className={`${collapser.overview ? styles.collapsed : ''} ${styles.main_panel}`}>
`

`
const mainPanel = `${collapser.overview ? styles.collapsed : ''} ${styles.main_panel}`
...
<div className={mainPanel}>
`

## Use shorter names if that can turn multiple multiline statements to single line

`
<div 
  className={COLLAPSER} 
  onClick={() => this.handleCollapser('overview')}
>
`

`
<div className={COLLAPSER} onClick={() => this.collapser('overview')}>
`

## Simpler render() with additional variables

`
<p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
  {shipmentStatii[shipment.status]}
</p>
`

`
const status = shipmentStatii[shipment.status]
...
<p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
  {status}
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

## Use function to reduce repeated DOM element declaration

`TextHeading` is used multiple times with only `text` as different property.

`
<TextHeading theme={theme} color="white" size={3} text="Cargo Details" />
`

`
{TextHeadingFactory('Cargo Details')}
`

`GetTextHeading`, `TextHeadingFn` and `getTextHeading` are alternative names for `TextHeadingFactory`

## Avoid long string, prefer using functions

`
<h3 className="flex-none letter_3">{`${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)} `}</h3>
`

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

## Prefer positive over negative `if` evaluations

`
if (!bool) {
  this.setState({ insurance: { bool: false, val: 0 } })
} else if (bool) {
  this.calcInsurance(false, true)
}
`

`
if (bool) {
  this.calcInsurance(false, true)
} else {
  this.setState({ insurance: { bool: false, val: 0 } })
}
`

## Deconstructing `state` before `setState`

`
handleInvalidSubmit () {
  this.setState({ finishBookingAttempted: true })
  const { shipper, consignee } = this.state
}
`

`
handleInvalidSubmit () {
  const { shipper, consignee } = this.state
  this.setState({ finishBookingAttempted: true })
}
`