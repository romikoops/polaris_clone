import React from 'react'
import PropTypes from 'prop-types'
import styles from './AlertModalBody.scss'

export function AlertModalBody (props) {
  const {
    message, maxWidth, logo, toggleAlertModal
  } = props
  return (
    <div
      className="layout row layout-align-center"
      style={{ maxWidth: maxWidth || '600px', width: '80vw' }}
    >
      <i className={`${styles.exit_icon} fa fa-times`} onClick={toggleAlertModal} />

      <div>
        <div>
          <img src={logo} style={{ height: '50px' }} />
        </div>

        { message }

        <div className="flex-100 layout-row layout-align-end">
          <div>
            <span style={{ fontSize: '10px', marginRight: '2px' }}>Powered by</span>
            <img
              src="https://assets.itsmycargo.com/assets/logos/logo_box.png"
              style={{ height: '20px', margin: '0 3px -5px 3px' }}
            />
            <span style={{ fontWeight: 'bold', color: 'rgb(100, 100, 100)', fontSize: '14px' }}>
              ItsMyCargo
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}

AlertModalBody.propTypes = {
  message: PropTypes.string.isRequired,
  logo: PropTypes.string.isRequired,
  toggleAlertModal: PropTypes.func.isRequired,
  maxWidth: PropTypes.string
}

AlertModalBody.defaultProps = {
  maxWidth: null
}
export default AlertModalBody
