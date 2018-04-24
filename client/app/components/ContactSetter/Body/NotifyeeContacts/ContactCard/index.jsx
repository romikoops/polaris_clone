import React from 'react'
import Truncate from 'react-truncate'
import { v4 } from 'node-uuid'
import PropTypes from '../../../../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../../../../helpers'

export default function ContactSetterBodyNotifyeeContactsContactCard ({
  theme, contactData, removeFunc
}) {
  const { contact } = contactData
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  }

  const removeIcon = (
    <i
      className={`${styles.remove_icon} fa fa-trash`}
      onClick={() => removeFunc()}
    />
  )

  return (
    <div
      key={v4()}
      className={`layout-row ${styles.contact_card}`}
    >
      { removeIcon }
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
    location: PropTypes.object
  }).isRequired,
  theme: PropTypes.theme,
  removeFunc: PropTypes.func
}

ContactSetterBodyNotifyeeContactsContactCard.defaultProps = {
  theme: null,
  removeFunc: null
}
