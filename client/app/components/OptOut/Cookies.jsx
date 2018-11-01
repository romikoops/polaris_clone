import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import styles from './index.scss'

class OptOutCookies extends Component {
  constructor (props) {
    super(props)
    this.state = { }
    this.handleOptOut = this.handleOptOut.bind(this)
  }
  handleOptOut () {
    const { userDispatch, user } = this.props
    userDispatch.optOut(user.id, 'cookies')
  }
  render () {
    const { theme, t } = this.props

    return (
      <div className={`${styles.container} flex-none layout-row layout-align-center-center layout-wrap`}>
        <div className="flex-100 layout-row layout-align-start-center">
          <h3 className="flex-none">{t('cookies:cookies')}</h3>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-100">
            {t('cookies:allWebshops')}
          </p>
          <p className="flex-100">
            {t('cookies:reasonsForCookiesHead')}
            {t('cookies:reasonsForCookiesTail')}
            {t('cookies:infoIsVital')}
          </p>
          <p className="flex-100">
            {t('cookies:useDiscontinuedHead')}
            {t('cookies:useDiscontinuedTail')}
          </p>
          <p className="flex-100">
            {t('cookies:useContinued')}
          </p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-aling-center-center">
          <p className="flex-100">
            {t('optout:optOutActionHead')}
          </p>
          <ul className="flex-100">
            <li>{t('optout:nonConsenting')}</li>
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

OptOutCookies.propTypes = {
  user: PropTypes.user.isRequired,
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    optOut: PropTypes.func
  }).isRequired
}

OptOutCookies.defaultProps = {
  theme: null
}

export default withNamespaces(['cookies', 'optOut'])(OptOutCookies)
