import React from 'react'
import PropTypes from '../../prop-types'
import styles from './CookieConsentBar.scss'
import ConsentButton from './ConsentButton'
import { Modal } from '../Modal/Modal'
import { moment } from '../../constants'

function handleAccept (user, tenant, loggedIn, authDispatch) {
  if (loggedIn) {
    authDispatch.updateUser(user, { cookie_consent: true })
  } else {
    const unixTimeStamp = moment().unix().toString()
    const randNum = Math.floor(Math.random() * 100).toString()
    const randSuffix = unixTimeStamp + randNum
    const email = `guest${randSuffix}@${tenant.data.subdomain}.com`

    authDispatch.register({
      email,
      password: 'guestpassword',
      password_confirmation: 'guestpassword',
      first_name: 'Guest',
      last_name: '',
      tenant_id: tenant.data.id,
      guest: true,
      cookie_consent: true
    })
  }
}

export default class CookieConsentBar extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      showModal: false
    }
    this.toggleShowModal = this.toggleShowModal.bind(this)
    this.handleDecline = this.handleDecline.bind(this)
  }
  handleDecline () {
    this.setState({ showModal: true })
  }

  toggleShowModal () {
    this.setState(prevState => ({ showModal: !prevState.showModal }))
  }

  render () {
    const {
      user,
      theme,
      tenant,
      loggedIn,
      authDispatch
    } = this.props

    const modal = (
      <Modal
        component={
          <div className={styles.cookie_modal} >
            <p>We use cookies to enhance your user experience. <br /><br />
            The consense is not mandatory but necessary to continue using our website.
            Are you sure you want to decline the usage of cookies?</p>
            <ConsentButton
              theme={theme}
              handleNext={() => handleAccept(user, tenant, loggedIn, authDispatch)}
              text="ok, accept"
              active
            />
            <ConsentButton
              theme={theme}
              handleNext={() => { window.open('https://www.itsmycargo.com/') }}
              text="cookies policy"
              active
            />
          </div>
        }
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleShowModal}
      />
    )

    if (!tenant) return ''

    const cookieBackground = theme && theme.colors ? theme.colors.secondary : '#aaa'
    return (
      <div
        className={`${styles.cookie_flex} ${user && user.cookie_consent ? styles.hidden : ''}`}
        style={{ background: cookieBackground, filter: 'grayscale(60%)' }}
      >
        { this.state.showModal && modal}
        <p className={styles.cookie_text}>
          This website uses cookies to enhance your user experience. <a href="https://www.itsmycargo.com/" target="_blank">Learn more</a>
        </p>

        <ConsentButton
          theme={theme}
          handleNext={() => handleAccept(user, tenant, loggedIn, authDispatch)}
          text="accept"
          active
        />
        <ConsentButton
          theme={theme}
          handleNext={this.handleDecline}
          text="decline"
          active
        />
      </div>
    )
  }
}

CookieConsentBar.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user,
  loggedIn: PropTypes.bool,
  authDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  tenant: PropTypes.tenant
}

CookieConsentBar.defaultProps = {
  tenant: null,
  user: null,
  loggedIn: false,
  theme: {}
}

// buttonText = {< i className = {`${styles.cookie_exit_icon} fa fa-times`} />}
// buttonStyle = {{ color: 'white', background: 'unset' }}
//
