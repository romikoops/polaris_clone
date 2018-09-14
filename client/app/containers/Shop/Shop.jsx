import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Route } from 'react-router'
import { withRouter } from 'react-router-dom'
import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { ChooseShipment } from '../../components/ChooseShipment/ChooseShipment'
import Header from '../../components/Header/Header'
import styles from './Shop.scss'
// eslint-disable-next-line no-named-as-default
import ShopStageView from '../../components/ShopStageView/ShopStageView'
// eslint-disable-next-line no-named-as-default
import ShipmentDetails from '../../components/ShipmentDetails/ShipmentDetails'
import { ChooseOffer } from '../../components/ChooseOffer/ChooseOffer'
// eslint-disable-next-line no-named-as-default
import Loading from '../../components/Loading/Loading'
import BookingDetails from '../../components/BookingDetails/BookingDetails'
import BookingConfirmation from '../../components/BookingConfirmation/BookingConfirmation'
import { shipmentActions, authenticationActions, userActions } from '../../actions'
import bookingSummaryActions from '../../actions/bookingSummary.actions'
// eslint-disable-next-line no-named-as-default
import ShipmentThankYou from '../../components/ShipmentThankYou/ShipmentThankYou'
import BookingSummary from '../../components/BookingSummary/BookingSummary'
import stageActions from './stageActions'

