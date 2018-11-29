import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminDashboard as adminTip } from '../../../../constants'
import { filters, capitalize, loadOriginNexus, loadDestinationNexus, loadClients, loadMot } from '../../../../helpers'
import Tabs from '../../../Tabs/Tabs'
import Tab from '../../../Tabs/Tab'
import { adminActions, appActions } from '../../../../actions'
import AdminShipmentsBox from './box' // eslint-disable-line
import NamedSelect from '../../../NamedSelect/NamedSelect'

export class ShipmentsCompAdmin extends Component {
  static prepShipment (baseShipment, clients) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''

    return shipment
  }
  constructor (props) {
    super(props)
    this.state = {
      search: {
        open: '',
        requested: '',
        finished: '',
        archived: '',
        rejected: ''
      },
      searchFilters: {
        countries: []
      },
      page: 1,
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.determinePerPage = this.determinePerPage.bind(this)
    this.handleInput = this.handleInput.bind(this)
    this.handleFilters = this.handleFilters.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
    this.determinePerPage()
    window.addEventListener('resize', this.determinePerPage)
  }
  componentWillUnmount () {
    window.removeEventListener('resize', this.determinePerPage)
  }
  getShipmentsFromPage (pages, params) {
    const { adminDispatch } = this.props
    const { perPage } = this.state
    adminDispatch.getShipments(pages, perPage, params, false)
  }
  getTargetShipmentsFromPage (target, page, params) {
    const { adminDispatch } = this.props
    const { perPage } = this.state
    adminDispatch.deltaShipmentsPage(target, page, perPage, params)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }
  determinePerPage () {
    const { perPage } = this.state
    const { adminDispatch, shipments } = this.props
    const { pages } = shipments
    const width = window.innerWidth
    const newPerPage = width >= 1920 ? 6 : 4
    if (newPerPage !== perPage) {
      adminDispatch.getShipments(pages, newPerPage, false)
    }
    this.setState({ perPage: newPerPage })
  }

  searchShipmentsFromPage (text, target, page) {
    const { perPage } = this.state
    const { adminDispatch } = this.props
    adminDispatch.searchShipments(text, target, page, perPage)
  }

  handlePage (target, delta) {
    const { pages } = this.props.shipments
    const nextPage = +pages[target] + (1 * delta)
    const realPage = nextPage > 0 ? nextPage : 1
    this.handleFilters(target, realPage)
  }

  nextPage (target) {
    this.handlePage(target, 1)
  }
  prevPage (target) {
    this.handlePage(target, -1)
  }
  doNothing () {
    console.log(this.state.page)
  }

  handleSearchQuery (e, target) {
    const { value } = e.target

    this.setState({
      search: {
        ...this.state.search,
        [target]: value
      }
    }, () => this.searchShipmentsFromPage(value, target, 1))
  }

  handleInput (selection) {
    const { name, ...others } = selection

    this.setState(prevState => ({
      searchFilters: {
        ...prevState.searchFilters,
        [name]: Object.values(others).map(x => x.value)
      }
    }), () => this.handleFilters())
  }
  handleFilters (target, realPage) {
    const { searchFilters } = this.state
    const { pages } = this.props.shipments

    const hubTypes = searchFilters.hubType
      ? searchFilters.hubType.filter(key => !searchFilters.hubType[key])
      : null
    const originNexuses = searchFilters.originNexus && searchFilters.originNexus.length > 0
      ? searchFilters.originNexus
      : null
    const destinationNexuses = searchFilters.destinationNexus && searchFilters.destinationNexus.length > 0
      ? searchFilters.destinationNexus
      : null
    const clients = searchFilters.clients && searchFilters.clients.length > 0
      ? searchFilters.clients
      : null
    const params = {}

    if (hubTypes) {
      params.hub_type = hubTypes
    }
    if (originNexuses) {
      params.origin_nexus = originNexuses
    }
    if (destinationNexuses) {
      params.destination_nexus = destinationNexuses
    }
    if (clients) {
      params.clients = clients
    }

    if (target) {
      this.getTargetShipmentsFromPage(target, realPage, params)
    } else {
      const pageReset = {
        open: '1',
        requested: '1',
        finished: '1',
        archived: '1',
        rejected: '1'
      }
      this.getShipmentsFromPage(pageReset, params)
    }
  }

  render () {
    const {
      theme,
      hubs,
      shipments,
      confirmShipmentData,
      clients,
      numShipmentsPages,
      hubHash,
      adminDispatch
    } = this.props
    const { search } = this.state

    if (!shipments || !shipments.pages || !hubs || !clients) {
      return ''
    }

    const { pages } = shipments
    const clientHash = {}
    clients.forEach((cl) => {
      clientHash[cl.id] = cl
    })

    const statusKeys = Object.keys(pages)
    const mergedShipments = {}
    statusKeys.forEach((status) => {
      mergedShipments[status] = filters.sortByDate(shipments[status], 'booking_placed_at')
        .map(sh => ShipmentsCompAdmin.prepShipment(sh, clientHash, hubHash))
    })
    const keysToRender = statusKeys.includes('quoted')
      ? statusKeys : ['requested', 'open', 'finished', 'rejected', 'archived']


    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          {keysToRender.map(status => (<Tab
            tabTitle={capitalize(status)}
            theme={theme}
            paddingFixes
          >
            <div>
              <div className="flex-100 layout-row padding_top">
                <div className="flex-15 layout-row">
                  <NamedSelect
                    className="flex-100 selectors"
                    multi
                    name="originNexus"
                    placeholder="Origin"
                    value={this.state.searchFilters.originNexus}
                    autoload={false}
                    options={filters.sortByAlphabet(loadOriginNexus(shipments.nexuses[status]), 'label')}
                    onChange={e => this.handleInput(e)}
                  />
                </div>
                <div className="flex-15 layout-row">
                  <NamedSelect
                    className="flex-100 selectors"
                    multi
                    name="destinationNexus"
                    placeholder="Destination"
                    value={this.state.searchFilters.destinationNexus}
                    autoload={false}
                    options={filters.sortByAlphabet(loadDestinationNexus(shipments.nexuses[status]), 'label')}
                    onChange={e => this.handleInput(e)}
                  />
                </div>
                <div className="flex-15 layout-row">
                  <NamedSelect
                    className="flex-100 selectors"
                    multi
                    name="hubType"
                    placeholder="Mode of Transport"
                    value={this.state.searchFilters.hubType}
                    autoload={false}
                    options={loadMot()}
                    onChange={e => this.handleInput(e)}
                  />
                </div>
                <div className="flex-15 layout-row">
                  <NamedSelect
                    className="flex-100 selectors"
                    multi
                    name="clients"
                    placeholder="Clients"
                    value={this.state.searchFilters.clients}
                    autoload={false}
                    options={filters.sortByAlphabet(loadClients(clients), 'label')}
                    onChange={e => this.handleInput(e)}
                  />
                </div>
              </div>
              <AdminShipmentsBox
                handleClick={this.viewShipment}
                dispatches={adminDispatch}
                shipments={mergedShipments[status]}
                theme={theme}
                nexuses={shipments.nexuses[status]}
                countries={shipments.countries}
                countriesIds={shipments[status]}
                status={status}
                confirmShipmentData={confirmShipmentData}
                tooltip={adminTip[status]}
                searchFilters={this.state.searchFilters}
                page={pages[status]}
                numPages={numShipmentsPages[status]}
                prevPage={() => this.prevPage(status)}
                nextPage={() => this.nextPage(status)}
                handleSearchChange={e => this.handleSearchQuery(e, status)}
                handleInput={e => this.handleInput(e)}
                getShipmentsRequest={this.props.getShipmentsRequest}
              />
            </div>
          </Tab>))}
        </Tabs>
      </div>
    )

    return (
      <div
        className="flex-100 layout-row layout-wrap layout-align-start-start"
        ref={(ref) => { this.viewport = ref }}
      >
        {listView}
      </div>
    )
  }
}
ShipmentsCompAdmin.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.objectOf(PropTypes.array),
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  clients: PropTypes.arrayOf(PropTypes.clients),
  numShipmentsPages: PropTypes.number,
  viewShipment: PropTypes.func.isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}

ShipmentsCompAdmin.defaultProps = {
  theme: null,
  hubs: [],
  shipments: {},
  confirmShipmentData: {},
  clients: [],
  hubHash: {},
  adminDispatch: {},
  numShipmentsPages: 1
}

function mapStateToProps (state) {
  const {
    authentication, app, admin, document
  } = state
  const { tenant } = app
  const { theme } = tenant
  const { user, loggedIn } = authentication
  const {
    clients, shipments, confirmShipmentData, getShipmentsRequest
  } = admin
  const { num_shipment_pages } = shipments  // eslint-disable-line

  return {
    user,
    tenant,
    loggedIn,
    theme,
    confirmShipmentData,
    shipments,
    numShipmentsPages: num_shipment_pages,
    clients,
    document,
    getShipmentsRequest
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentsCompAdmin)
