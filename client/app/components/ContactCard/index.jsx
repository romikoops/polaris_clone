import React from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../helpers'

export default function ContactCard ({
  contactData, theme, contactType, select
}) {
  const { contact, location } = contactData
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary),
    width: '28px',
    padding: '3px 0'
  }
  const fullAddress = (
    <p className="flex-100" style={{ margin: 0 }}>
      {location.street ? `${location.street}, ` : ''}
      {location.streetNumber ? `${location.streetNumber}, ` : ''}
      {location.zipCode ? `${location.zipCode}, ` : ''}
      {location.city ? `${location.city}` : ''}
      {location.country ? ', ' : ''}
      {location.country ? `${location.country}, ` : ''}
    </p>
  )

  return (
    <div
      className={`flex-100 layout-row ${styles.contact_card}`}
      onClick={() => select(contactData, contactType)}
    >
      <div className={styles.overlay} />
      <div className="flex layout-row layout-wrap">
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-60 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row alyout-align-start-center">
              <i className="fa fa-user-circle-o flex-none clip" style={iconStyle} />
              <p className={`flex ${styles.contact_header}`}>
                {contact.firstName} {contact.lastName}
              </p>
            </div>
          </div>
          <div className={
            `flex-40 layout-row layout-wrap layout-align-start-center ${styles.contact_details}`
          }
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-envelope flex-none clip" style={iconStyle} />
              <p className="flex-none"> {contact.email} </p>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-60 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-building-o flex-none clip" style={iconStyle} />
              <p className={`flex-80 ${styles.contact_header}`}>
                <Truncate trimWhitespace> {contact.companyName} </Truncate>
              </p>
            </div>
          </div>
          <div className={
            `flex-40 layout-row layout-wrap layout-align-start-center ${styles.contact_details}`
          }
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-phone flex-none clip" style={iconStyle} />
              <p className="flex-none"> {contact.phone} </p>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <i className="fa fa-globe flex-none clip" style={iconStyle} />
          <p className="flex-100">
            {(location && location.geocodedAddress) || fullAddress}
          </p>
        </div>
      </div>
    </div>
  )
}

ContactCard.propTypes = {
  contactData: PropTypes.shape({
    contact: PropTypes.object,
    location: PropTypes.object
  }).isRequired,
  theme: PropTypes.theme,
  select: PropTypes.func.isRequired,
  contactType: PropTypes.string
}

ContactCard.defaultProps = {
  theme: null,
  contactType: ''
}
