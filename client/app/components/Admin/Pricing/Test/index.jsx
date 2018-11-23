import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import React, { Component } from 'react'
import PropTypes from '../../../../prop-types'
import styles from '../../../../containers/Shop/Shop.scss'
import { adminActions } from '../../../../actions/shipment.actions'
import stageActions from '../../../../containers/Shop/stageActions'
import CargoItemInputs from './CargoItemInputs'
import ContainerInputs from './ContainerInputs'
import { RoundButton } from '../../../RoundButton/RoundButton'

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
      cargoUnits: [{}],
      charges: {
        has_pre_carriage: false,
        has_on_carriage: false
      },
      step: 1
    }
    this.selectLoadType = this.selectLoadType.bind(this)
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

  getPrices () {
    const {
      loadType,
      direction,
      cargoUnits,
      charges
    } = this.state
    const { adminDispatch, itinerary } = this.props
    const { has_pre_carriage, has_on_carriage } = charges // eslint-disable-line
    const request = {
      load_type: loadType,
      direction,
      cargo_units: cargoUnits,
      has_pre_carriage,
      has_on_carriage,
      itineraryId: itinerary.id
    }
    adminDispatch.getPricingsTest(request)

  }

  shouldGetShipment () {
    const { direction, loadType } = this.state
    if (direction !== '' && loadType !== '') {
      this.setStep(2)
    }
  }
  handleCargoChange (e, index) {
    const { name, value } = e.target
    this.setState((prevState) => {
      const { cargoUnits } = prevState
      cargoUnits[index][name] = value

      return { cargoUnits }
    })
  }

  selectLoadType (loadType) {
    this.getShipment(loadType)
  }

  selectShipmentStage (stage) {
    this.setState({ stageTracker: { stage } })
  }

  toggleCharges (target) {
    const adjTarget = target === 'export' ? 'has_pre_carriage' : 'has_on_carriage'
    this.setState(prevState => ({
      charges: {
        ...prevState.charges,
        [adjTarget]: !prevState.charges[adjTarget]
      }
    }))
  }
  addCargo () {
    this.setState((prevState) => {
      const { cargoUnits } = prevState
      cargoUnits.push({})

      return { cargoUnits }
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
      stageTracker, step, direction, loadType, cargoUnits
    } = this.state
    const {
      theme
      // scope
    } = tenant
    const {
      request, response, error, reusedShipment
    } = bookingData
    console.log(error)
    const selectedStyle = {
      border: `2px solid ${theme.colors.primary}`,
      color: theme.colors.primary
    }

    const shipmentData = stageActions.getShipmentData(response, stageTracker.stage)
    const cargoInputs = loadType === 'container'
      ? cargoUnits.map((cu, i) => <CargoItemInputs cargoItem={cu} handleChange={e => this.handleCargoChange(e, i)} index={i} />)
      : cargoUnits.map((cu, i) => <ContainerInputs cargoItem={cu} handleChange={e => this.handleCargoChange(e, i)} index={i} />)

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
          style={step === 2 ? {} : { display: 'none' }}
        >
          {cargoInputs}
          <div className="flex-100 layout-row layout-align-end-center">
            <RoundButton
              size="small"
              handleNext={() => this.addCargo()}
              theme={theme}
              text="Add Cargo"
              active
            />
          </div>
          <div className="flex-100 layout-row layout-align-end-center">
            <RoundButton
              size="small"
              handleNext={() => this.setStep(3)}
              theme={theme}
              text="Next"
              active
            />
          </div>
        </div>
        <div
          className="flex-100 layout-row layout-wrap layout-align-center-start"
          style={step === 3 ? {} : { display: 'none' }}
        >
          {cargoInputs}
          <div className="flex-100 layout-row layout-align-end-center">
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.toggleCharges('export')}
                style={direction === 'export' ? selectedStyle : {}}
              >
                <p className="flex-none">Export</p>
              </div>
              <div
                className="flex-45 layout-row layout-align-center-center"
                onClick={() => this.toggleCharges('import')}
                style={direction === 'import' ? selectedStyle : {}}
              >
                <p className="flex-none">Import</p>
              </div>

            </div>
          </div>
          <div className="flex-100 layout-row layout-align-end-center">
            <RoundButton
              size="small"
              handleNext={() => this.getPrices()}
              theme={theme}
              text="Get Prices"
              active
            />
          </div>
          </div>
        <div
          className="flex-100 layout-row layout-wrap layout-align-center-start"
          style={step === 4 ? {} : { display: 'none' }}
        >

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
  adminDispatch: PropTypes.shape({
    getPricingsTest: PropTypes.func
  }).isRequired
}

AdminPricingTest.defaultProps = {
  theme: null,
  tenant: null,
  user: null
}

function mapStateToProps (state) {
  const {
    authentication, admin, app
  } = state
  const {
    user, loggedIn, loggingIn, registering
  } = authentication
  const { currencies, tenant } = app
  const { itineraryPricings } = admin

  return {
    user,
    itineraryPricings,
    tenant,
    loggedIn,
    loggingIn,
    registering,
    currencies
  }
}

function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminPricingTest))
