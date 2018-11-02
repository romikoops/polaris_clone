import React from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import styles from './AddContactButton.scss'
import PropTypes from '../../../../../prop-types'

function ContactSetterBodyNotifyeeContactsAddContactButton ({
  onClick, t
}) {
  return (
    <div
      key={v4()}
      className={`flex-100 layout-row layout-align-center-center ${styles.add_contact_btn}`}
      onClick={onClick}
    >
      <h3>
        {t('common:addA')}<br />
        <span>
          {t('common:notifyee').toUpperCase()}
        </span>
      </h3>
    </div>
  )
}

ContactSetterBodyNotifyeeContactsAddContactButton.propTypes = {
  onClick: PropTypes.func,
  t: PropTypes.func.isRequired
}

ContactSetterBodyNotifyeeContactsAddContactButton.defaultProps = {
  onClick: null
}

export default withNamespaces('common')(ContactSetterBodyNotifyeeContactsAddContactButton)
