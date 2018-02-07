import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Route } from 'react-router'
import { withRouter } from 'react-router-dom'
import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { ChooseShipment } from '../../components/ChooseShipment/ChooseShipment'
import Header from '../../components/Header/Header'
import styles from './Shop.scss'
import { ShopStageView } from '../../components/ShopStageView/ShopStageView'
import { ShipmentDetails } from '../../components/ShipmentDetails/ShipmentDetails'
import { ChooseRoute } from '../../components/ChooseRoute/ChooseRoute'
import Loading from '../../components/Loading/Loading'
import { BookingDetails } from '../../components/BookingDetails/BookingDetails'
import { BookingConfirmation } from '../../components/BookingConfirmation/BookingConfirmation'
import { shipmentActions } from '../../actions/shipment.actions'
import { nexusActions } from '../../actions/nexus.actions'
import { Footer } from '../../components/Footer/Footer'

class Shop extends Component {
  constructor (props) {
    super(props)

    this.tenant = this.props.tenant

    this.state = {
      stageTracker: {},
      shopType: 'Booking',
      showRegistration: false
    }
    this.selectLoadType = this.selectLoadType.bind(this)
    this.setShipmentData = this.setShipmentData.bind(this)
    this.selectShipmentRoute = this.selectShipmentRoute.bind(this)
    this.setShipmentContacts = this.setShipmentContacts.bind(this)
    this.selectShipmentStage = this.selectShipmentStage.bind(this)
    this.selectShipmentStageAndGo = this.selectShipmentStageAndGo.bind(this)
    this.toggleShowRegistration = this.toggleShowRegistration.bind(this)
    this.hideRegistration = this.hideRegistration.bind(this)
  }

  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading } = nextProps
    return loading || !(loggingIn || registering)
  }

  getShipment (loadType) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.newShipment(loadType)
  }

  setShipmentData (data) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.setShipmentDetails(data)
  }

  setShipmentContacts (data) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.setShipmentContacts(data)
  }

  selectLoadType (loadType) {
    this.getShipment(loadType)
  }

  selectShipmentStage (stage) {
    this.setState({ stageTracker: { stage } })
  }
  selectShipmentStageAndGo (stage) {
    const { history, bookingData } = this.props
    const activeId = bookingData.activeShipment
    this.setState({ stageTracker: { stage: stage.step } })
    if (stage.step === 1) {
      history.push('/booking/')
    } else {
      history.push(`/booking/${activeId}${stage.url}`)
    }
  }

  toggleShowRegistration (req) {
    this.setState({
      showRegistration: !this.state.showRegistration,
      req
    })
  }

  hideRegistration () {
    this.setState({
      showRegistration: false
    })
  }
  toggleShowMessages () {
    this.setState({
      showMessages: !this.state.showMessages
    })
  }

  selectShipmentRoute (obj) {
    const { shipmentDispatch, bookingData } = this.props
    const { schedule, total } = obj
    const shipmentData = bookingData.response.stage2
    const req = {
      schedules: [schedule],
      total,
      shipment: shipmentData.shipment
    }

    if (this.props.user.guest) {
      this.toggleShowRegistration(req)
      return
    }
    this.hideRegistration()
    shipmentDispatch.setShipmentRoute(req)
  }

  render () {
    const {
      bookingData,
      match,
      loading,
      tenant,
      user,
      shipmentDispatch,
      nexusDispatch,
      currencies,
      dashboard
    } = this.props
    const { theme } = tenant.data
    const { request, response, error } = bookingData
    const route1 = `${match.url}/:shipmentId/shipment_details`
    const route2 = `${match.url}/:shipmentId/choose_route`
    const route3 = `${match.url}/:shipmentId/booking_details`
    const route4 = `${match.url}/:shipmentId/finish_booking`
    const loadingScreen = loading ? <Loading theme={theme} /> : ''
    let shipmentId = ''
    if (response && response.stage1 && !response.stage2) {
      shipmentId = response.stage1.shipment.id
    } else if (response && response.stage1 && response.stage2 && !response.stage3) {
      shipmentId = response.stage2.shipment.id
    } else if (
      response &&
      response.stage1 &&
      response.stage2 &&
      response.stage3 &&
      !response.stage4
    ) {
      shipmentId = response.stage3.shipment.id
    } else if (
      response &&
      response.stage1 &&
      response.stage2 &&
      response.stage3 &&
      response.stage4
    ) {
      shipmentId = response.stage4.shipment.id
    }
    const { req } = this.state

    return (
      <div className="layout-row flex-100 layout-wrap">
        {loadingScreen}
        <Header
          theme={this.props.theme}
          showMessages={this.toggleShowMessages}
          showRegistration={this.state.showRegistration}
          req={req}
        />
        <ShopStageView
          className="flex-100"
          shopType={this.state.shopType}
          match={match}
          theme={theme}
          currentStage={this.state.stageTracker.stage}
          setStage={this.selectShipmentStageAndGo}
          shipmentId={shipmentId}
        />
        <Route
          exact
          path={match.url}
          render={props => (
            <ChooseShipment
              {...props}
              theme={theme}
              selectLoadType={this.selectLoadType}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage1 : []}
              shipmentDispatch={shipmentDispatch}
            />
          )}
        />
        <Route
          path={route1}
          render={props => (
            <ShipmentDetails
              {...props}
              tenant={tenant}
              user={user}
              dashboard={dashboard}
              shipmentData={response ? response.stage1 : {}}
              prevRequest={request && request.stage2 ? request.stage2 : {}}
              req={request && request.stage1 ? request.stage1 : {}}
              setShipmentDetails={this.setShipmentData}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage2 : []}
              shipmentDispatch={shipmentDispatch}
              nexusDispatch={nexusDispatch}
              availableDestinations={this.props.availableDestinations}
            />
          )}
        />
        <Route
          path={route2}
          render={props => (
            <ChooseRoute
              {...props}
              chooseRoute={this.selectShipmentRoute}
              theme={theme}
              shipmentData={response && response.stage2 ? response.stage2 : {}}
              prevRequest={request && request.stage3 ? request.stage3 : null}
              req={request && request.stage2 ? request.stage2 : {}}
              user={user}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage3 : []}
              shipmentDispatch={shipmentDispatch}
            />
          )}
        />
        {response && response.stage3 ? (
          <Route
            path={route3}
            render={props => (
              <BookingDetails
                {...props}
                nextStage={this.setShipmentContacts}
                theme={theme}
                shipmentData={response && response.stage3 ? response.stage3 : {}}
                prevRequest={request && request.stage4 ? request.stage4 : null}
                currencies={currencies}
                setStage={this.selectShipmentStage}
                messages={error ? error.stage4 : []}
                tenant={tenant}
                user={user}
                shipmentDispatch={shipmentDispatch}
                hideRegistration={this.hideRegistration}
              />
            )}
          />
        ) : (
          ''
        )}
        <Route
          path={route4}
          render={props => (
            <BookingConfirmation
              {...props}
              theme={theme}
              tenant={tenant.data}
              user={user}
              shipmentData={response ? response.stage4 : {}}
              setStage={this.selectShipmentStage}
              shipmentDispatch={shipmentDispatch}
            />
          )}
        />
        <div className={`${styles.pre_footer_break} flex-100`} />
        <Footer className="flex-100" theme={theme} tenant={tenant.data} />
      </div>
    )
  }
}

