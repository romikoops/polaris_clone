/* eslint-disable camelcase */
import React, { PureComponent } from 'react'

class ContainerInputs extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      width: props.width,
      length: props.length,
      height: props.height,
      payload_in_kg: props.payload_in_kg,
      quantity: props.quantity
    }
  }

  render () {
    const { handleChange } = this.props
    const { width, length, height, payload_in_kg, quantity } = this.state

    return (
      <div className="flex-100 layout-row layout-align-start-start">
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={handleChange} name="length" value={length} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={handleChange} name="width" value={width} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={handleChange} name="height" value={height} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={handleChange} name="payload_in_kg" value={payload_in_kg} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center">
          <input type="number" onChange={handleChange} name="quantity" value={quantity} />
        </div>
      </div>
    )
  }
}

export default ContainerInputs
