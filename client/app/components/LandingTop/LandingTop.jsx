import React, { Component } from 'react'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './LandingTop.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import Header from '../Header/Header'
import { moment } from '../../constants'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(black, 0.3), rgba(black, 0.3));
  background-image: url(${props => props.bg});

  height: 65vh;
  background-size: cover;
  background-position: center;
  padding-bottom: 120px;
  box-shadow: 0px 1px 15px rgba(black, 0.7);
  position: relative;
`

export class LandingTop extends Component {
  constructor (props) {
    super(props)
    this.toAccount = this.toAccount.bind(this)
    this.toBooking = this.toBooking.bind(this)
    this.toAdmin = this.toAdmin.bind(this)
  }
  toAccount () {
    this.props.goTo('/account')
  }
  toAdmin (target) {
    this.props.toAdmin(true)
  }
  toBooking () {
    this.props.goTo('/booking')
  }
  render () {
    const { authDispatch, theme, user } = this.props
    const handleNext = () => {
      if (this.props.loggedIn) {
        this.toBooking()
      } else {
        const unixTimeStamp = moment()
          .unix()
          .toString()
        const randNum = Math.floor(Math.random() * 100).toString()
        const randSuffix = unixTimeStamp + randNum
        const email = `guest${randSuffix}@${this.props.tenant.data.subdomain}.com`

        authDispatch.register(
          {
            email,
            password: 'guestpassword',
            password_confirmation: 'guestpassword',
            first_name: 'Guest',
            last_name: '',
            tenant_id: this.props.tenant.data.id,
            guest: true
          },
          true
        )
      }
    }
    const myAccount = (
      <RoundButton text="My Account" theme={theme} handleNext={() => this.toAccount()} active />
    )

    const toAdmin = (
      <RoundButton text="Admin Dashboard" theme={theme} handleNext={this.toAdmin} active />
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
            <Header user={user} theme={theme} scrollable invert />
          </div>
          <div className={`flex-100 flex-gt-sm-50 layout-column layout-align-space-around-center ${styles.layout_elem}`}>
            {(user && user.role_id === 2) || !user ? (
              <RoundButton text="Book Now" theme={theme} handleNext={handleNext} active />
            ) : (
              ''
            )}
            {user && !user.guest && user.role_id === 2 ? myAccount : ''}
            {user && user.role_id === 1 ? toAdmin : ''}
          </div>
          <div className={`flex-100 flex-gt-sm-50 layout-row layout-align-center-end ${styles.layout_elem}`}>
            <div className={styles.sign_up}>
              <h2>Never spend precious time on transportation again, shipping made simple</h2>
              <h3>Enjoy the most advanced and easy to use booking system in the market</h3>
              <div className="flex-none layout-row layout-align-start-center">
                <p className="flex-none">powered by</p>
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
  loggedIn: PropTypes.bool,
  tenant: PropTypes.tenant,
  authDispatch: PropTypes.shape({
    register: PropTypes.func
  }).isRequired
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  loggedIn: false,
  tenant: null
}

export default LandingTop
