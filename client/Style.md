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