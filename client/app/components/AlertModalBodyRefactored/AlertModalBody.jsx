import React from 'react'
import PropTypes from 'prop-types'
import styles from './AlertModalBody.scss'

const CELL = 'flex-100 layout-row layout-align-end'
const CONTAINER = 'layout row layout-align-center'
const IMAGE_SRC = 'https://assets.itsmycargo.com/assets/logos/logo_box.png'

const creditStyle = { fontSize: '10px', marginRight: '2px' }
const imageStyle = { height: '20px', margin: '0 3px -5px 3px' }
const logoStyle = { height: '50px' }
const spanStyle = { fontWeight: 'bold', color: 'rgb(100, 100, 100)', fontSize: '14px' }

export function AlertModalBody (props) {
  const {
    message,
    maxWidth,
    logo, toggleAlertModal
  } = props

  const containerStyle = { maxWidth, width: '80vw' }
  const ICON = `${styles.exit_icon} fa fa-times`

  return (
    <div className={CONTAINER} style={containerStyle}>
      <i className={ICON} onClick={toggleAlertModal} />
      <div>
        <div><img src={logo} style={logoStyle} /></div>
        { message }
        <div className={CELL}>
          <div>
            <span style={creditStyle}>Powered by</span>
            <img src={IMAGE_SRC} style={imageStyle} />
            <span style={spanStyle}>ItsMyCargo</span>
          </div>
        </div>
      </div>
    </div>
  )
}

AlertModalBody.propTypes = {
  logo: PropTypes.string,
  maxWidth: PropTypes.string,
  message: PropTypes.string,
  toggleAlertModal: PropTypes.func
}

AlertModalBody.defaultProps = {
  logo: 'AlertModalBody.logo',
  maxWidth: '600px',
  message: 'AlertModalBody.message',
  toggleAlertModal: () => console.log('AlertModalBody.toggleAlertModal')
}

export default AlertModalBody
