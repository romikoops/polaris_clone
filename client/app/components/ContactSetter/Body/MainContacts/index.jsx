import React from 'react'
import { v4 } from 'uuid'
import styles from '../Body.scss'
import { gradientTextGenerator } from '../../../../helpers'
import PropTypes from '../../../../prop-types'
import ShipmentContactsBoxContactSectionContactCard from './ContactCard'
import ShipmentContactsBoxContactSectionPlaceholderCard from './PlaceholderCard'

export default function ShipmentContactsBoxMainContacts ({
  theme, shipper, consignee, direction, showAddressBook, showEditContact, handleClick
}) {
  const textStyle = theme
    ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    : { color: 'black' }

  let props = {
    contactData: shipper, contactType: 'shipper', theme, showAddressBook, showEditContact, handleClick
  }
  const shipperCard = shipper.contact
    ? <ShipmentContactsBoxContactSectionContactCard {...props} />
    : <ShipmentContactsBoxContactSectionPlaceholderCard {...props} />

  props = { ...props, contactData: consignee, contactType: 'consignee' }
  const consigneeCard = consignee.contact
    ? <ShipmentContactsBoxContactSectionContactCard {...props} />
    : <ShipmentContactsBoxContactSectionPlaceholderCard {...props} />

  const chevronDirection = direction === 'import' ? 'left' : 'right'

  const contentElems = [shipperCard, consigneeCard].map(elem => (
    <div className={`flex ${`ccb_${elem.props.contactType}`}`} key={v4()}> { elem } </div>
  ))
  if (direction === 'import') contentElems.reverse()
  const chevron = (
    <div className="flex-20 layout-row layout-align-center-center" key={v4()}>
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

ShipmentContactsBoxMainContacts.propTypes = {
  theme: PropTypes.theme,
  shipper: PropTypes.shape({
    contact: PropTypes.object,
    location: PropTypes.object
  }).isRequired,
  consignee: PropTypes.shape({
    contact: PropTypes.object,
    location: PropTypes.object
  }).isRequired,
  direction: PropTypes.string.isRequired,
  showAddressBook: PropTypes.func.isRequired,
  showEditContact: PropTypes.func,
  handleClick: PropTypes.func
}

ShipmentContactsBoxMainContacts.defaultProps = {
  theme: null,
  handleClick: null,
  showEditContact: null
}
