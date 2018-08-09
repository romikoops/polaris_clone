import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import React, { Component } from 'react'
import PropTypes from '../../../../prop-types'
import styles from '../../../../containers/Shop/Shop.scss'
import { shipmentActions } from '../../../../actions/shipment.actions'
import bookingSummaryActions from '../../../../actions/bookingSummary.actions'
import stageActions from '../../../../containers/Shop/stageActions'
import { Details } from './Details'

class AdminPricingTest extends Component {
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
      loadType: '',
      direction: '',
      // shopType: 'Booking',
      // fakeLoading: false,
      // showRegistration: false,
      step: 1
    }
    this.selectLoadType = this.selectLoadType.bind(this)
    this.selectShipmentStage = this.selectShipmentStage.bind(this)
    props.bookingSummaryDispatch.update()
  }
  componentWillReceiveProps (nextProps) {
    // if (AdminPricingTest.statusRequested(nextProps) && !AdminPricingTest.statusRequested(this.props)) {
    //   this.setState({ fakeLoading: true })
    //   setTimeout(() => this.setState({ fakeLoading: false }), 3000)
    // }
  }

  shouldComponentUpdate (nextProps) {
    const { loggingIn, registering, loading } = nextProps

    return loading || !(loggingIn || registering)
  }
  setDirection (direction) {
    this.setState({ direction }, () => this.shouldGetShipment())
  }
  setLoadType (loadType) {
    this.setState({ loadType }, () => this.shouldGetShipment())
  }
  setStep (step) {
    this.setState({ step })
  }

  getShipment (loadType) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.newShipment(loadType, false)
    this.setState({ step: 2 })
  }
  shouldGetShipment () {
    const { direction, loadType } = this.state
    if (direction !== '' && loadType !== '') {
      this.getShipment({ loadType, direction })
    }
  }

  selectLoadType (loadType) {
    this.getShipment(loadType)
  }

  selectShipmentStage (stage) {
    this.setState({ stageTracker: { stage } })
  }

  toggleShowMessages () {
    this.setState({
      showMessages: !this.state.showMessages
    })
  }

  render () {
    const {
      bookingData,
      tenant,
      user,
      shipmentDispatch,
      bookingSummaryDispatch,
      dashboard
    } = this.props
    const {
      stageTracker, step, direction, loadType
    } = this.state
    const {
      theme
      // scope
    } = tenant.data
    const {
      request, response, error, reusedShipment
    } = bookingData
    console.log(error)
    const selectedStyle = {
      border: `2px solid ${theme.colors.primary}`,
      color: theme.colors.primary
    }

    const shipmentData = stageActions.getShipmentData(response, stageTracker.stage)

    return (
      <div className="layout-row flex-100 layout-wrap">
        <div
          className="flex-100 layout-row layout-wrap layout-align-center-start"
          style={step === 1 ? {} : { display: 'none' }}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.setDirection('import')}
                style={direction === 'import' ? selectedStyle : {}}
              >
                <p className="flex-none">Import</p>
              </div>
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.setDirection('export')}
                style={direction === 'export' ? selectedStyle : {}}
              >
                <p className="flex-none">Export</p>
              </div>
            </div>
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.setLoadType('cargo_item')}
                style={loadType === 'cargo_item' ? selectedStyle : {}}
              >
                <p className="flex-none">Cargo Item</p>
              </div>
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.setLoadType('container')}
                style={loadType === 'container' ? selectedStyle : {}}
              >
                <p className="flex-none">Container</p>
              </div>
            </div>
          </div>
        </div>
        <div
          className="flex-100 layout-row layout-wrap layout-align-center-start"
          style={step >= 2 ? {} : { display: 'none' }}
        >
          <Details
            {...this.props}
            tenant={tenant}
            user={user}
            dashboard={dashboard}
            shipmentData={shipmentData}
            step={step}
            setStep={e => this.setStep(e)}
            prevRequest={request && request.stage2 ? request.stage2 : {}}
            req={request && request.stage1 ? request.stage1 : {}}
            getOffers={data => shipmentDispatch.getOffers(data, false)}
            setStage={this.selectShipmentStage}
            messages={error ? error.stage2 : []}
            shipmentDispatch={shipmentDispatch}
            bookingSummaryDispatch={bookingSummaryDispatch}
            reusedShipment={reusedShipment}
            hideMap
          />
        </div>
        <div className={styles.pusher_bottom} />
      </div>
    )
  }
}

AdminPricingTest.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  tenant: PropTypes.object,
  theme: PropTypes.theme,
  user: PropTypes.user,
  loading: PropTypes.bool,
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
    setShipmentContacts: PropTypes.func
  }).isRequired,
  bookingSummaryDispatch: PropTypes.shape({
    update: PropTypes.func
  }).isRequired
}

AdminPricingTest.defaultProps = {
  theme: null,
  loading: false,
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
  const { loading } = bookingData

  return {
    user,
    users,
    tenant,
    loggedIn,
    bookingData,
    loggingIn,
    registering,
    loading,
    currencies
  }
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch),
    bookingSummaryDispatch: bindActionCreators(bookingSummaryActions, dispatch)
  }
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminPricingTest))
