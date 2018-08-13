/* eslint react/prop-types: "off", consistent-return: "off" */
import * as Scroll from 'react-scroll'
import Formsy from 'formsy-react'
import React, { Component } from 'react'
import defaults from '../../styles/default_classes.scss'
import styles from './BookingDetails.scss'
import { CargoDetails } from '../CargoDetails/CargoDetails'
import { ContactSetter } from '../ContactSetter/ContactSetter'
import { RoundButton } from '../RoundButton/RoundButton'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { isEmpty } from '../../helpers/objectTools'

import {
  trim,
  ALIGN_END_CENTER,
  ALIGN_CENTER_START,
  ALIGN_START_CENTER,
  ROW,
  WRAP_ROW
} from '../../classNames'
import { totalPrice } from '../../helpers'

const CONTAINER = `BOOKING_DETAILS ${WRAP_ROW(100)} ${ALIGN_CENTER_START}`

export class BookingDetails extends Component {
  constructor (props) {
    super(props)
    this.newContactData = {
      contact: {
        companyName: '',
        email: '',
        firstName: '',
        lastName: '',
        phone: ''
      },
      location: {
        city: '',
        country: '',
        street: '',
        streetNumber: '',
        zipCode: ''
      }
    }

    this.state = {
      addons: {},
      acceptTerms: false,
      cargoNotes: '',
      consignee: {},
      customsCredit: false,
      finishBookingAttempted: false,
      hsCodes: {},
      hsTexts: {},
      incotermText: '',
      notifyees: [],
      shipper: {},
      totalGoodsValue: { value: 0, currency: 'EUR' },
      insurance: {
        bool: null,
        val: 0
      },
      customs: {
        import: {
          bool: false,
          val: 0
        },
        export: {
          bool: false,
          val: 0
        },
        total: {
          val: 0
        }
      }
    }
    this.calcInsurance = this.calcInsurance.bind(this)
    this.deleteCode = this.deleteCode.bind(this)
    this.handleCargoInput = this.handleCargoInput.bind(this)
    this.handleHsTextChange = this.handleHsTextChange.bind(this)
    this.handleInsurance = this.handleInsurance.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleTotalGoodsCurrency = this.handleTotalGoodsCurrency.bind(this)
    this.removeNotifyee = this.removeNotifyee.bind(this)
    this.setContact = this.setContact.bind(this)
    this.setCustomsFee = this.setCustomsFee.bind(this)
    this.setHsCode = this.setHsCode.bind(this)
    this.toNextStage = this.toNextStage.bind(this)
    this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this)
    this.toggleCustomAddon = this.toggleCustomAddon.bind(this)
    this.toggleCustomsCredit = this.toggleCustomsCredit.bind(this)
  }
  componentDidMount () {
    const { prevRequest, setStage, hideRegistration } = this.props
    if (prevRequest && prevRequest.shipment) {
      this.loadPrevReq(prevRequest.shipment)
    }
    hideRegistration()
    setStage(4)
    window.scrollTo(0, 0)
  }
  setHsCode (id, codes) {
    const exCodes = this.state.hsCodes[id]
      ? [...this.state.hsCodes[id], ...codes]
      : codes

    this.setState({
      hsCodes: {
        ...this.state.hsCodes,
        [id]: exCodes
      }
    })
  }
  setContact (contactData, type, index) {
    if (type === 'notifyee') {
      const { notifyees } = this.state
      notifyees[index] = contactData
      return this.setState({ notifyees })
    }
    this.setState({ [type]: contactData })
  }
  setCustomsFee (target, fee) {
    const { customs } = this.state
    const customsData = this.props.shipmentData.customs[target]
    const existsUnknown = customs.total.hasUnknown
    customs[target] = fee

    const totalFee = parseFloat(customs.import.val) + parseFloat(customs.export.val)
    customs.total = { val: totalFee, currency: fee.currency }
    if ((customsData.unknown && fee.bool) || existsUnknown) {
      customs.total.hasUnknown = true
    }
    this.setState({ customs })
  }
  handleHsTextChange (event) {
    const { name, value } = event.target
    this.setState({
      hsTexts: {
        ...this.state.hsTexts,
        [name]: value
      }
    })
  }
  loadPrevReq (obj) {
    this.setState({
      cargoNotes: obj.cargoNotes,
      consignee: obj.consignee,
      customsCredit: obj.customsCredit,
      eori: obj.eori,
      hsCodes: obj.hsCodes,
      incotermText: obj.incotermText,
      notes: obj.notes,
      notifyees: obj.notifyees,
      shipper: obj.shipper,
      totalGoodsValue: obj.totalGoodsValue
    })
  }
  toggleAcceptTerms () {
    this.setState({ acceptTerms: !this.state.acceptTerms })
  }
  deleteCode (cargoId, code) {
    const codes = this.state.hsCodes[cargoId]
    const newCodes = codes.filter(x => x !== code)
    this.setState({
      hsCodes: {
        ...this.state.hsCodes,
        [cargoId]: newCodes
      }
    })
  }
  toggleCustomsCredit () {
    this.setState({ customsCredit: !this.state.customsCredit })
  }
  toggleCustomAddon (target) {
    const { addons } = this.props.shipmentData
    const charge = addons[target].fees.total

    this.setState((prevState) => {
      const newTarget = !prevState[target] ? charge : false

      return ({
        addons: {
          ...prevState.addons,
          [target]: newTarget
        }
      })
    })
  }
  handleInsurance (bool) {
    if (bool) {
      return this.calcInsurance(false, true)
    }
    this.setState({ insurance: { bool: false, val: 0 } })
  }
  calcInsurance (val, bool) {
    const gVal = val || parseInt(this.state.totalGoodsValue.value, 10)
    const { shipmentData } = this.props
    const parsed = parseFloat(totalPrice(shipmentData.shipment).value, 10)
    const iVal = (gVal * 1.1 + parsed) * 0.0017
    if (bool) {
      return this.setState({ insurance: { bool, val: iVal } })
    }
    this.setState({ insurance: { ...this.state.insurance, val: iVal } })
  }
  removeNotifyee (i) {
    const { notifyees } = this.state
    notifyees.splice(i, 1)
    this.setState({ notifyees })
  }
  handleTotalGoodsCurrency (selection) {
    this.setState({
      totalGoodsValue: {
        ...this.state.totalGoodsValue,
        currency: selection
      }
    })
  }
  handleCargoInput (event) {
    const { name, value } = event.target
    if (name === 'totalGoodsValue') {
      const gVal = parseInt(value, 10)
      this.setState({
        [name]: {
          ...this.state[name],
          value: gVal
        }
      })

      return this.calcInsurance(gVal, false)
    }
    this.setState({ [name]: value })
  }
  orderTotal () {
    const { shipmentData } = this.props
    const { customs, insurance } = this.state
    const parsed = parseFloat(totalPrice(shipmentData.shipment).value, 10)

    return parsed + customs.val + insurance.val
  }
  toNextStage () {
    const {
      addons,
      cargoNotes,
      consignee,
      customs,
      customsCredit,
      eori,
      hsCodes,
      hsTexts,
      incotermText,
      insurance,
      notes,
      notifyees,
      shipper,
      totalGoodsValue
    } = this.state
    if ([shipper, consignee].some(isEmpty)) {
      scrollTo('contact_setter')
      this.setState({ finishBookingAttempted: true })

      return
    }
    if (cargoNotes === '' || !cargoNotes) {
      scrollTo('cargo_notes')
      this.setState({ finishBookingAttempted: true })

      return
    }

    const data = {
      shipment: {
        id: this.props.shipmentData.shipment.id,
        addons,
        consignee,
        shipper,
        notifyees,
        hsCodes,
        totalGoodsValue,
        cargoNotes,
        insurance,
        customs,
        hsTexts,
        eori,
        notes,
        incotermText,
        customsCredit
      }
    }

    this.props.nextStage(data)
  }
  handleInvalidSubmit () {
    this.setState({ finishBookingAttempted: true })

    const { shipper, consignee } = this.state
    if ([shipper, consignee].some(isEmpty)) {
      scrollTo('contact_setter')

      return
    }
    scrollTo('totalGoodsValue', -50)
  }
  backToDashboard (e) {
    e.preventDefault()
    this.props.shipmentDispatch.toDashboard()
  }
  render () {
    const {
      theme, shipmentData, shipmentDispatch, currencies, user, tenant, contacts
    } = this.props
    if (!shipmentData) return ''

    const {
      hubs,
      locations,
      shipment,
      userLocations
    } = shipmentData
    if (!shipment || !hubs) return ''

    const {
      consignee, shipper, notifyees, customs, customsCredit, eori
    } = this.state

    const maybeRouteHubBox = shipment && theme && hubs
      ? <RouteHubBox shipment={shipment} theme={theme} locations={locations} />
      : ''

    const ContactSetterComponent = (
      <ContactSetter
        consignee={consignee}
        contacts={contacts}
        direction={shipment.direction}
        finishBookingAttempted={this.state.finishBookingAttempted}
        notifyees={notifyees}
        removeNotifyee={this.removeNotifyee}
        setContact={this.setContact}
        shipper={shipper}
        theme={theme}
        userLocations={userLocations}
        shipmentDispatch={shipmentDispatch}
      />
    )

    const CargoDetailsComponent = (
      <CargoDetails
        cargoNotes={this.state.cargoNotes}
        currencies={currencies}
        customsCredit={customsCredit}
        customsData={customs}
        deleteCode={this.deleteCode}
        eori={eori}
        finishBookingAttempted={this.state.finishBookingAttempted}
        handleChange={this.handleCargoInput}
        handleHsTextChange={this.handleHsTextChange}
        handleInsurance={this.handleInsurance}
        handleTotalGoodsCurrency={this.handleTotalGoodsCurrency}
        hsCodes={this.state.hsCodes}
        hsTexts={this.state.hsTexts}
        incotermText={this.state.incotermText}
        insurance={this.state.insurance}
        notes={this.state.notes}
        setCustomsFee={this.setCustomsFee}
        setHsCode={this.setHsCode}
        shipmentData={shipmentData}
        shipmentDispatch={shipmentDispatch}
        tenant={tenant}
        theme={theme}
        toggleCustomAddon={this.toggleCustomAddon}
        toggleCustomsCredit={this.toggleCustomsCredit}
        totalGoodsValue={this.state.totalGoodsValue}
        user={user}
      />
    )

    const ReviewButtonComponent = (
      <div className={`${styles.btn_sec} ${WRAP_ROW(100)} layout-align-center`}>
        <div className={`${defaults.content_width} ${WRAP_ROW('none')} ${ALIGN_START_CENTER}`}>
          <div className={`${ROW(50)} ${ALIGN_START_CENTER}`} />
          <div className={`${ROW(50)} ${ALIGN_END_CENTER}`}>
            <div className="flex-none layout-row">
              <RoundButton theme={theme} text="Review Booking Request" active />
            </div>
          </div>
        </div>
      </div>
    )

    const BackButtonComponent = (
      <div className={`${styles.back_to_dash_sec} ${WRAP_ROW(100)} layout-align-center`}>
        <div className={trim(`
              ${defaults.content_width}
              content-width
              ${ROW('none')}
              ${ALIGN_START_CENTER}
            `)}
        >
          <RoundButton
            back
            handleNext={e => this.backToDashboard(e)}
            iconClass="fa-angle-left"
            text="Back to dashboard"
            theme={theme}
          />
        </div>
      </div>
    )

    return (
      <div
        className={CONTAINER}
        style={{ paddingTop: '60px' }}
      >
        {maybeRouteHubBox}
        <div className={`${styles.wrapper_contact_setter} ${ROW(100)}`}>
          {ContactSetterComponent}
        </div>

        <Formsy
          className="flex-100"
          onInvalidSubmit={this.handleInvalidSubmit}
          onValidSubmit={this.toNextStage}
        >
          {CargoDetailsComponent}
          {ReviewButtonComponent}
          <hr className={`${styles.sec_break} flex-100`} />
          {BackButtonComponent}
        </Formsy>
      </div>
    )
  }
}

function scrollTo (target, offset) {
  Scroll.scroller.scrollTo(target, {
    duration: 2000,
    smooth: true,
    offset: offset || 0
  })
}

export default BookingDetails
