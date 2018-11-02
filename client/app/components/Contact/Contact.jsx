import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './Contact.scss'
import { nameToDisplay } from '../../helpers'

function Contact (props) {
  const {
    contact, textStyle, contactType, t
  } = props

  return (
    <div className="flex-45 layout-row">
      <div className="flex-10 layout-column layout-align-start-center">
        <i className={` ${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
      </div>
      <div className="flex-90 layout-row layout-wrap layout-align-start-start">
        <h3 style={{ fontWeight: 'normal' }}>{nameToDisplay(contactType)}</h3>
        <div className="flex-100 layout-row layout-align-space-between-start">
          <div className="flex-60 layout-row layout-wrap layout-align-center-start">
            <p className={`${styles.contact_text} flex-100`}>
              {contact.data.first_name} {contact.data.last_name}
            </p>
            <p className={`${styles.contact_text} flex-100`}>{contact.data.company_name}</p>
            <p className={`${styles.contact_text} flex-100`}>{contact.data.email}</p>
            <p className={`${styles.contact_text} flex-100`}>{contact.data.phone}</p>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
            <p className={`${styles.contact_text} ${styles.address_buffer} flex-100 center`}>
              {t('common:address')}
            </p>

            <address className={` ${styles.address} flex-100 center`}>
              {contact.location
                ? `${contact.location.street || ''} ${contact.location.street_number || ''}`
                : ''}{' '}
              <br />
              {contact.location ? `${contact.location.zip_code} ${contact.location.city}` : ''}
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

export default withNamespaces('common')(Contact)
