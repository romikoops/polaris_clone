import React, { Component } from 'react'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './LandingTop.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import Header from '../Header/Header'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)),
    url(${props => props.bg});

  height: 550px;
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
      <RoundButton text="My Account" theme={theme} handleNext={() => this.toAccount()} active />
    )

    const toAdmin = (
      <RoundButton text="Admin Dashboard" theme={theme} handleNext={() => this.toAdmin()} active />
    )
    const backgroundImage =
      theme && theme.background
        ? theme.background
        : 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'
    return (
      <StyledTop className="layout-row flex-100 layout-align-center" bg={backgroundImage}>
        <div className={styles.top_shade} />
        <div className={styles.top_mask} />
        <div className="layout-row flex-100 layout-wrap">
          <div className={`${styles.top_row} flex-100 layout-row`}>
            <Header user={user} theme={theme} scrollable invert noMessages />
          </div>
          <div
            className={`flex-100 flex-gt-sm-50 layout-column layout-align-space-around-center ${
              styles.layout_elem
            } ${styles.responsive}`}
          >
            {(user && user.role_id === 2) || !user ? (
              <RoundButton text="Find Rates" theme={theme} handleNext={bookNow} active />
            ) : (
              ''
            )}
            {user && !user.guest && user.role_id === 2 ? myAccount : ''}
            {user && user.role_id === 1 ? toAdmin : ''}
          </div>
          <div
            className={`flex-100 flex-gt-sm-50 layout-row layout-align-center-center ${
              styles.layout_elem
            }`}
          >
            <div className={styles.sign_up}>
              <h2 className="flex-none">
                {`Welcome to the ${tenant.data.name} Shop for online freight`}
              </h2>
              <h3 className="flex-none">
                Enjoy the most advanced and easy to use booking system in the market. Finally,
                shipping is as simple as it should be.
              </h3>
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
  bookNow: PropTypes.func
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  bookNow: null
}

export default LandingTop
