import React from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../../prop-types'
import FormsyInput from '../../FormsyInput/FormsyInput'
import styles from '../ShipmentContactForm.scss'
import IconLable from '../IconLable'

function CompanyDetailsSection ({
  theme, contactData, setContactAttempted, checkValid, t
}) {
  return (
    <div className="flex-100 layout-row layout-wrap">
      <h3>{t('user:companyDetails')}</h3>
      <div className={`${styles.grouped_inputs} flex-100 layout-row layout-wrap`}>
        <div className="flex-95 layout-row">
          <IconLable faClass="building-o" theme={theme} />
          <FormsyInput
            wrapperClassName={`${styles.wrapper_input} flex`}
            className={styles.input}
            type="text"
            value={contactData.contact.companyName}
            name="companyName"
            placeholder={t('user:companyName')}
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
              placeholder={t('user:firstName')}
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
              wrapperClassName={`${styles.wrapper_input} flex-100`}
              className={styles.input}
              type="text"
              value={contactData.contact.lastName}
              name="lastName"
              placeholder={t('user:lastName')}
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
            placeholder={t('user:email')}
            onBlur={() => checkValid('email')}
            submitAttempted={setContactAttempted}
            errorMessageStyles={{
              fontSize: '12px',
              bottom: '-19px'
            }}
            validations={{
              matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
            }}
            validationErrors={{
              isDefaultRequiredValue: t('errors:notBlank'),
              matchRegexp: t('errors:invalidEmail')
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
            placeholder={t('user:phone')}
            submitAttempted={setContactAttempted}
            errorMessageStyles={{
              fontSize: '12px',
              bottom: '-19px'
            }}
            validations="minLength:4"
            validationErrors={{
              isDefaultRequiredValue: t('errors:fourChars'),
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
  t: PropTypes.func.isRequired,
  contactData: PropTypes.objectOf(PropTypes.any).isRequired,
  setContactAttempted: PropTypes.bool,
  checkValid: PropTypes.func.isRequired
}

CompanyDetailsSection.defaultProps = {
  theme: null,
  setContactAttempted: false
}

export default translate(['errors', 'user'])(CompanyDetailsSection)
