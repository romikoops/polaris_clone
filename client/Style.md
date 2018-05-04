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