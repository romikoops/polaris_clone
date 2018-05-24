import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './index.scss'

class OptOutTenant extends Component {
  constructor (props) {
    super(props)
    this.state = { }
    this.handleOptOut = this.handleOptOut.bind(this)
  }
  handleOptOut () {
    const { userDispatch, user } = this.props
    userDispatch.optOut(user.id, 'tenant')
  }
  render () {
    const { theme, tenant } = this.props
    if (!tenant.data) {
      return ''
    }
    return (
      <div className={`${styles.container} flex-none layout-row layout-align-center-center layout-wrap`}>
        <div className="flex-100 layout-row layout-align-start-center">
          <h3 className="flex-none">{tenant.data.name} Terms & Conditions</h3>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100">
            {` Use of the ${tenant.data.name} ItsMyCargo webshop requires
             accepting the terms and conditions laid out by ${tenant.data.name}.`}
          </p>
          <p className="flex-100">
            As such if you decide to withdraw your agreement to the terms and
              conditions you will not be
             able to continue using the shop and we will have to close the window
          </p>
          <p className="flex-100">
            {`Should you wish to resume using one of the ${tenant.data.name} ItsMyCargo Shop you will need to 
            agree to the terms and conditions again`}
          </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-aling-center-center">
          <p className="flex-100">
            By clicking the Opt Out button below the follwoing will happen:
          </p>
          <ul className="flex-100">
            <li> {`Your user account will be marked as not agreeing to the ${tenant.data.name} terms and conditions`}</li>
            <li> You will be logged out and returned to the landing page</li>
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

OptOutTenant.propTypes = {
  user: PropTypes.user.isRequired,
  theme: PropTypes.theme,
  tenant: PropTypes.tenant,
  userDispatch: PropTypes.shape({
    optOut: PropTypes.func
  }).isRequired
}

OptOutTenant.defaultProps = {
  theme: null,
  tenant: {}
}

export default OptOutTenant
