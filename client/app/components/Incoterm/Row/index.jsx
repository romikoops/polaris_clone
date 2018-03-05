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
  destinationFees
}) {
  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const deselectedStyle = { ...gradientTextGenerator('rgb(0, 0, 0)', 'rgb(25, 25, 25)'), opacity: '0.5' }
  const preCarriageStyle = preCarriage ? selectedStyle : deselectedStyle
  const onCarriageStyle = onCarriage ? selectedStyle : deselectedStyle
  const originDocumentStyle = originFees ? selectedStyle : deselectedStyle
  const destinationDocumentStyle = destinationFees ? selectedStyle : deselectedStyle
  const freightStyle = selectedStyle
  const preCarriageTile = (
    <div className="flex-20 layout-column layout-align-none-center">
      <div className="flex layout-row layout-align-center-center width_100">
        <i className="fa fa-truck clip flex-none" style={preCarriageStyle} />
      </div>
      <div className="flex-none layout-row layout-align-center-center width_100">
        <p className="flex-none no_m">Pre-Carriage</p>
      </div>
    </div>
  )
  const onCarriageTile = (
    <div className="flex-20 layout-column layout-align-none-center">
      <div className="flex layout-row layout-align-center-center width_100">
        <i className={`fa fa-truck clip flex-none ${styles.dest_truck}`} style={onCarriageStyle} />
      </div>
      <div className="flex-none layout-row layout-align-center-center width_100">
        <p className="flex-none no_m">On-Carriage</p>
      </div>
    </div>
  )
  const originFeesTile = (
    <div className="flex-20 layout-column layout-align-none-center">
      <div className="flex layout-row layout-align-center-center width_100">
        <i className="fa fa-file-text clip flex-none" style={originDocumentStyle} />
      </div>
      <div className="flex-none layout-row layout-align-center-center width_100">
        <p className="flex-none no_m">Origin Documentation</p>
      </div>
    </div>
  )
  const destinationFeesTile = (
    <div className="flex-20 layout-column layout-align-none-center">
      <div className="flex layout-row layout-align-center-center width_100">
        <i className="fa fa-file-text-o clip flex-none" style={destinationDocumentStyle} />
      </div>
      <div className="flex-none layout-row layout-align-center-center width_100">
        <p className="flex-none no_m">Destination Documentation</p>
      </div>
    </div>
  )
  const freightFeesTile = (
    <div className="flex-20 layout-column layout-align-none-center">
      <div className="flex layout-row layout-align-center-center width_100">
        <i className="fa fa-ship clip flex-none" style={freightStyle} />
      </div>
      <div className="flex-none layout-row layout-align-center-center width_100">
        <p className="flex-none no_m">Freight</p>
      </div>
    </div>
  )
  return (
    <div className={`flex-100 layout-row layout-align-start-start  ${styles.incoterm_wrapper}`}>
      {preCarriageTile} {originFeesTile} {freightFeesTile} {destinationFeesTile}
      {onCarriageTile}
    </div>
  )
}

IncotermRow.propTypes = {
  theme: PropTypes.theme,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  originFees: PropTypes.bool,
  destinationFees: PropTypes.bool,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired
}

IncotermRow.defaultProps = {
  theme: null,
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false
}

export default IncotermRow
