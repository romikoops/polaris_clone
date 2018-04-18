import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './ContactSetter.scss'
import defs from '../../styles/default_classes.scss'
// import { ShipmentContactForm } from '../ShipmentContactForm/ShipmentContactForm'
import { AddressBook } from '../AddressBook/AddressBook'
import { Modal } from '../Modal/Modal'
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox'
import { isEmpty, nameToDisplay } from '../../helpers'

nameToDisplay('...')
export class ContactSetter extends Component {
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
      location: {
        street: '',
        number: '',
        zipCode: '',
        city: '',
        country: '',
        gecodedAddress: ''
      }
    }
    this.contactTypes = props.direction === 'export'
      ? ['shipper', 'consignee', 'notifyee']
      : ['consignee', 'shipper', 'notifyee']

    this.state = {
      contactData: {
        type: this.contactTypes[0],
        ...this.newContactData
      },
      modal: '',
      showModal: false
    }
  }

  setContactForEdit (contactData) {
    this.setState({ contactData, showModal: true })
  }

  setContact (contactData) {
    const { type, index } = this.state.contactData

    const newState = {
      contactData: Object.assign({}, this.newContactData)
    }
    const nextType = this.nextUnsetContactType(type)

    this.props.setContact(contactData, type, index)

    if (nextType === 'notifyee') {
      this.setState({ showModal: false })
      return
    }
    newState.contactData.type = nextType

    this.setState(newState)
  }

  autofillContact (contactData) {
    this.setState({
      contactData: {
        ...this.state.contactData,
        contact: contactData.contact,
        location: contactData.location
      }
    })
  }
  nextUnsetContactType (thisType) {
    return this.contactTypes.slice(0, 2).find(type => (
      isEmpty(this.props[type]) && type !== thisType
    )) || 'notifyee'
  }

  availableContacts () {
    const {
      userLocations, shipper, consignee, notifyees
    } = this.props
    let { contacts } = this.props
    if (this.state.contactData.type === this.contactTypes[0]) {
      contacts = [...userLocations, ...contacts]
    }
    return contacts.filter(contactData => (
      shipper !== contactData &&
      consignee !== contactData &&
      notifyees.indexOf(contactData) === -1
    ))
  }

  toggleShowModal () {
    this.setState({ showModal: !this.state.showModal })
  }

  showAddressBook (contactType) {
    const modal = (
      <Modal
        component={
          <AddressBook
            theme={this.props.theme}
            contacts={this.availableContacts()}
            setContact={contactData => this.setContact(contactData)}
          />
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.toggleShowModal()}
      />
    )
    this.setState({ modal, showModal: true })
  }
  render () {
    const {
      theme, shipper, consignee, notifyees
    } = this.props
    const { showModal, modal } = this.state // contactData

    return (
      <div
        name="contact_setter"
        className={
          `${styles.contact_setter} flex-100 ` +
          'layout-row layout-wrap layout-align-center-start'
        }
      >
        { showModal && modal}
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <div
            className={`${styles.wrapper_main_h1} flex-100`}
            onClick={null}
          >
            <h1> Set Contact Details</h1>
            <hr className={styles.main_hr} />
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
            <ShipmentContactsBox
              consignee={consignee}
              shipper={shipper}
              notifyees={notifyees}
              direction={this.props.direction}
              theme={theme}
              removeNotifyee={this.props.removeNotifyee}
              showAddressBook={contactType => this.showAddressBook(contactType)}
              setContactForEdit={this.setContactForEdit}
              finishBookingAttempted={this.props.finishBookingAttempted}
            />
          </div>
          <hr className={`${styles.main_hr} ${styles.bottom_hr}`} />
        </div>
      </div>
    )
  }
}

ContactSetter.propTypes = {
  contacts: PropTypes.arrayOf(PropTypes.any).isRequired,
  userLocations: PropTypes.arrayOf(PropTypes.any),
  shipper: PropTypes.objectOf(PropTypes.any),
  consignee: PropTypes.objectOf(PropTypes.any),
  notifyees: PropTypes.arrayOf(PropTypes.any),
  direction: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  finishBookingAttempted: PropTypes.bool,
  setContact: PropTypes.func.isRequired,
  removeNotifyee: PropTypes.func.isRequired
}
ContactSetter.defaultProps = {
  userLocations: [],
  shipper: {},
  consignee: {},
  notifyees: [],
  theme: null,
  finishBookingAttempted: false
}

export default ContactSetter
