import React, { Component } from 'react'
import { v4 } from 'uuid'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox'
// import BestRoutesBox from '../BestRoutesBox/BestRoutesBox'
import RouteResult from '../RouteResult/RouteResult'
import { currencyOptions, moment } from '../../constants'
import styles from './ChooseOffer.scss'
import { numberSpacing } from '../../helpers'
import DocumentsDownloader from '../Documents/Downloader'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import TextHeading from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import QuoteCard from '../Quote/Card'
import FormsyInput from '../FormsyInput/FormsyInput'
import { Modal } from '../Modal/Modal'

export class ChooseOffer extends Component {
  static dynamicSort (property) {
    let sortOrder = 1
    let prop
    if (property[0] === '-') {
      sortOrder = -1
      prop = property.substr(1)
    } else {
      prop = property
    }

    return (a, b) => {
      const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop]
      const result2 = result1 ? 1 : 0

      return result2 * sortOrder
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      selectedMoT: {
        ocean: true,
        air: true,
        truck: true,
        rail: true
      },
      durationFilter: 40,
      limits: {
        focus: true,
        alt: true
      },
      outerLimit: 20,
      selectedOffers: [],
      isChecked: false,
      email: '',
      showModal: false
    }
    this.chooseResult = this.chooseResult.bind(this)
    this.selectQuotes = this.selectQuotes.bind(this)
    this.setDuration = this.setDuration.bind(this)
    this.setDepartureDate = this.setDepartureDate.bind(this)
    this.setMoT = this.setMoT.bind(this)
    this.emailValue = this.emailValue.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.toggleLimits = this.toggleLimits.bind(this)
  }
  componentDidMount () {
    const { prevRequest, setStage } = this.props
    if (prevRequest && prevRequest.shipment) {
      // this.loadPrevReq(prevRequest.shipment);
    }
    window.scrollTo(0, 0)
    setStage(3)
  }

  shouldComponentUpdate () {
    return !!(this.props.shipmentData && this.props.shipmentData.shipment)
  }
  componentWillUnmount () {
    this.setState({
      showModal: false
    })
  }

  setDuration (val) {
    this.setState({ durationFilter: val })
  }
  setDepartureDate (date) {
    const { shipmentDispatch, req } = this.props
    req.shipment.selected_day = date
    shipmentDispatch.getOffers(req)
  }
  setMoT (val, target) {
    this.setState({
      selectedMoT: {
        ...this.state.selectedMoT,
        [target]: val
      }
    })
  }
  toAccount () {
    this.props.goTo('/account')
  }
  bookNow () {
    this.props.goTo('/booking')
  }
  handleClick (e, value) {
    if (e.target.checked) {
      this.state.selectedOffers.push(value)
      this.setState({
        selectedOffers: this.state.selectedOffers
      })
    } else {
      this.setState({
        selectedOffers: this.state.selectedOffers.filter(val => val !== value)
      })
    }
    this.setState({
      isChecked: e.target.checked
    })
  }
  handleInputChange () {
    this.setState(prevState => ({
      isChecked: !prevState.isChecked
    }))
  }
  toggleLimits (target) {
    this.setState({ limits: { ...this.state.limits, [target]: !this.state.limits[target] } })
    this.showMore()
  }
  handleCurrencyUpdate (e) {
    const { value } = e
    const { shipmentDispatch, req } = this.props
    this.setState({ currentCurrency: e })
    shipmentDispatch.updateCurrency(value, req)
  }
  showMore () {
    const { outerLimit } = this.state
    const dayFactor = 10
    this.setState({ outerLimit: outerLimit + dayFactor })
    const { shipmentDispatch, req } = this.props
    req.delay = outerLimit + dayFactor
    shipmentDispatch.getOffers(req, false)
    this.setState({ outerLimit: req.delay })
  }
  emailValue (e) {
    this.setState({
      email: e.target.value
    })
  }
  downloadQuotations () {
    const { shipmentDispatch } = this.props
    shipmentDispatch.downloadQuotations()
  }
  shiftDepartureDate (operator, days) {
    const { shipmentDispatch, req } = this.props
    let newDepartureDate
    if (operator === 'add') {
      newDepartureDate = moment(req.shipment.selected_day)
        .add(days, 'days')
        .format()
    } else {
      newDepartureDate = moment(req.shipment.selected_day)
        .subtract(days, 'days')
        .format()
    }
    req.shipment.selected_day = newDepartureDate

    shipmentDispatch.getOffersForNewDate(req, false)
  }
  chooseResult (obj) {
    this.props.chooseOffer(obj)
  }
  selectQuotes (shipment, quotes, email) {
    const {
      shipmentDispatch
    } = this.props

    this.setState({
      showModal: this.props.modal
    })

    shipmentDispatch.sendQuotes({ shipment, quotes, email })
  }
  render () {
    const {
      shipmentData, user, shipmentDispatch, theme, tenant, originalSelectedDay
    } = this.props
    if (!shipmentData) return ''
    const { scope } = tenant.data
    const { currentCurrency } = this.state
    const isQuotationTool = scope.closed_quotation_tool || scope.open_quotation_tool || scope.quotation_tool
    const {
      shipment, results, lastTripDate
    } = shipmentData
    if (!shipment || !results) return ''

    const depDay = originalSelectedDay || shipment.selected_day
    results.sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
    const availableMoTKeys = {}
    results.forEach((s) => {
      if (tenant.data.scope.modes_of_transport[s.meta.mode_of_transport][shipment.load_type]) {
        availableMoTKeys[s.meta.mode_of_transport] = true
      }
    })
    const closestRoutes = []
    const focusRoutes = []
    const altRoutes = []
    const mKeys = Object.keys(tenant.data.scope.modes_of_transport)
      .filter(motKey => tenant.data.scope.modes_of_transport[motKey][shipment.load_type])
    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])
    const noMotKeys = Object.keys(this.state.selectedMoT).filter(k => !this.state.selectedMoT[k])
    const scheduleObj = {}
    mKeys.forEach((mk) => {
      scheduleObj[mk] = results.filter(s => s.meta.mode_of_transport === mk)
      scheduleObj[mk].sort((a, b) => Math.abs(moment(depDay).diff(a.closing_date)) - Math.abs(moment(depDay).diff(b.closing_date)))
    })
    motKeys.forEach((key) => {
      if (scheduleObj[key]) {
        const topSched = scheduleObj[key].shift()
        if (topSched) {
          closestRoutes.push(topSched)
        }
        scheduleObj[key].sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
        focusRoutes.push(...scheduleObj[key])
      }
    })
    noMotKeys.forEach((key) => {
      altRoutes.push(...scheduleObj[key])
    })
    const focusRoutestoRender = focusRoutes
      .sort((a, b) => new Date(a.closing_date) - new Date(b.closing_date))
      .map(s => (
        <div className="margin_bottom flex-100">
          <QuoteCard
            theme={theme}
            tenant={tenant}
            isQuotationTool={isQuotationTool}
            pickup={shipment.has_pre_carriage}
            result={s}
            handleClick={e => this.handleClick(e, s)}
            cargo={shipmentData.cargoUnits}
            selectResult={this.chooseResult}
            truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
          />
        </div>
      ))
    const closestRoutestoRender = closestRoutes.map(s => (

      <div className="margin_bottom flex-100">
        <QuoteCard
          theme={theme}
          tenant={tenant}
          isQuotationTool={isQuotationTool}
          pickup={shipment.has_pre_carriage}
          result={s}
          handleClick={e => this.handleClick(e, s)}
          selectResult={this.chooseResult}
          cargo={shipmentData.cargoUnits}
          truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
        />
      </div>
    ))

    const lastResultDate = results[results.length - 1].etd
    const firstResultDate = results[0].etd
    const showLaterDepButton = Math.abs(moment(lastTripDate).diff(lastResultDate, 'days')) > 5
    const showEarlierDepButton = Math.abs(moment().diff(firstResultDate, 'days')) > 10

    return (
      <div
        className="flex-100 layout-row layout-align-center-start layout-wrap"
        style={{ marginTop: '62px', marginBottom: '166px' }}
      >
        {this.state.showModal ? (
          <Modal
            component={(
              <div className={styles.mail_modal}>
                <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 130.2 130.2" className={styles.main_svg}>
                  <circle className={`${styles.svg_path} ${styles.svg_circle}`} fill="none" stroke="#73AF55" strokeWidth="6" strokeMiterlimit="10" cx="65.1" cy="65.1" r="62.1" />
                  <polyline className={`${styles.svg_path} ${styles.svg_check}`} fill="none" stroke="#73AF55" strokeWidth="6" strokeLinecap="round" strokeMiterlimit="10" points="100.2,40.2 51.5,88.8 29.8,67.5 " />
                </svg>
                <h4>Your email has been successfully sent.</h4>
                <p className={styles.thanks}>Thank you for using our service.</p>
                <div className="layout-row flex-100 layout-align-center-center">
                  <div className="layout-row flex-50" style={{ marginRight: '10px' }}>
                    <RoundButton
                      theme={theme}
                      size="small"
                      active
                      text="find rates"
                      handleNext={() => this.bookNow()}
                    />
                  </div>
                  <div className="layout-row flex-50">
                    <RoundButton
                      theme={theme}
                      size="small"
                      active
                      text="dashboard"
                      handleNext={() => this.toAccount()}
                    />
                  </div>
                </div>
              </div>
            )}
            verticalPadding="30px"
            horizontalPadding="40px"
            parentToggle={this.toggleNewHub}
          />
        ) : ''}
        <div className={`flex-none ${defs.content_width} layout-row`}>
          <div className="flex-20 layout-row layout-wrap">
            <RouteFilterBox
              theme={theme}
              cargos={shipmentData.cargoUnits}
              pickup={shipment.has_pre_carriage}
              setDurationFilter={this.setDuration}
              durationFilter={this.state.durationFilter}
              setMoT={this.setMoT}
              moT={this.state.selectedMoT}
              departureDate={depDay}
              shipment={shipment}
              availableMotKeys={availableMoTKeys}
              lastTripDate={lastTripDate}
              setDepartureDate={this.setDepartureDate}
            />
          </div>
          <div className="flex  offset-5 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div
                  className="flex-none layout-row layout-align-space-around-center pointy"
                  onClick={() => this.shiftDepartureDate('subtract', 5)}

                >
                  <i
                    style={!showEarlierDepButton ? { display: 'none' } : { margin: '0 5px' }}
                    className="flex-none fa fa-angle-double-left"
                  />
                  <p
                    style={!showEarlierDepButton ? { display: 'none' } : {}}
                    className="flex-none no_m"
                  >Show earlier departures
                  </p>
                </div>
                <div
                  className="flex-none layout-row layout-align-space-around-center pointy"
                  onClick={() => this.shiftDepartureDate('add', 5)}
                >
                  <p
                    style={!showLaterDepButton ? { display: 'none' } : {}}
                    className="flex-none no_m"
                  >Show later departures
                  </p>
                  <i
                    style={!showLaterDepButton ? { display: 'none' } : { margin: '0 5px' }}
                    className="flex-none fa fa-angle-double-right"
                  />
                </div>
              </div>
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  styles.route_header
                }`}
              >
                <div className="flex-none">
                  {isQuotationTool ? (
                    <TextHeading

                      theme={theme}
                      size={3}
                      text="These are best quotations for the specific route"
                    />
                  ) : (
                    <TextHeading
                      theme={theme}
                      size={3}
                      text="This is the closest departure to the specified date"
                    />
                  )}
                </div>
                <div className="flex-30 layout-row layout-align-end-center">
                  {scope.fixed_currency ? (
                    ''
                  ) : (
                    <NamedSelect
                      className="flex-100"
                      options={currencyOptions}
                      value={currentCurrency}
                      placeholder="Select Currency"
                      onChange={e => this.handleCurrencyUpdate(e)}
                    />
                  )}
                </div>
              </div>
              {closestRoutestoRender}
            </div>
            <div className="flex-100 layout-row layout-wrap">
              {isQuotationTool ? '' : (
                <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                  <div className="flex-none">
                    <TextHeading theme={theme} size={3} text="Alternative departures" />
                  </div>
                </div>
              )}

              {focusRoutestoRender}

              <div className="flex-100 layout-row layout-align-center-center">
                <div
                  className="flex-33 pointy layout-row layout-align-space-around-center"
                  onClick={() => this.showMore()}
                >
                  <i className="flex-none fa fa-angle-double-down" />
                  <div className="flex-5" />
                  <p className="flex-none">More Departures</p>
                  <div className="flex-5" />
                  <i className="flex-none fa fa-angle-double-down" />
                </div>
              </div>

            </div>
          </div>
          {isQuotationTool ? (
            <div className={`flex-20 offset-5  layout-wrap layout-align-center-start ${styles.download_section}`}>
              <p className={`flex-100 layout-row ${styles.offer_title}`} >Selected Offers</p>
              {this.state.selectedOffers !== 0 ? (
                this.state.selectedOffers.map(offer =>
                  (<div className={`flex-100 layout-row layout-align-start-center ${styles.selected_offer}`}>
                    <span>{numberSpacing(offer.quote.total.value, 2)}&nbsp;{shipmentData.results[0].quote.total.currency}</span>
                    <i className="fa fa-times pointy layout-row layout-align-end-center" onClick={e => this.handleClick(e, offer)} />
                  </div>))
              ) : ''}
              <div className={`flex-100 layout-row layout-align-center-center ${styles.download_button}`}>
                <div className="flex-90 layout-row layout-align-center-center layout-wrap">
                  <DocumentsDownloader
                    theme={theme}
                    target="quotations"
                    options={{ quotes: this.state.selectedOffers, shipment }}
                    size="full"
                    shipment={shipment}
                  />
                  <div className={styles.send_email}>
                    <Formsy>
                      <FormsyInput
                        type="email"
                        name="quotation_email"
                        value={this.state.email}
                        onChange={this.emailValue}
                        placeholder="bob@gateway.com"
                      />
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text="Send via email"
                        handleNext={() => this.selectQuotes(shipment, this.state.selectedOffers, this.state.email)}
                      />
                    </Formsy>
                  </div>
                </div>
              </div>
            </div>
          ) : ''}

        </div>
        {!user.guest && (
          <div
            className={`${
              styles.back_to_dash_sec
            } flex-100 layout-row layout-wrap layout-align-center`}
          >
            <div className="content_width_booking flex-none layout-row layout-align-start-center">
              <RoundButton
                theme={theme}
                text="Back to dashboard"
                back
                iconClass="fa-angle0-left"
                handleNext={() => shipmentDispatch.goTo('/account')}
              />
            </div>
          </div>
        )}
      </div>
    )
  }
}
ChooseOffer.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user.isRequired,
  shipmentData: PropTypes.shipmentData.isRequired,
  chooseOffer: PropTypes.func,
  modal: PropTypes.bool,
  req: PropTypes.objectOf(PropTypes.any),
  setStage: PropTypes.func.isRequired,
  goTo: PropTypes.func.isRequired,
  originalSelectedDay: PropTypes.string,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant
}

ChooseOffer.defaultProps = {
  theme: null,
  chooseOffer: null,
  prevRequest: null,
  req: {},
  tenant: {},
  modal: false,
  originalSelectedDay: false
}

export default ChooseOffer
