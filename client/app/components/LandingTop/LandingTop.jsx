import React, { Component } from 'react'
import styled from 'styled-components'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './LandingTop.scss'
import SquareButton from '../SquareButton'
import Header from '../Header/Header'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)),
    url(${props => props.bg});
  height: 100vh;
  background-size: cover;
  background-attachment: fixed;
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
      theme, user, tenant, bookNow, t, toggleShowLogin
    } = this.props
    const myAccount = (
      <div className="flex">
        <SquareButton
          text={t('common:accountTitle')}
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
          text={t('landing:adminDashboard')}
          theme={theme}
          handleNext={() => this.toAdmin()}
          size="small"
          active
        />
      </div>
    )
    const findRates = (
      <div className="flex">
        <SquareButton text={t('landing:callToAction')} theme={theme} handleNext={bookNow} size="small" active />
      </div>
    )
    const loginLink = <a onClick={this.props.toggleShowLogin}>Log In / Register</a>
    const backgroundImage =
      theme && theme.background
        ? theme.background
        : 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'

    const largeLogo = theme && theme.logoLarge ? theme.logoLarge : ''
    const whiteLogo = theme && theme.logoWhite ? theme.logoWhite : largeLogo
    const welcomeTextTail = theme && theme.welcome_text ? theme.welcome_text : t('landing:welcomeTextTail')

    const description = () => {
      const head = t('landing:descriptionHead')
      const middle = t('landing:descriptionMiddle')
      const tail = t('landing:descriptionTail')
      
      return (<React.Fragment>
        {head}<b>{middle}</b>{tail}
      </React.Fragment>)
    }

    return (
      <StyledTop className="layout-row flex-100 layout-align-center" bg={backgroundImage}>
        <div className="layout-row flex-100 layout-wrap">
          <div className="flex-100 layout-row">
            <Header user={user} theme={theme} toggleShowLogin={toggleShowLogin} scrollable invert noMessages />
          </div>
          <div className="flex-50 layout-row layout-align-center layout-wrap">
            <div className={`${styles.content_wrapper} flex-100 layout-row layout-wrap layout-align-center-center`}>
              <div className={`flex-75 ${styles.banner_text}`}>
                <img
                  src={whiteLogo}
                  alt=""
                  className={`flex-none ${styles.tenant_logo_landing}`}
                />
                <h2 className="flex-none">
                  <b>{t('landing:welcomeTextHead')} </b> <br />
                  <i> {tenant.data.name} </i> <b> <br />
                    {welcomeTextTail}</b>
                </h2>
                <div className={styles.wrapper_hr}>
                  <hr />
                </div>
                <div className={styles.wrapper_h3}>
                  <h3 className="flex-none">
                    {description()}
                  </h3>
                </div>
              </div>
              <div
                className={
                  `layout-row layout-align-start-center ${styles.wrapper_btns} flex-70 `
                }
              >
                {((user && user.role && user.role.name === 'shipper') || !user) && findRates}
                {(!user || user.guest) && loginLink}
                {user && !user.guest && user.role && user.role.name === 'shipper' && myAccount}
                {user && user.role && user.role.name === 'admin' && toAdmin}
              </div>
              <div className={`flex-70 ${styles.banner_text}`}>
                <div className="flex-none layout-row layout-align-start-center">
                  <h4 className="flex-none">{t('landing:094ae8a8-c7b3-49bc-b4b7-8bf3fef33d7b')}</h4>
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
  bookNow: PropTypes.func,
  t: PropTypes.func
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  toggleShowLogin: null,
  bookNow: null,
  t: null
}

export default translate(['landing', 'common'])(LandingTop)
