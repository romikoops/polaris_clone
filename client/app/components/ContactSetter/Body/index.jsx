import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import defs from '../../../styles/default_classes.scss'
import ShipmentContactsBoxMainContacts from './MainContacts'
import ShipmentContactsBoxNotifyeeContacts from './NotifyeeContacts'

export default class ContactSetterBody extends Component {
  constructor (props) {
    super(props)
    this.newContactData = {
      contact: {
        companyName: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
      },
      address: {
        street: '',
        number: '',
        zipCode: '',
        city: '',
        country: '',
        gecodedAddress: ''
      }
    }
  }

  render () {
    const {
      shipper, consignee, notifyees, theme, direction, showAddressBook, showEditContact
    } = this.props

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div className="flex-100 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap">
              <ShipmentContactsBoxMainContacts
                theme={theme}
                shipper={shipper}
                consignee={consignee}
                direction={direction}
                showEditContact={showEditContact}
                showAddressBook={showAddressBook}
              />
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <ShipmentContactsBoxNotifyeeContacts
                theme={theme}
                showEditContact={showEditContact}
                notifyees={notifyees}
                showAddressBook={showAddressBook}
                removeFunc={this.props.removeNotifyee}
              />
            </div>
          </div>

        </div>
      </div>
    )
  }
}
ContactSetterBody.propTypes = {
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
  showEditContact: PropTypes.func,
  direction: PropTypes.string.isRequired,
  showAddressBook: PropTypes.func.isRequired
}

ContactSetterBody.defaultProps = {
  theme: null,
  showEditContact: null,
  notifyees: []
}
