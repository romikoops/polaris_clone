import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../../Body.scss'
import errors from '../../../../../styles/errors.scss'
import PropTypes from '../../../../../prop-types'
import { capitalize, nameToDisplay } from '../../../../../helpers'

function ShipmentContactsBoxMainContactsPlaceholderCard ({
  contactType, theme, showAddressBook, t
}) {
  const showError = false // TBD - finishBookingAttempted
  const requiredSpanStyles = {
    left: '10px', top: '10px', bottom: 'unset', fontSize: '14px'
  }
  const borderStyles = theme ? { borderColor: theme.colors.secondary } : {}
  const requiredSpan = (
    <span
      className={errors.error_message}
      style={requiredSpanStyles}
    >
      * {t('common:required')}
    </span>
  )

  return (
    <div
      className={
        `layout-row layout-wrap ${styles.placeholder_card} ` +
        `${showError ? styles.with_errors : ''}`
      }
      style={borderStyles}
      onClick={() => showAddressBook(contactType)}
    >
      <div className="flex-100 layout-row layout-align-center-center">
        <h3>
          {t('account:chooseA')}<br />
          <span className={styles.contact_type}> { capitalize(nameToDisplay(contactType)) } </span>
        </h3>
      </div>
      { showError && requiredSpan }
    </div>
  )
}

ShipmentContactsBoxMainContactsPlaceholderCard.propTypes = {
  theme: PropTypes.theme,
  contactType: PropTypes.string,
  showAddressBook: PropTypes.func,
  t: PropTypes.func.isRequired
}

ShipmentContactsBoxMainContactsPlaceholderCard.defaultProps = {
  theme: null,
  contactType: '',
  showAddressBook: null
}

export default withNamespaces(['common', 'account'])(ShipmentContactsBoxMainContactsPlaceholderCard)
