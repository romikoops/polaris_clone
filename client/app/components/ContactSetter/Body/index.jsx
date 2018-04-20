import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
// import styles from './Body.scss'
import defs from '../../../styles/default_classes.scss'
import ShipmentContactsBoxMainContacts from './MainContacts'
import ShipmentContactsBoxNotifyeeContacts from './NotifyeeContacts'

export default class ShipmentContactsBox extends Component {
  constructor (props) {
    super(props)
    this.state = {}
    this.newContactData = {
      contact: {
        companyName: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
      },
      location: {
        street: '',
        number: '',
        zipCode: '',
        city: '',
        country: '',
        gecodedAddress: ''
      }
    }
  }

  setContactForEdit (contactData, contactType, contactIndex) {
    this.props.setContactForEdit({
      ...contactData,
      type: contactType,
      index: contactIndex
    })
  }

  render () {
    const {
      shipper, consignee, notifyees, theme, direction, showAddressBook
    } = this.props

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div className="flex-100 layout-row layout-wrap">
            <ShipmentContactsBoxMainContacts
              theme={theme}
              shipper={shipper}
              consignee={consignee}
              direction={direction}
              showAddressBook={showAddressBook}
            />
          </div>
          <div className="flex-100 layout-row layout-wrap">
            <ShipmentContactsBoxNotifyeeContacts
              theme={theme}
              notifyees={notifyees}
              showAddressBook={showAddressBook}
              removeFunc={this.props.removeNotifyee}
            />
          </div>
        </div>
      </div>
    )
  }
}
ShipmentContactsBox.propTypes = {
  theme: PropTypes.theme,
  removeNotifyee: PropTypes.func.isRequired,
  consignee: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  shipper: PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  }).isRequired,
  notifyees: PropTypes.arrayOf(PropTypes.shape({
    companyName: PropTypes.string,
    firstName: PropTypes.string,
    lastName: PropTypes.string,
    email: PropTypes.string,
    phone: PropTypes.string,
    street: PropTypes.string,
    number: PropTypes.string,
    zipCode: PropTypes.string,
    city: PropTypes.string,
    country: PropTypes.string
  })),
  setContactForEdit: PropTypes.func.isRequired,
  direction: PropTypes.string.isRequired,
  showAddressBook: PropTypes.func.isRequired
  // finishBookingAttempted: PropTypes.bool
}

ShipmentContactsBox.defaultProps = {
  theme: null,
  notifyees: []
  // finishBookingAttempted: false
}
