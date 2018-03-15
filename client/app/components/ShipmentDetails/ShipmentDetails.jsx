import React, { Component } from 'react'
import * as Scroll from 'react-scroll'
// import Select from 'react-select'
import DayPickerInput from 'react-day-picker/DayPickerInput'
// import styled from 'styled-components'
import PropTypes from '../../prop-types'
import GmapsLoader from '../../hocs/GmapsLoader'
import styles from './ShipmentDetails.scss'
import errorStyles from '../../styles/errors.scss'
import defaults from '../../styles/default_classes.scss'
import { moment } from '../../constants'
import '../../styles/day-picker-custom.css'
import TruckingDetails from '../TruckingDetails/TruckingDetails'
import { RoundButton } from '../RoundButton/RoundButton'
import { Tooltip } from '../Tooltip/Tooltip'
import { ShipmentLocationBox } from '../ShipmentLocationBox/ShipmentLocationBox'
import { ShipmentContainers } from '../ShipmentContainers/ShipmentContainers'
import { ShipmentCargoItems } from '../ShipmentCargoItems/ShipmentCargoItems'
import { TextHeading } from '../TextHeading/TextHeading'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import { IncotermRow } from '../Incoterm/Row'
import { IncotermBox } from '../Incoterm/Box'
import { isEmpty } from '../../helpers/objectTools'
import { Checkbox } from '../Checkbox/Checkbox'
import '../../styles/select-css-custom.css'
import getModals from './getModals'

