import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminDashboard as adminTip } from '../../../../constants'
import {
 filters, capitalize, loadOriginNexus, loadDestinationNexus, loadClients, loadMot 
} from '../../../../helpers'
import Tabs from '../../../Tabs/Tabs'
import Tab from '../../../Tabs/Tab'
import { userActions, appActions } from '../../../../actions'
import AdminShipmentsBox from './box' // eslint-disable-line
import NamedSelect from '../../../NamedSelect/NamedSelect'

export class ShipmentsCompUser extends Component {
  static prepShipment (baseShipment, user) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user
      ? `${user.first_name} ${user.last_name}`
      : ''
    shipment.companyName = user
      ? `${user.company_name}`
      : ''

    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {
      perPage: 4,
      search: {},
      searchFilters: {}
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.determinePerPage = this.determinePerPage.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    const pageReset = {
      open: '1',
      requested: '1',
      finished: '1',
      archived: '1',
      rejected: '1'
    }
    this.getShipmentsFromPage(pageReset, {})
    this.determinePerPage()
    window.addEventListener('resize', this.determinePerPage)
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.determinePerPage)
  }

  getShipmentsFromPage (pages, params) {
    const { userDispatch } = this.props
    const { perPage } = this.state
    userDispatch.getShipments(pages, perPage, params, false)
  }

  getTargetShipmentsFromPage (target, page, params) {
    const { userDispatch } = this.props
    const { perPage } = this.state
    userDispatch.deltaShipmentsPage(target, page, perPage, params)
  }

  determinePerPage () {
    const { perPage } = this.state
    const { userDispatch, shipments } = this.props
    if (!shipments) return
    const { pages } = shipments
    const width = window.innerWidth
    const newPerPage = width >= 1920 ? 6 : 4
    if (newPerPage !== perPage) {
      userDispatch.getShipments(pages, newPerPage, false)
    }
    this.setState({ perPage: newPerPage })
  }

  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  searchShipmentsFromPage (text, target, page) {
    const { perPage } = this.state
    const { userDispatch } = this.props
    userDispatch.searchShipments(text, target, page, perPage)
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
    }, () => this.handleFilters())
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

  handlePage (target, delta) {
    const { perPage } = this.state
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
    const { perPage } = this.state

    this.setState({
      search: {
        ...this.state.search,
        [target]: value
      }
    }, () => this.searchShipmentsFromPage(value, target, 1, perPage))
  }

  render () {
    const {
      theme,
      hubs,
      shipments,
      clients,
      numShipmentsPages,
      user,
      userDispatch
    } = this.props

    const { search } = this.state
    if (!shipments || !hubs || !clients) {
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
        .map(sh => ShipmentsCompUser.prepShipment(sh, user))
    })
    const keysToRender = statusKeys.includes('quoted')
      ? statusKeys : ['requested', 'open', 'finished', 'rejected', 'archived']

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          {keysToRender.map(status => (keysToRender.length > 1 ? (
<Tab
            tabTitle={capitalize(status)}
            theme={theme}
          >
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
              </div>
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedShipments[status]}
              status={status}
              theme={theme}
              userView
              searchText={search[status]}
              tooltip={adminTip[status]}
              page={pages[status]}
              numPages={numShipmentsPages[status]}
              prevPage={() => this.prevPage(status)}
              nextPage={() => this.nextPage(status)}
              handleSearchChange={e => this.handleSearchQuery(e, status)}
              getShipmentsRequest={this.props.getShipmentsRequest}
            />
          </Tab>
) : (
<Tab isUniq>
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedShipments[status]}
              theme={theme}
              userView
              status={status}
              searchText={search[status]}
              tooltip={adminTip[status]}
              page={pages[status]}
              numPages={numShipmentsPages[status]}
              prevPage={() => this.prevPage(status)}
              nextPage={() => this.nextPage(status)}
              handleSearchChange={e => this.handleSearchQuery(e, status)}
            />
          </Tab>
)))}

        </Tabs>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">{listView}</div>
    )
  }
}
ShipmentsCompUser.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.objectOf(PropTypes.array),
  clients: PropTypes.arrayOf(PropTypes.clients),
  numShipmentsPages: PropTypes.number,
  viewShipment: PropTypes.func.isRequired,
  user: PropTypes.user,
  userDispatch: PropTypes.objectOf(PropTypes.func)
}

ShipmentsCompUser.defaultProps = {
  theme: null,
  hubs: [],
  shipments: null,
  clients: [],
  user: {},
  userDispatch: {},
  numShipmentsPages: 1
}

function mapStateToProps (state) {
  const {
    authentication, app, users, document
  } = state
  const { tenant } = app
  const { theme } = tenant
  const { user, loggedIn } = authentication
  const {
    shipments,
    getShipmentsRequest
  } = users
  const { num_shipment_pages } = shipments ? shipments : {shipments: {}}  // eslint-disable-line

  return {
    user,
    tenant,
    loggedIn,
    theme,
    shipments,
    numShipmentsPages: num_shipment_pages,
    document,
    getShipmentsRequest
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentsCompUser)
