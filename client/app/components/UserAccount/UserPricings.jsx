import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import PricingList from '../Pricing/List'

class UserPricings extends Component {
  componentDidMount () {
    this.props.setNav('pricings')
    this.props.setCurrentUrl(this.props.match.url)
  }

  render () {
    return (<div
      className="layout-row flex-100 layout-wrap layout-align-center-center"
    >
      <div className="flex-100 layout-row layout-wrap layout-align-center-stretch extra_padding">
        <PricingList />
      </div>
    </div>)
  }
}

UserPricings.propTypes = {
  setNav: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  match: PropTypes.shape({
    url: PropTypes.string
  }).isRequired
}

export default UserPricings
