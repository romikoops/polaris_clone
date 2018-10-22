import React, { Component } from 'react'
import { v4 } from 'uuid'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import RouteFilterBox from '../RouteFilterBox/RouteFilterBox'
import { currencyOptions, moment } from '../../constants'
import styles from './ChooseOffer.scss'
import { numberSpacing, isQuote } from '../../helpers'
import DocumentsDownloader from '../Documents/Downloader'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import TextHeading from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import QuoteCard from '../Quote/Card'
import { Modal } from '../Modal/Modal'

class ChooseOffer extends Component {
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
      isChecked: {},
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
    this.handleScheduleRequest = this.handleScheduleRequest.bind(this)
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
  handleClick (checked, value) {
    if (checked) {
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
      isChecked: {
        ...this.state.isChecked,
        [value.meta.charge_trip_id]: checked
      }
    })
  }

  handleScheduleRequest (args) {
    const { shipmentDispatch, shipmentData } = this.props
    const req = {
      ...args,
      shipmentId: shipmentData.shipment.id
    }
    shipmentDispatch.getSchedulesForResult(req)
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
      shipmentData, user, shipmentDispatch, theme, tenant, originalSelectedDay, t
    } = this.props
    if (!shipmentData) return ''
    const { scope } = tenant.data

    const { currentCurrency, isChecked } = this.state
    const {
      shipment, results, lastTripDate, aggregatedCargo
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
      .sort((a, b) => parseFloat(a.quote.total.value) - parseFloat(b.quote.total.value))
      .map(s => (
        <div key={v4()} className="margin_bottom flex-100">
          <QuoteCard
            theme={theme}
            tenant={tenant}
            pickup={shipment.has_pre_carriage}
            startDate={shipment.desired_start_date}
            result={s}
            isChecked={isChecked[s.meta.charge_trip_id]}
            handleClick={e => this.handleClick(e, s)}
            cargo={shipmentData.cargoUnits}
            selectResult={this.chooseResult}
            aggregatedCargo={aggregatedCargo}
            handleScheduleRequest={this.handleScheduleRequest}
            truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
          />
        </div>
      ))

    const closestRoutestoRender = closestRoutes.map(s => (

      <div key={v4()} className="margin_bottom flex-100">
        <QuoteCard
          theme={theme}
          tenant={tenant}
          pickup={shipment.has_pre_carriage}
          startDate={shipment.desired_start_date}
          result={s}
          isFirst
          isChecked={isChecked[s.meta.charge_trip_id]}
          handleClick={e => this.handleClick(e, s)}
          selectResult={this.chooseResult}
          cargo={shipmentData.cargoUnits}
          aggregatedCargo={aggregatedCargo}
          handleScheduleRequest={this.handleScheduleRequest}
          truckingTime={shipment.trucking.pre_carriage.trucking_time_in_seconds}
        />
      </div>
    ))

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
                <h4>{t('account:emailSuccess')}</h4>
                <p className={styles.thanks}>{t('account:thankYouService')}</p>
                <div className="layout-row flex-100 layout-align-center-center">
                  <div className="layout-row flex-50" style={{ marginRight: '10px' }}>
                    <RoundButton
                      theme={theme}
                      size="small"
                      active
                      text={t('landing:callToAction')}
                      handleNext={() => this.bookNow()}
                    />
                  </div>
                  <div className="layout-row flex-50">
                    <RoundButton
                      theme={theme}
                      size="small"
                      active
                      text={t('account:dashboard')}
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
          {!isQuote(tenant) ? <div className="flex-20 layout-row layout-wrap">
            <RouteFilterBox
              theme={theme}
              tenant={tenant}
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
          </div> : ''}
          <div className="flex  offset-5 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap">
              <div
                className={`flex-100 layout-row layout-align-space-between-center margin_bottom ${
                  styles.route_header
                }`}
              >
                <div className="flex-30 layout-row layout-align-end-center">
                  {scope.fixed_currency ? (
                    ''
                  ) : (
                    <NamedSelect
                      className="flex-100"
                      options={currencyOptions}
                      value={currentCurrency}
                      placeholder={t('common:selectCurrency')}
                      onChange={e => this.handleCurrencyUpdate(e)}
                      clearable={false}
                    />
                  )}
                </div>
              </div>
              {closestRoutestoRender}
            </div>
            <div className="flex-100 layout-row layout-wrap">
              {focusRoutestoRender}
            </div>
          </div>
          {isQuote(tenant) ? (
            <div className={`flex-20 offset-5 quote_options layout-wrap layout-align-center-start ${styles.download_section}`}>
              <p className={`flex-100 layout-row ${styles.offer_title}`} >{isQuote(tenant) ? t('shipment:sendQuote') : t('shipment:selectedOffers') }</p>
              {this.state.selectedOffers !== 0 ? (
                this.state.selectedOffers.map((offer, i) =>
                  (<div className={`flex-100 layout-row layout-align-start-center ${styles.selected_offer}`}>
                    { scope.hide_grand_total
                      ? <span> {t('shipment:quoteNo', { number: i + 1 })}</span>
                      : <span>{numberSpacing(offer.quote.total.value, 2)}&nbsp;{shipmentData.results[0].quote.total.currency}</span>
                    }
                    <i className="fa fa-times pointy layout-row layout-align-end-center" onClick={() => this.handleClick(false, offer)} />
                  </div>))
              ) : ''}
              <div className={`flex-100 layout-row layout-align-center-center ${styles.download_button}`}>
                <div className="flex-90 layout-row layout-align-center-center layout-wrap">
                  <DocumentsDownloader
                    theme={theme}
                    target="quotations"
                    disabled={this.state.selectedOffers.length < 1}
                    options={{ quotes: this.state.selectedOffers, shipment }}
                    size="full"
                    shipment={shipment}
                  />
                </div>
              </div>
              <div className={`flex-100 layout-row layout-align-center-center ${styles.send_email}`}>
                <div className="flex-90 layout-row layout-align-center-center layout-wrap">
                  <RoundButton
                    theme={theme}
                    size="full"
                    disabled={this.state.selectedOffers.length < 1}
                    active={this.state.selectedOffers.length > 0}
                    text={t('account:sendViaEmail')}
                    handleNext={() => this.selectQuotes(shipment, this.state.selectedOffers, this.props.user.email)}
                  />
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
                text={t('common:back')}
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
  t: PropTypes.func.isRequired,
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

export default translate(['account', 'landing', 'common'])(ChooseOffer)
