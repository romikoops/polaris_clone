import React from 'react'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator } from '../../../helpers'

export function IncotermRow ({
  theme,
  shipment,
  onCarriage,
  preCarriage,
  originFees,
  destinationFees,
  feeHash,
  tenant
}) {
  const sumCargoFees = (cargos) => {
    let total = 0.0
    let curr = ''
    if (!cargos) {
      return ''
    }
    Object.keys(cargos).forEach((k) => {
      total += parseFloat(cargos[k].total.value)
      curr = cargos[k].total.currency
    })

    return { currency: curr, total: total.toFixed(2) }
  }

  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const deselectedStyle = {
    ...gradientTextGenerator('rgb(0, 0, 0)', 'rgb(25, 25, 25)'),
    opacity: '0.5'
  }
  const { scope } = tenant.data
  const preCarriageStyle = preCarriage ? selectedStyle : deselectedStyle
  const onCarriageStyle = onCarriage ? selectedStyle : deselectedStyle
  const originDocumentStyle = originFees ? selectedStyle : deselectedStyle
  const destinationDocumentStyle = destinationFees ? selectedStyle : deselectedStyle
  const customsStyle = feeHash && feeHash.customs && feeHash.customs.total
    ? selectedStyle : deselectedStyle
  const insuranceStyle = feeHash && feeHash.insurance && feeHash.insurance.total
    ? selectedStyle : deselectedStyle
  const freightStyle = selectedStyle

  const freightFeesValue = feeHash && feeHash.cargo ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      <p className="flex-none no_m letter_3 center">{sumCargoFees(feeHash.cargo).currency}</p>
      <p className="flex-none no_m letter_3 center">{sumCargoFees(feeHash.cargo).total}</p>
    </div>
  ) : ''
  const originFeesValue = feeHash && feeHash.export ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.export.total ? (
        <p className="flex-none no_m letter_3 center">{feeHash.export.total.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {feeHash.export.total ? `${feeHash.export.total.value.toFixed(2)}` : 'None'}
      </p>
    </div>
  ) : ''
  const destinationFeesValue = feeHash && feeHash.import ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.import.total ? (
        <p className="flex-none no_m letter_3 center">{feeHash.import.total.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {feeHash.import.total ? `${feeHash.import.total.value.toFixed(2)}` : 'None'}
      </p>
    </div>
  ) : ''
  const preCarriageFeesValue = feeHash && feeHash.trucking_pre ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.trucking_pre.total ? (
        <p className="flex-none no_m letter_3 center">{feeHash.trucking_pre.total.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {preCarriage ? `${feeHash.trucking_pre.total.value.toFixed(2)}` : 'None'}
      </p>
    </div>
  ) : ''
  const onCarriageFeesValue = feeHash && feeHash.trucking_on ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.trucking_on.total ? (
        <p className="flex-none no_m letter_3 center">{feeHash.trucking_on.total.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {onCarriage ? `${feeHash.trucking_on.total.value.toFixed(2)}` : 'None'}
      </p>
    </div>
  ) : ''
  const insuranceFeesValue = feeHash ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.insurance && feeHash.insurance.val ? (
        <p className="flex-none no_m letter_3 center">{feeHash.insurance.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {feeHash.insurance && feeHash.insurance.val
          ? `${feeHash.insurance.val.toFixed(2)}`
          : 'None'}
      </p>
    </div>
  ) : ''
  const customsFeesValue = feeHash ? (
    <div className={`${styles.fee_value} flex-none width_100 layout-row layout-align-center-center layout-wrap`}>
      {feeHash.customs && feeHash.customs.val ? (
        <p className="flex-none no_m letter_3 center">{feeHash.customs.currency}</p>
      ) : ''}
      <p className="flex-none no_m letter_3 center">
        {feeHash.customs && feeHash.customs.val ? `${feeHash.customs.val.toFixed(2)}` : 'None'}
      </p>
    </div>
  ) : ''
  const preCarriageFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-truck clip flex-none" style={preCarriageStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m">Pre-Carriage</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? preCarriageFeesValue : ''}
    </div>
  )
  const onCarriageFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className={`fa fa-truck clip flex-none ${styles.dest_truck}`} style={onCarriageStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m">On-Carriage</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? onCarriageFeesValue : ''}
    </div>
  )
  const originFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-file-text clip flex-none" style={originDocumentStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m center">Origin <br /> Documentation</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? originFeesValue : ''}
    </div>
  )
  const destinationFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-file-text-o clip flex-none" style={destinationDocumentStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m center">Destination <br /> Documentation</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? destinationFeesValue : ''}
    </div>
  )
  const freightFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-ship clip flex-none" style={freightStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m">Freight</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? freightFeesValue : ''}
    </div>
  )
  const customsFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-id-card clip flex-none" style={customsStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m">Customs</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? customsFeesValue : ''}
    </div>
  )
  const insuranceFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-umbrella clip flex-none" style={insuranceStyle} />
      </div>
      <div className={`${styles.fee_text} flex-none layout-row layout-align-center-center width_100`}>
        <p className="flex-none no_m">Insurance</p>
      </div>
      {scope.detailed_billing && feeHash.cargo ? insuranceFeesValue : ''}
    </div>
  )
  return (
    <div className={`flex-100 layout-row layout-align-start-start  ${styles.incoterm_wrapper}`}>
      {customsFeesTile} {preCarriageFeesTile} {originFeesTile}
      {freightFeesTile} {destinationFeesTile}
      {onCarriageFeesTile} {insuranceFeesTile}
    </div>
  )
}

IncotermRow.propTypes = {
  theme: PropTypes.theme,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  originFees: PropTypes.bool,
  destinationFees: PropTypes.bool,
  feeHash: PropTypes.objectOf(PropTypes.any),
  tenant: PropTypes.tenant,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired
}

IncotermRow.defaultProps = {
  theme: null,
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false,
  feeHash: {},
  tenant: {}
}

export default IncotermRow
