import React from 'react'
import PropTypes from 'prop-types'
import styles from './AlertModalBody.scss'

export function AlertModalBody ({ message, logo, toggleAlertModal }) {
  return (
    <div className="flex-100 layout row layout-align-center">
      <i className={`${styles.exit_icon} fa fa-times`} onClick={() => toggleAlertModal()} />

      <div className="flex-100" style={{ padding: '20px' }}>
        <div>
          <img src={logo} style={{ height: '50px' }} />
        </div>

        {message}

        <div className="flex-100 layout-row layout-align-end">
          <div>
            <span style={{ fontSize: '10px', marginRight: '2px' }}>Powered by</span>
            <img
              src="https://assets.itsmycargo.com/assets/logos/logo_box.png"
              style={{ height: '20px', marginBottom: '-2px' }}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

AlertModalBody.propTypes = {
  message: PropTypes.string.isRequired,
  logo: PropTypes.string.isRequired,
  toggleAlertModal: PropTypes.func.isRequired
}

export default AlertModalBody
