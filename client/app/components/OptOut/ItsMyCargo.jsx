import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from 'prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './index.scss'

class OptOutItsMyCargo extends Component {
  constructor (props) {
    super(props)
    this.state = { }
    this.handleOptOut = this.handleOptOut.bind(this)
  }
  handleOptOut () {
    const { userDispatch, user } = this.props
    userDispatch.optOut(user.id, 'itsmycargo')
  }
  render () {
    const { theme, tenant, t } = this.props
    if (!tenant.data) {
      return ''
    }

    return (
      <div className={`${styles.container} flex-none layout-row layout-align-center-center layout-wrap`}>
        <div className="flex-100 layout-row layout-align-start-center">
          <h3 className="flex-none">{t('imc:imcTerms')}</h3>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100">
            {t('optout:useOfAny')}{t('optout:useRequiredIMC')}
          </p>
          <p className="flex-100">
            {t('optout:withdrawWarningHead')}{t('optout:withdrawWarningTail')}
          </p>
          <p className="flex-100">
            {t('optout:agreeAgainHead')}{t('optout:agreeAgainGeneral')}
          </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-aling-center-center">
          <p className="flex-100">
            {t('optout:optOutActionHead')}
          </p>
          <ul className="flex-100">
            <li>{t('optout:accountMarked')}{t('imc:imcTerms')}</li>
            <li>{t('optout:optOutActionTail')}</li>
          </ul>
        </div>
        <div className="flex-100 layout-row layout-align-space-around-center">
          <div className="flex-60 layout-row layout-align-start-center">
            <h4 className="flex-none">{t('common:areYouSure')}</h4>
          </div>
          <div className="flex-40 layout-row layout-align-start-center">
            <RoundButton theme={theme} handleNext={this.handleOptOut} active text={t('common:optOut')} />
          </div>
        </div>
      </div>
    )
  }
}

OptOutItsMyCargo.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  tenant: PropTypes.tenant,
  userDispatch: PropTypes.shape({
    optOut: PropTypes.func
  }).isRequired
}

OptOutItsMyCargo.defaultProps = {
  theme: null,
  tenant: {}
}

export default translate(['common', 'optout', 'imc'])(OptOutItsMyCargo)
