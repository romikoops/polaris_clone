import React, { Component } from 'react'
import { Switch, Route } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { AdminShipmentView, AdminShipmentsIndex } from './'
// import {v4} from 'node-uuid';
// import { withRouter } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton'
import { adminActions } from '../../actions'
import { TextHeading } from '../TextHeading/TextHeading'

class AdminShipments extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedShipment: false
    }
    this.viewShipment = this.viewShipment.bind(this)
    this.backToIndex = this.backToIndex.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
  }
  componentDidMount () {
    const { shipments, loading, adminDispatch } = this.props
    if (!shipments && !loading) {
      adminDispatch.getShipments(false)
    }
  }
  viewShipment (shipment) {
    const { adminDispatch } = this.props
    adminDispatch.getShipment(shipment.id, true)
    this.setState({ selectedShipment: true })
  }

  backToIndex () {
    const { dispatch, history } = this.props
    this.setState({ selectedShipment: false })
    dispatch(history.push('/admin/shipments'))
  }
  handleShipmentAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }

  render () {
    const { selectedShipment } = this.state
    const {
      theme,
      hubs,
      shipments,
      clients,
      shipment,
      loading,
      adminDispatch,
      hubHash
    } = this.props
    // ;
    if (!shipments || !hubs || !clients) {
      return <h1>NO SHIPMENTS DATA</h1>
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={this.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <TextHeading theme={theme} size={1} text="Shipments" />
          {selectedShipment ? backButton : ''}
        </div>
        <Switch className="flex">
          <Route
            exact
            path="/admin/shipments"
            render={props => (
              <AdminShipmentsIndex
                theme={theme}
                handleShipmentAction={this.handleShipmentAction}
                clients={clients}
                hubs={hubs}
                hubHash={hubHash}
                shipments={shipments}
                viewShipment={this.viewShipment}
                {...props}
              />
            )}
          />
          <Route
            exact
            path="/admin/shipments/:id"
            render={props => (
              <AdminShipmentView
                theme={theme}
                adminDispatch={adminDispatch}
                loading={loading}
                hubs={hubs}
                handleShipmentAction={this.handleShipmentAction}
                shipmentData={shipment}
                clients={clients}
                {...props}
              />
            )}
          />
        </Switch>
      </div>
    )
  }
}
AdminShipments.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  shipment: PropTypes.shipment,
  clients: PropTypes.arrayOf(PropTypes.client),
  hubHash: PropTypes.objectOf(PropTypes.hub),
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getShipments: PropTypes.func
  }).isRequired,
  dispatch: PropTypes.func.isRequired,
  history: PropTypes.history.isRequired
}

AdminShipments.defaultProps = {
  theme: null,
  hubs: null,
  shipments: [],
  shipment: null,
  clients: [],
  loading: false,
  hubHash: null
}

function mapStateToProps (state) {
  const { authentication, tenant, admin } = state
  const { user, loggedIn } = authentication
  const {
    clients, shipment, shipments, hubs, loading
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    clients,
    shipments,
    shipment,
    hubs,
    loading
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminShipments)
