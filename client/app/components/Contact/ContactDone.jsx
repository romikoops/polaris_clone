import React from 'react'
import translate from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './Contact.scss'
import { nameToDisplay } from '../../helpers'
import { ROW, WRAP_ROW, COLUMN } from '../../classNames'

const CONTAINER = `CONTACT ${ROW(45)}`
const ENVELOPE_ICON = `${styles.icon} fa fa-envelope-open-o flex-none`
const CONTACT = `${styles.contact_text} flex-100`
const ADDRESS = `${styles.contact_text} ${styles.address_buffer} flex-100 center`

export function Contact (props) {
  const {
    contact,
    textStyle,
    contactType,
    t
  } = props
  const Street = () => {
    if (!contact.location) return ''

    const street = contact.location.street || ''
    const streetNumber = contact.location.street_number || ''

    return `${street} ${streetNumber}`
  }
  const City = () => {
    if (!contact.location) return ''

    const { city, zipCode } = contact.location

    return `${zipCode} ${city}`
  }

  return (
    <div className={CONTAINER}>
      <div className={`${COLUMN(10)} layout-align-start-center`}>
        <i className={ENVELOPE_ICON} style={textStyle} />
      </div>

      <div className="flex-90 layout-row layout-wrap layout-align-start-start">
        <h3 style={{ fontWeight: 'normal' }}>
          {nameToDisplay(contactType)}
        </h3>

        <div className={`${ROW(100)} layout-align-space-between-start`}>
          <div className={`${WRAP_ROW(60)} layout-align-center-start`}>
            <p className={CONTACT}>
              {contact.data.first_name} {contact.data.last_name}
            </p>
            <p className={CONTACT}>{contact.data.company_name}</p>
            <p className={CONTACT}>{contact.data.email}</p>
            <p className={CONTACT}>{contact.data.phone}</p>
          </div>

          <div className={`${WRAP_ROW(100)} layout-align-space-between-start`}>
            <p className={ADDRESS}>{t('common:address')}</p>
            <address className={`${styles.address} flex-100 center`}>
              {Street()}{' '}
              <br />
              {City()}
              <br />
              {contact.location ? `${contact.location.country}` : ''}
            </address>
          </div>
        </div>
      </div>
    </div>
  )
}

Contact.propTypes = {
  contact: PropTypes.objectOf(PropTypes.any).isRequired,
  t: PropTypes.func.isRequired,
  contactType: PropTypes.string.isRequired,
  textStyle: PropTypes.objectOf(PropTypes.string)
}

Contact.defaultProps = {
  textStyle: {}
}

export default translate('common')(Contact)
