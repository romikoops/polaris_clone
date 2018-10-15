import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 as uuidV4 } from 'uuid'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator, switchIcon } from '../../../helpers'
import { tooltips } from '../../../constants'

export function ChargeIcons ({
  theme,
  onCarriage,
  preCarriage,
  originFees,
  destinationFees,
  mot
}) {
  const tooltipId = uuidV4()

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
    <div className={`${styles.fee_tile} flex-none layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i
          className="fa fa-truck clip flex-none"
          style={preCarriageStyle}
          data-tip={tooltips.charge_icons.pre_carriage}
          data-for={tooltipId}
        />
      </div>
      <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
    </div>
  )
  const onCarriageFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i
          className={`fa fa-truck clip flex-none flip_icon_horizontal ${styles.no_flip}`}
          style={onCarriageStyle}
          data-tip={tooltips.charge_icons.on_carriage}
          data-for={tooltipId}
        />
      </div>
      <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
    </div>
  )
  const originFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i
          className="fa fa-file-text clip flex-none"
          style={originDocumentStyle}
          data-tip={tooltips.charge_icons.documentation.origin}
          data-for={tooltipId}
        />
      </div>
      <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
    </div>
  )
  const destinationFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        <i
          className="fa fa-file-text-o clip flex-none"
          style={destinationDocumentStyle}
          data-tip={tooltips.charge_icons.documentation.destination}
          data-for={tooltipId}
        />
      </div>
      <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
    </div>
  )
  const freightFeesTile = (
    <div className={`${styles.fee_tile} flex-none layout-column layout-align-none-center`}>
      <div className="flex layout-row layout-align-center-start width_100">
        {switchIcon(mot, freightStyle, '', { dataFor: tooltipId, dataTip: tooltips.charge_icons.freight })}
      </div>
      <ReactTooltip id={tooltipId} className={styles.tooltip} effect="solid" />
    </div>
  )

  return (
    <div className={`flex-100 layout-row layout-align-end-start ${styles.incoterm_wrapper}`}>
      {preCarriageFeesTile} {originFeesTile}
      {freightFeesTile} {destinationFeesTile}
      {onCarriageFeesTile}
    </div>
  )
}

ChargeIcons.propTypes = {
  theme: PropTypes.theme,
  mot: PropTypes.string,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  originFees: PropTypes.bool,
  destinationFees: PropTypes.bool,
  tenant: PropTypes.tenant
}

ChargeIcons.defaultProps = {
  theme: null,
  mot: '',
  onCarriage: false,
  preCarriage: false,
  originFees: false,
  destinationFees: false,
  tenant: {}
}

export default ChargeIcons
