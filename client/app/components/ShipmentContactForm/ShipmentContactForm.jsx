import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './ShipmentContactForm.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { nameToDisplay } from '../../helpers'
import AddressDetailsSection from './AddressDetailsSection'
import CompanyDetailsSection from './CompanyDetailsSection'

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
    this.handleFormChange = this.handleFormChange.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
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
    const { theme, contactType } = this.props
    const { contactData } = this.state

    const setContactBtn = (
      <RoundButton
        text={
          `${contactType === 'notifyee' ? 'Add' : 'Set'} ` +
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
        contactData={contactData}
        handlePlaceChange={place => this.handlePlaceChange(place)}
        setContactAttempted={this.state.setContactAttempted}
        setContactBtn={setContactBtn}
      />
    )

    const setContactBtnWrapper = (
      <div
        className="flex-100 layout-row layout-align-center-center"
      >
        { setContactBtn }
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
          onValidSubmit={this.handleSubmit}
          onInvalidSubmit={this.handleInvalidSubmit}
          mapping={ShipmentContactForm.mapInputs}
          ref={(c) => { this.contactForm = c }}
          style={{ padding: '8px 20px' }}
        >
          <div className={`flex${contactType === 'notifyee' ? '-100' : ''} layout-row`}>
            <CompanyDetailsSection
              theme={theme}
              contactData={contactData}
              setContactAttempted={this.state.setContactAttempted}
            />
          </div>

          { contactType === 'notifyee' ? setContactBtnWrapper : addressDetailsSection }
        </Formsy>
      </div>
    )
  }
}

ShipmentContactForm.propTypes = {
  theme: PropTypes.theme,
  setContact: PropTypes.func,
  handleChange: PropTypes.func,
  contactType: PropTypes.string
}

ShipmentContactForm.defaultProps = {
  theme: null,
  handleChange: null,
  setContact: null,
  contactType: ''
}

export default ShipmentContactForm
