import React, { Component } from 'react'
import styles from '../Card.scss'

class CardRoutePricing extends Component {
  constructor (props) {
    super(props)
    // import routes (ツ?)
    // import clients (ツ?)
  }
  render () {
    return (
      // .card-route-pricing --> will be a flexbox
      // .top-routes --> border-bottom
      // TODO: calc number of clients and fees
      <div className="card-route-pricing">
        <div className="top-routes">
          <div className="">
            <p>From: <strong><span> (ツ?) </span></strong></p>
            <p>To: <strong><span> (ツ?) </span></strong></p>
          </div>
          <i></i>
        </div>
        <div className="bottom-routes">
          <p><strong> (ツ?) </strong> clients</p>
          <p><strong> (ツ?) </strong> fees</p>
        </div>
      </div>
      )
  }
}

export default CardRoutePricing;
