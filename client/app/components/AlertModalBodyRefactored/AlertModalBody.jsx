import React from 'react'
import PropTypes from 'prop-types'
import styles from './AlertModalBody.scss'

import {
  trim,
  ROW
} from '../../classNames'

const LOGO_BOX = 'https://assets.itsmycargo.com/assets/logos/logo_box.png'
const CONTAINER = 'ALERT_MODAL_BODY layout row layout-align-center'

export function AlertModalBody (props) {
  const {
    message,
    maxWidth,
    logo,
    toggleAlertModal
  } = props

  return (
    <div
      className={CONTAINER}
      style={{ maxWidth: maxWidth || '600px', width: '80vw' }}
    >
      <i
        className={trim(`
          ${styles.exit_icon} 
          fa fa-times
        `)}
        onClick={toggleAlertModal}
      />

      <div>
        <div>
          <img
            src={logo}
            style={{ height: '50px' }}
          />
        </div>

        { message }

        <div
          className={trim(`
            ${ROW(100)} 
            layout-align-end
          `)}
        >
          <div>
            <span style={{
              fontSize: '10px', marginRight: '2px'
            }}
            >Powered by</span>
            <img
              src={LOGO_BOX}
              style={{
                height: '20px',
                margin: '0 3px -5px 3px'
              }}
            />
            <span style={{
              fontWeight: 'bold',
              color: 'rgb(100, 100, 100)',
              fontSize: '14px'
            }}
            >
              ItsMyCargo
            </span>
          </div>
        </div>
      </div>
    </div>
  )
}

AlertModalBody.propTypes = {
  logo: PropTypes.string.isRequired,
  maxWidth: PropTypes.string,
  message: PropTypes.string.isRequired,
  toggleAlertModal: PropTypes.func.isRequired
}

AlertModalBody.defaultProps = {
  maxWidth: null
}
export default AlertModalBody
