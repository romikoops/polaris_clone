import React from 'react'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './ContactCard.scss'
import { gradientTextGenerator } from '../../helpers'
import { ROW, trim, WRAP_ROW, ALIGN_START } from '../../classNames'

const CONTAINER = `CONTACT_CARD flex-100 layout-row ${styles.contact_card}`
const BUILDING_ICON = 'fa fa-building-o flex-none clip'
const ENVELOPE_ICON = 'fa fa-envelope flex-none clip'
const GLOBE_ICON = 'fa fa-globe flex-none clip'
const PHONE_ICON = 'fa fa-phone flex-none clip'
const USER_CIRCLE_ICON = 'fa fa-user-circle-o flex-none clip'

export default function ContactCard ({
  contactData, theme, contactType, select
}) {
  const { contact, location } = contactData
  const iconStyle = {
    ...gradientTextGenerator(theme.colors.primary, theme.colors.secondary),
    width: '28px',
    padding: '3px 0'
  }

  return (
    <div
      className={CONTAINER}
      onClick={() => select(contactData, contactType)}
    >
      <div className={styles.overlay} />

      <div className={`flex ${WRAP_ROW()}`}>
        <div className={`${ROW(100)} layout-align-space-between-center`}>
          <div className={`${WRAP_ROW(60)} ${ALIGN_START}`}>
            <div className={`${ROW(100)} layout-align-start-center`}>
              <i className={USER_CIRCLE_ICON} style={iconStyle} />
              <p className={`flex ${styles.contact_header}`}>
                {contact.firstName} {contact.lastName}
              </p>
            </div>
          </div>

          <div className={`${WRAP_ROW(40)} layout-align-start-center ${styles.contact_details}`}>
            <div className={`${ROW(100)} layout-align-start-center`}>
              <i className={ENVELOPE_ICON} style={iconStyle} />
              <p className="flex-none"> {contact.email} </p>
            </div>
          </div>
        </div>

        <div className={`${ROW(100)} layout-align-space-between-center`}>
          <div className={`${WRAP_ROW(60)} ${ALIGN_START}`}>
            <div className={`${ROW(100)} layout-align-start-center`}>
              <i className={BUILDING_ICON} style={iconStyle} />
              <p className={`flex-80 ${styles.contact_header}`}>
                <Truncate trimWhitespace> {contact.companyName} </Truncate>
              </p>
            </div>
          </div>

          <div className={trim(`
            ${WRAP_ROW(40)} 
            layout-align-start-center 
            ${styles.contact_details}
          `)}
          >
            <div className={`${ROW(100)} layout-align-start-center`}>
              <i className={PHONE_ICON} style={iconStyle} />
              <p className="flex-none"> {contact.phone} </p>
            </div>
          </div>
        </div>

        <div className={`${ROW(100)} layout-align-start-center`}>
          <i className={GLOBE_ICON} style={iconStyle} />
          <p className="flex-100">
            {(location && location.geocodedAddress) || location.fullAddress}
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
