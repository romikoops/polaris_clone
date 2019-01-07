import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'

import styles from './Admin.scss'

import { capitalize, gradientTextGenerator, switchIcon } from '../../helpers'

import Tab from '../Tabs/Tab'
import Tabs from '../Tabs/Tabs'

import CardRoutesIndex from './CardRouteIndex'

import { WorldMap } from './DashboardMap/WorldMap'

export class AdminRoutesIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchFilters: {}
    }
  }

  componentDidMount () {
    const { itineraries, loading, adminDispatch } = this.props
    if (!itineraries && !loading) {
      adminDispatch.getItineraries(false)
    }
    window.scrollTo(0, 0)
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  toggleFilterValue (target, key) {
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        [target]: {
          ...this.state.searchFilters[target],
          [key]: !this.state.searchFilters[target][key]
        }
      }
    })
  }
  handleSearchQuery (e) {
    const { value } = e.target
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        query: value
      }
    })
  }

  render () {
    const {
      t, theme, itineraries, adminDispatch, tenant, toggleNewRoute, user
    } = this.props

    if (!itineraries) {
      return ''
    }
    const { scope } = tenant

    const modesOfTransport = scope.modes_of_transport
    const modeOfTransportNames = Object.keys(modesOfTransport).filter(modeOfTransportName =>
      Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool))

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }

    const motTabs = modeOfTransportNames.sort().map(mot => (<Tab
      tabTitle={capitalize(mot)}
      theme={theme}
      icon={switchIcon(mot, gradientFontStyle)}
    >
      <CardRoutesIndex
        itineraries={itineraries.filter(itin => itin.mode_of_transport === mot)}
        theme={theme}
        scope={scope}
        mot={mot}
        user={user}
        newText={t('admin:newRoutePlain')}
        adminDispatch={adminDispatch}
        toggleNew={toggleNewRoute}
        handleClick={id => adminDispatch.getItinerary(id, true)}
      />
    </Tab>))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start extra_padding_left">
        <div className={`${styles.component_view} flex layout-row layout-align-start-start`}>
          <Tabs
            wrapperTabs="layout-row flex-45 flex-sm-40 flex-xs-80"
            paddingFixes
          >
            {motTabs}

          </Tabs>
        </div>
      </div>
    )
  }
}

AdminRoutesIndex.defaultProps = {
  theme: null,
  loading: false,
  tenant: { data: {} }
}

export default withNamespaces('admin')(AdminRoutesIndex)
