import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './LoginRegistrationWrapper.scss'
import { LoginPage } from '../../containers/LoginPage/LoginPage'
import { RegistrationPage } from '../../containers/RegistrationPage/RegistrationPage'

class LoginRegistrationWrapper extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
    this.components = { LoginPage, RegistrationPage }
    const { t } = this.props
    this.togglePrompt = {
      LoginPage: {
        promptText: t('account:newAccount'),
        linkText: t('common:register')
      },
      RegistrationPage: {
        promptText: t('account:existingAccount'),
        linkText: t('common:logIn')
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

    let togglePromptClasses = `${styles.toggle_prompt} layout-row layout-align-space-between`
    if (navigator.userAgent.indexOf('MSIE') !== -1 || document.documentMode) {
      togglePromptClasses += ` ${styles.ie_11}`
    }

    return (
      <div>
        <div>
          <Comp {...compProps} />
        </div>
        <hr className={styles.toggle_prompt_separator} />
        <div className={togglePromptClasses}>
          <div>{this.togglePrompt[compName].promptText}</div>
          <div className="emulate_link" onClick={() => this.toggleComp(compName)}>
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
  t: PropTypes.func.isRequired,
  updateDimensions: PropTypes.func
}

LoginRegistrationWrapper.defaultProps = {
  LoginPageProps: {},
  RegistrationPageProps: {},
  updateDimensions: null
}

export default translate(['common', 'account'])(LoginRegistrationWrapper)
