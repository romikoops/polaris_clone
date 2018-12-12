import React from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../../../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../../../../helpers'

function commaSeparatedWhenBothExist (str1, str2) {
  return str1 && str2 ? `${str1}, ${str2}` : (str1 || str2)
}
function addressForDisplay (address) {
  const {
    street, streetNumber, city, country
  } = address
  const cityCountry = commaSeparatedWhenBothExist(city, country)

  const streetWithNumber = (street || '') + (streetNumber ? ` ${streetNumber}` : '')
  const addressDetails = streetWithNumber

  return { cityCountry, addressDetails }
}

export default function ShipmentContactsBoxMainContactsContactCard ({
  contactData, theme, contactType, showAddressBook, showEditContact, handleClick
}) {
  const { contact, address } = contactData
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  }

  const borderStyles = theme ? { borderColor: theme.colors.secondary } : {}

  const icons = (
    <div className="flex layout-row" onClick={handleClick}>
      <i
        className={`${styles.plus_icon} fa fa-plus`}
        onClick={() => showAddressBook(contactType)}
      />
      <i
        className={`${styles.edit_icon} fa fa-pencil`}
        onClick={() => showEditContact(contactType)}
      />
    </div>
  )

  const { addressDetails } = addressForDisplay(address)

  return (
    <div className={`flex-100 layout-row layout-wrap ${styles.contact_card}`} style={borderStyles}>
      {icons}
      <div className="flex-100 layout-row layout-align-start-start">
        <i className={`${styles.main_icon} fa fa-user`} style={iconStyle} />
        <h3 className={`${styles.contact_name}`}>
          <Truncate lines={1}>{contact.firstName} {contact.lastName}</Truncate> <br />
          <span className={styles.secondary_info}>
            <Truncate lines={1}>{contact.companyName} </Truncate>
          </span>
        </h3>
      </div>
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div className="flex-100 layout-row layout-align-space-around-center">
          <i className={`${styles.main_icon} fa fa-map-marker flex-10`} style={iconStyle} />
          <p className={`${styles.secondary_info} flex`}>
            { addressDetails }
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-end-center">
          <p className={`${styles.secondary_info_city} flex-90 offset-10`}>
            <b> { address.city } </b>, {address.zipCode}
          </p>
        </div>
        <div className="flex-100 layout-row layout-align-end-center">
          <p className={`${styles.secondary_info_country} flex-90 offset-10`}>
            <Truncate lines={1}> { address.country }</Truncate>
          </p>
        </div>
      </div>
      <div className={
        `${styles.contact_data_sec} flex-100 ` +
        'layout-row layout-wrap layout-align-space-between-center'
      }
      >
        <div className="flex-50 layout-row layout-align-start-center">
          <i className="fa fa-envelope flex-none" style={iconStyle} />
          <p className={`${styles.contact_data} flex`}><Truncate lines={1}> {contact.email} </Truncate></p>
        </div>
        <div className="flex-45 layout-row layout-align-end-center">
          <i className="fa fa-phone flex-none" style={iconStyle} />
          <p className={`${styles.contact_data} flex`}><Truncate lines={1}> {contact.phone} </Truncate></p>
        </div>
      </div>
    </div>
  )
}

ShipmentContactsBoxMainContactsContactCard.propTypes = {
  contactData: PropTypes.shape({
    contact: PropTypes.object,
    address: PropTypes.object
  }).isRequired,
  theme: PropTypes.theme,
  contactType: PropTypes.string,
  showAddressBook: PropTypes.func,
  showEditContact: PropTypes.func,
  handleClick: PropTypes.func
}

ShipmentContactsBoxMainContactsContactCard.defaultProps = {
  theme: null,
  contactType: '',
  showAddressBook: null,
  handleClick: null,
  showEditContact: null
}
