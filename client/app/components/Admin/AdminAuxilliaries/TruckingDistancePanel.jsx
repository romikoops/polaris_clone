import React from 'react'
import PropTypes from 'prop-types'
import { withNamespaces } from 'react-i18next'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'

export const TruckingDistancePanel = ({
  t,
  cells,
  rateBasis,
  handleRateChange,
  handleMinimumChange,
  weightSteps,
  currency,
  loadType,
  handleFCLChange
}) => cells.map((s, i) => {
  const wsInputs = []
  if (loadType.value === 'fcl') {
    // eslint-disable-next-line react/no-array-index-key
    wsInputs.push(<div key={`ws_${i}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
      <div className="flex-100 layout-row layout-align-start-center">
        <p className="flex-none sup">{`${t('admin:chassiRate')} ${rateBasis.label} / ${currency.label}`}</p>
      </div>
      <div className="flex-100 layout-row layout-align-start-center input_box">
        <input type="number" value={cells[i].chassi_rate} onChange={handleFCLChange} name={`${i}-chassi_rate`} />
      </div>
    </div>)
    // eslint-disable-next-line react/no-array-index-key
    wsInputs.push(<div key={`ws_${i}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
      <div className="flex-100 layout-row layout-align-start-center">
        <p className="flex-none sup">{`${t('admin:simaRate')} ${rateBasis.label} / ${currency.label}`}</p>
      </div>
      <div className="flex-100 layout-row layout-align-start-center input_box">
        <input type="number" value={cells[i].sima_rate} onChange={handleFCLChange} name={`${i}-sima_rate`} />
      </div>
    </div>)
  } else {
    weightSteps.forEach((ws, iw) => {
      // eslint-disable-next-line react/no-array-index-key
      wsInputs.push(<div key={`ws_${iw}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none sup">{`${ws.min} - ${ws.max} ${rateBasis.label} / ${currency.label}`}</p>
        </div>
        <div className="flex-100 layout-row layout-align-start-center input_box">
          <input type="number" value={cells[i].table[iw].value} onChange={handleRateChange} name={`${i}-${iw}`} />
        </div>
      </div>)
    })
  }

  return (
    // eslint-disable-next-line react/no-array-index-key
    <div key={`cell_${i}`} className="flex-100 layout-row layout-align-start-center layout-wrap">
      <div className="flex-50 layout-row layout-row layout-wrap layout-align-start-start">
        <p className="flex-none">{`${t('admin:distanceRange')}: ${s.lower_distance} - ${s.upper_distance}`}</p>
      </div>
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-25 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup">{t('admin:minimumCharge')}</p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center input_box">
            <input type="number" value={s.min_value} onChange={handleMinimumChange} name={`${i}-minimum`} />
          </div>
        </div>
        {wsInputs}
      </div>
    </div>
  )
})

TruckingDistancePanel.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  cells: PropTypes.arrayOf(PropTypes.object).isRequired,
  weightSteps: PropTypes.arrayOf(PropTypes.object).isRequired,
  rateBasis: PropTypes.objectOf(PropTypes.string).isRequired,
  currency: PropTypes.objectOf(PropTypes.string).isRequired,
  handleRateChange: PropTypes.func.isRequired,
  handleMinimumChange: PropTypes.func.isRequired
}
TruckingDistancePanel.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(TruckingDistancePanel)
