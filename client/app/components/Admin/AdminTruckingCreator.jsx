import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import FormsyInput from '../FormsyInput/FormsyInput'
import { RoundButton } from '../RoundButton/RoundButton'
import { gradientTextGenerator } from '../../helpers'
import { countries } from '../../constants'
import {
  TruckingCitySetter,
  TruckingDistanceSetter,
  TruckingZipSetter,
  TruckingFeeSetter,
  TruckingStepSetter,
  TruckingPanel
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
      loadType: {},
      cells: [],
      newCell: {
        table: []
      },
      cities: [],
      newStep: {},
      cellSteps: [],
      feeSchema: {},
      steps: {
        nexus: false,
        rateBasis: false,
        currency: false,
        truckingBasis: false,
        cellSteps: false
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
    this.saveSteps = this.saveSteps.bind(this)
    this.addNewCell = this.addNewCell.bind(this)
    this.handlePlaceChange = this.handlePlaceChange.bind(this)
    this.handleInputDisplays = this.handleInputDisplays.bind(this)
    this.setFeeSchema = this.setFeeSchema.bind(this)
    this.saveGlobalFees = this.saveGlobalFees.bind(this)
  }
  componentWillMount () {
    if (this.props.hub) {
      this.setState({ hub: this.props.hub })
    }
  }
  setFeeSchema (fees) {
    this.setState({
      feeSchema: fees,
      steps: {
        ...this.state.steps,
        fees: true
      }
    })
  }
  saveGlobalFees (fees) {
    this.setState({
      globalFees: fees
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
    const { truckingBasis, newCell, tmpCity } = this.state
    const { theme } = this.props
    switch (truckingBasis.value) {
      case 'city':
        return (
          <TruckingCitySetter
            theme={theme}
            newCell={newCell}
            tmpCity={tmpCity}
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
  addNewCell (model) {
    const {
      cells, cellSteps, loadType, feeSchema, truckingBasis
    } = this.state
    const tmpCell = {}
    const keys = Object.keys(model).sort()
    if (loadType.value === 'fcl') {
      tmpCell.chassis = { [truckingBasis.value]: { ...model } }
      tmpCell.side_lifter = { [truckingBasis.value]: { ...model } }
      tmpCell.chassis.table = cellSteps.map((s) => {
        const tmp = Object.assign({}, s)
        tmp.fees = {}
        Object.keys(feeSchema.variableFees).forEach((k) => {
          tmp.fees[k] = Object.assign({}, feeSchema.variableFees[k])
        })

        return tmp
      })
      tmpCell.side_lifter.table = cellSteps.map((s) => {
        const tmp = Object.assign({}, s)
        tmp.fees = {}
        Object.keys(feeSchema.variableFees).forEach((k) => {
          tmp.fees[k] = Object.assign({}, feeSchema.variableFees[k])
        })

        return tmp
      })
    } else {
      tmpCell.lcl = { [truckingBasis.value]: { ...model } }
      tmpCell.lcl.table = cellSteps.map((s) => {
        const tmp = Object.assign({}, s)
        tmp.fees = {}
        Object.keys(feeSchema.variableFees).forEach((k) => {
          tmp.fees[k] = Object.assign({}, feeSchema.variableFees[k])
        })

        return tmp
      })
    }

    cells.push(tmpCell)
    this.setState({
      cells,
      cellUpperKey: keys[1],
      cellLowerKey: keys[0],
      newCell: {
        table: []
      }
    })
  }
  addWeightStep (model) {
    const { cellSteps } = this.state
    cellSteps.push({ ...model })
    this.setState({
      newStep: {
        min: parseInt(model.max, 10) + 1,
        max: parseInt(model.max, 10) + 4
      },
      cellSteps
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
    const nameKeys = name.split('-')
    const cells = [...this.state.cells]
    cells[parseInt(nameKeys[0], 10)][nameKeys[1]].table[parseInt(nameKeys[2], 10)]
      .fees[nameKeys[3]][nameKeys[4]] = +value
    this.setState({
      cells
    })
  }
  handleFCLChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-').map(i => parseInt(i, 10))
    const cells = [...this.state.cells]
    cells[parseInt(nameKeys[0], 10)][nameKeys[1]] = parseInt(value, 10)
    this.setState({
      cells
    })
  }
  handleMinimumChange (event) {
    const { name, value } = event.target
    const nameKeys = name.split('-')
    const { cells } = this.state
    const adjCellTable = cells[parseInt(nameKeys[0], 10)][nameKeys[1]].table.map((x) => {
      const tx = x
      tx.min_value = parseInt(value, 10)

      return tx
    })
    cells[parseInt(nameKeys[0], 10)][nameKeys[1]].min_value = parseInt(value, 10)
    cells[parseInt(nameKeys[0], 10)][nameKeys[1]].table = adjCellTable
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
  saveSteps (obj) {
    this.setState({
      cellSteps: obj.steps,
      stepBasis: obj.stepBasis,
      upperKey: obj.upperKey,
      lowerKey: obj.lowerKey,
      steps: {
        ...this.state.steps,
        cellSteps: true
      }
    })
  }

  saveEdit () {
    console.log(this.state)
    const {
      cells,
      nexus,
      currency,
      truckingBasis,
      stepBasis,
      loadType,
      direction,
      hub
    } = this.state
    const data = cells.map((c) => {
      const tc = Object.assign({}, c)
      delete tc.min_value
      tc.currency = currency.label

      return tc
    })
    const meta = {
      modifier: truckingBasis.value,
      nexus_id: nexus.value.id,
      hub_id: hub.id,
      loadType: loadType.value,
      direction: direction.value,
      subModifier: stepBasis.value
    }
    this.props.adminDispatch.saveNewTrucking({ meta, data })
    this.props.closeForm()
  }

  render () {
    const { t, theme } = this.props
    const {
      nexus,
      rateBasis,
      steps,
      cells,
      newStep,
      cellSteps,
      truckingBasis,
      loadType,
      direction,
      newCell,
      currency,
      lowerKey,
      upperKey,
      stepBasis,
      feeSchema,
      cellUpperKey,
      cellLowerKey,
      country
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
    const directionOpts = [
      { value: 'import', label: 'Import' },
      { value: 'export', label: 'Export' },
      { value: 'either', label: 'Either' }
    ]
    const loadTypeOpts = [{ value: 'lcl', label: 'LCL' }, { value: 'fcl', label: 'FCL' }]

    const selectDirection = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">Select a Direction</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="direction"
              classes={`${styles.select}`}
              value={direction}
              options={directionOpts}
              className="flex-100"
              onChange={this.handleTopLevelSelect}
            />
          </div>
        </div>
      </div>
    )
    const selectCountry = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <h4 className="flex-100 letter_3">Select a Destination Country</h4>
          <div className="flex-75 layout-row">
            <NamedSelect
              name="country"
              classes={`${styles.select}`}
              value={country}
              options={countries}
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
        <TruckingPanel
          theme={theme}
          cells={cells}
          truckingBasis={truckingBasis}
          newCell={newCell}
          stepBasis={stepBasis}
          upperKey={upperKey}
          lowerKey={lowerKey}
          loadType={loadType}
          cellUpperKey={cellUpperKey}
          cellLowerKey={cellLowerKey}
          globalFees={feeSchema.globalFees}
          handleRateChange={this.handleRateChange}
          saveGlobalFees={this.saveGlobalFees}
          handleMinimumChange={this.handleMinimumChange}
          cellSteps={cellSteps}
          currency={currency}
        />
      </div>
    )
    const cellStepsArr = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        {cellSteps.map((ws, i) => (
          <div
            // eslint-disable-next-line react/no-array-index-key
            key={`ows_${i}`}
            className="flex-33 layout-row layout-wrap layout-align-center-start"
          >
            <div className="flex-100 layout-row">
              <p className="flex-none">{`${AdminTruckingCreator.grammarize(rateBasis.label)} ${t('admin:range')}:  ${ws.min} - ${ws.max}`}</p>
            </div>
          </div>
        ))}
      </div>
    )
    const setcellSteps = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{t('admin:setPricingWeightSteps', { label: rateBasis.label })}</p>
        </div>
        <Formsy
          onValidSubmit={this.addWeightStep}
          className="flex-100 layout-row layout-align-start-center"
        >
          <div
            className="
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
              placeholder={t('admin:lowerLimit')}
            />
          </div>
          <div
            className="
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
              placeholder={t('admin:upperLimit')}
            />
          </div>
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              text={t('admin:addAnother')}
              iconClass="fa-plus-square-o"
            />
          </div>
        </Formsy>
        <div className="flex-100 layout-row layout-align-start-center">{cellStepsArr}</div>
        <div className="flex-100 layout-row layout-align-end-center button_padding">
          <RoundButton
            theme={theme}
            size="small"
            text="Next"
            active
            handleNext={this.saveSteps}
            iconClass="fa-chevron-right"
          />
        </div>
      </div>
    )
    console.log(setcellSteps)
    const saveBtn = (
      <div
        className="flex-100 layout-align-end-center layout-row button_padding"
        style={{ margin: '15px' }}
      >
        <RoundButton
          theme={theme}
          size="small"
          text={t('admin:save')}
          active
          handleNext={this.saveEdit}
          iconClass="fa-floppy-o"
        />
      </div>
    )
    const contextPanel = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          {selectLoadType}
          {selectCountry}
          {selectTruckingBasis}
          {selectDirection}
          {/* {steps.truckingBasis === true && steps.cellSteps === false
            ? setcellSteps
            : cellStepsArr} */}
        </div>
      </div>
    )
    const stepSetter = <TruckingStepSetter theme={theme} saveSteps={this.saveSteps} />
    const feeBuilder = <TruckingFeeSetter theme={theme} setFees={this.setFeeSchema} />

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className="flex-none content_width layout-row layout-wrap layout-align-center-start">
          <div className="flex-95 layout-row layout-wrap layout-align-center-start height_100">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_title
              }`}
            >
              <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
                {t('admin:newTruckingPricing')}
              </p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex-60 layout-row layout-align-start-center">
                <i className="fa fa-map-signs clip" style={textStyle} />
                <p className="flex-none offset-5">{nexus ? nexus.label : ''}</p>
              </div>
            </div>
            {!steps.fees && !steps.direction ? contextPanel : ''}
            {!steps.fees && steps.direction ? feeBuilder : ''}
            {!steps.cellSteps && steps.fees ? stepSetter : ''}
            {steps.cellSteps && steps.fees ? rateView : ''}
            {cells.length > 0 ? saveBtn : ''}
          </div>
        </div>
      </div>
    )
  }
}

AdminTruckingCreator.defaultProps = {
  theme: {},
  hub: {}
}

export default withNamespaces('admin')(AdminTruckingCreator)
