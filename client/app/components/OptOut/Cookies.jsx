import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './index.scss'

class OptOutCookies extends Component {
  constructor (props) {
    super(props)
    this.state = { }
    this.handleOptOut = this.handleOptOut.bind(this)
  }
  handleOptOut () {
    const { userDispatch, user } = this.props
    userDispatch.optOut(user.id, 'cookies')
  }
  render () {
    const { theme } = this.props

    return (
      <div className={`${styles.container} flex-none layout-row layout-align-center-center layout-wrap`}>
        <div className="flex-100 layout-row layout-align-start-center">
          <h3 className="flex-none">Cookies</h3>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100">
            All ItsMyCargo webshops use Cookies to help make our services better.
          </p>
          <p className="flex-100">
            Though we do not use cookies to track your movements through out the web we do need to
             save some information about your profile and the data you are accessing in the browser.
             This information is vital to the functioning of the site.
          </p>
          <p className="flex-100">
            As such if you decide to withdraw your consent to the use of cookies you will not be
             able to continue using the shop and we will have to close the window
          </p>
          <p className="flex-100">
            Should you wish to resume using one of the ItsMyCargo Shops you will need to consent
             to the use of cookies again
          </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-aling-center-center">
          <p className="flex-100">
            By clicking the Opt Out button below the follwoing will happen:
          </p>
          <ul className="flex-100">
            <li> Your user account will be marked as not consenting to the use of cookies</li>
            <li> You will be logged out and the browser window will close</li>
          </ul>
        </div>
        <div className="flex-100 layout-row layout-align-space-around-center">
          <div className="flex-60 layout-row layout-align-start-center">
            <h4 className="flex-none">Are you sure?</h4>
          </div>
          <div className="flex-40 layout-row layout-align-start-center">
            <RoundButton theme={theme} handleNext={this.handleOptOut} active text="Opt Out" />
          </div>
        </div>
      </div>
    )
  }
}

OptOutCookies.propTypes = {
  user: PropTypes.user.isRequired,
  theme: PropTypes.theme,
  userDispatch: PropTypes.shape({
    optOut: PropTypes.func
  }).isRequired
}

OptOutCookies.defaultProps = {
  theme: null
}

export default OptOutCookies
