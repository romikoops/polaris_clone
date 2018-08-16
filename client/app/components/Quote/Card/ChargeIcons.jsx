import React from 'react'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator, determineSpecialism, switchIcon } from '../../../helpers'

export function ChargeIcons ({
  theme,
  onCarriage,
  preCarriage,
  originFees,
  destinationFees,
  tenant
}) {
  const speciality = determineSpecialism(tenant.data.scope.modes_of_transport)

  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const deselectedStyle = {
    ...gradientTextGenerator('rgb(0, 0, 0)', 'rgb(25, 25, 25)'),
    opacity: '0.25'
  }
  const preCarriageStyle = preCarriage ? selectedStyle : deselectedStyle
  const onCarriageStyle = onCarriage ? selectedStyle : deselectedStyle
  const originDocumentStyle = originFees ? selectedStyle : deselectedStyle
  const destinationDocumentStyle = destinationFees ? selectedStyle : deselectedStyle
  const freightStyle = selectedStyle

  const preCarriageFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-truck clip flex-none" style={preCarriageStyle} />
      </div>
    </div>
  )
  const onCarriageFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className={`fa fa-truck clip flex-none ${styles.dest_truck}`} style={onCarriageStyle} />
      </div>
    </div>
  )
  const originFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-file-text clip flex-none" style={originDocumentStyle} />
      </div>
    </div>
  )
  const destinationFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i className="fa fa-file-text-o clip flex-none" style={destinationDocumentStyle} />
      </div>
    </div>
  )
  const freightFeesTile = (
    <div className={`${styles.fee_tile} flex layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        {switchIcon(speciality, freightStyle)}
        {/* <i className="fa fa-ship  flex-none" style={freightStyle} /> */}
      </div>
    </div>
  )
  return (
    <div className={`flex-100 layout-row layout-align-start-start  ${styles.incoterm_wrapper}`}>
      {preCarriageFeesTile} {originFeesTile}
      {freightFeesTile} {destinationFeesTile}
      {onCarriageFeesTile}
    </div>
  )
}

ChargeIcons.propTypes = {
  theme: PropTypes.theme,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  originFees: PropTypes.bool,
  destinationFees: PropTypes.bool,
  tenant: PropTypes.tenant
}

ChargeIcons.defaultProps = {
  theme: null,
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false,
  tenant: {}
}

export default ChargeIcons
