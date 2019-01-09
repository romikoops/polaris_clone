import React from 'react'
import { get } from 'lodash'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions } from '../../../actions'
import CargoUnits from './CargoUnits'
import CargoUnitToggleMode from './CargoUnits/CargoUnit/ToggleMode'
import AddUnitButton from './AddUnitButton'

class CargoSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.handleAddUnit = this.handleAddUnit.bind(this)
    this.handleToggleAggregated = this.handleToggleAggregated.bind(this)
    this.handleDeleteUnit = this.handleDeleteUnit.bind(this)
    this.handleUpdateCargoUnit = this.handleUpdateCargoUnit.bind(this)
    this.handleChangeCargoUnitSelect = this.handleChangeCargoUnitSelect.bind(this)
    this.handleChangeCargoUnitInput = this.handleChangeCargoUnitInput.bind(this)
    this.handleChangeCargoUnitCheckbox = this.handleChangeCargoUnitCheckbox.bind(this)

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
      sizeClass: 'smallDryContainer',
      quantity: 1,
      dangerousGoods: false
      // Below props are still not used
      // tareWeight: 0,
      // payloadInKg: 0
    }
    if (props.shipment.cargoUnits.length === 0) this.handleAddUnit()
  }

  getNewUnit () {
    const { loadType } = this.props.shipment

    return loadType === 'cargo_item' ? { ...this.cargoItem } : { ...this.container }
  }

  handleDeleteUnit (cargoUnit, i) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.deleteCargoUnit(i)
  }

  handleAddUnit (cargoUnit) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.addCargoUnit(this.getNewUnit())
  }

  handleChangeCargoUnitInput (e) {
    const [index, prop] = e.target.name.split('-')

    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit({
      index: Number(index),
      prop,
      newValue: Number(e.target.value)
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

  handleChangeCargoUnitSelect ({ name, value }) {
    const [index, prop] = name.split('-')

    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit({
      index: Number(index),
      prop,
      newValue: value
    })
  }

  handleToggleAggregated () {
    const { bookingProcessDispatch, shipment } = this.props
    bookingProcessDispatch.updateShipment(
      'aggregatedCargo',
      !shipment.aggregatedCargo
    )
  }

  handleUpdateCargoUnit (payload) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateCargoUnit(payload)
  }

  render () {
    const {
      theme, scope, cargoItemTypes, maxDimensions, t, shipment, ShipmentDetails, toggleModal
    } = this.props

    return (
      <div className="route_section_form layout-row flex-100 layout-wrap layout-align-center-center">
        <div className="layout-row flex-none layout-wrap layout-align-center-center content_width_booking">
          {shipment.loadType === 'cargo_item' && (
            <CargoUnitToggleMode disabled={!scope.total_dimensions} t={t} checked={shipment.aggregatedCargo} onToggleAggregated={this.handleToggleAggregated} />
          )}
          <CargoUnits
            ShipmentDetails={ShipmentDetails}
            cargoItemTypes={cargoItemTypes}
            toggleModal={toggleModal}
            maxDimensions={maxDimensions}
            onChangeCargoUnitCheckbox={this.handleChangeCargoUnitCheckbox}
            onChangeCargoUnitInput={this.handleChangeCargoUnitInput}
            onChangeCargoUnitSelect={this.handleChangeCargoUnitSelect}
            onDeleteUnit={this.handleDeleteUnit}
            onUpdateCargoUnit={this.handleUpdateCargoUnit}
            scope={scope}
            theme={theme}
            {...shipment}
          />

          <div className="flex-100 layout-row layout-align-start">
            <AddUnitButton theme={theme} onClick={this.handleAddUnit} />
          </div>
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
  const { cargoItemTypes, maxDimensions } = get(bookingData, 'response.stage1', {})

  return {
    shipment, theme, scope, ShipmentDetails, maxDimensions, cargoItemTypes
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(CargoSection)
