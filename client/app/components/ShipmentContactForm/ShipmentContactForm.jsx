import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './ShipmentContactForm.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { nameToDisplay, authHeader, emailServerValidation } from '../../helpers'
import { BASE_URL } from '../../constants'
import AddressDetailsSection from './AddressDetailsSection'
import CompanyDetailsSection from './CompanyDetailsSection'

const { fetch, FormData } = window

class ShipmentContactForm extends Component {
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
    this.handleInputChange = this.handleInputChange.bind(this)
    this.checkValid = this.checkValid.bind(this)
  }

  handleInputChange (event) {
    this.setState({ [event.target.name]: event.target.value })
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
    const { shipmentDispatch } = this.props

    const editedContact = {
      ...contactData.contact,
      ...contactData.location,
      id: this.props.selectedContact.contact.id,
      locationId: this.props.selectedContact.location.id
    }

    shipmentDispatch.updateContact(editedContact)
    this.props.setContact({
      contact: {
        ...contactData.contact,
        id: this.props.selectedContact.contact.id,
        locationId: this.props.selectedContact.location.id
      },
      location: {
        ...contactData.location
      }
    })

    this.contactForm.reset()
    this.setState({ setContactAttempted: false })
  }

  handleInvalidSubmit () {
    this.setState({ setContactAttempted: true })
  }

  checkValid () {
    const { t } = this.props
    const input = this.contactForm.inputs.filter(x => x.props.name === 'email')[0].state.value

    function isEmailValid (data) {
      if (data.email === true) {
        this.contactForm.updateInputsWithError({
          email: t('errors:invalidEmail')
        })
      }
    }

    emailServerValidation('email', null, input, isEmailValid.bind(this))
  }

  render () {
    const {
      theme, contactType, showEdit, t
    } = this.props

    const setContactBtn = (
      <RoundButton
        text={
          `${contactType === 'notifyee' && !showEdit ? t('common:add') : t('common:set')} ` +
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
        contactData={this.props.selectedContact}
        handlePlaceChange={place => this.handlePlaceChange(place)}
        setContactAttempted={this.state.setContactAttempted}
        setContactBtn={setContactBtn}
        newLocation={this.state.contactData.location}
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
              checkValid={this.checkValid}
              contactData={this.props.selectedContact}
              handleInputChange={this.handleInputChange}
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
  t: PropTypes.func.isRequired,
  setContact: PropTypes.func,
  contactType: PropTypes.string,
  showEdit: PropTypes.bool,
  selectedContact: PropTypes.objectOf(PropTypes.any),
  shipmentDispatch: PropTypes.shape({
    updateContact: PropTypes.func
  }).isRequired
}

ShipmentContactForm.defaultProps = {
  theme: null,
  setContact: null,
  contactType: '',
  selectedContact: {},
  showEdit: false
}

export default translate(['common', 'errors'])(ShipmentContactForm)