Shop.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  tenant: PropTypes.object,
  theme: PropTypes.theme,
  user: PropTypes.user,
  loading: PropTypes.bool,
  bookingData: PropTypes.shape({
    request: PropTypes.object,
    response: PropTypes.object,
    error: PropTypes.object
  }).isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  nexusDispatch: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  currencies: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  dashboard: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  availableDestinations: PropTypes.any,

  history: PropTypes.history.isRequired,
  match: PropTypes.shape({
    url: PropTypes.string
  }).isRequired,

  shipmentDispatch: PropTypes.shape({
    newShipment: PropTypes.func,
    setShipmentDetails: PropTypes.func,
    setShipmentContacts: PropTypes.func
  }).isRequired
}

Shop.defaultProps = {
  theme: null,
  loading: false,
  tenant: null,
  user: null,
  nexusDispatch: null,
  currencies: null,
  dashboard: null,
  availableDestinations: null
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, bookingData, nexus, app
  } = state
  const {
    user, loggedIn, loggingIn, registering
  } = authentication
  const { currencies } = app
  const { loading } = bookingData
  const { availableDestinations } = nexus
  return {
    user,
    users,
    tenant,
    loggedIn,
    bookingData,
    loggingIn,
    registering,
    loading,
    currencies,
    availableDestinations
  }
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    nexusDispatch: bindActionCreators(nexusActions, dispatch)
  }
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Shop))
