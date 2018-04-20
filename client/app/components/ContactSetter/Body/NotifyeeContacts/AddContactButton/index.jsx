import React from 'react'
import { v4 } from 'node-uuid'
import styles from './AddContactButton.scss'
import PropTypes from '../../../../../prop-types'

export default function ContactSetterBodyNotifyeeContactsAddContactButton ({
  onClick
}) {
  return (
    <div
      key={v4()}
      className={`flex-100 layout-row layout-align-center-center ${styles.add_contact_btn}`}
      onClick={onClick}
    >
      <h3>
        Add a <br />
        <span>
          NOTIFYEE
        </span>
      </h3>
    </div>
  )
}

ContactSetterBodyNotifyeeContactsAddContactButton.propTypes = {
  onClick: PropTypes.func
}

ContactSetterBodyNotifyeeContactsAddContactButton.defaultProps = {
  onClick: null
}
