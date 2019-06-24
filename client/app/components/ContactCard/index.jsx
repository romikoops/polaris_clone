import React from 'react'
import Truncate from 'react-truncate'
import styles from './ContactCard.scss'
import { gradientTextGenerator, deepCamelizeKeys } from '../../helpers'

export default function ContactCard ({
  contactData, theme, contactType, select
}) {
  const { contact, address } = contactData
  if (!contact) return ''

  const contactToRender = contact.first_name ? deepCamelizeKeys(contact) : contact
  const addressToRender = address.street_number ? deepCamelizeKeys(address) : address
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary),
    width: '28px',
    padding: '3px 0'
  }
  const fullAddress = (
    <p className="flex-100" style={{ margin: 0 }}>
      {addressToRender.street ? `${addressToRender.street}, ` : ''}
      {addressToRender.streetNumber ? `${addressToRender.streetNumber}, ` : ''}
      {addressToRender.zipCode ? `${addressToRender.zipCode}, ` : ''}
      {addressToRender.city ? `${addressToRender.city}` : ''}
      {addressToRender.country ? ', ' : ''}
      {addressToRender.country ? `${addressToRender.country}, ` : ''}
    </p>
  )

  return (
    <div
      className={`flex-100 layout-row ${styles.contact_card}`}
      onClick={() => select(contactData, contactType)}
    >
      <div className={styles.overlay} />
      <div className="flex layout-row layout-wrap">

        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 layout-row alyout-align-start-center">
            <i className="fa fa-user-circle-o flex-none clip" style={iconStyle} />
            <p className={`flex ${styles.contact_header}`}>
              {contactToRender.firstName}
              {' '}
              {contactToRender.lastName}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <i className="fa fa-building-o flex-none clip" style={iconStyle} />
            <p className={`flex-80 ${styles.contact_header}`}>
              <Truncate trimWhitespace>
                {' '}
                {contactToRender.companyName}
                {' '}
              </Truncate>
            </p>
          </div>
          <div className={`flex-100 layout-row layout-wrap ${styles.info_wrapper}`}>
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-envelope flex-none clip" style={iconStyle} />
              <div className="flex-none">
                {' '}
                {contactToRender.email}
                {' '}
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-phone flex-none clip" style={iconStyle} />
              <div className="flex-none">
                {' '}
                {contactToRender.phone}
                {' '}
              </div>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <i className="fa fa-globe flex-none clip" style={iconStyle} />
          <p className="flex-100">
            {(addressToRender && addressToRender.geocodedAddress) || fullAddress}
          </p>
        </div>
      </div>
    </div>
  )
}

ContactCard.defaultProps = {
  theme: null,
  contactType: ''
}
