import React from 'react'
import PropTypes from 'prop-types'
// import Formsy from 'formsy-react'
import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
// import GmapsWrapper from '../../../hocs/GmapsWrapper'
// import { PlaceSearch } from '../../Maps/PlaceSearch'
// import { RoundButton } from '../../RoundButton/RoundButton'

export const PanelBox = ({
  cells,
  cellSteps,
  theme,
  handleRateChange,
  shrinkPanel,
  shrinkView,
  lowerKey,
  upperKey,
  handleMinimumChange,
  target,
  stepBasis,
  truckingBasis
}) =>
  (cells
    ? cells.map((s, i) => {
      const wsInputs = []
      console.log(cells)
      cellSteps.forEach((ws, iw) => {
        console.log(truckingBasis)
        console.log(cells[i][target].table[iw].value)
        wsInputs.push(<div
          // eslint-disable-next-line react/no-array-index-key
          key={`ws_${iw}`}
          className="flex-100 layout-row layout-wrap layout-align-start-start"
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none sup">{`${ws[lowerKey]} - ${ws[upperKey]} ${
              stepBasis.label
            }`}</p>
          </div>
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-none sup">Base Rate</p>
            <input
              type="number"
              value={cells[i][target].table[iw].value}
              onChange={handleRateChange}
              name={`${i}-${target}-${iw}-value`}
            />
          </div>
          {Object.keys(cells[i][target].table[iw].fees).map(fk => (
            <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
              <p className="flex-none sup">{cells[i][target].table[iw].fees[fk].label}</p>
              <input
                type="number"
                value={cells[i][target].table[iw].fees[fk].value}
                onChange={handleRateChange}
                name={`${i}-${target}-${iw}-${fk}`}
              />
            </div>
          ))}
        </div>)
      })
      const panelStyle = shrinkView[`cell_${i}`] ? styles.open : styles.closed
      return (
        <div
          // eslint-disable-next-line react/no-array-index-key
          key={`cell_${i}`}
          className="flex-100 layout-row layout-align-start-center layout-wrap"
        >
          <div className="
              flex-50
              layout-row
              layout-row
              layout-wrap
              layout-align-space-between-start"
          >
            <p className="flex-none">{`${truckingBasis.label} Range ${s[target][lowerKey]} - ${s[target][upperKey]}`}</p>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => shrinkPanel(`cell_${i}`)}
            >
              <i className="fa fa-close" />
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-align-start-center layout-wrap ${panelStyle}`}
          >
            <div className="flex-25 layout-row layout-wrap layout-align-start-start">
              <div className="flex-100 layout-row layout-align-start-center">
                <p className="flex-none sup">Minimum charge (Flat Rate)</p>
              </div>
              <div className="flex-100 layout-row layout-align-start-center input_box">
                <input
                  type="number"
                  value={s[target].min_value}
                  onChange={handleMinimumChange}
                  name={`${target}-${i}-minimum`}
                />
              </div>
            </div>
            {wsInputs}
          </div>
        </div>
      )
    })
    : [])
PanelBox.propTypes = {
  theme: PropTypes.theme,
  cells: PropTypes.arrayOf(PropTypes.object),
  cellSteps: PropTypes.arrayOf(PropTypes.object),
  handleRateChange: PropTypes.func.isRequired,
  shrinkPanel: PropTypes.func.isRequired,
  shrinkView: PropTypes.objectOf(PropTypes.string),
  lowerKey: PropTypes.string,
  upperKey: PropTypes.string,
  handleMinimumChange: PropTypes.func.isRequired,
  target: PropTypes.string,
  stepBasis: PropTypes.objectOf(PropTypes.string),
  truckingBasis: PropTypes.objectOf(PropTypes.string)
}
PanelBox.defaultProps = {
  theme: {},
  lowerKey: '',
  upperKey: '',
  target: ''
}
export default PanelBox
