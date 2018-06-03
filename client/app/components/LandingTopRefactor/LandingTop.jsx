import React, { Component } from 'react'
import styled from 'styled-components'

import Header from '../Header/Header'
import PropTypes from '../../prop-types'
import SquareButton from '../SquareButton'
import styles from './LandingTop.scss'
import { ROW, WRAP_ROW, ALIGN_CENTER, ALIGN_START_CENTER } from '../../classNames'

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

const fallbackBackground = 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'
const poweredByLogo = 'https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png'
const CONTAINER = `LANDING_TOP ${ROW(100)} layout-align-center`

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
      bookNow,
      tenant,
      theme,
      user
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

    const loginLink = <a onClick={this.props.toggleShowLogin}>Log In / Register</a>

    const backgroundImage =
      theme && theme.background
        ? theme.background
        : fallbackBackground

    const largeLogo = theme && theme.logoLarge ? theme.logoLarge : ''
    const whiteLogo = theme && theme.logoWhite ? theme.logoWhite : largeLogo
    const welcomeText = theme && theme.welcome_text
      ? theme.welcome_text
      : 'shop for online freight'

    const Welcome = (
      <div className={`flex-75 ${styles.banner_text}`}>
        <img
          src={whiteLogo}
          alt=""
          className={`flex-none ${styles.tenant_logo_landing}`}
        />
        <h2 className="flex-none">
          <b>Welcome to the </b> <br />
          <i> {tenant.data.name} </i> <b> <br />
            {welcomeText}</b>
        </h2>
        <div className={styles.wrapper_hr}>
          <hr />
        </div>
        <div className={styles.wrapper_h3}>
          <h3 className="flex-none">
            Enjoy the most advanced and easy to use <b>booking system</b> in the market.
            Finally, shipping is as simple as it should be.
          </h3>
        </div>
      </div>
    )
    const UserInfo = (
      <div className={`${ROW(70)} ${ALIGN_START_CENTER} ${styles.wrapper_btns}`}>
        {((user && user.role_id === 2) || !user) && findRates}
        {(!user || user.guest) && loginLink}
        {user && !user.guest && user.role_id === 2 && myAccount}
        {user && user.role_id === 1 && toAdmin}
      </div>
    )
    const PoweredBy = (
      <div className={`flex-70 ${styles.banner_text}`}>
        <div className="flex-none layout-row layout-align-start-center">
          <h4 className="flex-none">powered by</h4>
          <div className="flex-5" />
          <img
            alt=""
            className={`flex-none ${styles.powered_by_logo}`}
            src={poweredByLogo}
          />
        </div>
      </div>
    )

    return (
      <StyledTop className={CONTAINER} bg={backgroundImage}>
        <div className={WRAP_ROW(100)}>
          <div className={ROW(100)}>
            <Header user={user} theme={theme} scrollable invert noMessages />
          </div>

          <div className={`${WRAP_ROW(50)} layout-align-center`}>
            <div className={`${styles.content_wrapper} ${WRAP_ROW(100)} ${ALIGN_CENTER}`}>
              {Welcome}
              {UserInfo}
              {PoweredBy}
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
