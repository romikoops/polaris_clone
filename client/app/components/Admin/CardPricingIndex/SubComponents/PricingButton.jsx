import React, { Component } from 'react'
import styles from '../Card.scss'


class PricingButton extends Component {
  constructor (props) {
    super(props)
  }
  render () {
    return (
      <div className="pricing-button">
        <p className="center-items">+ New Route Pricing</p>
      </div>
      )
  }
}

export default PricingButton;
