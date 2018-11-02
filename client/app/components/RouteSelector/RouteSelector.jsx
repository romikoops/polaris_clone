import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import Fuse from 'fuse.js'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { RouteOption } from '../RouteOption/RouteOption'
import styles from './RouteSelector.scss'
import defs from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'

export class RouteSelector extends Component {
  constructor (props) {
    super(props)
    this.state = {
      routes: this.props.routes
    }
    this.routeSelected = this.routeSelected.bind(this)
    this.togglePublic = this.togglePublic.bind(this)
    this.handleSearchChange = this.handleSearchChange.bind(this)
  }

  routeSelected (route) {
    this.props.routeSelected(route)
  }
  togglePublic () {
    this.setState({ viewPublic: !this.state.viewPublic })
  }
  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        routes: this.props.routes
      })

      return
    }

    const search = (key) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys: [key]
      }
      const fuse = new Fuse(this.props.routes, options)

      return fuse.search(event.target.value)
    }

    const filteredRoutesOrigin = search('originNexus')
    const filteredRoutesDestination = search('destinationNexus')

    let TopRoutes = filteredRoutesDestination.filter(route => filteredRoutesOrigin.includes(route))

    if (TopRoutes.length === 0) {
      TopRoutes = filteredRoutesDestination.concat(filteredRoutesOrigin)
    }

    this.setState({
      routes: TopRoutes
    })
  }

  render () {
    const { theme, t } = this.props
    const routes = this.state.routes ? this.state.routes : this.props.routes
    if (!routes) {
      return (
        <div className={`flex-100 layout-row layout-align-center-start ${styles.selector}`}>
          {t('errors:noRoutesFound')}
        </div>
      )
    }
    const routesOptions = routes.map(route => (
      <RouteOption key={v4()} theme={theme} route={route} routeSelected={this.routeSelected} />
    ))

    return (
      <div className={`flex-100 layout-row layout-align-center-start ${styles.selector}`}>
        <div className={`${defs.content_width} layout-row layout-wrap`}>
          <div className="flex-100 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div className="flex-none layput-row layout-align-start-center">
                <TextHeading theme={theme} size={2} text={t('shipment:availableRoutes')} />
              </div>
              <div className={`${styles.input_box} flex-none layput-row layout-align-start-center`}>
                <input
                  type="text"
                  name="search"
                  placeholder={t('shipment:searchRoute')}
                  onChange={this.handleSearchChange}
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
              {routesOptions}
            </div>
          </div>
        </div>
      </div>
    )
  }
}
RouteSelector.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  routeSelected: PropTypes.func.isRequired,
  routes: PropTypes.arrayOf(PropTypes.route).isRequired
}

RouteSelector.defaultProps = {
  theme: null
}

export default withNamespaces(['errors', 'shipment'])(RouteSelector)
