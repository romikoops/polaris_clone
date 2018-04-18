import React from 'react'
import styles from '../ShipmentContactsBox.scss'
import { gradientTextGenerator, nameToDisplay, capitalize } from '../../../helpers'
import ShipmentContactsBoxContactSectionContactCard from './ContactCard'
import ShipmentContactsBoxContactSectionPlaceholderCard from './PlaceholderCard'

export default function ShipmentContactsBoxMainContacts ({
  theme, shipper, consignee, direction
}) {
  const textStyle = theme
    ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    : { color: 'black' }

  let props = { contactData: shipper, contactType: 'shipper', theme }
  const shipperCard = shipper.contact
    ? <ShipmentContactsBoxContactSectionContactCard {...props} />
    : <ShipmentContactsBoxContactSectionPlaceholderCard {...props } />

  props = { contactData: consignee, contactType: 'consignee', theme }
  const consigneeCard = consignee.contact
    ? <ShipmentContactsBoxContactSectionContactCard {...props} />
    : <ShipmentContactsBoxContactSectionPlaceholderCard {...props } />

  const chevronDirection = direction === 'import' ? 'left' : 'right'

  const contentElems = [shipperCard, consigneeCard].map(elem => (
    <div className="flex"> { elem } </div>
  ))
  if (direction === 'import') contentElems.reverse()
  const chevron = (
    <div className="flex-20 layout-row layout-align-center-center">
      <i
        className={`fa fa-angle-double-${chevronDirection} ${styles.dir_icon} clip`}
        style={textStyle}
      />
    </div>
  )
  contentElems.splice(1, 0, chevron)
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-stretch">
      { contentElems }
    </div>
  )
}
