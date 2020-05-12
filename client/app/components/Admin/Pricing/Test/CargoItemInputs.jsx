import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../../prop-types'

class CargoItemInputs extends PureComponent {
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
    const { handleChange, t, index } = this.props
    // eslint-disable-next-line camelcase
    const { width, length, height, payload_in_kg, quantity } = this.state

    return (
      <div className="flex-100 layout-row layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">
            {t('admin:cargoItemSmallCaps')}
            {' '}
            {index + 1}
          </p>
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={handleChange} placeholder={t('common:width')} name="width" value={width} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={handleChange} placeholder={t('common:length')} name="length" value={length} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input type="number" onChange={handleChange} placeholder={t('common:height')} name="height" value={height} />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input
            type="number"
            onChange={handleChange}
            placeholder={t('common:payload')}
            name="payload_in_kg"
            // eslint-disable-next-line camelcase
            value={payload_in_kg}
          />
        </div>
        <div className="flex-25 layout-row layout-align-center-center input_box_full">
          <input
            type="number"
            onChange={handleChange}
            placeholder={t('admin:quantity')}
            name="quantity"
            value={quantity}
          />
        </div>
      </div>
    )
  }
}

CargoItemInputs.propTypes = {
  t: PropTypes.func.isRequired,
  width: PropTypes.number,
  length: PropTypes.number,
  height: PropTypes.number,
  payload_in_kg: PropTypes.number,
  quantity: PropTypes.number,
  index: PropTypes.number,
  handleChange: PropTypes.func
}
CargoItemInputs.defaultProps = {
  width: 0,
  length: 0,
  height: 0,
  payload_in_kg: 0,
  quantity: 0,
  index: 0,
  handleChange: null
}

export default withNamespaces(['admin', 'common'])(CargoItemInputs)
