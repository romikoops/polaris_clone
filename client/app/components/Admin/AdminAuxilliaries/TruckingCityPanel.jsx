import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
// import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'

export const TruckingCityPanel = ({
  cells, rateBasis, handleRateChange, handleMinimumChange, weightSteps, currency, t
}) => cells.map((s, i) => {
  const wsInputs = []
  weightSteps.forEach((ws, iw) => {
    // eslint-disable-next-line react/no-array-index-key
    wsInputs.push(<div key={`ws_${iw}`} className="flex-25 layout-row layout-wrap layout-align-start-start">
      <div className="flex-100 layout-row layout-align-start-center">
        <p className="flex-none sup">{`${ws.city} - ${ws.country} ${rateBasis.label} / ${currency.label}`}</p>
      </div>
      <div className="flex-100 layout-row layout-align-start-center input_box">
        <input type="number" value={cells[i].table[iw].value} onChange={handleRateChange} name={`${i}-${iw}`} />
      </div>
    </div>)
  })

  return (
    // eslint-disable-next-line react/no-array-index-key
    <div key={`cell_${i}`} className="flex-100 layout-row layout-align-start-center layout-wrap">
      <div className="flex-50 layout-row layout-row layout-wrap layout-align-start-start">
        <p className="flex-none">{`${t('admin:zipcodeRange')} ${s.lower_zip} - ${s.upper_zip}`}</p>
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

TruckingCityPanel.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  cells: PropTypes.arrayOf(PropTypes.object).isRequired,
  weightSteps: PropTypes.arrayOf(PropTypes.object).isRequired,
  rateBasis: PropTypes.objectOf(PropTypes.string).isRequired,
  currency: PropTypes.objectOf(PropTypes.string).isRequired,
  handleRateChange: PropTypes.func.isRequired,
  handleMinimumChange: PropTypes.func.isRequired
}
TruckingCityPanel.defaultProps = {
  theme: {}
}

export default withNamespaces('admin')(TruckingCityPanel)
