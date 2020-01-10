import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import styles from './index.scss'
import AdminFeeTable from '../../Pricing/FeeTable'
import AdminRangeFeeTable from '../../Pricing/RangeTable'
import TruckingTableRateHeaders from '../../Trucking/Table/RateHeaders'
import AdminMarginPreviewMargins from './Margins'

class AdminMarginPreviewRate extends Component {
  constructor (props) {
    super(props)
    this.state = {
      hoverActive: {}
    }
  }

  selectView (target) {
    this.setState({ targetView: target }, () => (this.toggleHoverClass(target)))
  }

  toggleHoverClass (key) {
    this.setState(prevState => ({
      ...prevState,
      hoverActive: {
        ...prevState.hoverActive,
        [key]: !get(prevState, ['hoverActive', key], false)
      }
    }))
  }

  renderFeeTable (fee, localCharge) {
    const { t } = this.props

    if (
      Object.values(fee)
        .some(val => val.range && val.range.length > 0)
    ) {
      return (
        <div className="flex-100 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-aling-start-center ${styles.back_btn_row}`}>
            <div
              className={`flex-none layout-row layout-align-start-center ${styles.back_btn}`}
              onClick={() => this.selectView(false)}
            >
              <i className="fa fa-chevron-left" />
              <p className="flex-none">{t('common:basicBack')}</p>
            </div>
          </div>
          <AdminRangeFeeTable classes="flex-100" row={fee} isLocalCharge={localCharge} />
        </div>
      )
    }

    return (
      <div className="flex-100 layout-row layout-wrap">
        <div className={`flex-100 layout-row layout-aling-start-center ${styles.back_btn_row}`}>
          <div
            className={`flex-none layout-row layout-align-start-center ${styles.back_btn}`}
            onClick={() => this.selectView(false)}
          >
            <i className="fa fa-chevron-left" />
            <p className="flex-none">{t('common:basicBack')}</p>
          </div>
        </div>
        <AdminFeeTable classes="flex-100" row={fee} isLocalCharge={localCharge} />
      </div>
    )
  }

  renderRate (target) {
    const { type, rate, feeKey } = this.props

    if ( ['cargo', 'freight'].includes(type) && target !== 'margins') {
      return this.renderFeeTable({ [feeKey]: rate[target] }, false)
    }
    if (['import', 'export'].includes(type) && target !== 'margins') {
      return this.renderFeeTable({ [feeKey]: rate[target] }, true)
    }
    if (['trucking_pre', 'trucking_on'].includes(type) && target !== 'margins') {
      return (
        <TruckingTableRateHeaders
          truckingPricing={{ rates: rate[target] }}
          back={() => this.selectView(false)}
        />
      )
    }
    if (target === 'margins') {
      return (
        <AdminMarginPreviewMargins
          data={rate[target]}
          back={() => this.selectView(false)}
        />
      )
    }

    return ''
  }

  render () {
    const { t, rate } = this.props
    const { targetView, hoverActive } = this.state
    const showMargins = rate.margins.length > 0

    const listComp = (
      <div className="flex-100 layout-row layout-wrap layout-align-center-center">
        <div
          className={`flex-100 layout-row layout-align-center-center ${styles.rate_nav_buttons} ${hoverActive.original ? styles.hover : ''}`}
          onClick={() => this.selectView('original')}
          onMouseEnter={() => this.toggleHoverClass('original')}
          onMouseLeave={() => this.toggleHoverClass('original')}
        >
          <h3 className="flex-none">{t('rates:viewOriginal')}</h3>
        </div>
        <div
          className={`flex-100 layout-row layout-align-center-center ${styles.rate_nav_buttons} ${hoverActive.margins ? styles.hover : ''}`}
          onClick={showMargins ? () => this.selectView('margins') : null}
          onMouseEnter={() => this.toggleHoverClass('margins')}
          onMouseLeave={() => this.toggleHoverClass('margins')}
        >
          <h3 className="flex-none">{t(`rates:${showMargins ? 'viewMargins' : 'noMargins'}`)}</h3>
        </div>
        <div
          className={`flex-100 layout-row layout-align-center-center ${styles.rate_nav_buttons} ${hoverActive.final ? styles.hover : ''}`}
          onClick={() => this.selectView('final')}
          onMouseEnter={() => this.toggleHoverClass('final')}
          onMouseLeave={() => this.toggleHoverClass('final')}
        >
          <h3 className="flex-none">{t('rates:viewFinal')}</h3>
        </div>
      </div>

    )

    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          {targetView ? this.renderRate(targetView) : listComp}
        </div>
      </div>
    )
  }
}

export default withNamespaces(['admin', 'shipment'])(AdminMarginPreviewRate)
