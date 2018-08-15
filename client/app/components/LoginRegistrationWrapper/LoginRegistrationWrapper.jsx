import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './LoginRegistrationWrapper.scss'
import defs from '../../styles/default_classes.scss'
import { LoginPage } from '../../containers/LoginPage/LoginPage'
import { RegistrationPage } from '../../containers/RegistrationPage/RegistrationPage'

export class LoginRegistrationWrapper extends Component {
  constructor (props) {
    super(props)
    this.state = {}
    this.components = { LoginPage, RegistrationPage }
    this.togglePrompt = {
      LoginPage: {
        promptText: 'New account?',
        linkText: 'Register'
      },
      RegistrationPage: {
        promptText: 'Already have an account?',
        linkText: 'Login'
      }
    }
  }

  toggleComp (currentCompName) {
    if (this.props.updateDimensions != null) this.props.updateDimensions()

    const nextCompName = currentCompName === 'LoginPage' ? 'RegistrationPage' : 'LoginPage'
    this.setState({
      compName: nextCompName
    })
  }
  render () {
    const compName = this.state.compName ? this.state.compName : this.props.initialCompName
    const Comp = this.components[compName]
    const compProps = this.props[`${compName}Props`]

    const textStyling =
      navigator.userAgent.indexOf('MSIE') !== -1 || !!document.documentMode === true
        ? `${styles.ie_11} layout-row layout-align-space-between`
        : 'layout-row layout-align-space-between'

    return (
      <div style={{ color: 'black' }}>
        <div>
          <Comp {...compProps} />
        </div>
        <hr className={styles.toggle_prompt_separator} />
        <div className={textStyling}>
          <div>{this.togglePrompt[compName].promptText}</div>
          <div className={`${defs.emulate_link}`} onClick={() => this.toggleComp(compName)}>
            {this.togglePrompt[compName].linkText}
          </div>
        </div>
      </div>
    )
  }
}

LoginRegistrationWrapper.propTypes = {
  initialCompName: PropTypes.string.isRequired,
  LoginPageProps: PropTypes.objectOf(PropTypes.any),
  RegistrationPageProps: PropTypes.objectOf(PropTypes.any),
  updateDimensions: PropTypes.func
}

LoginRegistrationWrapper.defaultProps = {
  LoginPageProps: {},
  RegistrationPageProps: {},
  updateDimensions: null
}

export default LoginRegistrationWrapper
