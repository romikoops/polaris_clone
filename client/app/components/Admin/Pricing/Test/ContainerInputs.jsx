import React, { PureComponent } from 'react'

class ContainerInputs extends PureComponent {
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
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={this.props.handleChange} name="dimension_x" value={this.state.dimension_x} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={this.props.handleChange} name="dimension_y" value={this.state.dimension_y} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={this.props.handleChange} name="dimension_z" value={this.state.dimension_z} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={this.props.handleChange} name="payload_in_kg" value={this.state.payload_in_kg} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={this.props.handleChange} name="quantity" value={this.state.quantity} />
        </div>
      </div>
    )
  }
}

export default ContainerInputs
