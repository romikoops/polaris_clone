import React from 'react'
import PropTypes from '../../../prop-types'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import FormsyInput from '../../FormsyInput/FormsyInput'
import styles from '../ShipmentContactForm.scss'
import { PlaceSearch } from '../../Maps/PlaceSearch'
import IconLable from '../IconLable'

export default function AddressDetailsSection ({
  theme, contactData, handlePlaceChange, setContactAttempted, setContactBtn
}) {
  return (
    <div className="flex offset-5 layout-row layout-wrap layout-align-start-start">
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
            handlePlaceChange={handlePlaceChange}
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
              value={contactData.location.street}
              name="location-street"
              placeholder="Street"
              submitAttempted={setContactAttempted}
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
              submitAttempted={setContactAttempted}
              errorMessageStyles={{
                fontSize: '12px',
                bottom: '-19px'
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must not be blank'
              }}
              required
            />
          </div>
          <div className={`${styles.grouped_inputs} flex-100 layout-row`}>
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-95`}
              className={styles.input}
              type="text"
              value={contactData.location.city}
              name="location-city"
              placeholder="City"
              submitAttempted={setContactAttempted}
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
          </div>
          <div className={`${styles.grouped_inputs} flex-100 layout-row`}>
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-40`}
              className={styles.input}
              type="text"
              value={contactData.location.zipCode}
              name="location-zipCode"
              placeholder="Postal Code"
              submitAttempted={setContactAttempted}
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
              wrapperClassName={`${styles.wrapper_input} offset-5 flex-50`}
              className={styles.input}
              type="text"
              value={contactData.location.country}
              name="location-country"
              placeholder="Country"
              submitAttempted={setContactAttempted}
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
          </div>
          <FormsyInput
            wrapperClassName="flex-100"
            type="hidden"
            value={contactData.location.geocodedAddress}
            name="location-geocodedAddress"
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

AddressDetailsSection.propTypes = {
  theme: PropTypes.theme,
  contactData: PropTypes.objectOf(PropTypes.any).isRequired,
  handlePlaceChange: PropTypes.func.isRequired,
  setContactAttempted: PropTypes.bool
}

AddressDetailsSection.defaultProps = {
  theme: null,
  setContactAttempted: false
}
