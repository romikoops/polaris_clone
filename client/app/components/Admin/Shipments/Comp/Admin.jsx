import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminDashboard as adminTip } from '../../../../constants'
import { filters, capitalize } from '../../../../helpers'
import Tabs from '../../../Tabs/Tabs'
import Tab from '../../../Tabs/Tab'
import { adminActions, appActions } from '../../../../actions'
import AdminShipmentsBox from './box' // eslint-disable-line

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
      }
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.determinePerPage = this.determinePerPage.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
    this.determinePerPage()
    window.addEventListener('resize', this.determinePerPage)
  }
  componentWillUnmount () {
    window.removeEventListener('resize', this.determinePerPage)
  }

  getShipmentsFromPage (pages) {
    const { adminDispatch } = this.props
    const { perPage } = this.state
    adminDispatch.getShipments(pages, perPage, false)
  }
  getTargetShipmentsFromPage (target, page) {
    const { adminDispatch } = this.props
    const { perPage } = this.state
    adminDispatch.deltaShipmentsPage(target, page, perPage)
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
    const selectValues = selection
    delete selectValues.name

    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        countries: Object.values(selectValues)
      }
    }, () => this.handleFilters())
  }

  handlePage (target, delta) {
    const { perPage } = this.state
    const { pages } = this.props.shipments
    const nextPage = +pages[target] + (1 * delta)
    const realPage = nextPage > 0 ? nextPage : 1
    this.getTargetShipmentsFromPage(target, realPage, perPage)
  }
  handleFilters () {
    this.setState((prevState) => {
      const { perPage } = this.state
      const { pages } = this.props.shipments
      this.getShipmentsFromPage(pages, perPage)

      return { page: prevState.page }
    })
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
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={adminDispatch}
              shipments={mergedShipments[status]}
              theme={theme}
              status={status}
              confirmShipmentData={confirmShipmentData}
              searchText={search[status]}
              tooltip={adminTip[status]}
              page={pages[status]}
              numPages={numShipmentsPages[status]}
              prevPage={() => this.prevPage(status)}
              nextPage={() => this.nextPage(status)}
              handleSearchChange={e => this.handleSearchQuery(e, status)}
            />
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
    clients, shipments, confirmShipmentData
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
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentsCompAdmin)
