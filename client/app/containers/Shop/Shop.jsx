import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Route } from 'react-router'
import { withRouter } from 'react-router-dom'
import React, { Component } from 'react'
import { get } from 'lodash'
import ChooseShipment from '../../components/ChooseShipment/ChooseShipment'
import Header from '../../components/Header/Header'
import styles from './Shop.scss'
import ShopStageView from '../../components/ShopStageView/ShopStageView'
import ShipmentDetails from '../../components/ShipmentDetails'
import ChooseOffer from '../../components/ChooseOffer/ChooseOffer'
import Loading from '../../components/Loading/Loading'
import BookingDetails from '../../components/BookingDetails/BookingDetails'
import BookingConfirmation from '../../components/BookingConfirmation/BookingConfirmation'
import { authenticationActions, shipmentActions, userActions } from '../../actions'
import bookingSummaryActions from '../../actions/bookingSummary.actions'
import ShipmentThankYou from '../../components/ShipmentThankYou/ShipmentThankYou'
import BookingSummary from '../../components/BookingSummary/BookingSummary'
import stageActions from './stageActions'
import GenericError from '../../components/ErrorHandling/Generic'

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
    this.getOffers = this.getOffers.bind(this)
    this.setShipmentContacts = this.setShipmentContacts.bind(this)
    this.selectShipmentStage = this.selectShipmentStage.bind(this)
    this.selectShipmentStageAndGo = this.selectShipmentStageAndGo.bind(this)
    this.toggleShowRegistration = this.toggleShowRegistration.bind(this)
    this.hideRegistration = this.hideRegistration.bind(this)
    this.bookingHasCompleted = this.bookingHasCompleted.bind(this)

    props.bookingSummaryDispatch.update()
  }

  componentWillMount () {
    const { authenticationDispatch, tenant, user } = this.props

    if (!user) {
      authenticationDispatch.registerGuestOrAuthenticate(tenant, '/booking')
    }
  }

  componentWillReceiveProps (nextProps) {
    if (Shop.statusRequested(nextProps) && !Shop.statusRequested(this.props)) {
      this.setState({ fakeLoading: true })
      setTimeout(() => this.setState({ fakeLoading: false }), 3000)
    }
  }

  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading, user } = nextProps

    return user && loading || !(loggingIn || registering)
  }

  componentDidUpdate () {
    const { bookingData, user, shipmentDispatch } = this.props
    const { ahoyRequest, ahoyParams } = bookingData

    if (ahoyRequest && user) {
      shipmentDispatch.newAhoyShipment(ahoyParams)
    }
  }

  getShipment (loadType) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.newShipment(loadType, true)
  }

  setShipmentContacts (data) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.setShipmentContacts(data)
  }

  bookingHasCompleted (id) {
    const { bookingData, userDispatch } = this.props
    const existingShipment = get(bookingData, ['response', 'stage5', 'shipment'], false)
    if (existingShipment && existingShipment.booking_placed_at && String(existingShipment.id) === id) {
      userDispatch.getDashboard(existingShipment.user_id, true)
    }
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
    const { shipmentDispatch, bookingSummaryDispatch, bookingData, user, activeShipment } = this.props
    const { schedule, total, meta } = obj
    // eslint-disable-next-line camelcase
    const { id, user_id, customs_credit } = bookingData.response.stage2.shipment
    const req = {
      id: id || activeShipment,
      schedule,
      total,
      user_id,
      customs_credit,
      meta
    }
    if (user.guest) {
      req.action = 'chooseOffer'
      this.toggleShowRegistration(req)

      return
    }
    this.hideRegistration()
    bookingSummaryDispatch.update({ modeOfTransport: schedule.mode_of_transport })
    shipmentDispatch.chooseOffer(req)
  }

  getOffers (obj, redirect) {
    const { shipmentDispatch, user, tenant } = this.props
    const { scope } = tenant
    if (user.guest && scope.closed_after_map) {
      obj.action = 'getOffers'
      this.toggleShowRegistration(obj)

      return
    }
    this.hideRegistration()
    shipmentDispatch.getOffers(obj, redirect)
  }

  render () {
    const {
      bookingData,
      match,
      loading,
      tenant,
      user,
      shipmentDispatch,
      bookingSummaryDispatch,
      currencies
    } = this.props
    const { fakeLoading, stageTracker } = this.state
    const { theme, scope } = tenant
    const {
      request, response, error, reusedShipment, contacts, originalSelectedDay, ahoyRequest
    } = bookingData

    if (loading || fakeLoading || ahoyRequest){
      return <Loading tenant={tenant} />
    }

    const { showRegistration } = this.state
    const shipmentData = stageActions.getShipmentData(response, stageTracker.stage)

    return (
      <div className="layout-row flex-100 layout-wrap">
        <div className={styles.pusher_top} />
        <GenericError theme={theme}>
          <Header
            theme={theme}
            component={<BookingSummary theme={theme} scope={scope} shipmentData={shipmentData} />}
            showMessages={this.toggleShowMessages}
            showRegistration={this.state.showRegistration}
            noMessages
            scrollable
            noRedirect
          />
        </GenericError>
        <GenericError theme={theme}>

          <ShopStageView
            shopType={this.state.shopType}
            theme={theme}
            tenant={tenant}
            currentStage={this.state.stageTracker.stage}
            setStage={this.selectShipmentStageAndGo}
            disabledClick={Shop.statusRequested(this.props)}
            goForward={() => this.determineForwardFunction(stageTracker.stage)}
            hasNextStage={Boolean(stageActions.hasNextStage(response, stageTracker.stage))}
          />
        </GenericError>
        <GenericError theme={theme}>
          <Route
            exact
            path={match.url}
            render={props => (
              <ChooseShipment
                {...props}
                theme={theme}
                scope={scope}
                user={user}
                selectLoadType={this.selectLoadType}
                setStage={this.selectShipmentStage}
                messages={error ? error.stage1 : []}
                shipmentDispatch={shipmentDispatch}
              />
            )}
          />
        </GenericError>
        <GenericError theme={theme}>
          <Route
            path={`${match.url}/:shipmentId/shipment_details`}
            render={props => (
              <ShipmentDetails
                {...props}
                tenant={tenant}
                user={user}
                shipmentData={shipmentData}
                prevRequest={get(request, ['stage2'], {})}
                req={get(request, ['stage1'], {})}
                getOffers={data => this.getOffers(data, true)}
                setStage={this.selectShipmentStage}
                messages={error ? error.stage2 : []}
                shipmentDispatch={shipmentDispatch}
                bookingSummaryDispatch={bookingSummaryDispatch}
                reusedShipment={reusedShipment === false ? {} : reusedShipment}
                showRegistration={showRegistration}
                bookingHasCompleted={this.bookingHasCompleted}
                hideRegistration={() => this.hideRegistration()}
              />
            )}
          />
        </GenericError>
        <GenericError theme={theme}>
          <Route
            path={`${match.url}/:shipmentId/choose_offer`}
            render={props => (
              <ChooseOffer
                {...props}
                chooseOffer={this.chooseOffer}
                theme={theme}
                tenant={tenant}
                contacts={contacts}
                shipmentData={shipmentData}
                prevRequest={request && request.stage3 ? request.stage3 : null}
                req={request && request.stage2 ? request.stage2 : {}}
                user={user}
                setStage={this.selectShipmentStage}
                messages={error ? error.stage3 : []}
                shipmentDispatch={shipmentDispatch}
                bookingHasCompleted={this.bookingHasCompleted}
                reusedShipment={reusedShipment}
                originalSelectedDay={originalSelectedDay}
              />
            )}
          />
        </GenericError>

        {response && response.stage3 ? (
          <GenericError theme={theme}>
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
                  bookingHasCompleted={this.bookingHasCompleted}
                />
              )}
            />
          </GenericError>

        ) : (
          ''
        )}
        <GenericError theme={theme}>
          <Route
            path={`${match.url}/:shipmentId/finish_booking`}
            render={props => (
              <BookingConfirmation
                {...props}
                theme={theme}
                tenant={tenant}
                user={user}
                shipmentData={shipmentData}
                setStage={this.selectShipmentStage}
                shipmentDispatch={shipmentDispatch}
                reusedShipment={reusedShipment}
                bookingHasCompleted={this.bookingHasCompleted}
              />
            )}
          />
        </GenericError>
        <GenericError theme={theme}>
          <Route
            path={`${match.url}/:shipmentId/thank_you`}
            render={props => (
              <ShipmentThankYou
                {...props}
                theme={theme}
                tenant={tenant}
                user={user}
                shipmentData={shipmentData}
                setStage={this.selectShipmentStage}
                shipmentDispatch={shipmentDispatch}
              />
            )}
          />
        </GenericError>

        <div className={styles.pusher_bottom} />
      </div>
    )
  }
}

Shop.defaultProps = {
  theme: null,
  loading: false,
  noRedirect: true,
  tenant: null,
  user: null,
  nexusDispatch: null,
  currencies: null
}

function mapStateToProps (state) {
  const {
    users, authentication, bookingData, app
  } = state
  const {
    user, loggedIn, loggingIn, registering
  } = authentication
  const { currencies, tenant } = app
  const { loading, modal, activeShipment } = bookingData

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
    currencies,
    activeShipment
  }
}

function mapDispatchToProps (dispatch) {
  return {
    authenticationDispatch: bindActionCreators(authenticationActions, dispatch),
    userDispatch: bindActionCreators(userActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    bookingSummaryDispatch: bindActionCreators(bookingSummaryActions, dispatch)
  }
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Shop))
