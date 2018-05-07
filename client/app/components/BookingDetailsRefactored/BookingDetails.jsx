import React, { Component } from 'react'
import * as Scroll from 'react-scroll'
import Formsy from 'formsy-react'
import { pick } from 'lodash'
import PropTypes from '../../prop-types'
import styles from './BookingDetails.scss'
import defaults from '../../styles/default_classes.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { ContactSetter } from '../ContactSetter/ContactSetter'
import { CargoDetails } from '../CargoDetails/CargoDetails'
import { RoundButton } from '../RoundButton/RoundButton'
import { isEmpty } from '../../helpers/objectTools'

const nextStagePickProps = [
  'customs',
  'eori',
  'hsCodes',
  'hsTexts',
  'incoterm',
  'insurance',
  'notes',
  'notifyees',
  'totalGoodsValue'
]

const WRAP_ROW = 'flex-100 layout-row layout-wrap'
const BACK_TO_DASH = `${styles.back_to_dash_sec} ${WRAP_ROW} layout-align-center`
const BUTTON = `${styles.btn_sec} ${WRAP_ROW} layout-align-center`
const CONTACT_SETTER = `${styles.wrapper_contact_setter} flex-100 layout-row`

const AFTER_BUTTON = `${defaults.content_width} flex-none layout-row layout-wrap layout-align-start-center`

const AFTER_BACK_TO_DASH = `${defaults.content_width} flex-none content-width layout-row layout-align-start-center`

const paddingTop = { paddingTop: '60px' }

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
    const customs = {
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

    this.state = {
      acceptTerms: false,
      cargoNotes: '',
      consignee: {},
      customs,
      customsCredit: false,
      finishBookingAttempted: false,
      hsCodes: {},
      hsTexts: {},
      incoterm: '',
      insurance: { bool: null, val: 0 },
      notifyees: [],
      shipper: {},
      totalGoodsValue: { value: 0, currency: 'EUR' }
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
      this.setState({ notifyees })
    } else {
      this.setState({ [type]: contactData })
    }
  }
  setCustomsFee (target, fee) {
    const { customs } = this.state
    customs[target] = fee

    const totalFee = customs.import.val + customs.export.val
    customs.total = { val: totalFee, currency: fee.currency }

    this.setState({
      customs
    })
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
      incoterm: obj.incoterm,
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
    this.setState({
      customsCredit: !this.state.customsCredit
    })
  }
  handleInsurance (bool) {
    if (bool) {
      this.calcInsurance(false, true)
    } else {
      this.setState({ insurance: { bool: false, val: 0 } })
    }
  }
  calcInsurance (val, bool) {
    const { shipmentData } = this.props
    const gVal = val || parseInt(this.state.totalGoodsValue.value, 10)

    const parsed = parseFloat(shipmentData.shipment.total_price.value, 10)
    const iVal = (gVal * 1.1 + parsed) * 0.0017

    if (bool) {
      this.setState({ insurance: { bool, val: iVal } })
    } else {
      this.setState({ insurance: { ...this.state.insurance, val: iVal } })
    }
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

      this.calcInsurance(gVal, false)
    } else {
      this.setState({ [name]: value })
    }
  }
  orderTotal () {
    const { shipmentData } = this.props
    const { customs, insurance } = this.state
    const parsed = parseFloat(shipmentData.shipment.total_price.value, 10)

    return parsed + customs.val + insurance.val
  }
  toNextStage () {
    const {
      cargoNotes,
      consignee,
      customsCredit,
      shipper
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
    const picked = pick(
      this.state,
      nextStagePickProps
    )

    const data = {
      shipment: {
        ...picked,
        cargoNotes,
        consignee,
        customsCredit,
        id: this.props.shipmentData.shipment.id,
        shipper
      }
    }

    this.props.nextStage(data)
  }
  handleInvalidSubmit () {
    const { shipper, consignee } = this.state
    this.setState({ finishBookingAttempted: true })

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
      currencies,
      shipmentData,
      shipmentDispatch,
      tenant,
      theme,
      user
    } = this.props

    if (!shipmentData) {
      return ''
    }

    const {
      shipment,
      hubs,
      contacts,
      userLocations,
      schedules,
      locations
    } = shipmentData

    if (!shipment || !hubs) {
      return ''
    }

    const {
      consignee,
      customs,
      customsCredit,
      eori,
      notifyees,
      shipper
    } = this.state

    const okRouteHubBox = shipment && theme && hubs

    return (
      <div className={`${WRAP_ROW} layout-align-center-start`} style={paddingTop}>
        {maybeRouteHubBox({
          ok: okRouteHubBox, hubs, schedules, theme, locations
        })}

        <div className={CONTACT_SETTER}>
          <ContactSetter
            contacts={contacts}
            userLocations={userLocations}
            shipper={shipper}
            consignee={consignee}
            notifyees={notifyees}
            direction={shipment.direction}
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
            handleTotalGoodsCurrency={this.handleTotalGoodsCurrency}
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
            notes={this.state.notes}
            setCustomsFee={this.setCustomsFee}
            user={user}
            eori={eori}
            customsCredit={customsCredit}
            tenant={tenant}
            incoterm={this.state.incoterm}
            toggleCustomsCredit={this.toggleCustomsCredit}
            finishBookingAttempted={this.state.finishBookingAttempted}
          />

          <div className={BUTTON}>
            <div className={AFTER_BUTTON}>
              <div className="flex-50 layout-row layout-align-start-center" />
              <div className="flex-50 layout-row layout-align-end-center">
                <div className="flex-none layout-row">
                  <RoundButton theme={theme} text="Review Booking" active />
                </div>
              </div>
            </div>
          </div>

          <hr className={`${styles.sec_break} flex-100`} />

          <div className={BACK_TO_DASH}>
            <div className={AFTER_BACK_TO_DASH}>
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

function scrollTo (target, offset) {
  Scroll.scroller.scrollTo(target, {
    duration: 2000,
    smooth: true,
    offset: offset || 0
  })
}

// eslint-disable-next-line
function maybeRouteHubBox ({ hubs, locations,ok,schedules,theme}) {
  return ok ? (
    <RouteHubBox
      hubs={hubs}
      route={schedules}
      theme={theme}
      locations={locations}
    />
  )
    : ''
}

export default BookingDetails
