import React, { Component } from 'react'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './LandingTop.scss'
import SquareButton from '../SquareButton'
import Header from '../Header/Header'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)),
    url(${props => props.bg});

  height: 100vh;
  background-size: cover;
  background-position: center;
  padding-bottom: 120px;
  box-shadow: 0px 1px 15px rgba(0, 0, 0, 0.7);
  position: relative;
`

export class LandingTop extends Component {
  constructor (props) {
    super(props)
    this.toAccount = this.toAccount.bind(this)
    this.toAdmin = this.toAdmin.bind(this)
  }
  toAccount () {
    this.props.goTo('/account')
  }
  toAdmin (target) {
    this.props.toAdmin(true)
  }
  render () {
    const {
      theme, user, tenant, bookNow
    } = this.props
    const myAccount = (
      <div className="flex">
        <SquareButton
          text="My Account"
          theme={theme}
          handleNext={() => this.toAccount()}
          size="small"
          active
        />
      </div>
    )
    const toAdmin = (
      <div className="flex">
        <SquareButton
          text="Admin Dashboard"
          theme={theme}
          handleNext={() => this.toAdmin()}
          size="small"
          active
        />
      </div>
    )
    const findRates = (
      <div className="flex">
        <SquareButton text="Find Rates" theme={theme} handleNext={bookNow} size="small" active />
      </div>
    )

    const loginLink = (
      <a
        onClick={this.props.toggleShowLogin}
      >
        Log In / Register
      </a>
    )

    const backgroundImage =
    theme && theme.background
      ? theme.background
      : 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'

    return (
      <StyledTop className="layout-row flex-100 layout-align-center" bg={backgroundImage}>
        <div className="layout-row flex-100 layout-wrap">
          <div className="flex-100 layout-row">
            <Header user={user} theme={theme} scrollable invert noMessages />
          </div>
          <div className="flex-50 layout-row layout-align-center layout-wrap">
            <div className="flex-100 layout-row layout-wrap layout-align-center-center">
              <div className={`flex-75 ${styles.banner_text}`}>
                <img
                  src="https://assets.itsmycargo.com/assets/images/logos/logo_white.png"
                  alt=""
                  className={`flex-none ${styles.tenant_logo_landing}`}
                />
                <h2 className="flex-none">
                  <b>Welcome to the </b> <br />
                  <i> {tenant.data.name} </i> <b> <br />
                  online freight calculator</b>
                </h2>
                <div className={styles.wrapper_hr}>
                  <hr />
                </div>
                <div className={styles.wrapper_h3}>
                  <h3 className="flex-none">
                    Enjoy the most advanced and easy to use <b>booking system</b> in
                    the market. Finally, shipping is as simple as it should be.
                  </h3>
                </div>
              </div>
              <div className={
                `${styles.wrapper_btns} flex-75 ` +
                'layout-row layout-align-start-center'
              }
              >
                {((user && user.role_id === 2) || !user) && findRates}
                {(!user || user.guest) && loginLink}
                {user && !user.guest && user.role_id === 2 && myAccount}
                {user && user.role_id === 1 && toAdmin}
              </div>
              <div className={`flex-70 ${styles.banner_text}`}>
                <div className="flex-none layout-row layout-align-start-center">
                  <h4 className="flex-none">powered by</h4>
                  <div className="flex-5" />
                  <img
                    src="https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png"
                    alt=""
                    className={`flex-none ${styles.powered_by_logo}`}
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </StyledTop>
    )
  }
}

LandingTop.propTypes = {
  theme: PropTypes.theme,
  goTo: PropTypes.func.isRequired,
  toAdmin: PropTypes.func.isRequired,
  user: PropTypes.user,
  tenant: PropTypes.tenant,
  toggleShowLogin: PropTypes.func,
  bookNow: PropTypes.func
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  toggleShowLogin: null,
  bookNow: null
}

export default LandingTop
