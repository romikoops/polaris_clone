import React, { Component } from 'react'
import styles from '../Card.scss'
import AdminItineraryRow from './'
import { v4 } from 'node-uuid'
import PropTypes from 'prop-types'

class CardRoutePricing extends Component {
  constructor (props) {
    super(props)
    // import routes (ツ?)
    // import clients (ツ?)

    // clients: how many clients i have (active) in total for each route?
    // *OPT* fees: how many different fees?
    this.selectItinerary = this.selectItinerary.bind(this)
  }

  selectItinerary () {
    const { itinerary, handleClick } = this.props
    handleClick(itinerary)
  }

  render () {
    const {
      itinerary
    } = this.props
    return (
      // .card-route-pricing --> will be a flexbox
      // .top-routes --> border-bottom
      // TODO: calc number of clients and fees
      <div className="card-route-pricing">
        <div className="top-routes">
          <div>
            <p>From: <strong><span> {itinerary.name} </span></strong></p>
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

CardRoutePricing.propTypes = {
  itinerary: PropTypes.objectOf(PropTypes.any).isRequired,
  handleClick: PropTypes.func.isRequired,
}

export default CardRoutePricing
