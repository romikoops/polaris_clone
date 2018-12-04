import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../../prop-types'

class CargoItemInputs extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      dimension_x: props.dimension_x,
      dimension_y: props.dimension_y,
      dimension_z: props.dimension_z,
      payload_in_kg: props.payload_in_kg,
      quantity: props.quantity
    }
  }
  render () {
    return (
      <div className="flex-100 layout-row layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{this.props.t('admin:cargoItemSmallCaps')} {this.props.index + 1}</p>
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={this.props.handleChange} placeholder={this.props.t('common:width')} name="dimension_x" value={this.state.dimension_x} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={this.props.handleChange} placeholder={this.props.t('common:length')} name="dimension_y" value={this.state.dimension_y} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={this.props.handleChange} placeholder={this.props.t('common:height')} name="dimension_z" value={this.state.dimension_z} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={this.props.handleChange} placeholder={this.props.t('common:payload')} name="payload_in_kg" value={this.state.payload_in_kg} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={this.props.handleChange} placeholder={this.props.t('admin:quantity')} name="quantity" value={this.state.quantity} />
        </div>
      </div>
    )
  }
}

CargoItemInputs.propTypes = {
  t: PropTypes.func.isRequired,
  dimension_x: PropTypes.number,
  dimension_y: PropTypes.number,
  dimension_z: PropTypes.number,
  payload_in_kg: PropTypes.number,
  quantity: PropTypes.number,
  index: PropTypes.number,
  handleChange: PropTypes.func
}
CargoItemInputs.defaultProps = {
  dimension_x: 0,
  dimension_y: 0,
  dimension_z: 0,
  payload_in_kg: 0,
  quantity: 0,
  index: 0,
  handleChange: null
}

export default withNamespaces(['admin', 'common'])(CargoItemInputs)
