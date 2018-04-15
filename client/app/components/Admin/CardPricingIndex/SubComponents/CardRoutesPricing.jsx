import React, { Component } from 'react'
import styles from '../Card.scss'

class CardRoutePricing extends Component {
  constructor (props) {
    super(props)
    // import routes (ツ?)
    // import clients (ツ?)

    // clients: how many clients i have (active) in total for each route?
    // *OPT* fees: how many different fees?
  }
  render () {
    return (
      // .card-route-pricing --> will be a flexbox
      // .top-routes --> border-bottom
      // TODO: calc number of clients and fees
      <div className="card-route-pricing">
        <div className="top-routes">
          <div className="">
            <p>From: <strong><span> Stockholm </span></strong></p>
            <p>To: <strong><span> Guthenberg </span></strong></p>
          </div>
          <i>icon</i>
        </div>
        <div className="bottom-routes">
          <p><strong> 3 </strong> clients</p>
          <p><strong> 2 </strong> fees</p>
        </div>
      </div>
      )
  }
}

export default CardRoutePricing
