import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import adminStyles from '../../Admin.scss'
import { adminDashboard as adminTip } from '../../../../constants'
import { filters } from '../../../../helpers'
import Tabs from '../../../Tabs/Tabs'
import Tab from '../../../Tabs/Tab'
import { userActions, appActions } from '../../../../actions'
import AdminShipmentsBox from './box' // eslint-disable-line

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
      search: {}
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

  getShipmentsFromPage (open, requested, finished) {
    const { perPage } = this.state
    const { userDispatch } = this.props
    userDispatch.getShipments(open, requested, finished, perPage, false)
  }
  getTargetShipmentsFromPage (target, page) {
    const { perPage } = this.state
    const { userDispatch } = this.props
    userDispatch.deltaShipmentsPage(target, page, perPage)
  }
  determinePerPage () {
    const { perPage } = this.state
    const { userDispatch, shipments } = this.props
    const { open, requested, finished } = shipments.pages
    const width = window.innerWidth
    const newPerPage = width >= 1920 ? 6 : 4
    if (newPerPage !== perPage) {
      userDispatch.getShipments(open, requested, finished, newPerPage, false)
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
      const { open, requested, finished } = this.props.shipments.pages
      this.getShipmentsFromPage(open, requested, finished, perPage)

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
      clients,
      numShipmentsPages,
      user,
      userDispatch
    } = this.props
    const { pages } = shipments
    const { search } = this.state
    if (!shipments || !hubs || !clients) {
      return ''
    }
    const clientHash = {}
    clients.forEach((cl) => {
      clientHash[cl.id] = cl
    })
    const mergedOpenShipments = filters.sortByDate(shipments.open, 'booking_placed_at')
      .map(sh => ShipmentsCompUser.prepShipment(sh, user))
    const mergedReqShipments = filters.sortByDate(shipments.requested, 'booking_placed_at')
      .map(sh => ShipmentsCompUser.prepShipment(sh, user))
    const mergedFinishedShipments = filters.sortByDate(shipments.finished, 'booking_placed_at')
      .map(sh => ShipmentsCompUser.prepShipment(sh, user))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          <Tab
            tabTitle="Requested"
            theme={theme}
          >
            <AdminShipmentsBox
              handleClick={this.viewShipment}
              dispatches={userDispatch}
              shipments={mergedReqShipments}
              theme={theme}
              userView
              searchText={search.requested}
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
              dispatches={userDispatch}
              shipments={mergedOpenShipments}
              theme={theme}
              userView
              searchText={search.open}
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
              dispatches={userDispatch}
              shipments={mergedFinishedShipments}
              theme={theme}
              userView
              searchText={search.finished}
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
  shipments: {},
  clients: [],
  user: {},
  userDispatch: {},
  numShipmentsPages: 1
}

function mapStateToProps (state) {
  const {
    authentication, tenant, users, document
  } = state
  const { theme } = tenant.data
  const { user, loggedIn } = authentication
  const {
    shipments
  } = users
  const { num_shipment_pages } = shipments ? shipments : {shipments: {}}  // eslint-disable-line

  return {
    user,
    tenant,
    loggedIn,
    theme,
    shipments,
    numShipmentsPages: num_shipment_pages,
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(ShipmentsCompUser)
