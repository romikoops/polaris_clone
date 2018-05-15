import React, { Component } from 'react'
import { Redirect } from 'react-router'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminRouteTile } from './'
import { history } from '../../helpers'
// import { pricingNames } from '../../constants/admin.constants';
import { AdminSearchableRoutes } from './AdminSearchables'
import { RoundButton } from '../RoundButton/RoundButton'

export class AdminPricingsRouteIndex extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      redirect: false
    }
    this.viewRoute = this.viewRoute.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }

  viewRoute (route) {
    const { adminTools } = this.props
    adminTools.getItineraryPricings(route.id, true)
  }

  render () {
    const { theme, hubs, itineraries } = this.props
    // const { selectedPricing } = this.state;
    if (!itineraries) {
      return ''
    }
    if (this.state.redirect) {
      return <Redirect push to="/admin/pricings" />
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={AdminPricingsRouteIndex.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    let routesArr
    if (itineraries) {
      routesArr = itineraries.map(rt => (
        <AdminRouteTile
          key={v4()}
          hubs={hubs}
          route={rt}
          theme={theme}
          handleClick={() => this.viewRoute(rt)}
        />
      ))
    }
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            Route Pricings
          </p>
          {backButton}
        </div>
        <AdminSearchableRoutes
          itineraries={itineraries}
          theme={theme}
          hubs={hubs}
          handleClick={this.viewRoute}
          sideScroll={false}
          seeAll={false}
        />
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {routesArr}
          </div>
        </div>
      </div>
    )
  }
}
AdminPricingsRouteIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  itineraries: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number
  })),
  adminTools: PropTypes.shape({
    getRoutePricings: PropTypes.func
  }).isRequired
}

AdminPricingsRouteIndex.defaultProps = {
  theme: null,
  hubs: [],
  itineraries: []
}

export default AdminPricingsRouteIndex
