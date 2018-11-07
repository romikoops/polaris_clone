import React from 'react'
import Truncate from 'react-truncate'
import { v4 } from 'uuid'
import PropTypes from '../../../../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../../../../helpers'

export default function ContactSetterBodyNotifyeeContactsContactCard ({
  theme, contactData, removeFunc, showEditContact
}) {
  const { contact } = contactData
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  }

  const icons = (
    <div className={`flex layout-row ${styles.icons}`}>
      <i
        className={`${styles.remove_icon} pointy fa fa-trash`}
        onClick={() => removeFunc()}
      />
      <i
        className={`${styles.edit_icon} pointy fa fa-pencil`}
        onClick={() => showEditContact()}
      />
    </div>
  )

  return (
    <div
      key={v4()}
      className={`layout-row ${styles.contact_card}`}
    >
      { icons }
      <div className="flex-100 layout-row layout-align-start-start">
        <i className={`${styles.user_icon} fa fa-user clip`} style={iconStyle} />
        <h3 className={`${styles.contact_name}`}>
          {contact.firstName} {contact.lastName} <br />
          <span className={styles.secondary_info}>
            <Truncate lines={1}>{contact.companyName} </Truncate>
          </span>
        </h3>
      </div>
    </div>
  )
}

ContactSetterBodyNotifyeeContactsContactCard.propTypes = {
  contactData: PropTypes.shape({
    contact: PropTypes.object,
    address: PropTypes.object
  }).isRequired,
  theme: PropTypes.theme,
  removeFunc: PropTypes.func,
  showEditContact: PropTypes.func
}

ContactSetterBodyNotifyeeContactsContactCard.defaultProps = {
  theme: null,
  showEditContact: null,
  removeFunc: null
}
