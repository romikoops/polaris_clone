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
    } else if (e.key === '.') {
      e.preventDefault()
    }
  }

  render () {
    const {
      cargoItem,
      i,
      nextStageAttempt,
      handleDelta
    } = this.props

    const { pressedUp, pressedDown } = this.state

    return (
      <div className="flex-100 layout-row">
        <div className="flex-100 layout-row layout-align-center">
          <div
            className={
              `${styles.quantity} layout-row flex-100 ` +
              `${pressedUp && styles.pressed_up} ${pressedDown && styles.pressed_down} ` +
              'layout-wrap layout-align-start-center'
            }
          >
            <p
              className="flex-100 layout-row layout-align-center-start"
              style={{ margin: '0 0 4px 0' }}
            >
              Quantity
            </p>
            <div className="flex-100 layout-row">
              <ValidatedInput
                onKeyDown={e => this.handleKeyDown(e)}
                wrapperClassName="flex-100"
                name={`${i}-quantity`}
                value={cargoItem ? cargoItem.quantity : ''}
                type="number"
                min="1"
                step="any"
                placeholder="Quantity"
                onChange={handleDelta}
                errorStyles={{
                  fontSize: '10px',
                  top: '-14px',
                  bottom: 'unset'
                }}
                validations={{ nonNegative: (values, value) => value > 0 }}
                validationErrors={{ nonNegative: 'Must be greater than 0' }}
                firstRenderInputs
                setFirstRenderInputs={this.setFirstRenderInputs}
                nextStageAttempt={nextStageAttempt}
              />
            </div>
            <hr className="flex-70" />
          </div>
        </div>
      </div>
    )
  }
}
QuantityInput.propTypes = {
  cargoItem: PropTypes.objectOf(PropTypes.any),
  i: PropTypes.integer,
  handleDelta: PropTypes.func,
  nextStageAttempt: PropTypes.bool
}

QuantityInput.defaultProps = {
  cargoItem: null,
  i: -1,
  handleDelta: null,
  nextStageAttempt: false
}