export class ShipmentDetails extends Component {
  static scrollTo (target) {
    Scroll.scroller.scrollTo(target, {
      duration: 800,
      smooth: true,
      offset: -50
    })
  }
  static errorsExist (errorsObjects) {
    errorsObjects.some(errorsObj => Object.values(errorsObj).some(error => error))
  }
  constructor (props) {
    super(props)
    this.state = {
      origin: {},
      destination: {},
      containers: [
        {
          payload_in_kg: 0,
          sizeClass: '',
          tareWeight: 0,
          quantity: 1,
          dangerous_goods: false
        }
      ],
      cargoItems: [
        {
          payload_in_kg: 0,
          dimension_x: 0,
          dimension_y: 0,
          dimension_z: 0,
          quantity: 1,
          cargo_item_type_id: '',
          dangerous_goods: false,
          stackable: true
        }
      ],
      routes: {},
      containersErrors: [
        {
          payload_in_kg: true
        }
      ],
      cargoItemsErrors: [
        {
          payload_in_kg: true,
          dimension_x: true,
          dimension_y: true,
          dimension_z: true,
          cargo_item_type_id: true,
          quantity: false
        }
      ],
      nextStageAttempt: false,
      has_on_carriage: false,
      has_pre_carriage: false,
      shipment: props.shipmentData ? props.shipmentData.shipment : {},
      allNexuses: props.shipmentData ? props.shipmentData.allNexuses : {},
      routeSet: false,
      noDangerousGoodsConfirmed: false
    }
    this.truckTypes = {
      container: ['side_lifter', 'chassis'],
      cargo_item: ['default']
    }

    if (this.props.shipmentData && this.props.shipmentData.shipment) {
      this.state.selectedDay = this.props.shipmentData.shipment.planned_pickup_date
      this.state.has_on_carriage = this.props.shipmentData.shipment.has_on_carriage
      this.state.has_pre_carriage = this.props.shipmentData.shipment.has_pre_carriage
    }

    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.handleNextStage = this.handleNextStage.bind(this)
    this.addNewCargoItem = this.addNewCargoItem.bind(this)
    this.addNewContainer = this.addNewContainer.bind(this)
    this.setTargetAddress = this.setTargetAddress.bind(this)
    this.handleChangeCarriage = this.handleChangeCarriage.bind(this)
    this.handleCargoItemChange = this.handleCargoItemChange.bind(this)
    this.handleContainerChange = this.handleContainerChange.bind(this)
    this.handleTruckingDetailsChange = this.handleTruckingDetailsChange.bind(this)
    this.deleteCargo = this.deleteCargo.bind(this)
    this.setIncoTerm = this.setIncoTerm.bind(this)
    this.handleSelectLocation = this.handleSelectLocation.bind(this)
    this.loadPrevReq = this.loadPrevReq.bind(this)
    this.handleCarriageNexuses = this.handleCarriageNexuses.bind(this)
  }
  componentWillMount () {
    const { prevRequest, setStage } = this.props
    if (prevRequest && prevRequest.shipment) {
      this.loadPrevReq(prevRequest.shipment)
    }
    setStage(2)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  componentWillReceiveProps (nextProps) {
    if (!this.state.shipment) {
      const { shipment } = nextProps.shipmentData
      this.setState({ shipment })
    }
  }
  shouldComponentUpdate (nextProps, nextState) {
    if (!nextState.modals) {
      this.setState({ modals: getModals(nextProps, name => this.toggleModal(name)) })
    }
    return (
      nextProps.shipmentData &&
      nextState.shipment &&
      nextState.modals &&
      nextProps.tenant &&
      nextProps.user
    )
  }
  setIncoTerm (opt) {
    this.handleChangeCarriage('has_on_carriage', opt.onCarriage)
    this.handleChangeCarriage('has_pre_carriage', opt.preCarriage)
    this.setState({
      incoterm: opt
    })
  }
  setTargetAddress (target, address) {
    this.setState({ [target]: { ...this.state[target], ...address } })
  }

  loadPrevReq (obj) {
    this.setState({
      cargoItems: obj.cargo_items_attributes,
      containers: obj.containers_attributes,
      selectedDay: obj.planned_pickup_date,
      origin: {
        fullAddress: obj.origin_user_input ? obj.origin_user_input : '',
        hub_id: obj.origin_id
      },
      destination: {
        fullAddress: obj.destination_user_input ? obj.destination_user_input : '',
        hub_id: obj.destination_id
      },
      has_on_carriage: obj.has_on_carriage,
      has_pre_carriage: obj.has_pre_carriage,
      trucking: obj.trucking,
      incoterm: obj.incoterm,
      routeSet: true
    })
  }

  newContainerGrossWeight () {
    const container = this.state.containers.new
    return container.type ? container.tare_weight + container.weight : 0
  }

  handleDayChange (selectedDay) {
    this.setState({ selectedDay })
  }
  deleteCargo (target, index) {
    const cargoArr = this.state[target]
    const errorsArr = this.state[`${target}Errors`]
    cargoArr.splice(index, 1)
    errorsArr.splice(index, 1)
    this.setState({ [target]: cargoArr })
    this.setState({ [`${target}Errors`]: errorsArr })
  }
  handleSelectLocation (bool) {
    this.setState({
      AddressFormsHaveErrors: bool
    })
  }
  handleAddressChange (event) {
    const eventKeys = event.target.name.split('-')
    const key1 = eventKeys[0]
    const key2 = eventKeys[1]
    const val = event.target.value
    const addObj = this.state[key1]
    addObj[key2] = val
    let { fullAddress } = this.state[key1]

    if (fullAddress) {
      fullAddress = `${addObj.number} ${addObj.street} ${addObj.city} ${addObj.zipCode} ${
        addObj.country
      }`
    }
    this.setState({
      ...this.state,
      [key1]: { ...this.state[key1], [key2]: val, fullAddress }
    })
  }

  handleCargoItemChange (event, hasError) {
    const { name, value } = event.target
    const [index, suffixName] = name.split('-')
    const { cargoItems, cargoItemsErrors } = this.state

    if (!cargoItems[index] || !cargoItemsErrors[index]) return
    if (typeof value === 'boolean') {
      cargoItems[index][suffixName] = value
    } else {
      cargoItems[index][suffixName] = value ? parseInt(value, 10) : 0
    }
    if (hasError !== undefined) cargoItemsErrors[index][suffixName] = hasError
    this.setState({ cargoItems, cargoItemsErrors })
  }

  handleContainerChange (event, hasError) {
    const { name, value } = event.target
    const [index, suffixName] = name.split('-')
    const { containers, containersErrors } = this.state
    if (!containers[index] || !containersErrors[index]) return
    if (suffixName === 'sizeClass' || typeof value === 'boolean') {
      containers[index][suffixName] = value
    } else {
      containers[index][suffixName] = value ? parseInt(value, 10) : 0
    }
    if (hasError !== undefined) containersErrors[index][suffixName] = hasError

    this.setState({ containers, containersErrors })
  }

  addNewCargoItem () {
    const newCargoItem = {
      payload_in_kg: 0,
      dimension_x: 0,
      dimension_y: 0,
      dimension_z: 0,
      quantity: 1,
      cargo_item_type_id: '',
      dangerous_goods: false,
      stackable: true
    }
    const newErrors = {
      payload_in_kg: true,
      dimension_x: true,
      dimension_y: true,
      dimension_z: true,
      cargo_item_type_id: true,
      quantity: false
    }
    const { cargoItems, cargoItemsErrors } = this.state
    cargoItems.push(newCargoItem)
    cargoItemsErrors.push(newErrors)
    this.setState({ cargoItems, cargoItemsErrors })
  }

  addNewContainer () {
    const newContainer = {
      payload_in_kg: 0,
      sizeClass: '',
      tareWeight: 0,
      quantity: 1,
      dangerous_goods: false
    }

    const newErrors = {
      payload_in_kg: true
    }

    const { containers, containersErrors } = this.state
    containers.push(newContainer)
    containersErrors.push(newErrors)
    this.setState({ containers, containersErrors })
  }

  handleNextStage () {
    if (!this.state.selectedDay) {
      this.setState({ nextStageAttempt: true })
      ShipmentDetails.scrollTo('dayPicker')
      return
    }

    if (!this.state.incoterm && this.props.tenant.data.scope.incoterm_info_level === 'full') {
      this.setState({ nextStageAttempt: true })
      ShipmentDetails.scrollTo('incoterms')
      return
    }
    if (
      isEmpty(this.state.origin) ||
      isEmpty(this.state.destination) ||
      this.state.AddressFormsHaveErrors
    ) {
      this.setState({ nextStageAttempt: true })
      ShipmentDetails.scrollTo('map')
      return
    }
    // This was implemented under the assuption that in
    // the initial state the following return values apply:
    //   (1) ShipmentDetails.errorsExist(this.state.cargoItemsErrors) //=> true
    //   (2) ShipmentDetails.errorsExist(this.state.containersErrors) //=> true
    // So it will break out of the function and set nextStage attempt to true,
    // in case one of them returns false
    if (
      ShipmentDetails.errorsExist(this.state.cargoItemsErrors) &&
      ShipmentDetails.errorsExist(this.state.containersErrors)
    ) {
      this.setState({ nextStageAttempt: true })
      return
    }

    const data = { shipment: this.state.shipment }

    data.shipment.origin_user_input = this.state.origin.fullAddress
      ? this.state.origin.fullAddress
      : ''
    data.shipment.destination_user_input = this.state.destination.fullAddress
      ? this.state.destination.fullAddress
      : ''
    data.shipment.origin_id = this.state.origin.hub_id
    data.shipment.destination_id = this.state.destination.hub_id
    data.shipment.cargo_items_attributes = this.state.cargoItems
    data.shipment.containers_attributes = this.state.containers
    data.shipment.has_on_carriage = this.state.has_on_carriage
    data.shipment.has_pre_carriage = this.state.has_pre_carriage
    data.shipment.planned_pickup_date = this.state.selectedDay
    data.shipment.incoterm = this.state.incoterm
    data.shipment.carriageNexuses = this.state.carriageNexuses
    this.props.setShipmentDetails(data)
  }
  handleCarriageNexuses (target, id) {
    this.setState({
      carriageNexuses: {
        ...this.state.carriageNexuses,
        [target]: id
      }
    })
  }
  returnToDashboard () {
    this.props.shipmentDispatch.getDashboard(true)
  }

  handleChangeCarriage (target, value) {
    this.setState({ [target]: value })

    // Upate trucking details according to toggle
    const truckingKey = target.replace('has_', '')
    const { shipment } = this.state
    const artificialEvent = { target: {} }
    if (!value) {
      // Set truckType to '', if carriage is toggled off
      artificialEvent.target.id = `${truckingKey}-`
    } else if (!shipment.trucking[truckingKey].truck_type) {
      // Set first truckType if carriage is toggled on and truckType is empty
      const truckType = this.truckTypes[this.state.shipment.load_type][0]
      artificialEvent.target.id = `${truckingKey}-${truckType}`
    }
    if (!artificialEvent.target.id) return
    this.handleTruckingDetailsChange(artificialEvent)
  }

  handleTruckingDetailsChange (event) {
    const [carriage, truckType] = event.target.id.split('-')
    const { shipment } = this.state
    this.setState({
      shipment: {
        ...shipment,
        trucking: {
          ...shipment.trucking,
          [carriage]: { truck_type: truckType }
        }
      }
    })
  }

  toggleModal (name) {
    const { modals } = this.state
    modals[name].show = !modals[name].show
    this.setState({ modals })
  }

  render () {
    const {
      tenant, user, shipmentData, shipmentDispatch
    } = this.props
    const { modals } = this.state
    const {
      theme, scope
    } = tenant.data
    const { messages } = this.props
    let cargoDetails

    if (shipmentData.shipment) {
      if (shipmentData.shipment.load_type === 'container') {
        cargoDetails = (
          <ShipmentContainers
            containers={this.state.containers}
            addContainer={this.addNewContainer}
            handleDelta={this.handleContainerChange}
            deleteItem={this.deleteCargo}
            nextStageAttempt={this.state.nextStageAttempt}
            theme={theme}
            scope={scope}
            toggleModal={name => this.toggleModal(name)}
          />
        )
      }
      if (shipmentData.shipment.load_type === 'cargo_item') {
        cargoDetails = (
          <ShipmentCargoItems
            cargoItems={this.state.cargoItems}
            addCargoItem={this.addNewCargoItem}
            handleDelta={this.handleCargoItemChange}
            deleteItem={this.deleteCargo}
            nextStageAttempt={this.state.nextStageAttempt}
            theme={theme}
            scope={scope}
            availableCargoItemTypes={shipmentData.cargoItemTypes}
            toggleModal={name => this.toggleModal(name)}
          />
        )
      }
    }

    const routeIds = shipmentData.itineraries ? shipmentData.itineraries.map(route => route.id) : []

    const mapBox = (
      <GmapsLoader
        theme={theme}
        setTargetAddress={this.setTargetAddress}
        allNexuses={shipmentData.allNexuses}
        component={ShipmentLocationBox}
        handleChangeCarriage={this.handleChangeCarriage}
        has_on_carriage={this.state.has_on_carriage}
        has_pre_carriage={this.state.has_pre_carriage}
        origin={this.state.origin}
        destination={this.state.destination}
        nextStageAttempt={this.state.nextStageAttempt}
        handleAddressChange={this.handleAddressChange}
        shipment={shipmentData}
        routeIds={routeIds}
        handleCarriageNexuses={this.handleCarriageNexuses}
        shipmentDispatch={shipmentDispatch}
        prevRequest={this.props.prevRequest}
        handleSelectLocation={this.handleSelectLocation}
      />
    )
    const formattedSelectedDay = this.state.selectedDay
      ? moment(this.state.selectedDay).format('DD/MM/YYYY')
      : ''
    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''
    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }

    const showDayPickerError = this.state.nextStageAttempt && !this.state.selectedDay
    const showIncotermError = this.state.nextStageAttempt && !this.state.incoterm

    // const backgroundColor = value => (!value && this.state.
    // nextStageAttempt ? '#FAD1CA' : '#F9F9F9')
    // const placeholderColorOverwrite = value =>
    //   (!value && this.state.nextStageAttempt ? 'color: rgb(211, 104, 80);' : '')
    // const StyledSelect = styled(Select)`
    //   .Select-control {
    //     background-color: ${props => backgroundColor(props.value)};
    //     box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    //     border: 1px solid #f2f2f2 !important;
    //   }
    //   .Select-menu-outer {
    //     box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    //     border: 1px solid #f2f2f2;
    //   }
    //   .Select-value {
    //     background-color: ${props => backgroundColor(props.value)};
    //     border: 1px solid #f2f2f2;
    //   }
    //   .Select-placeholder {
    //     background-color: ${props => backgroundColor(props.value)};
    //     ${props => placeholderColorOverwrite(props.value)};
    //   }
    //   .Select-option {
    //     background-color: #f9f9f9;
    //   }
    // `

    const dayPickerSection = (
      <div className={`${defaults.content_width} layout-row flex-none layout-align-start-center`}>
        <div className="layout-row flex-50 layout-align-start-center layout-wrap">
          <div className={`${styles.bottom_margin} flex-100 layout-row layout-align-start-center`}>
            <div className="flex-none letter_2 layout-align-space-between-end">
              <TextHeading
                theme={theme}
                text="Available Dates"
                size={3}
              />
            </div>
            <Tooltip theme={theme} text="planned_pickup_date" icon="fa-info-circle" />
          </div>
          <div
            name="dayPicker"
            className={
              `flex-none layout-row ${styles.dpb} ` +
              `${showDayPickerError ? styles.with_errors : ''}`
            }
          >
            <div className={`flex-none layout-row layout-align-center-center ${styles.dpb_icon}`}>
              <i className="flex-none fa fa-calendar" />
            </div>
            <DayPickerInput
              name="dayPicker"
              placeholder="DD/MM/YYYY"
              format="DD/MM/YYYY"
              value={formattedSelectedDay}
              onDayChange={this.handleDayChange}
              dayPickerProps={dayPickerProps}
            />
            <span className={errorStyles.error_message}>
              {showDayPickerError ? 'Must not be blank' : ''}
            </span>
          </div>
        </div>

        <div className="flex-50 layout-row layout-wrap layout-align-end-center">
          <IncotermBox
            theme={theme}
            preCarriage={this.state.has_pre_carriage}
            onCarriage={this.state.has_on_carriage}
            tenantScope={scope}
            incoterm={this.state.incoterm}
            setIncoTerm={this.setIncoTerm}
            errorStyles={errorStyles}
            direction={shipmentData.shipment.direction}
            showIncotermError={showIncotermError}
            nextStageAttempt={this.state.nextStageAttempt}
          />
          {/* <div className="flex-100 layout-row layout-align-end-center">
            <div className="flex-none letter_2">
              <TextHeading theme={theme} text="Select Incoterm:" size={3} />
            </div>
          </div>
          <div className="flex-80" name="incoterms" style={{ position: 'relative' }}>
            <StyledSelect
              name="incoterms"
              className={styles.select}
              value={this.state.incoterm}
              options={incoterms}
              onChange={this.setIncoTerm}
            />
            <span className={errorStyles.error_message}>
              {showIncotermError ? 'Must not be blank' : ''}
            </span>
          </div> */}
        </div>
      </div>
    )
    const truckTypes = this.truckTypes[this.state.shipment.load_type]
    const showTruckingDetails =
      truckTypes.length > 1 && (this.state.has_pre_carriage || this.state.has_on_carriage)

    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '1800px' }}
      >
        {flash}
        {
          modals && Object.keys(modals)
            .filter(modalName => modals[modalName].show)
            .map(modalName => modals[modalName].jsx)
        }
        <div className={`layout-row flex-100 layout-wrap ${styles.map_cont}`}>{mapBox}</div>
        <div
          className={`${
            styles.date_sec
          } layout-row flex-100 layout-wrap layout-align-center-center`}
        >
          {dayPickerSection}
        </div>
        <div
          className={
            `${defaults.border_divider} ${styles.trucking_sec} layout-row flex-100 ` +
            `${showTruckingDetails ? styles.visible : ''} ` +
            'layout-wrap layout-align-center'
          }
        >
          <TruckingDetails
            theme={theme}
            trucking={this.state.shipment.trucking}
            truckTypes={truckTypes}
            handleTruckingDetailsChange={this.handleTruckingDetailsChange}
          />
        </div>
        <div className="flex-100 layout-row layout-align-center-center">
          <div className="flex-none content_width_booking layout-row layout-align-center-center">
            <IncotermRow
              theme={theme}
              preCarriage={this.state.has_pre_carriage}
              onCarriage={this.state.has_on_carriage}
              originFees={this.state.has_pre_carriage}
              destinationFees={this.state.has_on_carriage}
            />
          </div>
        </div>
        <div className={`layout-row flex-100 layout-wrap ${styles.cargo_sec}`}>{cargoDetails}</div>
        <div
          className={
            `${defaults.border_divider} layout-row flex-100 ` +
            'layout-wrap layout-align-center-center'
          }
        >
          <div
            className={
              `${styles.btn_sec} ${defaults.content_width} ` +
              'layout-row flex-none layout-wrap layout-align-start-start'
            }
          >
            {
              !(
                this.state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
                this.state.containers.some(container => container.dangerous_goods)
              )
                ? (
                  <div className="flex-50 layout-row layout-align-stretch">

                    <div className="flex-10 layout-row layout-align-start-start">
                      <Checkbox
                        theme={theme}
                        onChange={() => this.setState({
                          noDangerousGoodsConfirmed: !this.state.noDangerousGoodsConfirmed
                        })}
                        size="30px"
                        name="no_dangerous_goods_confirmation"
                        checked={this.state.noDangerousGoodsConfirmed}
                      />
                    </div>
                    <p className="flex-80" style={{ fontSize: '10.5px', textAlign: 'justify', margin: 0 }}>
                      By clicking this checkbox, you herby confirm that your cargo does not contain
                      hazardous materials, including (yet not limited to) pure chemicals,
                      mixtures of substances, manufactured products,
                      or articles which can pose a risk to people, animals or the environment
                      if not properly handled in use or in transport.
                    </p>
                  </div>
                )
                : <div className="flex-50" />
            }
            <div className="flex-50 layout-row layout-align-end">
              <RoundButton
                text="Get Offers"
                handleNext={this.handleNextStage}
                theme={theme}
                active={
                  this.state.noDangerousGoodsConfirmed ||
                  this.state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
                  this.state.containers.some(container => container.dangerous_goods)
                }
                disabled={
                  !this.state.noDangerousGoodsConfirmed &&
                  (
                    !this.state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
                    !this.state.containers.some(container => container.dangerous_goods)
                  )
                }
              />
            </div>
          </div>
        </div>
        {
          user && !user.guest && (
            <div className={
              `${defaults.border_divider} layout-row flex-100 ` +
              'layout-wrap layout-align-center-center'
            }
            >
              <div className={
                `${styles.btn_sec} ${defaults.content_width} ` +
                'layout-row flex-none layout-wrap layout-align-start-start'
              }
              >
                <RoundButton
                  text="Back to Dashboard"
                  handleNext={this.returnToDashboard}
                  iconClass="fa-angle-left"
                  theme={theme}
                  back
                />
              </div>
            </div>
          )
        }
      </div>
    )
  }
}

ShipmentDetails.propTypes = {
  shipmentData: PropTypes.shipmentData.isRequired,
  setShipmentDetails: PropTypes.func.isRequired,
  messages: PropTypes.arrayOf(PropTypes.string),
  setStage: PropTypes.func.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    getDashboard: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant.isRequired,
  user: PropTypes.user.isRequired
}

ShipmentDetails.defaultProps = {
  prevRequest: null,
  messages: []
}

export default ShipmentDetails
