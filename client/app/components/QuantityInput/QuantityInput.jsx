import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'
import { ValidatedInput } from '../ValidatedInput/ValidatedInput'
import styles from './QuantityInput.scss'

export default class QuantityInput extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      pressedUp: false,
      pressedDown: false
    }
  }

  handleKeyDown (e) {
    if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
      this.setState({
        pressedUp: e.key === 'ArrowUp',
        pressedDown: e.key === 'ArrowDown'
      })
      setTimeout(() => {
        this.setState({
          pressedUp: false,
          pressedDown: false
        })
      }, 300)
      // do stuff
    } else if (e.key === '.') {
      e.preventDefault()
    }
  }

  handleChange (e) {
    // if (e.target.value <= 0 || e.target.value === '') {
    //   e.preventDefault()
    //   return false
    // }
    this.props.handleDelta(e)
    return true
  }

  render () {
    const {
      cargoItem,
      i,
      firstRenderInputs,
      nextStageAttempt
    } = this.props

    const { pressedUp, pressedDown } = this.state

    return (
      <div
        className={
          `${styles.quantity} layout-row flex-100 ` +
          `${pressedUp && styles.pressed_up} ${pressedDown && styles.pressed_down} ` +
          'layout-wrap layout-align-start-center'
        }
      >
        <div className="flex-100 layout-row">
          <ValidatedInput
            onKeyDown={e => this.handleKeyDown(e)}
            wrapperClassName="flex-100"
            name={`${i}-quantity`}
            value={cargoItem ? cargoItem.quantity : ''}
            type="number"
            min="0"
            step="any"
            onChange={e => this.handleChange(e)}
            firstRenderInputs={firstRenderInputs}
            setFirstRenderInputs={this.setFirstRenderInputs}
            nextStageAttempt={nextStageAttempt}
            validations={{
              nonNegative: (values, value) => value > 0
            }}
            validationErrors={{
              nonNegative: 'Must be greater than 0'
            }}
          />
        </div>
        <hr className="flex-100" />
        <p className="flex-100 layout-row layout-align-center-start"> Quantity </p>
      </div>
    )
  }
}
QuantityInput.propTypes = {
  cargoItem: PropTypes.objectOf(PropTypes.any),
  i: PropTypes.integer,
  handleDelta: PropTypes.func,
  firstRenderInputs: PropTypes.bool,
  nextStageAttempt: PropTypes.bool
}

QuantityInput.defaultProps = {
  cargoItem: null,
  i: -1,
  handleDelta: null,
  firstRenderInputs: false,
  nextStageAttempt: false
}
