import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import FormsyInput from '../FormsyInput/FormsyInput'
import { RoundButton } from '../RoundButton/RoundButton'
import { gradientTextGenerator } from '../../helpers'
import {
  TruckingCitySetter,
  TruckingDistanceSetter,
  TruckingZipPanel,
  TruckingZipSetter,
  TruckingFeeSetter,
  TruckingDistancePanel,
  TruckingCityPanel
} from './AdminAuxilliaries'

export class AdminTruckingCreator extends Component {
  static prepForSelect (arr, labelKey, valueKey, glossary) {
    return arr.map(a => ({
      value: valueKey ? a[valueKey] : a,
      label: glossary ? glossary[a[labelKey]] : a[labelKey]
    }))
  }
  static grammarize (label) {
    let result
    switch (label) {
      case 'Per Container':
        result = 'containers'
        break
      case 'Per Item':
        result = 'items'
        break
      case 'Per cbm':
        result = 'cbms'
        break
      case 'Per cbm/ton':
        result = 'cbms/tons'
        break
      case 'Per Shipment':
        result = 'shipments'
        break
      default:
        result = ''
        break
    }
    return result
  }
  constructor (props) {
    super(props)
    this.state = {
      selectOptions: {},
      options: {},
      nexus: false,
      rateBasis: false,
      truckingBasis: false,
      currency: false,
      laodType: {},
      cells: [],
      newCell: {
        table: []
      },
      cities: [],
      newStep: {},
      weightSteps: [],
      steps: {
        nexus: false,
        rateBasis: false,
        currency: false,
        truckingBasis: false,
        weightSteps: false
      }
    }
    this.handleFCLChange = this.handleFCLChange.bind(this)
    this.handleStepChange = this.handleStepChange.bind(this)
    this.handleRateChange = this.handleRateChange.bind(this)
    this.handleMinimumChange = this.handleMinimumChange.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.handleTopLevelSelect = this.handleTopLevelSelect.bind(this)
    this.addWeightStep = this.addWeightStep.bind(this)
    this.saveWeightSteps = this.saveWeightSteps.bind(this)
    this.addNewCell = this.addNewCell.bind(this)
    this.handlePlaceChange = this.handlePlaceChange.bind(this)
    this.handleInputDisplays = this.handleInputDisplays.bind(this)
    this.setFeeSchema = this.setFeeSchema.bind(this)
  }
  setFeeSchema (fees) {
    this.setState({
      feeSchema: fees
    })
  }
  handleChange (event) {
    const { name, value } = event.target
    this.setState({
      newCell: {
        ...this.state.newCell,
        [name]: parseInt(value, 10)
      }
    })
  }
  handleInputDisplays () {
    const { truckingBasis, newCell } = this.state
    const { theme } = this.props
    switch (truckingBasis.value) {
      case 'city':
        return (
          <TruckingCitySetter
            theme={theme}
            newCell={newCell}
            addNewCell={this.addNewCell}
            handlePlaceChange={this.handlePlaceChange}
          />
        )
      case 'zipcode':
        return <TruckingZipSetter theme={theme} newCell={newCell} addNewCell={this.addNewCell} />
      case 'distance':
        return (
          <TruckingDistanceSetter theme={theme} newCell={newCell} addNewCell={this.addNewCell} />
        )
      default:
        return <TruckingZipSetter theme={theme} newCell={newCell} addNewCell={this.addNewCell} />
    }
  }
  handleCellDisplays () {
    const {
      truckingBasis, newCell, cells, rateBasis, weightSteps, loadType, currency
    } = this.state
    const { theme } = this.props
    switch (truckingBasis.value) {
      case 'city':
        return <TruckingCityPanel theme={theme} newCell={newCell} addNewCell={this.addNewCell} />
      case 'zipcode':
        return (
          <TruckingZipPanel
            theme={theme}
            cells={cells}
            rateBasis={rateBasis}
            newCell={newCell}
            handleRateChange={this.handleRateChange}
            handleMinimumChange={this.handleMinimumChange}
            weightSteps={weightSteps}
            currency={currency}
          />
        )
      case 'distance':
        return (
          <TruckingDistancePanel
            theme={theme}
            cells={cells}
            rateBasis={rateBasis}
            newCell={newCell}
            handleRateChange={this.handleRateChange}
            handleFCLChange={this.handleFCLChange}
            handleMinimumChange={this.handleMinimumChange}
            weightSteps={weightSteps}
            currency={currency}
            loadType={loadType}
          />
        )
      default:
        return (
          <TruckingZipPanel
            theme={theme}
            cells={cells}
            rateBasis={rateBasis}
            newCell={newCell}
            handleRateChange={this.handleRateChange}
            handleMinimumChange={this.handleMinimumChange}
            weightSteps={weightSteps}
            currency={currency}
          />
        )
    }
  }

