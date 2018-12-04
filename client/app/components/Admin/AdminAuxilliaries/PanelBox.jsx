import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
// import Formsy from 'formsy-react'
import styles from '../Admin.scss'
// import { NamedSelect } from '../../NamedSelect/NamedSelect'
// import GmapsWrapper from '../../../hocs/GmapsWrapper'
// import { PlaceSearch } from '../../Maps/PlaceSearch'
// import { RoundButton } from '../../RoundButton/RoundButton'

export class PanelBox extends Component {
  static panelSwitcher (fee, cells, i, iw, target, fk, handleRateChange) {
    console.log(fee, cells, i, iw, target, fk, handleRateChange)
    if (fee.cbm !== undefined && fee.kg !== undefined) {
      return (
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-none sup">{cells[i][target].table[iw].fees[fk].label}</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].value}
              onChange={handleRateChange}
              name={`${i}-${target}-${iw}-${fk}-value`}
            />
          </div>
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-none sup">CBM</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].cbm}
              onChange={handleRateChange}
              step="0.01"
              name={`${i}-${target}-${iw}-${fk}-cbm`}
            />
          </div>
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-none sup">KG</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].kg}
              onChange={handleRateChange}
              step="0.01"
              name={`${i}-${target}-${iw}-${fk}-kg`}
            />
          </div>
        </div>
      )
    }

    if (fee.cbm !== undefined && fee.ton !== undefined) {
      return (
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-100 sup">{cells[i][target].table[iw].fees[fk].label}</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].value}
              onChange={handleRateChange}
              name={`${i}-${target}-${iw}-${fk}-value`}
            />
          </div>
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-100 sup">CBM</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].cbm}
              onChange={handleRateChange}
              step="0.01"
              name={`${i}-${target}-${iw}-${fk}-cbm`}
            />
          </div>
          <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
            <p className="flex-100 sup">KG</p>
            <input
              type="number"
              value={cells[i][target].table[iw].fees[fk].ton}
              onChange={handleRateChange}
              step="0.01"
              name={`${i}-${target}-${iw}-${fk}-ton`}
            />
          </div>
        </div>
      )
    }

    return (
      <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
        <p className="flex-100 sup">{cells[i][target].table[iw].fees[fk].label}</p>
        <input
          type="number"
          value={cells[i][target].table[iw].fees[fk].value}
          onChange={handleRateChange}
          name={`${i}-${target}-${iw}-${fk}-value`}
        />
      </div>
    )
  }

  render () {
    const {
      // theme,
      t,
      cells,
      cellSteps,
      handleRateChange,
      shrinkPanel,
      shrinkView,
      lowerKey,
      upperKey,
      handleMinimumChange,
      target,
      stepBasis,
      truckingBasis,
      cellUpperKey,
      cellLowerKey
    } = this.props

    const panel = cells
      ? cells.map((s, i) => {
        const panelStyle = shrinkView[`cell_${i}`] ? styles.open : styles.closed
        const wsInputs = []
        console.log(cells, lowerKey, upperKey)
        cellSteps.forEach((ws, iw) => {
          console.log(truckingBasis)
          console.log(cells[i][target].table[iw].value)
          wsInputs.push(<div
            // eslint-disable-next-line react/no-array-index-key
            key={`ws_${iw}`}
            className="flex-100 layout-row layout-wrap layout-align-start-start"
          >
            <div className="flex-100 layout-row layout-align-start-center">
              {ws.city ? (
                <p className="flex-none sup">{`${ws.city} ${ws.country} ${stepBasis.label}`}</p>
              ) : (
                <p className="flex-none sup">
                  {`${ws[lowerKey]} - ${ws[upperKey]} ${
                    stepBasis.label
                  }`}
                </p>
              )}
            </div>
            {Object.keys(cells[i][target].table[iw].fees).map(fk => PanelBox.panelSwitcher(
              cells[i][target].table[iw].fees[fk],
              cells,
              i,
              iw,
              target,
              fk,
              handleRateChange
            ))}
          </div>)
        })

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
              {cellLowerKey === 'city' ? (
                <p className="flex-none">
                  {`${truckingBasis.label}: ${s[target][cellLowerKey]}, ${
                    s[target][cellUpperKey]
                  }`}
                </p>
              ) : (
                <p className="flex-none">{`${truckingBasis.label} ${t('admin:range')} ${
                  s[target][cellLowerKey]
                } - ${s[target][cellUpperKey]}`}</p>
              )}
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
                  <p className="flex-none sup">{t('admin:minimumCharge')}</p>
                </div>
                <div className="flex-100 layout-row layout-align-start-center input_box">
                  <input
                    type="number"
                    value={s[target].min_value}
                    onChange={handleMinimumChange}
                    name={`${i}-${target}-minimum`}
                  />
                </div>
              </div>
              {wsInputs}
            </div>
          </div>
        )
      })
      : []

    return <div className="flex-100 layout-row layout-align-start-start layout-wrap">{panel}</div>
  }
}
PanelBox.propTypes = {
  // theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  cells: PropTypes.arrayOf(PropTypes.object),
  cellSteps: PropTypes.arrayOf(PropTypes.object),
  handleRateChange: PropTypes.func.isRequired,
  shrinkPanel: PropTypes.func.isRequired,
  shrinkView: PropTypes.objectOf(PropTypes.bool),
  lowerKey: PropTypes.string,
  upperKey: PropTypes.string,
  handleMinimumChange: PropTypes.func.isRequired,
  target: PropTypes.string,
  stepBasis: PropTypes.objectOf(PropTypes.string),
  truckingBasis: PropTypes.objectOf(PropTypes.string),
  cellUpperKey: PropTypes.string.isRequired,
  cellLowerKey: PropTypes.string.isRequired
}
PanelBox.defaultProps = {
  // theme: {},
  lowerKey: '',
  upperKey: '',
  target: '',
  cells: [],
  cellSteps: [],
  shrinkView: {},
  stepBasis: {},
  truckingBasis: {}
}
export default withNamespaces('admin')(PanelBox)
