import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import { moment } from '../../../../constants'

export class ValidatorResult extends Component {
  static statusIcon (section) {
    let iconClass
    let iconStyle
    const { status, required } = section
    if (['no_data', 'expired'].includes(status)) {
      iconClass = 'exclamation-triangle'
      iconStyle = required ? styles.icon_severe : styles.icon_warning
    } else if (status === 'expiring_soon') {
      iconClass = 'question-circle'
      iconStyle = styles.icon_info
    } else {
      iconClass = 'check-circle-o'
      iconStyle = styles.icon_ok
    }

    return (<i className={`flex-20 fa fa-${iconClass} ${iconStyle}`} />)
  }

  constructor (props) {
    super(props)
    this.state = {

    }
  }

  renderContent (section) {
    const { t } = this.props
    const expiryValue = section.last_expiry ? moment(section.last_expiry).utc().format('ll') : t(`admin:expired`)

    return (
      <div className={`flex layout-row layout-wrap layout-align-center-center ${styles.section}`}>
        <div className={`flex-100 layout-row layout-align-start-center ${styles.section_title}`}>
          {ValidatorResult.statusIcon(section)}
          <p className="flex">
            {t(`admin:${section.key}`)}
          </p>
        </div>

        <p className={`flex-none center ${styles.section_data}`}>
          {`${t('admin:status')}: ${t(`admin:${section.status}`)} `}
        </p>
        <p className={`flex center ${styles.section_data}`}>
          {`${t('admin:nextExpiry')}: ${expiryValue} `}
        </p>
      </div>
    )
  }

  render () {
    const {
      data
    } = this.props
    const resultValues = ['origin_local_charges', 'freight', 'schedules', 'destination_local_charges'].map(k => ({ ...data[k], key: k }))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-space-around-center">
          { resultValues.map(section => this.renderContent(section))}
        </div>
      </div>
    )
  }
}

ValidatorResult.defaultProps = {
  theme: null,
  hubHash: {}
}

export default withNamespaces(['common', 'admin'])(ValidatorResult)
