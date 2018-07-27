import React from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../../../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../../../../helpers'
import { RoundButton } from '../../../../RoundButton/RoundButton';

function commaSeparatedWhenBothExist (str1, str2) {
  return str1 && str2 ? `${str1}, ${str2}` : (str1 || str2)
}
function locationForDisplay (location) {
  const {
    street, streetNumber, city, country, zipCode
  } = location
  const cityCountry = commaSeparatedWhenBothExist(city, country)

  const streetWithNumber = street && street + (streetNumber && ` ${streetNumber}`)
  const addressDetails = commaSeparatedWhenBothExist(streetWithNumber, zipCode)

  return { cityCountry, addressDetails }
}

export default function ShipmentContactsBoxMainContactsContactCard ({
  contactData, theme, contactType, showAddressBook, showEditContact, handleClick
}) {
  const { contact, location } = contactData
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

  const { addressDetails, cityCountry } = locationForDisplay(location)

  return (
    <div className={`flex-100 layout-row layout-wrap ${styles.contact_card}`} style={borderStyles}>
      {icons}
      <div className="flex-100 layout-row layout-align-start-start">
        <i className={`${styles.main_icon} fa fa-user`} style={iconStyle} />
        <h3 className={`${styles.contact_name}`}>
          {contact.firstName} {contact.lastName} <br />
          <span className={styles.secondary_info}>
            <Truncate lines={1}>{contact.companyName} </Truncate>
          </span>
        </h3>
      </div>
      <div className="flex-100 layout-row layout-align-start-start">
        <i className={`${styles.main_icon} fa fa-map-marker`} style={iconStyle} />
        <p className={styles.secondary_info}>
          { addressDetails } <br />
          <b> { cityCountry } </b>
        </p>
      </div>
      <div className={
        `${styles.contact_data_sec} flex-100 ` +
        'layout-row layout-wrap layout-align-center-center'
      }
      >
        <div className="flex-none layout-row layout-align-start-center">
          <i className="fa fa-envelope flex-none" style={iconStyle} />
          <p className={styles.contact_data}> {contact.email} </p>
        </div>
        <div className="offset-5 flex-none layout-row layout-align-start-center">
          <i className="fa fa-phone flex-none" style={iconStyle} />
          <p className={styles.contact_data}> {contact.phone} </p>
        </div>
      </div>
    </div>
  )
}

ShipmentContactsBoxMainContactsContactCard.propTypes = {
  contactData: PropTypes.shape({
    contact: PropTypes.object,
    location: PropTypes.object
  }).isRequired,
  theme: PropTypes.theme,
  contactType: PropTypes.string,
  showAddressBook: PropTypes.func
}

ShipmentContactsBoxMainContactsContactCard.defaultProps = {
  theme: null,
  contactType: '',
  showAddressBook: null
}