  addNewCell (model) {
    const { cells, weightSteps, loadType } = this.state
    const tmpCell = { ...model }
    if (loadType.value === 'fcl') {
      tmpCell.chassi_rate = 0
      tmpCell.sima_rate = 0
    } else {
      tmpCell.table = weightSteps.map(s => Object.assign({}, s))
    }
    cells.push(tmpCell)
    this.setState({
      cells,
      newCell: {
        table: []
      }
    })
  }
  addWeightStep (model) {
    const { weightSteps } = this.state
    weightSteps.push({ ...model })
    this.setState({
      newStep: {
        min: parseInt(model.max, 10) + 1,
        max: parseInt(model.max, 10) + 4
      },
      weightSteps
    })
  }

  handleStepChange (event) {
    const { name, value } = event.target
    this.setState({
      newStep: {
        ...this.state.newStep,
        [name]: parseInt(value, 10)
      }
    })
  }

  handlePlaceChange (place) {
    // eslint-disable-next-line no-debugger
    debugger
    const newLocation = {
      streetNumber: '',
      street: '',
      zipCode: '',
      city: '',
      country: ''
    }
    place.address_components.forEach((ac) => {
      if (ac.types.includes('street_number')) {
        newLocation.streetNumber = ac.long_name
      }

      if (ac.types.includes('route') || ac.types.includes('premise')) {
        newLocation.street = ac.long_name
      }

      if (ac.types.includes('administrative_area_level_1') || ac.types.includes('locality')) {
        newLocation.city = ac.long_name
      }

      if (ac.types.includes('postal_code')) {
        newLocation.zipCode = ac.long_name
      }

      if (ac.types.includes('country')) {
        newLocation.country = ac.long_name
      }
    })
    newLocation.latitude = place.geometry.location.lat()
    newLocation.longitude = place.geometry.location.lng()
    newLocation.geocodedAddress = place.formatted_address
    this.setState({
      tmpCity: newLocation,
      newCell: {
        ...this.state.newCell,
        city: newLocation.city,
        country: newLocation.country
      }
    })
  }

  handleRateChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-').map(i => parseInt(i, 10))
    const cells = [...this.state.cells]
    cells[nameKeys[0]].table[nameKeys[1]].value = parseInt(value, 10)
    this.setState({
      cells
    })
  }
  handleFCLChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-').map(i => parseInt(i, 10))
    const cells = [...this.state.cells]
    cells[nameKeys[0]][nameKeys[1]] = parseInt(value, 10)
    this.setState({
      cells
    })
  }
  handleMinimumChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-').map(i => parseInt(i, 10))
    const { cells } = this.state
    const adjCellTable = cells[nameKeys[0]].table.map((x) => {
      const tx = x
      tx.min_value = parseInt(value, 10)
      return tx
    })
    cells[nameKeys[0]].min_value = parseInt(value, 10)
    cells[nameKeys[0]].table = adjCellTable
    this.setState({
      cells
    })
  }

  handleTopLevelSelect (selection) {
    this.setState({
      [selection.name]: selection,
      steps: {
        ...this.state.steps,
        [selection.name]: true
      }
    })
  }
  saveWeightSteps () {
    this.setState({
      steps: {
        ...this.state.steps,
        weightSteps: true
      }
    })
  }

  saveEdit () {
    console.log(this.state)
    const {
      cells, nexus, currency, rateBasis, truckingBasis
    } = this.state
    const data = cells.map((c) => {
      const tc = c
      delete tc.min_value
      tc.nexus_id = nexus.value.id
      tc.currency = currency.label
      return tc
    })
    const meta = {
      type: truckingBasis.value,
      modifier: rateBasis.value,
      nexus_id: nexus.value.id
    }
    this.props.adminDispatch.saveNewTrucking({ meta, data })
    this.props.closeForm()
  }

  render () {
    const { theme, nexuses } = this.props
    const {
      nexus,
      rateBasis,
      steps,
      cells,
      newStep,
      weightSteps,
      truckingBasis,
      loadType
    } = this.state
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const truckingBasises = [
      { value: 'city', label: 'City' },
      { value: 'zipcode', label: 'Zip Code' },
      { value: 'distance', label: 'Distance (Round Trip)' }
    ]
    const loadTypeOpts = [{ value: 'lcl', label: 'LCL' }, { value: 'fcl', label: 'FCL' }]
    const nexusOpts = AdminTruckingCreator.prepForSelect(nexuses, 'name', false, false)
    const selectNexus = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">Select a City</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="nexus"
              classes={`${styles.select}`}
              value={nexus}
              options={nexusOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const selectLoadType = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">Select a Load Type</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="loadType"
              classes={`${styles.select}`}
              value={loadType}
              options={loadTypeOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const selectTruckingBasis = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">Select your Trucking Zone Basis</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="truckingBasis"
              classes={`${styles.select}`}
              value={truckingBasis}
              options={truckingBasises}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )

    const rateView = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">
        {this.handleInputDisplays()}
        {this.handleCellDisplays()}
      </div>
    )
    const weightStepsArr = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        {weightSteps.map((ws, i) => (
          <div
            // eslint-disable-next-line react/no-array-index-key
            key={`ows_${i}`}
            className="flex-33 layout-row layout-wrap layout-align-center-start"
          >
            <div className="flex-100 layout-row">
              <p className="flex-none">{`${AdminTruckingCreator.grammarize(rateBasis.label)} Range:  ${ws.min} - ${ws.max}`}</p>
            </div>
          </div>
        ))}
      </div>
    )
    const setWeightSteps = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{`Set pricing weight steps. Values ${
            rateBasis.label
          } and inclusive`}</p>
        </div>
        <Formsy
          onValidSubmit={this.addWeightStep}
          className="flex-100 layout-row layout-align-start-center"
        >
          <div className="
            flex-33
            layout-row
            layout-row
            layout-wrap
            layout-align-start-start
            input_box"
          >
            <FormsyInput
              type="number"
              name="min"
              value={newStep.min}
              validations="isNumeric"
              placeholder="Lower Limit"
            />
          </div>
          <div className="
            flex-33
            layout-row
            layout-row
            layout-wrap
            layout-align-start-start
            input_box"
          >
            <FormsyInput
              type="number"
              name="max"
              value={newStep.max}
              validations="isNumeric"
              placeholder="Upper Limit"
            />
          </div>
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              text="Add another"
              iconClass="fa-plus-square-o"
            />
          </div>
        </Formsy>
        <div className="flex-100 layout-row layout-align-start-center">{weightStepsArr}</div>
        <div className="flex-100 layout-row layout-align-end-center button_padding">
          <RoundButton
            theme={theme}
            size="small"
            text="Next"
            active
            handleNext={this.saveWeightSteps}
            iconClass="fa-chevron-right"
          />
        </div>
      </div>
    )
    console.log(setWeightSteps)
    const saveBtn = (
      <div
        className="flex-100 layout-align-end-center layout-row button_padding"
        style={{ margin: '15px' }}
      >
        <RoundButton
          theme={theme}
          size="small"
          text="Save"
          active
          handleNext={this.saveEdit}
          iconClass="fa-floppy-o"
        />
      </div>
    )
    const contextPanel = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          {selectNexus}
          {selectLoadType}
          {selectTruckingBasis}
          {/* {steps.truckingBasis === true && steps.weightSteps === false
            ? setWeightSteps
            : weightStepsArr} */}
        </div>
      </div>
    )

    const feeBuilder = <TruckingFeeSetter theme={theme} />
    return (
      <div
        className={` ${
          styles.editor_backdrop
        } flex-none layout-row layout-wrap layout-align-center-center`}
      >
        <div
          className={` ${
            styles.editor_fade
          } flex-none layout-row layout-wrap layout-align-center-start`}
          onClick={this.props.closeForm}
        />
        <div
          className={` ${
            styles.editor_box
          } flex-none layout-row layout-wrap layout-align-center-start`}
        >
          <div className="flex-95 layout-row layout-wrap layout-align-center-start height_100">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_title
              }`}
            >
              <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
                New Trucking Pricing
              </p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-60 layout-row layout-align-start-center">
                <i className="fa fa-map-signs clip" style={textStyle} />
                <p className="flex-none offset-5">{nexus ? nexus.label : ''}</p>
              </div>
            </div>
            {steps.truckingBasis ? feeBuilder : contextPanel}
            {steps.weightSteps && steps.fees ? rateView : ''}
            {cells.length > 0 ? saveBtn : ''}
          </div>
        </div>
      </div>
    )
  }
}
AdminTruckingCreator.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  closeForm: PropTypes.func.isRequired,
  nexuses: PropTypes.arrayOf(PropTypes.any).isRequired
}
AdminTruckingCreator.defaultProps = {
  theme: {}
}

export default AdminTruckingCreator
