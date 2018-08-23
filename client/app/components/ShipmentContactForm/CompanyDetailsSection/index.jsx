import React from 'react'
import PropTypes from '../../../prop-types'
import FormsyInput from '../../FormsyInput/FormsyInput'
import styles from '../ShipmentContactForm.scss'
import IconLable from '../IconLable'

export default function CompanyDetailsSection ({
  theme, contactData, setContactAttempted, checkValid, formErrors
}) {
  return (
    <div className="flex-100 layout-row layout-wrap">
      <h3>Company Details</h3>
      <div className={`${styles.grouped_inputs} flex-100 layout-row layout-wrap`}>
        <div className="flex-95 layout-row">
          <IconLable faClass="building-o" theme={theme} />
          <FormsyInput
            wrapperClassName={`${styles.wrapper_input} flex`}
            className={styles.input}
            type="text"
            value={contactData.contact.companyName}
            name="companyName"
            placeholder="Company Name"
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
      </div>
      <div className={`${styles.grouped_inputs} flex-100 layout-row layout-wrap`}>
        <div className="flex-95 layout-row">
          <IconLable faClass="user" theme={theme} />
          <div className="flex layout-row layout-wrap">
            <FormsyInput
              wrapperClassName={`${styles.wrapper_input} flex-100`}
              className={styles.input}
              type="text"
              value={contactData.contact.firstName}
              name="firstName"
              placeholder="First Name"
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
              wrapperClassName={`${styles.wrapper_input} flex-100`}
              className={styles.input}
              type="text"
              value={contactData.contact.lastName}
              name="lastName"
              placeholder="Last Name"
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
        </div>
      </div>
      <div className={`${styles.grouped_inputs} flex-100 layout-row layout-wrap`}>
        <div className="flex-95 layout-row">
          <IconLable faClass="envelope" theme={theme} />
          <FormsyInput
            wrapperClassName={`${styles.wrapper_input} flex-95`}
            className={styles.input}
            type="text"
            value={contactData.contact.email}
            name="email"
            placeholder="Email"
            onBlur={() => checkValid('email')}
            submitAttempted={setContactAttempted}
            errorMessageStyles={{
              fontSize: '12px',
              bottom: '-19px'
            }}
            validations={{
              matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
            }}
            validationErrors={{
              isDefaultRequiredValue: 'Must not be blank',
              matchRegexp: 'Invalid email',
            }}
            required
          />
        </div>
        <div className="flex-95 layout-row">
          <IconLable faClass="phone" theme={theme} />
          <FormsyInput
            wrapperClassName={`${styles.wrapper_input} flex-95`}
            className={styles.input}
            type="text"
            value={contactData.contact.phone}
            name="phone"
            placeholder="Phone"
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
        </div>
      </div>
    </div>
  )
}

CompanyDetailsSection.propTypes = {
  theme: PropTypes.theme,
  contactData: PropTypes.objectOf(PropTypes.any).isRequired,
  setContactAttempted: PropTypes.bool,
  checkValid: PropTypes.func.isRequired,
  formErrors: PropTypes.bool
}

CompanyDetailsSection.defaultProps = {
  theme: null,
  setContactAttempted: false,
  formErrors: false
}
