import React from 'react'
import { get } from 'lodash'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions } from '../../../actions'
import CargoUnits from './CargoUnits'
import CargoUnitToggleMode from './CargoUnits/CargoUnit/ToggleMode'
import AddUnitButton from './AddUnitButton'
import { debounce } from '../../../helpers'
import { getTotalShipmentErrors } from './getErrors'

class CargoSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.handleAddUnit = this.handleAddUnit.bind(this)
    this.handleToggleAggregated = debounce(this.handleToggleAggregated.bind(this), 200)
    this.handleDeleteUnit = this.handleDeleteUnit.bind(this)
    this.handleChangeCargoUnitSelect = this.handleChangeCargoUnitSelect.bind(this)

    this.handleChangeCargoUnitInput = this.handleChangeCargoUnitInput.bind(this)
    this.getPropValue = this.getPropValue.bind(this)
    this.getPropStep = this.getPropStep.bind(this)
    this.handleChangeCargoUnitCheckbox = debounce(
      this.handleChangeCargoUnitCheckbox.bind(this),
      200,
      (_, e) => e.persist()
    )

    this.cargoItem = {
      payloadInKg: 0,
      totalVolume: 0,
      totalWeight: 0,
      dimensionX: 0,
      dimensionY: 0,
      dimensionZ: 0,
      quantity: 1,
      cargoItemTypeId: '',
      dangerousGoods: false,
      stackable: true
    }
    this.container = {
      sizeClass: undefined,
      quantity: 1,
      payloadInKg: 0,
      dangerousGoods: false
    }
    if (props.shipment.cargoUnits.length === 0) this.handleAddUnit()
  }

  getNewUnit () {
    const { loadType } = this.props.shipment

    return loadType === 'cargo_item' ? { ...this.cargoItem } : { ...this.container }
  }

  handleDeleteUnit (i) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.deleteCargoUnit(i)
  }

  handleAddUnit () {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.addCargoUnit(this.getNewUnit())
  }

  handleChangeCollectiveWeight (index, prop, newValue) {
    const { shipment } = this.props
    const { cargoUnits } = shipment
    const { quantity, collectiveWeight } = cargoUnits[index]
    const { bookingProcessDispatch } = this.props

    if (prop === 'collectiveWeight') {
      bookingProcessDispatch.updateCargoUnit({
        index: Number(index),
        prop: 'payloadInKg',
        newValue: newValue / quantity
      })
    } else {
      bookingProcessDispatch.updateCargoUnit({
        index: Number(index),
        prop: 'payloadInKg',
        newValue: collectiveWeight / newValue
      })
    }
  }

  handleUnitWeightManipulation (value) {
    const { scope } = this.props
    const { values } = scope
    const { weight } = values
    const { unit, decimals } = weight
    const newValue = Number(value)

    return unit === 'kg' ? newValue : (newValue * 1000).toFixed(decimals)
  }

  handleChangeCargoUnitInput (e) {
    const { scope } = this.props
    const { target } = e
    const { name, value } = target

    const [index, prop] = name.split('-')

    let newValue
    if (['collectiveWeight', 'payloadInKg', 'totalWeight'].includes(prop)) {
      newValue = this.handleUnitWeightManipulation(value) 
    } else {
      newValue = Number(value)
    }
    
    if (['collectiveWeight', 'quantity'].includes(prop) && get(scope, ['consolidation', 'cargo', 'frontend'], false)) {
      this.handleChangeCollectiveWeight(index, prop, newValue)
    }
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit({
      index: Number(index),
      prop,
      newValue
    })
  }

  handleChangeCargoUnitCheckbox (checked, e) {
    const [index, prop] = e.target.name.split('-')

    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit({
      index: Number(index),
      prop,
      newValue: checked
    })
  }

  handleChangeCargoUnitSelect (index, prop, newValue) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit({ index, prop, newValue })
  }

  handleToggleAggregated () {
    const { bookingProcessDispatch, shipment } = this.props
    bookingProcessDispatch.updateShipment(
      'aggregatedCargo',
      !shipment.aggregatedCargo
    )
    bookingProcessDispatch.updateShipment(
      'cargoUnits',
      [this.getNewUnit()]
    )
  }

  getPropValue (prop, cargoUnit) {
    const { scope } = this.props
    if (!['collectiveWeight', 'payloadInKg', 'totalWeight'].includes(prop)) {
      return cargoUnit[prop]
    }
    const { values } = scope
    const { weight } = values
    const { unit, decimals } = weight
    
    return unit === 'kg' ? cargoUnit[prop] : (cargoUnit[prop] / 1000).toFixed(decimals)
  }

  getPropStep (prop) {
    const { scope } = this.props
    if (!['collectiveWeight', 'payloadInKg', 'totalWeight'].includes(prop)) {
      return '1'
    }
    const { values } = scope
    const { weight } = values
    const { unit, decimals } = weight

    return unit === 'kg' ? '1' : String(1 * (10 ** -decimals))
  }

  render () {
    const {
      theme, scope, cargoItemTypes, maxDimensions, maxAggregateDimensions, shipment, ShipmentDetails, toggleModal, totalShipmentErrors
    } = this.props

    const { loadType, aggregatedCargo } = shipment
    const contentWidthClass = loadType === 'cargo_item' ? 'content_width_booking' : 'content_width_booking_half'

    return (
      <div name="cargoSection" className="route_section_form layout-row flex-100 layout-wrap layout-align-center-center">
        <div className={`layout-row flex-none layout-wrap layout-align-center-center ${contentWidthClass}`}>
          {loadType === 'cargo_item' && (
            <CargoUnitToggleMode
              disabled={!scope.total_dimensions}
              checked={shipment.aggregatedCargo}
              onToggleAggregated={this.handleToggleAggregated}
            />
          )}
          <CargoUnits
            ShipmentDetails={ShipmentDetails}
            cargoItemTypes={cargoItemTypes}
            toggleModal={toggleModal}
            maxDimensions={maxDimensions}
            maxAggregateDimensions={maxAggregateDimensions}
            onChangeCargoUnitCheckbox={this.handleChangeCargoUnitCheckbox}
            onChangeCargoUnitInput={this.handleChangeCargoUnitInput}
            onChangeCargoUnitSelect={this.handleChangeCargoUnitSelect}
            onDeleteUnit={this.handleDeleteUnit}
            getPropValue={this.getPropValue}
            getPropStep={this.getPropStep}
            scope={scope}
            theme={theme}
            totalShipmentErrors={totalShipmentErrors}
            {...shipment}
          />

          {
            !aggregatedCargo && (
              <div className="flex-100 layout-row layout-align-start">
                <AddUnitButton theme={theme} onClick={this.handleAddUnit} />
              </div>
            )
          }
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, app, bookingData } = state
  const { shipment, ShipmentDetails } = bookingProcess
  const { tenant } = app
  const { theme, scope } = tenant
  const { cargoItemTypes, maxDimensions, maxAggregateDimensions } = get(bookingData, 'response.stage1', {})

  return {
    shipment, theme, scope, ShipmentDetails, maxDimensions, maxAggregateDimensions, cargoItemTypes
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(CargoSection)
