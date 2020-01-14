import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get, has } from 'lodash'
import defaults from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'
import CustomsToggle from './CustomsToggle'
import { numberSpacing } from '../../helpers'

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
      customsViewImport: null,
      customsViewExport: null
    }

    this.toggleCustoms = this.toggleCustoms.bind(this)
    this.toggleTargetCustoms = this.toggleTargetCustoms.bind(this)
  }

  toggleCustoms (bool, target) {
    if (target === 'export') {
      this.setState({ customsViewExport: bool })
    } else {
      this.setState({ customsViewImport: bool })
    }
    this.toggleTargetCustoms(target)
  }

  toggleTargetCustoms (target) {
    const {
      setCustomsFee,
      customsData,
      shipmentData
    } = this.props
    const { customs } = shipmentData
    if (!has(customs, [target, 'total', 'value'])) {
      return
    }
    const resp = customsData[target].bool
      ? { bool: false, val: 0 }
      : {
        bool: true,
        val: numberSpacing(customs[target].total.value, 2),
        currency: customs[target].total.currency
      }
    setCustomsFee(target, resp)
  }

  render () {
    const {
      theme,
      t,
      tenant,
      shipmentData
    } = this.props
    const { customs } = shipmentData
    const {
      customsViewImport,
      customsViewExport
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
          {
            customs.export && (
              <CustomsToggle
                t={t}
                tenant={tenant}
                toggleCustoms={this.toggleCustoms}
                customsFee={get(customs, ['export', 'total'])}
                customsView={customsViewExport}
                target="export"
                port={shipmentData.shipment.origin_nexus.name}
              />
            )
          }
          {
            customs.import && (
              <CustomsToggle
                t={t}
                tenant={tenant}
                toggleCustoms={this.toggleCustoms}
                customsFee={get(customs, ['import', 'total'])}
                customsView={customsViewImport}
                target="import"
                port={shipmentData.shipment.destination_nexus.name}
              />
            )}
        </div>
      </div>
    )
  }
}

export default withNamespaces(['common', 'cargo'])(CustomsClearance)
