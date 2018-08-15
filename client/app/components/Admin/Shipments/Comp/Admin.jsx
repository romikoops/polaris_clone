import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import adminStyles from '../../Admin.scss'
import { adminDashboard as adminTip } from '../../../../constants'
import { filters } from '../../../../helpers'
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
    }
    this.viewShipment = this.viewShipment.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }

  getShipmentsFromPage (open, requested, finished) {
    const { adminDispatch } = this.props
    adminDispatch.getShipments(open, requested, finished, false)
  }
  getTargetShipmentsFromPage (target, page) {
    const { adminDispatch } = this.props
    adminDispatch.deltaShipmentsPage(target, page)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  searchShipmentsFromPage (text, target, page) {
    const { adminDispatch } = this.props
    adminDispatch.searchShipments(text, target, page)
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
    const { pages } = this.props.shipments
    const nextPage = +pages[target] + (1 * delta)
    const realPage = nextPage > 0 ? nextPage : 1
    this.getTargetShipmentsFromPage(target, realPage)
  }
  handleFilters () {
    this.setState((prevState) => {
      const { open, requested, finished } = this.props.shipments.pages
      this.getShipmentsFromPage(open, requested, finished)

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
    console.log(value)
    this.searchShipmentsFromPage(value, target, 1)
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
    const { pages } = shipments
    if (!shipments || !hubs || !clients) {
      return ''
    }
    const clientHash = {}
    clients.forEach((cl) => {
      clientHash[cl.id] = cl
    })
    const mergedOpenShipments = filters.sortByDate(shipments.open, 'booking_placed_at')
      .map(sh => ShipmentsCompAdmin.prepShipment(sh, clientHash, hubHash))
    const mergedReqShipments = filters.sortByDate(shipments.requested, 'booking_placed_at')
      .map(sh => ShipmentsCompAdmin.prepShipment(sh, clientHash, hubHash))
    const mergedFinishedShipments = filters.sortByDate(shipments.finished, 'booking_placed_at')
      .map(sh => ShipmentsCompAdmin.prepShipment(sh, clientHash, hubHash))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          <Tab
            tabTitle="Requested"
            theme={theme}
          >
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={adminDispatch}
              shipments={mergedReqShipments}
              theme={theme}
              confirmShipmentData={confirmShipmentData}
              tooltip={adminTip.requested}
              page={pages.requested}
              numPages={numShipmentsPages.requested}
              prevPage={() => this.prevPage('requested')}
              nextPage={() => this.nextPage('requested')}
              handleSearchChange={e => this.handleSearchQuery(e, 'requested')}
            />
          </Tab>
          <Tab
            tabTitle="Open"
            theme={theme}
          >
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={adminDispatch}
              shipments={mergedOpenShipments}
              theme={theme}
              tooltip={adminTip.open}
              page={pages.open}
              numPages={numShipmentsPages.open}
              prevPage={() => this.prevPage('open')}
              nextPage={() => this.nextPage('open')}
              handleSearchChange={e => this.handleSearchQuery(e, 'open')}
            />
          </Tab>
          <Tab
            tabTitle="Finished"
            theme={theme}
          >
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={adminDispatch}
              shipments={mergedFinishedShipments}
              theme={theme}
              page={pages.finished}
              tooltip={adminTip.finished}
              seeAll={false}
              numPages={numShipmentsPages.finished}
              prevPage={() => this.prevPage('finished')}
              nextPage={() => this.nextPage('finished')}
              handleSearchChange={e => this.handleSearchQuery(e, 'finished')}
            />
          </Tab>
        </Tabs>

        {mergedOpenShipments.length === 0 &&
          mergedReqShipments.length === 0 &&
          mergedFinishedShipments.length === 0 ? (
            <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  adminStyles.sec_subheader
                }`}
              >
                <p className={` ${adminStyles.sec_subheader_text} flex-none`}> No Shipments yet</p>
              </div>
              <p className="flex-none"> As shipments are requested, they will appear here</p>
            </div>
          ) : (
            ''
          )}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">{listView}</div>
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
    authentication, tenant, admin, document
  } = state
  const { theme } = tenant.data
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
