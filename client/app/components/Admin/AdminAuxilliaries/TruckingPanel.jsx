import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import { PanelBox } from './'
// import styles from '../Admin.scss'

export class TruckingPanel extends Component {
  constructor (props) {
    super(props)
    this.state = {
      globalFeeData: { ...props.globalFees },
      shrinkView: {}
    }
    this.handleGlobalFeeChange = this.handleGlobalFeeChange.bind(this)
    this.shrinkPanel = this.shrinkPanel.bind(this)
  }
  handleGlobalFeeChange (event) {
    const { name, value } = event.target
    this.setState({
      globalFeeData: {
        ...this.state.globalFeeData,
        [name]: {
          ...this.state.globalFeeData[name],
          value
        }
      }
    })
    this.props.saveGlobalFees({
      ...this.state.globalFeeData,
      [name]: {
        ...this.state.globalFeeData[name],
        value
      }
    })
  }
  shrinkPanel (key) {
    this.setState({
      shrinkView: {
        ...this.state.shrinkView,
        [key]: !this.state.shrinkView[key]
      }
    })
  }
  render () {
    const {
      cells,
      cellSteps,
      theme,
      upperKey,
      lowerKey,
      stepBasis,
      handleRateChange,
      loadType,
      handleMinimumChange,
      truckingBasis,
      cellUpperKey,
      t,
      cellLowerKey
    } = this.props
    const { globalFeeData, shrinkView } = this.state
    console.log(cellSteps)
    const globalFeePanel = Object.keys(globalFeeData).map(fk => (
      <div className="flex-25 layout-row layout-align-start-center input_box layout-wrap">
        <p className="flex-none sup">{globalFeeData[fk].label}</p>
        <input
          type="number"
          value={globalFeeData[fk].value}
          onChange={this.handleGlobalFeeChange}
          name={`${fk}`}
        />
      </div>
    ))

    const lclPanel = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <PanelBox
            cells={cells}
            cellSteps={cellSteps}
            theme={theme}
            handleRateChange={handleRateChange}
            shrinkPanel={this.shrinkPanel}
            shrinkView={shrinkView}
            lowerKey={lowerKey}
            upperKey={upperKey}
            handleMinimumChange={handleMinimumChange}
            target="lcl"
            stepBasis={stepBasis}
            truckingBasis={truckingBasis}
            cellUpperKey={cellUpperKey}
            cellLowerKey={cellLowerKey}
          />
        </div>
      </div>
    )
    const fclPanel = ['chassis', 'side_lifter'].map(truckType => (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <p className="flex-none">
            {truckType === 'chassis' ? t('admin:chassisTruck') : t('admin:sidelifterTruck')}
          </p>
        </div>

        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <PanelBox
            cells={cells}
            cellSteps={cellSteps}
            theme={theme}
            handleRateChange={handleRateChange}
            shrinkPanel={this.shrinkPanel}
            shrinkView={shrinkView}
            lowerKey={lowerKey}
            upperKey={upperKey}
            handleMinimumChange={handleMinimumChange}
            target={truckType}
            stepBasis={stepBasis}
            cellUpperKey={cellUpperKey}
            cellLowerKey={cellLowerKey}
            truckingBasis={truckingBasis}
          />
        </div>
      </div>
    ))

    return (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            <p className="flex-none">{t('admin:globalFees')}</p>
          </div>
          {globalFeePanel}
        </div>
        {loadType.value === 'lcl' ? lclPanel : fclPanel}
      </div>
    )
  }
}
TruckingPanel.propTypes = {
  theme: PropTypes.theme,
  cellSteps: PropTypes.arrayOf(PropTypes.object).isRequired,
  cells: PropTypes.arrayOf(PropTypes.object).isRequired,
  upperKey: PropTypes.string.isRequired,
  lowerKey: PropTypes.string.isRequired,
  stepBasis: PropTypes.objectOf(PropTypes.string).isRequired,
  truckingBasis: PropTypes.objectOf(PropTypes.string).isRequired,
  loadType: PropTypes.objectOf(PropTypes.string).isRequired,
  globalFees: PropTypes.objectOf(PropTypes.any).isRequired,
  handleRateChange: PropTypes.func.isRequired,
  handleMinimumChange: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  saveGlobalFees: PropTypes.func.isRequired,
  cellUpperKey: PropTypes.string.isRequired,
  cellLowerKey: PropTypes.string.isRequired
}
TruckingPanel.defaultProps = {
  theme: {}
}
export default withNamespaces('admin')(TruckingPanel)
