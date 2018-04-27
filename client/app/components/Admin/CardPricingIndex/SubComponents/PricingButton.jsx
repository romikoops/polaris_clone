import React, { Component } from 'react'
import styles from '../Card.scss'


class PricingButton extends Component {
  constructor (props) {
    super(props)
  }

  render () {
    const { onClick, onDisabledClick, disabled } = this.props
    const disabledClass = disabled ? styles.disabled : ''
    return (
      <div
        className={`${styles.pricing_button} ${disabledClass} layout-row layout-align-center-center`}
        onClick={disabled ? onDisabledClick : onClick}
      >
        <p className="flex-none">+ New Route Pricing</p>
      </div>
    )
  }
}

export default PricingButton;
