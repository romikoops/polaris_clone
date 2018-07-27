import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './ContactSetter.scss'
import defs from '../../styles/default_classes.scss'
import { Modal } from '../Modal/Modal'
import ContactSetterBody from './Body'
import ContactSetterNewContactWrapper from './NewContactWrapper'
import { ShipmentContactForm } from '../ShipmentContactForm/ShipmentContactForm'

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
      modal: '',
      showModal: false,
      contactData: {
        contact: {},
        location: {}
      }
    }
    this.setContactForEdit = this.setContactForEdit.bind(this)
  }

  setContactForEdit (contactData) {
    this.setState({ contactData, showModal: true })
    debugger // eslint-disable-line no-debugger
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

  availableContacts (contactType) {
    const {
      userLocations, shipper, consignee, notifyees
    } = this.props
    let { contacts } = this.props
    if (contactType === this.contactTypes[0]) {
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

  showAddressBook (contactType, index) {
    const modal = (
      <Modal
        component={
          <ContactSetterNewContactWrapper
            AddressBookProps={{
              theme: this.props.theme,
              contacts: this.availableContacts(contactType),
              setContact: (contactData) => {
                this.props.setContact(contactData, contactType, index)
                this.setState({ modal: null, showModal: false })
              }
            }}
            ShipmentContactFormProps={{
              contactType,
              theme: this.props.theme,
              setContact: (contactData) => {
                this.props.setContact(contactData, contactType, index)
                this.setState({ modal: null, showModal: false })
              }
            }}
            contactType={contactType}
          />
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.toggleShowModal()}
      />
    )
    this.setState({ modal, showModal: true })
  }

  editProfile () {
    const { contactData } = this.props
    const { contact } = contactData
    this.setState({
      editBool: true,
      editObj: contact
    })
  }

  handleChange (ev) {
    const { contact, location } = ev.target
    this.setState({
      contactData: {
        ...this.state.contactData,
        contact,
        location
      }
    })
  }

  showEditContact (contactType, contact) {
    const modal = (
      <Modal
        component={
          <ShipmentContactForm
            theme={this.props.theme}
            contactType={contactType}
            handleChange={e => this.handleChange(e)}
          />
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.toggleShowModal()}
      />
    )
    this.setState({ modal, showModal: true, contact })
  }

  render () {
    const {
      theme, shipper, consignee, notifyees, contacts
    } = this.props
    const { showModal, modal } = this.state

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
          <div
            className="flex-100 layout-row layout-align-center-center"
          >
          {console.log(contacts)}
            <ContactSetterBody
              consignee={consignee}
              shipper={shipper}
              notifyees={notifyees}
              direction={this.props.direction}
              theme={theme}
              removeNotifyee={this.props.removeNotifyee}
              handleClick={(contactData, index) => this.setContact(contactData, index)}
              showEditContact={contactType => this.showEditContact(contactType)}
              showAddressBook={(contactType, index) => this.showAddressBook(contactType, index)}
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
