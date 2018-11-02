import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './AlertModalBody.scss'
import { trim, ROW } from '../../classNames'

const LOGO_BOX = 'https://assets.itsmycargo.com/assets/logos/logo_box.png'
const CONTAINER = 'ALERT_MODAL_BODY layout row layout-align-center'

function AlertModalBody (props) {
  const {
    message,
    maxWidth,
    logo,
    toggleAlertModal,
    t
  } = props

  const Icon = (
    <i
      className={trim(`
        ${styles.exit_icon} 
        fa fa-times
      `)}
      onClick={toggleAlertModal}
    />
  )

  return (
    <div
      className={CONTAINER}
      style={{ maxWidth: maxWidth || '600px', width: '80vw' }}
    >
      {Icon}

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
            >{t('footer:poweredBy')}</span>

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
            >{t('imc:imc')}</span>
          </div>
        </div>
      </div>
    </div>
  )
}

AlertModalBody.propTypes = {
  logo: PropTypes.string.isRequired,
  t: PropTypes.string.isRequired,
  maxWidth: PropTypes.string,
  message: PropTypes.string.isRequired,
  toggleAlertModal: PropTypes.func.isRequired
}

AlertModalBody.defaultProps = {
  maxWidth: null
}

export default withNamespaces(['footer', 'imc'])(AlertModalBody)
