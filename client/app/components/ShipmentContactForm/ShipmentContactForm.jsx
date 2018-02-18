import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './ShipmentContactForm.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import defs from '../../styles/default_classes.scss'
import GmapsWrapper from '../../hocs/GmapsWrapper'
import { PlaceSearch } from '../Maps/PlaceSearch'

import FormsyInput from '../FormsyInput/FormsyInput'

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
      contactData: props.contactData,
      setContactAttempted: false
    }
    this.handleFormChange = this.handleFormChange.bind(this)
    this.handlePlaceChange = this.handlePlaceChange.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    this.close = this.close.bind(this)
  }

  componentWillReceiveProps (nextProps) {
    this.setState({
      contactData: nextProps.contactData
    })
  }
  close (e) {
    e.preventDefault()
    this.props.close()
  }

  handleFormChange (event) {
    this.props.handleChange(event)
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
    this.contactForm.reset()
    this.setState({ setContactAttempted: false })
  }
  handleInvalidSubmit () {
    this.setState({ setContactAttempted: true })
  }

  render () {
    const { theme } = this.props
    const { contactData } = this.state
    const locationSection = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap">
          <h3 className="flex-40">Address Details</h3>
          <div className="offset-5 flex-55">
            <GmapsWrapper
              theme={theme}
              component={PlaceSearch}
              inputStyles={{
                width: '96%',
                marginTop: '9px',
                background: 'white'
              }}
              handlePlaceChange={this.handlePlaceChange}
              hideMap
            />
          </div>
        </div>
        <FormsyInput
          wrapperClassName={`${styles.wrapper_input} flex-75`}
          className={styles.input}
          type="text"
          value={contactData.location.street}
          name="location-street"
          placeholder="Street"
          submitAttempted={this.state.setContactAttempted}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          validations="minLength:2"
          validationErrors={{
            isDefaultRequiredValue: 'Minimum 2 characters',
            minLength: 'Minimum 2 characters'
          }}
          required
        />
        <FormsyInput
          wrapperClassName={`${styles.wrapper_input} offset-5 flex-15`}
          className={styles.input}
          type="text"
          value={contactData.location.streetNumber}
          name="location-streetNumber"
          placeholder="Number"
          submitAttempted={this.state.setContactAttempted}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          validationErrors={{
            isDefaultRequiredValue: 'Must not be blank'
          }}
          required
        />
        <FormsyInput
          wrapperClassName={`${styles.wrapper_input} flex-25`}
          className={styles.input}
          type="text"
          value={contactData.location.zipCode}
          name="location-zipCode"
          placeholder="Postal Code"
          submitAttempted={this.state.setContactAttempted}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          validations="minLength:4"
          validationErrors={{
            isDefaultRequiredValue: 'Minimum 4 characters',
            minLength: 'Minimum 4 characters'
          }}
          required
        />
        <FormsyInput
          wrapperClassName={`${styles.wrapper_input} offset-5 flex-30`}
          className={styles.input}
          type="text"
          value={contactData.location.city}
          name="location-city"
          placeholder="City"
          submitAttempted={this.state.setContactAttempted}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          validations="minLength:2"
          validationErrors={{
            isDefaultRequiredValue: 'Minimum 2 characters',
            minLength: 'Minimum 2 characters'
          }}
          required
        />
        <FormsyInput
          wrapperClassName={`${styles.wrapper_input} offset-5 flex-30`}
          className={styles.input}
          type="text"
          value={contactData.location.country}
          name="location-country"
          placeholder="Country"
          submitAttempted={this.state.setContactAttempted}
          errorMessageStyles={{
            fontSize: '12px',
            bottom: '-19px'
          }}
          validations="minLength:3"
          validationErrors={{
            isDefaultRequiredValue: 'Minimum 3 characters',
            minLength: 'Minimum 3 characters'
          }}
          required
        />
        <FormsyInput
          wrapperClassName="flex-100"
          type="hidden"
          value={contactData.location.geocodedAddress}
          name="location-geocodedAddress"
          placeholder=""
        />
      </div>
    )
    const pusherPlaceholder = <div style={{ height: '248px' }} />

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
          <Formsy
            className="flex-100 layout-row layout-wrap layout-align-start-start"
            name="form"
            onValidSubmit={this.handleSubmit}
            onInvalidSubmit={this.handleInvalidSubmit}
            mapping={ShipmentContactForm.mapInputs}
            ref={(c) => { this.contactForm = c }}
            style={{ padding: '8px 20px' }}
          >
            <h3>Basic Details</h3>
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-95`}
              className={styles.input}
              type="text"
              value={contactData.contact.companyName}
              name="companyName"
              placeholder="Company Name"
              submitAttempted={this.state.setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validations="minLength:2"
              validationErrors={{
                isDefaultRequiredValue: 'Minimum 2 characters',
                minLength: 'Minimum 2 characters'
              }}
              required
            />
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-45`}
              className={styles.input}
              type="text"
              value={contactData.contact.firstName}
              name="firstName"
              placeholder="First Name"
              submitAttempted={this.state.setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validations="minLength:2"
              validationErrors={{
                isDefaultRequiredValue: 'Minimum 2 characters',
                minLength: 'Minimum 2 characters'
              }}
              required
            />
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} offset-5 flex-45`}
              className={styles.input}
              type="text"
              value={contactData.contact.lastName}
              name="lastName"
              placeholder="Last Name"
              submitAttempted={this.state.setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validations="minLength:2"
              validationErrors={{
                isDefaultRequiredValue: 'Minimum 2 characters',
                minLength: 'Minimum 2 characters'
              }}
              required
            />
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-45`}
              className={styles.input}
              type="text"
              value={contactData.contact.email}
              name="email"
              placeholder="Email"
              submitAttempted={this.state.setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validations={{
                matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must not be blank',
                matchRegexp: 'Invalid email'
              }}
              required
            />
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} offset-5 flex-45`}
              className={styles.input}
              type="text"
              value={contactData.contact.phone}
              name="phone"
              placeholder="Phone"
              submitAttempted={this.state.setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validations="minLength:4"
              validationErrors={{
                isDefaultRequiredValue: 'Minimum 4 characters',
                minLength: 'Minimum 4 characters'
              }}
              required
            />
            { contactData.type !== 'notifyee' ? locationSection : pusherPlaceholder }
            <div className="layout-row layout-align-space-between" style={{ width: '97.5%' }}>
              <RoundButton
                text={`${contactData.type === 'notifyee' ? 'Add' : 'Set'} ${contactData.type}`}
                theme={theme}
                size="small"
                active
              />
              <RoundButton
                text="Done"
                theme={theme}
                size="small"
                handleNext={this.close}
              />
            </div>
          </Formsy>
        </div>
      </div>
    )
  }
}
ShipmentContactForm.propTypes = {
  theme: PropTypes.theme,
  close: PropTypes.func,
  setContact: PropTypes.func,
  handleChange: PropTypes.func,
  contactData: PropTypes.objectOf(PropTypes.any)
}
ShipmentContactForm.defaultProps = {
  theme: {},
  handleChange: null,
  contactData: {},
  setContact: null,
  close: null
}

export default ShipmentContactForm
