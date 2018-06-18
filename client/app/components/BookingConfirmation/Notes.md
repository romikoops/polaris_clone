# Notes

## Handle long class names

Current solution is:

`
import {
  ALIGN_AROUND_CENTER,
  ALIGN_AROUND_STRETCH,
  ALIGN_BETWEEN_CENTER,
  ROW_45,
  ROW_65,
  ROW_CONTENT,
  ROW_NONE,
  WRAP_ROW,
  WRAP_ROW_100,
  WRAP_ROW_45,
} from '../../classNames'

const ACCEPT = `${ROW_33} ${ALIGN_END} height_100`
...
  <div className={ACCEPT} style={acceptStyle}>
    {acceptTerms ? acceptedBtn : nonAcceptedBtn}
  </div>
`

As number of imported variable could be quite long, there are alternative solutions in order to have much shorter import statements.

---

Case1:

using `cn`(from ClassNames) to import all class-names constants.

`
import * as cn from '../../classNames'

const ACCEPT = `${cn.ROW_33} ${cn.ALIGN_END} height_100`
...
  <div className={ACCEPT} style={acceptStyle}>
    {acceptTerms ? acceptedBtn : nonAcceptedBtn}
  </div>
`

---

Case2:

use functions that return class-names constants

`
import {ROW, ALIGN} from '../../classNames'

const ACCEPT = `${ROW(33)} ${ALIGN('end')} height_100`
//or const ACCEPT = `${ROW(33)} ${ALIGN('END')} height_100
...
  <div className={ACCEPT} style={acceptStyle}>
    {acceptTerms ? acceptedBtn : nonAcceptedBtn}
  </div>
`

---

Case3:

Stay with current solution, but declare additional constants only for really long class-names:

`
import {
  ALIGN_AROUND_CENTER,
  ALIGN_AROUND_STRETCH,
  ALIGN_BETWEEN_CENTER,
  ROW_45,
  ROW_65,
  ROW_CONTENT,
  ROW_NONE,
  WRAP_ROW,
  WRAP_ROW_100,
  WRAP_ROW_45,
} from '../../classNames'

...
  <div 
    className={`${ROW_33} ${ALIGN_END} height_100`} 
    style={acceptStyle}
  >
    {acceptTerms ? acceptedBtn : nonAcceptedBtn}
  </div>
`

## No factory

In the edited version of code style, factory for repeated components are discouraged. Therefore we have this code:

`
const OverviewHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Overview"
/>)
const ItineraryHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Itinerary"
/>)
const FaresAndFeesHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Fares & Fees"
/>)
const AdditionalServicesHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Additional Services"
/>)
const ContactDetailsHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Contact Details"
/>)
const CargoDetailsHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Cargo Details"
/>)
const AdditionalInformationHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Additional Information"
/>)
const DocumentsHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Documents"
/>)
const AgreeAndSubmitHeading = (<TextHeading
  theme={theme}
  color="white"
  size={3}
  text="Agree and Submit"
/>)
`

This is not a question, just explanation why this peace of code exists in the refactored component.

## Series of if evaluations

`
let cargoView = ''
if (containers) {
  cargoView = prepContainerGroups(containers, this.props)
}
if (cargoItems.length > 0) {
  cargoView = prepCargoItemGroups(cargoItems, this.props)
}
if (aggregatedCargo) {
  cargoView = <CargoItemGroupAggregated group={aggregatedCargo} />
}
`

I coudn't understand if this is the desirable logic as it the following version is more readable:

`
let cargoView = ''
if (containers) {
  cargoView = prepContainerGroups(containers, this.props)
}else if (cargoItems.length > 0) {
  cargoView = prepCargoItemGroups(cargoItems, this.props)
}else if (aggregatedCargo) {
  cargoView = <CargoItemGroupAggregated group={aggregatedCargo} />
}
`