class Shop extends Component {
  static statusRequested (props) {
    return (
      props.bookingData.response &&
      props.bookingData.response.stage5 &&
      props.bookingData.response.stage5.shipment &&
      props.bookingData.response.stage5.shipment.status === 'requested'
    )
  }
  constructor (props) {
    super(props)

    this.tenant = this.props.tenant

    this.state = {
      stageTracker: {},
      shopType: 'Booking',
      fakeLoading: false,
      showRegistration: false,
      showLogin: false
    }
    this.selectLoadType = this.selectLoadType.bind(this)
    this.chooseOffer = this.chooseOffer.bind(this)
    this.setShipmentContacts = this.setShipmentContacts.bind(this)
    this.selectShipmentStage = this.selectShipmentStage.bind(this)
    this.selectShipmentStageAndGo = this.selectShipmentStageAndGo.bind(this)
    this.toggleShowRegistration = this.toggleShowRegistration.bind(this)
    this.hideRegistration = this.hideRegistration.bind(this)

    props.bookingSummaryDispatch.update()
  }
  componentWillReceiveProps (nextProps) {
    if (Shop.statusRequested(nextProps) && !Shop.statusRequested(this.props)) {
      this.setState({ fakeLoading: true })
      setTimeout(() => this.setState({ fakeLoading: false }), 3000)
    }
  }

  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading } = nextProps

    return loading || !(loggingIn || registering)
  }

  getShipment (loadType) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.newShipment(loadType, true)
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

  toggleShowLogin () {
    this.setState(prevState => ({
      showLogin: !prevState.showLogin
    }))
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
    this.props.authenticationDispatch.showLogin({ req })
  }

  hideRegistration () {
    this.props.authenticationDispatch.closeLogin()
  }

  toggleShowMessages () {
    this.setState({
      showMessages: !this.state.showMessages
    })
  }
  determineForwardFunction (stage) {
    const { bookingData, shipmentDispatch } = this.props
    const { request } = bookingData
    const req = request[`stage${stage}`]
    switch (stage) {
      case 1:
        shipmentDispatch.newShipment(req)
        break
      case 2:
        shipmentDispatch.getOffers(req, true)
        break
      case 3:
        shipmentDispatch.chooseOffer(req)
        break
      case 4:
        shipmentDispatch.setShipmentContacts(req)
        break
      case 5:
        shipmentDispatch.acceptShipment(req)
        break
      default:
        break
    }
  }
  chooseOffer (obj) {
    const { shipmentDispatch, bookingSummaryDispatch, bookingData } = this.props
    const { schedule, total } = obj
    // eslint-disable-next-line camelcase
    const { id, user_id, customs_credit } = bookingData.response.stage2.shipment
    const req = {
      id,
      schedule,
      total,
      user_id,
      customs_credit
    }

    if (this.props.user.guest) {
      this.toggleShowRegistration(req)

      return
    }
    this.hideRegistration()
    bookingSummaryDispatch.update({ modeOfTransport: schedule.mode_of_transport })
    shipmentDispatch.chooseOffer(req)
  }

  render () {
    const {
      bookingData,
      userDispatch,
      match,
      loading,
      tenant,
      user,
      shipmentDispatch,
      bookingSummaryDispatch,
      currencies
    } = this.props
    const { fakeLoading, stageTracker } = this.state
    const { theme, scope } = tenant.data
    const {
      modal, request, response, error, reusedShipment, contacts, originalSelectedDay
    } = bookingData
    const loadingScreen = loading || fakeLoading ? <Loading theme={theme} /> : ''
    const { showRegistration } = this.state
    const shipmentData = stageActions.getShipmentData(response, stageTracker.stage)

    return (
      <div className="layout-row flex-100 layout-wrap">
        <div className={styles.pusher_top} />
        {loadingScreen}
        <Header
          theme={this.props.theme}
          component={<BookingSummary theme={theme} shipmentData={shipmentData} />}
          showMessages={this.toggleShowMessages}
          showRegistration={this.state.showRegistration}
          noMessages
          scrollable
          noRedirect
        />
        <ShopStageView
          shopType={this.state.shopType}
          theme={theme}
          tenant={tenant}
          currentStage={this.state.stageTracker.stage}
          setStage={this.selectShipmentStageAndGo}
          disabledClick={Shop.statusRequested(this.props)}
          goForward={() => this.determineForwardFunction(stageTracker.stage)}
          hasNextStage={stageActions.hasNextStage(response, stageTracker.stage)}
        />
        <Route
          exact
          path={match.url}
          render={props => (
            <ChooseShipment
              {...props}
              theme={theme}
              scope={scope}
              selectLoadType={this.selectLoadType}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage1 : []}
              shipmentDispatch={shipmentDispatch}
            />
          )}
        />
        <Route
          path={`${match.url}/:shipmentId/shipment_details`}
          render={props => (
            <ShipmentDetails
              {...props}
              tenant={tenant}
              user={user}
              shipmentData={shipmentData}
              prevRequest={request && request.stage2 ? request.stage2 : {}}
              req={request && request.stage1 ? request.stage1 : {}}
              getOffers={data => shipmentDispatch.getOffers(data, true)}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage2 : []}
              shipmentDispatch={shipmentDispatch}
              bookingSummaryDispatch={bookingSummaryDispatch}
              reusedShipment={reusedShipment}
              showRegistration={showRegistration}
              hideRegistration={() => this.hideRegistration()}
            />
          )}
        />
        <Route
          path={`${match.url}/:shipmentId/choose_offer`}
          render={props => (
            <ChooseOffer
              {...props}
              chooseOffer={this.chooseOffer}
              theme={theme}
              goTo={userDispatch.goTo}
              tenant={tenant}
              contacts={contacts}
              shipmentData={shipmentData}
              prevRequest={request && request.stage3 ? request.stage3 : null}
              req={request && request.stage2 ? request.stage2 : {}}
              user={user}
              modal={modal}
              setStage={this.selectShipmentStage}
              messages={error ? error.stage3 : []}
              shipmentDispatch={shipmentDispatch}
              reusedShipment={reusedShipment}
              originalSelectedDay={originalSelectedDay}
            />
          )}
        />
        {response && response.stage3 ? (
          <Route
            path={`${match.url}/:shipmentId/final_details`}
            render={props => (
              <BookingDetails
                {...props}
                nextStage={this.setShipmentContacts}
                theme={theme}
                shipmentData={shipmentData}
                prevRequest={request && request.stage4 ? request.stage4 : null}
                currencies={currencies}
                setStage={this.selectShipmentStage}
                messages={error ? error.stage4 : []}
                tenant={tenant}
                user={user}
                contacts={contacts}
                shipmentDispatch={shipmentDispatch}
                hideRegistration={this.hideRegistration}
                reusedShipment={reusedShipment}
              />
            )}
          />
        ) : (
          ''
        )}
        <Route
          path={`${match.url}/:shipmentId/finish_booking`}
          render={props => (
            <BookingConfirmation
              {...props}
              theme={theme}
              tenant={tenant.data}
              user={user}
              shipmentData={shipmentData}
              setStage={this.selectShipmentStage}
              shipmentDispatch={shipmentDispatch}
              reusedShipment={reusedShipment}
            />
          )}
        />
        <Route
          path={`${match.url}/:shipmentId/thank_you`}
          render={props => (
            <ShipmentThankYou
              {...props}
              theme={theme}
              tenant={tenant.data}
              user={user}
              shipmentData={shipmentData}
              setStage={this.selectShipmentStage}
              shipmentDispatch={shipmentDispatch}
            />
          )}
        />
        <div className={styles.pusher_bottom} />
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
  noRedirect: PropTypes.bool,
  bookingData: PropTypes.shape({
    request: PropTypes.object,
    response: PropTypes.object,
    contacts: PropTypes.arrayOf(PropTypes.contact),
    error: PropTypes.object
  }).isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  nexusDispatch: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  currencies: PropTypes.any,
  // eslint-disable-next-line react/forbid-prop-types
  dashboard: PropTypes.any,

  history: PropTypes.history.isRequired,
  match: PropTypes.shape({
    url: PropTypes.string
  }).isRequired,
  contactData: PropTypes.shape({
    contact: PropTypes.contact,
    location: PropTypes.location
  }).isRequired,
  shipmentDispatch: PropTypes.shape({
    updateContact: PropTypes.func,
    newShipment: PropTypes.func,
    getOffers: PropTypes.func,
    chooseQuotes: PropTypes.func,
    setShipmentContacts: PropTypes.func
  }).isRequired,
  userDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired,
  bookingSummaryDispatch: PropTypes.shape({
    update: PropTypes.func
  }).isRequired,
  authenticationDispatch: PropTypes.shape({
    showLogin: PropTypes.func,
    closeLogin: PropTypes.func
  }).isRequired
}

Shop.defaultProps = {
  theme: null,
  loading: false,
  noRedirect: true,
  tenant: null,
  user: null,
  nexusDispatch: null,
  currencies: null,
  dashboard: null
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, bookingData, app
  } = state
  const {
    user, loggedIn, loggingIn, registering
  } = authentication
  const { currencies } = app
  const { loading, modal } = bookingData

  return {
    user,
    users,
    tenant,
    loggedIn,
    bookingData,
    modal,
    loggingIn,
    registering,
    loading,
    currencies
  }
}

function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch),
    bookingSummaryDispatch: bindActionCreators(bookingSummaryActions, dispatch)
  }
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Shop))
