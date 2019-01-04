import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import { Redirect } from 'react-router'
import { AdminPriceCreator } from '.'
import CardPricingIndex from './CardPricingIndex'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import AdminTrucking from './AdminTrucking'
import { capitalize } from '../../helpers'

export class AdminPricingsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirectRoutes: false,
      redirectClients: false,
      newPricing: {}
    }
    this.viewAllRoutes = this.viewAllRoutes.bind(this)
    this.viewAllClients = this.viewAllClients.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.viewRoute = this.viewRoute.bind(this)
    this.toggleCreator = this.toggleCreator.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
  }

  getInitialPricingPage () {
    const { adminDispatch, scope } = this.props
    const pages = {}
    Object.keys(scope.modes_of_transport).forEach((mot) => {
      if (Object.values(scope.modes_of_transport[mot]) > 0) {
        pages[mot] = 1
      }
    })
    adminDispatch.getPricings(false, pages)
  }

  toggleCreator (mot) {
    this.setState(prevState => ({
      newPricing: {
        ...prevState.newPricing,
        [mot]: !this.state.newPricing[mot]
      }
    }))
  }

  viewAllRoutes () {
    this.setState({ redirectRoutes: true })
  }

  viewAllClients () {
    this.setState({ redirectClients: true })
  }

  viewClient (client) {
    const { adminDispatch } = this.props
    adminDispatch.getClientPricings(client.id, true)
  }

  viewRoute (route) {
    const { adminDispatch } = this.props
    adminDispatch.getItineraryPricings(route.id, true)
  }

  lclUpload (file) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, 'lcl', false)
  }

  fclUpload (file) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, 'fcl', false)
  }

  render () {
    const {
      t, theme, pricingData, clients, adminDispatch, scope, hubHash
    } = this.props
    const { newPricing } = this.state
    if (!pricingData) {
      return ''
    }

    if (this.state.redirectRoutes) {
      return <Redirect push to="/admin/pricings/routes" />
    }
    if (this.state.redirectClients) {
      return <Redirect push to="/admin/pricings/clients" />
    }

    const {
      itineraries, detailedItineraries, transportCategories, lastUpdate, numItineraryPages
    } = pricingData
    const modesOfTransport = scope.modes_of_transport
    const modeOfTransportNames = Object.keys(modesOfTransport).filter(modeOfTransportName => Object.values(modesOfTransport[modeOfTransportName]).some(bool => bool))

    const motTabs = modeOfTransportNames.sort().map(mot => (
      <Tab
        tabTitle={capitalize(mot)}
        theme={theme}
        mot={mot}
      >
        <CardPricingIndex
          itineraries={detailedItineraries[mot]}
          numPages={numItineraryPages}
          theme={theme}
          scope={scope}
          mot={mot}
          adminDispatch={adminDispatch}
          toggleCreator={() => this.toggleCreator(mot)}
          documentDispatch={this.props.documentDispatch}
          lastUpdate={lastUpdate}
        />
        {newPricing[mot] ? (
          <AdminPriceCreator
            theme={theme}
            itineraries={itineraries}
            clients={clients}
            adminDispatch={adminDispatch}
            detailedItineraries={detailedItineraries}
            transportCategories={transportCategories}
            closeForm={this.toggleCreator}
          />
        ) : (
          ''
        )}
      </Tab>
    ))
    motTabs.push(<Tab
      tabTitle={t('admin:trucking')}
      theme={theme}
      mot="truck"
    >
      <AdminTrucking
        theme={theme}
        hubHash={hubHash}
      />
    </Tab>)

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">

        <Tabs
          wrapperTabs="layout-row flex-45 flex-sm-40 flex-xs-80 margin_bottom"
          paddingFixes
        >
          {motTabs}

        </Tabs>

      </div>
    )
  }
}
AdminPricingsIndex.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  clients: PropTypes.arrayOf(PropTypes.client),
  adminDispatch: PropTypes.shape({
    getClientPricings: PropTypes.func,
    getRoutePricings: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadPricings: PropTypes.func
  }).isRequired,
  pricingData: PropTypes.shape({
    routes: PropTypes.array,
    lastUpdate: PropTypes.string
  }),
  scope: PropTypes.scope,
  hubHash: PropTypes.objectOf(PropTypes.hub)
}

AdminPricingsIndex.defaultProps = {
  theme: null,
  clients: [],
  hubHash: {},
  pricingData: null,
  scope: null
}

export default withNamespaces('admin')(AdminPricingsIndex)
