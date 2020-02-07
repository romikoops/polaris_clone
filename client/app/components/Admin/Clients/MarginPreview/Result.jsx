import React, { Component } from 'react'
import { get, has } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import Modal from '../../../Modal/Modal'
import AdminMarginPreviewRate from './Rate'
import { numberSpacing } from '../../../../helpers'
import ResultSection from './ResultSection'

class AdminMarginPreviewResult extends Component {
  constructor (props) {
    super(props)
    this.state = {
      hoverActive: {},
      selectedRate: false
    }
    this.viewRate = this.viewRate.bind(this)
  }

  toggleHoverClass (feeKey) {
    this.setState(prevState => ({
      ...prevState,
      hoverActive: {
        ...prevState.hoverActive,
        [feeKey]: !get(prevState, ['hoverActive', feeKey], false)
      }
    }))
  }

  viewRate (sectionKey, feeKey) {
    this.setState({ targetSectionKey: sectionKey, targetRateKey: feeKey })
  }

  renderSection (sectionKey) {
    const { result } = this.props

    return <ResultSection section={result[sectionKey]} sectionKey={sectionKey} viewRate={this.viewRate} />
  }

  render () {
    const { targetSectionKey, targetRateKey } = this.state
    const { tenant, result, t } = this.props
    const selectedRate = get(result, [targetSectionKey, 'fees', targetRateKey], false)
    const { theme } = tenant
    const sectionKeys = ['trucking_pre', 'export', 'freight', 'import', 'trucking_on']

    const rateModal = selectedRate ? (
      <Modal
        component={(
          <AdminMarginPreviewRate
            theme={theme}
            rate={selectedRate}
            type={targetSectionKey}
            price={{ name: targetRateKey }}
          />
        )}
        minWidth="400px"
        minHeight="400px"
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={() => this.viewRate(false, false)}
      />
    ) : ''

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.result_wrapper}`}>
        {rateModal}
        <div className="flex-100 layout-row layout-align-start-center">
          <div className={`flex-20 center ${styles.service_level}`}>
            <p className="flex-none">{`${t('shipment:serviceLevel')}:  ${get(result, ['trucking_pre', 'service_level'], 'N/A')}`}</p>
          </div>
          <div className={`flex-60 center ${styles.service_level} ${styles.service_level_main}`}>
            <p className="flex-none">{`${t('shipment:serviceLevel')}:  ${get(result, ['freight', 'service_level'], 'N/A')}`}</p>
          </div>
          <div className={`flex-20 center ${styles.service_level}`}>
            <p className="flex-none">{`${t('shipment:serviceLevel')}:  ${get(result, ['trucking_on', 'service_level'], 'N/A')}`}</p>
          </div>
        </div>
        <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.section_container}`}>
          {sectionKeys.map(sectionKey => <ResultSection section={result[sectionKey]} sectionKey={sectionKey} viewRate={this.viewRate} />)}
        </div>
      </div>
    )
  }
}

export default withNamespaces(['admin', 'shipment'])(AdminMarginPreviewResult)
