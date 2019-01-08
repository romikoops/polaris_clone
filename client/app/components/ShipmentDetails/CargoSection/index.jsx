import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions } from '../../../actions'
import CargoUnits from './CargoUnits'
import AddUnitButton from './AddUnitButton'

class CargoSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.handleAddUnit = this.handleAddUnit.bind(this)
    this.handleDeleteUnit = this.handleDeleteUnit.bind(this)

    this.cargoItem = {
      payload_in_kg: 0,
      dimension_x: 0,
      dimension_y: 0,
      dimension_z: 0,
      quantity: 1,
      cargo_item_type_id: '',
      dangerous_goods: false,
      stackable: true
    }
    this.container = {
      payload_in_kg: 0,
      sizeClass: '',
      tareWeight: 0,
      quantity: 1,
      dangerous_goods: false
    }

    this.handleAddUnit()
  }

  getNewUnit () {
    const { loadType } = this.props

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

  render () {
    const {
      theme, scope, shipment
    } = this.props

    return (
      <div className="route_section_form layout-row flex-100 layout-wrap layout-align-center-center">
        <div className="layout-row flex-none layout-wrap layout-align-center-center content_width_booking">
          <CargoUnits theme={theme} scope={scope} onDeleteUnit={this.handleDeleteUnit} {...shipment} />

          <div className="flex-100 layout-row layout-align-start">
            <AddUnitButton theme={theme} onClick={this.handleAddUnit} />
          </div>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, app } = state
  const { shipment } = bookingProcess
  const { tenant } = app
  const { theme, scope } = tenant

  return {
    shipment, theme, scope
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(CargoSection)
