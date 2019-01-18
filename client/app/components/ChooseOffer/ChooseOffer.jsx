import React, { Component } from 'react'
import { connect } from 'react-redux'
import { v4 } from 'uuid'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import PropTypes from '../../prop-types'
import RouteFilterBox from '../RouteFilterBox/RouteFilterBox'
import { moment } from '../../constants'
import styles from './ChooseOffer.scss'
import { numberSpacing, isQuote } from '../../helpers'
import DocumentsDownloader from '../Documents/Downloader'
import defs from '../../styles/default_classes.scss'
import { RoundButton } from '../RoundButton/RoundButton'
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
    this.handleClick = this.handleClick.bind(this)
    this.toggleLimits = this.toggleLimits.bind(this)
    this.handleScheduleRequest = this.handleScheduleRequest.bind(this)
    this.getRoutes = this.getRoutes.bind(this)
  }

  componentDidMount () {
    const {
      prevRequest, setStage, bookingHasCompleted, match
    } = this.props
    bookingHasCompleted(match.params.shipmentId)
    window.scrollTo(0, 0)
    setStage(3)
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
      this.setState(prevState => ({ selectedOffers: [...prevState.selectedOffers, value] }))
    } else {
      this.setState(prevState => ({ selectedOffers: prevState.selectedOffers.filter(_value => _value !== value) }))
    }
    this.setState(prevState => ({
      isChecked: {
        ...prevState.isChecked,
        [value.meta.charge_trip_id]: checked
      }
    }))
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

  getRoutes () {
    const { shipmentData } = this.props
    if (!shipmentData) return []

    const { shipment, results } = shipmentData
    if (!shipment || !results) return []

    const motKeys = Object.keys(this.state.selectedMoT).filter(k => this.state.selectedMoT[k])

    return results.filter(result => motKeys.includes(result.meta.mode_of_transport))
  }

  render () {
    const {
      shipmentData, user, shipmentDispatch, theme, tenant, originalSelectedDay, lastAvailableDate, t
    } = this.props
    if (!shipmentData) return ''
    const { scope } = tenant

    const { isChecked } = this.state
    const {
      shipment, results, aggregatedCargo
    } = shipmentData
    if (!shipment || !results) return ''

    const availableMoTKeys = {}
    results.forEach((s) => {
      if (tenant.scope.modes_of_transport[s.meta.mode_of_transport][shipment.load_type]) {
        availableMoTKeys[s.meta.mode_of_transport] = true
      }
    })

    const routes = this.getRoutes()
    const depDay = originalSelectedDay || shipment.selected_day
    const isSingleResultRender = routes.length === 1

    const selectedOffers = isSingleResultRender ? routes : this.state.selectedOffers

    const routesToRender = routes
      .sort((a, b) => parseFloat(a.quote.total.value) - parseFloat(b.quote.total.value))
      .map(s => (
        <div key={v4()} className="margin_bottom flex-100">
          <QuoteCard
            theme={theme}
            tenant={tenant}
            pickup={shipment.has_pre_carriage}
            startDate={shipment.desired_start_date}
            result={s}
            shipment={shipment}
            isFirst
            isChecked={isChecked[s.meta.charge_trip_id] || isSingleResultRender}
            onClickAdd={isSingleResultRender ? null : e => this.handleClick(e, s)}
            selectResult={this.chooseResult}
            cargo={shipmentData.cargoUnits}
            aggregatedCargo={aggregatedCargo}
            onScheduleRequest={this.handleScheduleRequest}
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
        <div className="flex-none content_width_booking layout-row">
          {!isQuote(tenant) ? (
            <div className="flex-20 flex-sm-30 layout-row layout-wrap">
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
                lastAvailableDate={lastAvailableDate}
                setDepartureDate={this.setDepartureDate}
              />
            </div>
          ) : ''}
          <div className={`${styles.quotes_wrapper} flex flex-sm-70 offset-md-5 offset-lg-5 layout-row layout-wrap`}>
            <div className="flex-100 layout-row layout-wrap">
              {routesToRender}
            </div>
          </div>
          {isQuote(tenant) ? (
            <div className={`flex-20 offset-5 quote_options layout-wrap layout-align-center-start ${styles.download_section}`}>
              <p className={`flex-100 layout-row ${styles.offer_title}`}>{isQuote(tenant) ? t('shipment:sendQuote') : t('shipment:selectedOffers') }</p>
              {selectedOffers.length !== 0 ? (
                selectedOffers.map((offer, i) => (
                  <div className={`flex-100 layout-row layout-align-start-center ${styles.selected_offer}`}>
                    { scope.hide_grand_total
                      ? (
                        <span>
                          {' '}
                          {t('shipment:quoteNo', { number: i + 1 })}
                        </span>
                      )
                      : (
                        <span>
                          {numberSpacing(offer.quote.total.value, 2)}
                        &nbsp;
                          {shipmentData.results[0].quote.total.currency}
                        </span>
                      )
                    }
                    <i className="fa fa-times pointy layout-row layout-align-end-center" onClick={() => this.handleClick(false, offer)} />
                  </div>
                ))
              ) : ''}
              <div className={`flex-100 layout-row layout-align-center-center ${styles.download_button}`}>
                <div className="flex-90 layout-row layout-align-center-center layout-wrap">
                  <DocumentsDownloader
                    theme={theme}
                    target="quotations"
                    disabled={selectedOffers.length < 1}
                    options={{ quotes: selectedOffers, shipment }}
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
                    disabled={selectedOffers.length < 1}
                    active={selectedOffers.length > 0}
                    text={t('account:sendViaEmail')}
                    handleNext={() => this.selectQuotes(shipment, selectedOffers, this.props.user.email)}
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

ChooseOffer.defaultProps = {
  theme: null,
  chooseOffer: null,
  prevRequest: null,
  req: {},
  tenant: {},
  modal: false,
  originalSelectedDay: false
}

function mapStateToProps (state) {
  const lastAvailableDate = get(state, 'bookingData.response.stage1.lastAvailableDate')

  return { lastAvailableDate }
}

// Unconnected export for specs
export const unconnectedChooseOffer = withNamespaces(['account', 'landing', 'common'])(ChooseOffer)

export default withNamespaces(['account', 'landing', 'common'])(connect(mapStateToProps)(ChooseOffer))
