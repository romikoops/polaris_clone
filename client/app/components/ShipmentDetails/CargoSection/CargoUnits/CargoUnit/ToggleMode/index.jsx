import React from 'react'
import Toggle from 'react-toggle'
import styles from './index.scss'

export default function CargoItemToggleMode ({
  checked,
  disabed,
  onToggleAggregated,
  t
}) {
  if (disabed) return ''

  return (
    <div className="layout-row flex-100 layout-wrap layout-align-center">
      <div className="content_width_booking layout-row layout-wrap layout-align-center">
        <div
          className={
            `${styles.toggle_aggregated_sec} ` +
            'flex-50 layout-row layout-align-space-around-center'
          }
        >
          <h3
            style={{ opacity: checked ? 0.4 : 1 }}
            onClick={onToggleAggregated}
          >
            {t('cargo:cargoUnits')}
          </h3>
          <Toggle
            className="flex-none aggregated_cargo"
            id="aggregated_cargo"
            name="aggregated_cargo"
            checked={checked}
            tabIndex="-1"
            onChange={onToggleAggregated}
          />
          <h3
            style={{ opacity: checked ? 1 : 0.4 }}
            onClick={onToggleAggregated}
          >
            {t('cargo:totalDimensions')}
          </h3>
        </div>
      </div>
    </div>
  )
}
