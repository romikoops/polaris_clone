import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import defaults from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'
import Checkbox from '../Checkbox/Checkbox'
import { hsCodes } from '../../mocks'

class CustomsClearance extends Component {
  static displayCustomsFee (customsData, target, customs, t) {
    if (target === 'total') {
      let newTotal = 0
      if (customsData.import.bool && !get(customs, ['import', 'unknown'])) {
        newTotal += parseFloat(get(customs, ['import', 'total', 'value'], 0))
      }
      if (customsData.export.bool && !customs.export.unknown) {
        newTotal += parseFloat(customs.export.total.value)
      }
      if (newTotal === 0 && get(customs, ['import', 'unknown']) && get(customs, ['export', 'unknown'])) {
        return t('cargo:priceLocalRegulations')
      }

      return `${newTotal.toFixed(2)} ${customs.total.total.currency}`
    }
    if (customsData[target].bool) {
      if (customs) {
        const fee = customs[target]

        if (fee && !fee.unknown && fee.total.value) {
          return `${parseFloat(fee.total.value).toFixed(2)} ${fee.total.currency}`
        }

        return t('cargo:priceLocalRegulations')
      }
    }
    if (customsData[target].unknown) {
      return t('cargo:priceLocalRegulations')
    }

    return '0 EUR'
  }

  constructor (props) {
    super(props)
    this.state = {
      customsView: null
    }
  }

  toggleCustoms (bool) {
    this.setState({ customsView: bool })
  }

  render () {
    const {
      theme,
      t,
      tenant
    } = this.props

    const { scope, currency } = tenant

    const {
      customsView
    } = this.state

    return (
      <div className="flex-100 layout-row layout-align-center padd_top">
        <div
          className={`flex-none ${
            defaults.content_width
          } layout-row layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
            <div className="flex-none layout-row layout-align-space-around-center">
              <TextHeading
                theme={theme}
                size={2}
                text={t('cargo:customsClearance')}
                fontWeight="bold"
                color="#4F4F4F"
              />
            </div>
          </div>
          <div className="flex-60 layout-row layout-align-center-center layout-wrap">
            <p className="flex-100 margin_5">
              {t('cargo:customClearanceDescription')}
            </p>
          </div>
          <div
            className="flex-100 layout-wrap layout-row layout-align-space-around-center"
          >
            <div className="flex-100 layout-row layout-align-end-center padd_top">
              <div className="flex-20 layout-row layout-align-end-center">
                <Checkbox
                  id="yes_clearance"
                  className="ccb_yes_clearance padding"
                  onChange={() => this.toggleCustoms(true)}
                  checked={customsView}
                  theme={theme}
                />
              </div>
              <div className="flex-5" />
              <div className="flex-75 layout-row layout-align-start-center">
                <label htmlFor="yes_clearance" className="pointy">
                  <b>{t('common:yes')}</b>
                  {t('cargo:clearanceYes', {
                    tenantName: tenant.name,
                    clearanceFee: scope.customs_clearance_fee,
                    currency
                  })}
                  {(scope.hs_fee > 0) ? t('cargo:plusHS', {
                    hsFee: scope.hs_fee,
                    currency
                  }) : ''}
                </label>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-end-center">
              <div className="flex-20 layout-row layout-align-end-center padd_top">
                <Checkbox
                  id="no_clearance"
                  onChange={() => this.toggleCustoms(false)}
                  className="ccb_no_clearance"
                  checked={customsView === null ? null : !customsView}
                  theme={theme}
                />
              </div>
              <div className="flex-5" />
              <div className="flex-75 layout-row layout-align-start-center padding">
                <label htmlFor="no_clearance" className="pointy">
                  <b>{t('common:no')}</b>
                  {t('cargo:clearanceNo', { tenantName: tenant.name })}
                </label>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

export default withNamespaces(['common', 'cargo'])(CustomsClearance)
