import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './ShipmentContactForm.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { nameToDisplay, authHeader } from '../../helpers'
import { BASE_URL } from '../../constants'
import AddressDetailsSection from './AddressDetailsSection'
import CompanyDetailsSection from './CompanyDetailsSection'

const { fetch, FormData } = window

export class ShipmentContactForm extends Component {
  static mapInputs (inputs) {
    const location = {}
    const contact = {}
    Object.keys(inputs).forEach((k) => {
      if (k.split('-')[0] === 'location') {
        location[k.split('-')[1]] = inputs[k]
      } else {
        contact[k] = inputs[k]
      }
    })

    return { location, contact }
  }
  constructor (props) {
    super(props)
    this.state = {
      contactData: { contact: {}, location: {} },
      setContactAttempted: false
    }
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.editSubmit = this.editSubmit.bind(this)
  }

  componentWillMount () {
    const { showEdit, selectedContact } = this.props
    if (showEdit) {
      this.setState({
        contactData: selectedContact
      })
    }
  }
  componentWillUnmount () {
    this.setState({
      contactData: { contact: {}, location: {} }
    })
  }
  handlePlaceChange (place) {
    const newLocation = {
      streetNumber: '',
      street: '',
      zipCode: '',
      city: '',
      country: ''
    }
    place.address_components.forEach((ac) => {
      if (ac.types.includes('street_number')) {
        newLocation.streetNumber = ac.long_name
      }

      if (ac.types.includes('route') || ac.types.includes('premise')) {
        newLocation.street = ac.long_name
      }

      if (ac.types.includes('administrative_area_level_1') || ac.types.includes('locality')) {
        newLocation.city = ac.long_name
      }

      if (ac.types.includes('postal_code')) {
        newLocation.zipCode = ac.long_name
      }

      if (ac.types.includes('country')) {
        newLocation.country = ac.long_name
      }
    })
    newLocation.latitude = place.geometry.location.lat()
    newLocation.longitude = place.geometry.location.lng()
    newLocation.geocodedAddress = place.formatted_address
    this.setState({
      contactData: { ...this.state.contactData, location: newLocation }
    })
    this.setState({
      autocomplete: { ...this.state.autocomplete, location: true }
    })
  }
  handleSubmit (contactData) {
    this.props.setContact(contactData)

    const newContact = {
      firstName: contactData.contact.firstName,
      lastName: contactData.contact.lastName,
      companyName: contactData.contact.companyName,
      phone: contactData.contact.phone,
      email: contactData.contact.email,
      number: contactData.location.number,
      street: contactData.location.street,
      city: contactData.location.city,
      zipCode: contactData.location.zipCode,
      country: contactData.location.country
    }

    const formData = new FormData()
    formData.append('new_contact', JSON.stringify(newContact))
    const requestOptions = {
      method: 'POST',
      headers: authHeader(),
      body: formData
    }
    fetch(`${BASE_URL}/contacts`, requestOptions)
      .then(
        () => console.log('saved'),
        error => console.log(error)
      )

    this.contactForm.reset()
    this.setState({ setContactAttempted: false })
  }
  editSubmit (contactData) {
    this.setState(prevState => ({
      contactData: {
        ...prevState.contactData.contact,
        ...prevState.contactData.location,
        contact: contactData.contact,
        location: contactData.location
      }
    }))

    const editedContact = {
      ...this.state.contactData.contact,
      number: this.state.contactData.location.number,
      street: this.state.contactData.location.street,
      city: this.state.contactData.location.city,
      zipCode: this.state.contactData.location.zipCode,
      country: this.state.contactData.location.country,
      locationId: this.state.contactData.location.id
    }

    console.log(editedContact)
    console.log(this.state.contactData)
    const formData = new FormData()
    formData.append('update', JSON.stringify(editedContact))
    const requestOptions = {
      method: 'POST',
      headers: authHeader(),
      body: formData
    }
    fetch(`${BASE_URL}/contacts/update_contact/${editedContact.id}`, requestOptions)
      .then(
        () => console.log('saved'),
        error => console.log(error)
      )

    this.props.setContact(contactData)
    this.contactForm.reset()
    this.setState({ setContactAttempted: false })
  }

  handleInvalidSubmit () {
    this.setState({ setContactAttempted: true })
  }

  render () {
    const {
      theme, contactType, showEdit
    } = this.props

    const setContactBtn = (
      <RoundButton
        text={
          `${contactType === 'notifyee' && !showEdit ? 'Add' : 'Set'} ` +
          `${nameToDisplay(contactType)}`
        }
        theme={theme}
        size="small"
        active
      />
    )

    const addressDetailsSection = (
      <AddressDetailsSection
        theme={theme}
        contactData={this.state.contactData}
        handlePlaceChange={place => this.handlePlaceChange(place)}
        setContactAttempted={this.state.setContactAttempted}
        setContactBtn={setContactBtn}
      />
    )

    const setContactBtnWrapper = (
      <div
        className="flex-100 layout-row layout-align-center-center"
      >
        {setContactBtn}
      </div>
    )

    return (
      <div className={
        `${styles.wrapper_form} flex-100 ` +
        'layout-row layout-wrap layout-align-center-start'
      }
      >
        <Formsy
          className="flex-100 layout-row layout-wrap layout-align-start-start"
          name="form"
          onValidSubmit={showEdit ? this.editSubmit : this.handleSubmit}
          onInvalidSubmit={this.handleInvalidSubmit}
          mapping={ShipmentContactForm.mapInputs}
          ref={(c) => { this.contactForm = c }}
          style={{ padding: '8px 20px' }}
        >
          <div className={`flex${contactType === 'notifyee' ? '-100' : ''} layout-row`}>
            <CompanyDetailsSection
              theme={theme}
              showEdit={showEdit}
              contactData={this.state.contactData}
              setContactAttempted={this.state.setContactAttempted}
            />
          </div>
          {contactType === 'notifyee' ? setContactBtnWrapper : addressDetailsSection}
        </Formsy>
      </div>
    )
  }
}

ShipmentContactForm.propTypes = {
  theme: PropTypes.theme,
  setContact: PropTypes.func,
  contactType: PropTypes.string,
  showEdit: PropTypes.bool,
  selectedContact: PropTypes.objectOf(PropTypes.any)
}

ShipmentContactForm.defaultProps = {
  theme: null,
  setContact: null,
  contactType: '',
  selectedContact: {},
  showEdit: false
}

export default ShipmentContactForm
