import React, { Component } from 'react'
import * as Scroll from 'react-scroll'
import Formsy from 'formsy-react'
import PropTypes from '../../prop-types'
import styles from './BookingDetails.scss'
import defaults from '../../styles/default_classes.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { ContactSetter } from '../ContactSetter/ContactSetter'
import { CargoDetails } from '../CargoDetails/CargoDetails'
import { RoundButton } from '../RoundButton/RoundButton'
import { isEmpty } from '../../helpers/objectTools'

export class BookingDetails extends Component {
  static scrollTo (target, offset) {
    Scroll.scroller.scrollTo(target, {
      duration: 2000,
      smooth: true,
      offset: offset || 0
    })
  }
  constructor (props) {
    super(props)
    this.newContactData = {
      contact: {
        companyName: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: ''
      },
      location: {
        street: '',
        streetNumber: '',
        zipCode: '',
        city: '',
        country: ''
      }
    }

    this.state = {
      acceptTerms: false,
      consignee: {},
      shipper: {},
      notifyees: [],
      insurance: {
        bool: false,
        val: 0
      },
      customs: {
        bool: false,
        val: 0
      },
      hsCodes: {},
      hsTexts: {},
      totalGoodsValue: 0,
      cargoNotes: '',
      finishBookingAttempted: false,
      customsCredit: false
    }
    this.removeNotifyee = this.removeNotifyee.bind(this)
    this.toNextStage = this.toNextStage.bind(this)
    this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this)
    this.handleCargoInput = this.handleCargoInput.bind(this)
    this.handleInsurance = this.handleInsurance.bind(this)
    this.calcInsurance = this.calcInsurance.bind(this)
    this.setHsCode = this.setHsCode.bind(this)
    this.handleHsTextChange = this.handleHsTextChange.bind(this)
    this.deleteCode = this.deleteCode.bind(this)
    this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this)
    this.setCustomsFee = this.setCustomsFee.bind(this)
    this.setContact = this.setContact.bind(this)
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
    let exCodes
    if (this.state.hsCodes[id]) {
      exCodes = [...this.state.hsCodes[id], ...codes]
    } else {
      exCodes = codes
    }
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
      this.setState({ notifyees })
    } else {
      this.setState({ [type]: contactData })
    }
  }
  setCustomsFee (fee) {
    this.setState({ customs: fee })
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
      consignee: obj.consignee,
      shipper: obj.shipper,
      notifyees: obj.notifyees,
      hsCodes: obj.hsCodes,
      totalGoodsValue: obj.totalGoodsValue,
      cargoNotes: obj.cargoNotes
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
    this.setState({
      customsCredit: !this.state.customsCredit
    })
  }
  handleInsurance () {
    const { insurance } = this.state

    if (insurance.bool) {
      this.setState({ insurance: { bool: false, val: 0 } })
    } else {
      this.calcInsurance()
    }
  }
  calcInsurance (val) {
    const gVal = val || parseInt(this.state.totalGoodsValue, 10)

    const { shipmentData } = this.props
    const iVal = (gVal * 1.1 + parseFloat(shipmentData.shipment.total_price, 10)) * 0.0017
    this.setState({ insurance: { bool: true, val: iVal } })
  }
  removeNotifyee (i) {
    const { notifyees } = this.state
    notifyees.splice(i, 1)
    this.setState({ notifyees })
  }
  handleCargoInput (event) {
    const { name, value } = event.target
    if (name === 'totalGoodsValue') {
      const gVal = parseInt(value, 10)
      this.setState({ [name]: gVal })
      this.calcInsurance(gVal)
    } else {
      this.setState({ [name]: value })
    }
  }
  orderTotal () {
    const { shipmentData } = this.props
    const { customs, insurance } = this.state
    return parseFloat(shipmentData.shipment.total_price, 10) + customs.val + insurance.val
  }
  toNextStage () {
    const {
      consignee,
      shipper,
      notifyees,
      hsCodes,
      totalGoodsValue,
      cargoNotes,
      insurance,
      customs,
      hsTexts,
      customsCredit
    } = this.state
    const { documents } = this.props.shipmentData
    // eslint-disable-next-line camelcase
    const { packing_sheet, commercial_invoice } = documents
    if ([shipper, consignee].some(isEmpty)) {
      BookingDetails.scrollTo('contact_setter')
      this.setState({ finishBookingAttempted: true })
      return
    }
    // eslint-disable-next-line camelcase
    if (!packing_sheet || (packing_sheet && isEmpty(packing_sheet))) {
      BookingDetails.scrollTo('contact_setter')
      this.setState({ finishBookingAttempted: true })
      return
    }
    // eslint-disable-next-line camelcase
    if (!commercial_invoice || (commercial_invoice && isEmpty(commercial_invoice))) {
      BookingDetails.scrollTo('contact_setter')
      this.setState({ finishBookingAttempted: true })
      return
    }
    const data = {
      shipment: {
        id: this.props.shipmentData.shipment.id,
        consignee,
        shipper,
        notifyees,
        hsCodes,
        totalGoodsValue,
        cargoNotes,
        insurance,
        customs,
        hsTexts,
        customsCredit
      }
    }
    this.props.nextStage(data)
  }
  handleInvalidSubmit () {
    this.setState({ finishBookingAttempted: true })

    const { shipper, consignee } = this.state
    if ([shipper, consignee].some(isEmpty)) {
      BookingDetails.scrollTo('contact_setter')
      return
    }
    BookingDetails.scrollTo('totalGoodsValue', -50)
  }
  backToDashboard (e) {
    e.preventDefault()
    this.props.shipmentDispatch.toDashboard()
  }
  render () {
    const {
      theme, shipmentData, shipmentDispatch, currencies, user, tenant
    } = this.props
    const {
      shipment,
      hubs,
      contacts,
      userLocations,
      schedules
      // containers,
      // cargoItems,
      // locations
    } = shipmentData
    const {
      consignee, shipper, notifyees, customs, customsCredit
    } = this.state

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        {shipment && theme && hubs ? (
          <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
        ) : (
          ''
        )}
        <div className={`${styles.wrapper_contact_setter} flex-100 layout-row`}>
          <ContactSetter
            contacts={contacts}
            userLocations={userLocations}
            shipper={shipper}
            consignee={consignee}
            notifyees={notifyees}
            setContact={this.setContact}
            theme={theme}
            removeNotifyee={this.removeNotifyee}
            finishBookingAttempted={this.state.finishBookingAttempted}
          />
        </div>
        <Formsy onValidSubmit={this.toNextStage} onInvalidSubmit={this.handleInvalidSubmit}>
          <CargoDetails
            theme={theme}
            handleChange={this.handleCargoInput}
            shipmentData={shipmentData}
            hsCodes={this.state.hsCodes}
            hsTexts={this.state.hsTexts}
            setHsCode={this.setHsCode}
            handleHsTextChange={this.handleHsTextChange}
            deleteCode={this.deleteCode}
            cargoNotes={this.state.cargoNotes}
            totalGoodsValue={this.state.totalGoodsValue}
            handleInsurance={this.handleInsurance}
            insurance={this.state.insurance}
            shipmentDispatch={shipmentDispatch}
            currencies={currencies}
            customsData={customs}
            setCustomsFee={this.setCustomsFee}
            user={user}
            customsCredit={customsCredit}
            tenant={tenant}
            toggleCustomsCredit={this.toggleCustomsCredit}
            finishBookingAttempted={this.state.finishBookingAttempted}
          />
          <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
            <div
              className={`${
                defaults.content_width
              } flex-none  layout-row layout-wrap layout-align-start-center`}
            >
              <div className="flex-50 layout-row layout-align-start-center" />
              <div className="flex-50 layout-row layout-align-end-center">
                <div className="flex-none layout-row">
                  <RoundButton theme={theme} text="Review Booking" active />
                </div>
              </div>
            </div>
          </div>
          <hr className={`${styles.sec_break} flex-100`} />
          <div
            className={`${
              styles.back_to_dash_sec
            } flex-100 layout-row layout-wrap layout-align-center`}
          >
            <div
              className={`${
                defaults.content_width
              } flex-none content-width layout-row layout-align-start-center`}
            >
              <RoundButton
                theme={theme}
                text="Back to dashboard"
                back
                iconClass="fa-angle-left"
                handleNext={this.backToDashboard}
              />
            </div>
          </div>
        </Formsy>
      </div>
    )
  }
}

BookingDetails.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.objectOf(PropTypes.any),
  shipmentData: PropTypes.shipmentData,
  nextStage: PropTypes.func.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  setStage: PropTypes.func.isRequired,
  hideRegistration: PropTypes.func.isRequired,
  shipmentDispatch: PropTypes.shape({
    toDashboard: PropTypes.func
  }).isRequired,
  currencies: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    rate: PropTypes.number
  })).isRequired,
  user: PropTypes.user.isRequired
}

BookingDetails.defaultProps = {
  theme: null,
  tenant: null,
  prevRequest: null,
  shipmentData: null
}

export default BookingDetails
