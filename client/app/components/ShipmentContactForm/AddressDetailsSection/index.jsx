import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import FormsyInput from '../../FormsyInput/FormsyInput'
import styles from '../ShipmentContactForm.scss'
import PlaceSearch from '../../Maps/PlaceSearch'
import IconLable from '../IconLable'

class AddressDetailsSection extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      contactData: props.contactData
    }
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
      contactData: { ...this.state.contactData, address: newLocation }
    })
    this.setState({
      autocomplete: { ...this.state.autocomplete, address: true }
    })
  }
  render () {
    const {
      theme,
      setContactAttempted,
      setContactBtn,
      t
    } = this.props
    const { contactData } = this.state

    return (
      <div className="flex offset-5 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap">
          <h3 className="flex-40">{t('user:addressDetails')}</h3>
          <div className="offset-5 flex-55">
            <GmapsWrapper
              theme={theme}
              component={PlaceSearch}
              inputStyles={{
                width: '96%',
                marginTop: '9px',
                background: 'white',
                boxShadow: 'unset'
              }}
              handlePlaceChange={e => this.handlePlaceChange(e)}
              hideMap
            />
          </div>
        </div>
        <div className="flex-100 layout-row">
          <IconLable faClass="map-marker" theme={theme} />
          <div className="flex-95 layout-row layout-wrap">
            <div className={`${styles.grouped_inputs} flex-100 layout-row`}>
              <FormsyInput
                wrapperClassName={`${styles.wrapper_input} flex-75`}
                className={styles.input}
                type="text"
                value={contactData.address.street}
                name="address-street"
                placeholder={t('user:street')}
                submitAttempted={setContactAttempted}
                errorMessageStyles={{
                  fontSize: '12px',
                  bottom: '-19px'
                }}
                validations="minLength:2"
                validationErrors={{
                  isDefaultRequiredValue: t('errors:twoChars'),
                  minLength: t('errors:twoChars')
                }}
                required
              />
              <FormsyInput
                wrapperClassName={`${styles.wrapper_input} offset-5 flex-15`}
                className={styles.input}
                type="text"
                value={contactData.address.streetNumber}
                name="address-streetNumber"
                placeholder={t('user:number')}
                submitAttempted={setContactAttempted}
                errorMessageStyles={{
                  fontSize: '12px',
                  bottom: '-19px'
                }}
                validationErrors={{
                  isDefaultRequiredValue: t('errors:notBlank')
                }}
                required
              />
            </div>
            <div className={`${styles.grouped_inputs} flex-100 layout-row`}>
              <FormsyInput
                wrapperClassName={`${styles.wrapper_input} flex-95`}
                className={styles.input}
                type="text"
                value={contactData.address.city}
                name="address-city"
                placeholder={t('user:city')}
                submitAttempted={setContactAttempted}
                errorMessageStyles={{
                  fontSize: '12px',
                  bottom: '-19px'
                }}
                validations="minLength:2"
                validationErrors={{
                  isDefaultRequiredValue: t('errors:twoChars'),
                  minLength: t('errors:twoChars')
                }}
                required
              />
            </div>
            <div className={`${styles.grouped_inputs} flex-100 layout-row`}>
              <FormsyInput
                wrapperClassName={`${styles.wrapper_input} flex-40`}
                className={styles.input}
                type="text"
                value={contactData.address.zipCode}
                name="address-zipCode"
                placeholder={t('user:postalCode')}
                submitAttempted={setContactAttempted}
                errorMessageStyles={{
                  fontSize: '12px',
                  bottom: '-19px'
                }}
                validations="minLength:4"
                validationErrors={{
                  isDefaultRequiredValue: t('errors:fourChars'),
                  minLength: t('errors:fourChars')
                }}
                required
              />
              <FormsyInput
                wrapperClassName={`${styles.wrapper_input} offset-5 flex-50`}
                className={styles.input}
                type="text"
                value={contactData.address.country}
                name="address-country"
                placeholder={t('user:country')}
                submitAttempted={setContactAttempted}
                errorMessageStyles={{
                  fontSize: '12px',
                  bottom: '-19px'
                }}
                validations="minLength:3"
                validationErrors={{
                  isDefaultRequiredValue: t('errors:threeChars'),
                  minLength: t('errors:threeChars')
                }}
                required
              />
            </div>
            <FormsyInput
              wrapperClassName="flex-100"
              type="hidden"
              value={contactData.address.geocodedAddress}
              name="address-geocodedAddress"
              placeholder=""
            />
            <div
              className={`${styles.grouped_inputs} flex-100 layout-row layout-align-start-start`}
              style={{ marginTop: '50px' }}
            >
              { setContactBtn }
            </div>
          </div>
        </div>
      </div>
    )
  }
}

AddressDetailsSection.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  contactData: PropTypes.objectOf(PropTypes.any).isRequired,
  setContactAttempted: PropTypes.bool,
  setContactBtn: PropTypes.node
}

AddressDetailsSection.defaultProps = {
  theme: null,
  setContactAttempted: false,
  setContactBtn: null
}

export default withNamespaces(['errors', 'user'])(AddressDetailsSection)
