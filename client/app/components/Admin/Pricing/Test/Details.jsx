import React, { Component } from 'react'
import * as Scroll from 'react-scroll'
import Toggle from 'react-toggle'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../../../prop-types'
import GmapsLoader from '../../../../hocs/GmapsLoader'
import styles from '../../../ShipmentDetails/ShipmentDetails.scss'
import defaults from '../../../../styles/default_classes.scss'
import '../../../../styles/day-picker-custom.css'
import { RoundButton } from '../../../RoundButton/RoundButton'
import { LocationDetails } from './LocationDetails'
import { ShipmentContainers } from '../../../ShipmentContainers/ShipmentContainers'
import { ShipmentCargoItems } from '../../../ShipmentCargoItems/ShipmentCargoItems'
import ShipmentAggregatedCargo from '../../../ShipmentAggregatedCargo/ShipmentAggregatedCargo'
import { FlashMessages } from '../../../FlashMessages/FlashMessages'
import { camelize, isEmpty, chargeableWeight } from '../../../../helpers'
import { Checkbox } from '../../../Checkbox/Checkbox'
import '../../../../styles/select-css-custom.css'
import getModals from '../../../ShipmentDetails/getModals'
import toggleCSS from '../../../ShipmentDetails/toggleCSS'
import getOffersBtnIsActive, {
  noDangerousGoodsCondition,
  stackableGoodsCondition
} from '../../../ShipmentDetails/getOffersBtnIsActive'
import formatCargoItemTypes from '../../../ShipmentDetails/formatCargoItemTypes'
import addressFieldsAreValid from '../../../ShipmentDetails/addressFieldsAreValid'
import calcAvailableMotsForRoute,
{ shouldUpdateAvailableMotsForRoute } from '../../../ShipmentDetails/calcAvailableMotsForRoute'
import getRequests from '../../../ShipmentLocationBox/getRequests'
import reuseShipments from '../../../../helpers/reuseShipment'

export class Details extends Component {
  static scrollTo (target) {
    Scroll.scroller.scrollTo(target, {
      duration: 800,
      smooth: true,
      offset: -180
    })
  }
  static errorsAt (errorsObjects) {
    return errorsObjects.findIndex(errorsObj => Object.values(errorsObj).some(error => error))
  }
  constructor (props) {
    super(props)
    this.state = {
      origin: {},
      noteIds: {},
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
      aggregatedCargo: {
        weight: 0,
        volume: 0
      },
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
      aggregatedCargoErrors: {
        weight: true,
        volume: true
      },
      aggregated: false,
      nextStageAttempts: 0,
      has_on_carriage: false,
      has_pre_carriage: false,
      shipment: props.shipmentData ? props.shipmentData.shipment : null,
      allNexuses: props.shipmentData ? props.shipmentData.allNexuses : {},
      routeSet: false,
      noDangerousGoodsConfirmed: false,
      stackableGoodsConfirmed: false,
      mandatoryCarriageIsPreset: false,
      shakeClass: {
        noDangerousGoodsConfirmed: '',
        stackableGoodsConfirmed: ''
      },
      prevRequestLoaded: false,
      availableMotsForRoute: [],
      filteredRouteIndexes: []
    }
    this.truckTypes = {
      container: ['side_lifter', 'chassis'],
      cargo_item: ['default']
    }

    if (this.props.shipmentData && this.props.shipmentData.shipment) {
      /* eslint-disable camelcase */
      const {
        planned_pickup_date, planned_origin_drop_off_date, has_on_carriage, has_pre_carriage
      } = this.props.shipmentData.shipment
      this.state.selectedDay = planned_pickup_date
      this.state = {
        ...this.state,
        has_on_carriage,
        has_pre_carriage,
        selectedDay: has_pre_carriage ? planned_pickup_date : planned_origin_drop_off_date
      }
      /* eslint-enable camelcase */
    }

    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.handleNextStage = this.handleNextStage.bind(this)
    this.addNewCargoItem = this.addNewCargoItem.bind(this)
    this.addNewContainer = this.addNewContainer.bind(this)
    this.setTargetAddress = this.setTargetAddress.bind(this)
    this.handleCargoItemChange = this.handleCargoItemChange.bind(this)
    this.handleContainerChange = this.handleContainerChange.bind(this)
    this.handleTruckingDetailsChange = this.handleTruckingDetailsChange.bind(this)
    this.deleteCargo = this.deleteCargo.bind(this)
    this.setIncoTerm = this.setIncoTerm.bind(this)
    this.handleSelectLocation = this.handleSelectLocation.bind(this)
    this.loadPrevReq = this.loadPrevReq.bind(this)
    this.updateFilteredRouteIndexes = this.updateFilteredRouteIndexes.bind(this)
  }
  componentWillMount () {
    const { prevRequest, setStage, reusedShipment } = this.props
    if (reusedShipment && reusedShipment.shipment && !this.state.prevRequestLoaded) {
      this.loadReusedShipment(reusedShipment)
    } else if (prevRequest && prevRequest.shipment && !this.state.prevRequestLoaded) {
      this.loadPrevReq(prevRequest.shipment)
    }
    // if (this.state.shipment && !this.state.mandatoryCarriageIsPreset) {
    //   this.presetMandatoryCarriage()
    // }

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
    if (
      shouldUpdateAvailableMotsForRoute(
        this.state.filteredRouteIndexes,
        nextState.filteredRouteIndexes
      )
    ) {
      this.updateAvailableMotsForRoute()

      return false
    }
    if (nextProps.shipmentData.routes && nextProps.shipmentData.routes.length > 0 &&
    nextState.filteredRouteIndexes.length === 0) {
      this.getInitalFilteredRouteIndexes()
    }

    return !!(
      (isEmpty(nextProps.prevRequest) || nextState.prevRequestLoaded) &&
      nextProps.shipmentData &&
      nextState.shipment &&
      nextState.modals &&
      nextProps.tenant &&
      nextProps.user &&
      nextProps.shipmentData.maxDimensions &&
      nextProps.shipmentData.routes
    )
  }
  componentWillUpdate () {
    if (this.state.shipment && !this.state.mandatoryCarriageIsPreset) {
      this.presetMandatoryCarriage()
    }
  }
  componentDidUpdate () {
    const {
      shipment,
      cargoItems,
      containers,
      aggregatedCargo,
      selectedDay,
      origin,
      destination,
      aggregated
    } = this.state
    this.props.bookingSummaryDispatch.update({
      shipment,
      cargoItems,
      aggregatedCargo,
      containers,
      selectedDay,
      origin,
      destination,
      aggregated
    })
  }

  setIncoTerm (opt) {
    // this.handleCarriageChange('has_on_carriage', opt.onCarriage)
    // this.handleCarriageChange('has_pre_carriage', opt.preCarriage)
    this.setState({
      incoterm: opt.value.id
    })
  }
  setNotesIds (ids, target) {
    const { noteIds } = this.state
    const { shipmentDispatch, shipmentData } = this.props
    if (!noteIds.itineraries) {
      const { routes } = shipmentData
      noteIds.itineraries = routes
    }
    noteIds[`${target}s`] = ids
    if (noteIds.origins && noteIds.destinations) {
      shipmentDispatch.getNotes(noteIds)
    }
    this.setState({ noteIds })
  }
  setTargetAddress (target, address) {
    this.setState({ [target]: address }, () => this.shouldProceedToCargo())
  }

  setAggregatedCargo (bool) {
    this.setState({ aggregated: bool })
  }

  getInitalFilteredRouteIndexes () {
    this.setState((prevState) => {
      const {
        filteredRouteIndexes
      } = prevState
      const { routes } = this.props.shipmentData

      if (filteredRouteIndexes.length === 0) {
        return { filteredRouteIndexes: routes.map((_, i) => i) }
      }

      return { filteredRouteIndexes }
    })
  }

  presetMandatoryCarriage () {
    const { scope } = this.props.tenant.data
    Object.keys(scope.carriage_options).forEach((carriage) => {
      const carriageOptionScope = scope.carriage_options[carriage][this.state.shipment.direction]
      if (carriageOptionScope === 'mandatory') {
        this.handleCarriageChange(`has_${carriage}`, true, { force: true })
      }
    })
    this.setState({ mandatoryCarriageIsPreset: true })
  }

  loadPrevReq (obj) {
    const newCargoItemsErrors = obj.cargo_items_attributes.map(cia => ({
      payload_in_kg: false,
      dimension_x: false,
      dimension_y: false,
      dimension_z: false,
      cargo_item_type_id: false,
      quantity: false
    }))
    const newContainerErrors = obj.containers_attributes.map(cia => ({
      payload_in_kg: false
    }))

    this.setState({
      cargoItems: obj.cargo_items_attributes,
      containers: obj.containers_attributes,
      cargoItemsErrors: newCargoItemsErrors,
      containersErrors: newContainerErrors,
      selectedDay: obj.selected_day,
      origin: obj.origin,
      destination: obj.destination,
      has_on_carriage: !!obj.trucking.on_carriage.truck_type,
      has_pre_carriage: !!obj.trucking.pre_carriage.truck_type,
      trucking: obj.trucking,
      incoterm: obj.incoterm,
      routeSet: true,
      prevRequestLoaded: true
    })
  }
  loadReusedShipment (obj) {
    const newCargoItemsErrors = obj.cargoItems.map(cia => ({
      payload_in_kg: false,
      dimension_x: false,
      dimension_y: false,
      dimension_z: false,
      cargo_item_type_id: false,
      quantity: false
    }))
    const newContainerErrors = obj.containers.map(cia => ({
      payload_in_kg: false
    }))
    this.setState({
      cargoItems: reuseShipments.reuseCargoItems(obj.cargoItems),
      containers: reuseShipments.reuseContainers(obj.containers),
      cargoItemsErrors: newCargoItemsErrors,
      containersErrors: newContainerErrors,
      selectedDay: obj.shipment.has_pre_carriage
        ? obj.shipment.planned_pickup_date : obj.shipment.planned_origin_dropp_off_date,
      origin: reuseShipments.reuseLocation(obj.shipment, 'origin'),
      destination: reuseShipments.reuseLocation(obj.shipment, 'destination'),
      has_on_carriage: !!obj.shipment.trucking.on_carriage.truck_type,
      has_pre_carriage: !!obj.shipment.trucking.pre_carriage.truck_type,
      trucking: obj.shipment.trucking,
      incoterm: obj.shipment.incoterm,
      routeSet: true,
      prevRequestLoaded: true
    })
  }

  updateAvailableMotsForRoute () {
    this.setState((prevState) => {
      const { routes, lookupTablesForRoutes } = this.props.shipmentData
      const { filteredRouteIndexes } = prevState
      const availableMotsForRoute =
        calcAvailableMotsForRoute(routes, lookupTablesForRoutes, filteredRouteIndexes)

      return { availableMotsForRoute }
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
      addressFormsHaveErrors: bool
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

  handleAggregatedCargoChange (event, hasError) {
    const { name, value } = event.target
    const { aggregatedCargo, aggregatedCargoErrors } = this.state

    if (!aggregatedCargo || !aggregatedCargoErrors) return
    aggregatedCargo[name] = value ? +value : 0
    if (hasError !== undefined) aggregatedCargoErrors[name] = hasError
    this.setState({ aggregatedCargo, aggregatedCargoErrors })
  }

  updateAirMaxDimensionsTooltips (value, divRef, suffixName) {
    const { maxDimensions } = this.props.shipmentData
    const { availableMotsForRoute } = this.state
    if (
      !maxDimensions.air ||
      (availableMotsForRoute.length && availableMotsForRoute.every(mot => mot === 'air'))
    ) {
      return
    }

    if (+value > +maxDimensions.air[camelize(suffixName)]) {
      setTimeout(() => { ReactTooltip.show(divRef) }, 500)
    } else {
      ReactTooltip.hide(divRef)
    }
  }

  updatedExcessChargeableWeightText (cargoItems) {
    const { maxAggregateDimensions } = this.props.shipmentData
    const { availableMotsForRoute } = this.state
    if (
      !maxAggregateDimensions.air ||
      (availableMotsForRoute.length && availableMotsForRoute.every(mot => mot === 'air'))
    ) {
      return ''
    }

    const totalChargeableWeight = cargoItems.reduce((sum, cargoItem) => (
      sum + +chargeableWeight(cargoItem, 'air')
    ), 0)

    let excessChargeableWeightText = ''
    if (totalChargeableWeight > +maxAggregateDimensions.air.chargeableWeight) {
      excessChargeableWeightText = `
        Please note that the total chargeable weight for Air Freight shipments
        (${totalChargeableWeight.toFixed(1)} kg) excedes the maximum
        (${maxAggregateDimensions.air.chargeableWeight} kg).
      `
    } else {
      excessChargeableWeightText = ''
    }

    return excessChargeableWeightText
  }

  handleCargoItemChange (event, hasError, divRef) {
    const { name, value } = event.target
    const [index, suffixName] = name.split('-')
    const { cargoItems, cargoItemsErrors } = this.state

    if (!cargoItems[index] || !cargoItemsErrors[index]) return
    if (typeof value === 'boolean') {
      cargoItems[index][suffixName] = value
    } else {
      cargoItems[index][suffixName] = value ? +value : 0
    }

    this.updateAirMaxDimensionsTooltips(value, divRef, suffixName)

    const excessChargeableWeightText =
      this.updatedExcessChargeableWeightText(cargoItems)

    if (hasError !== undefined) cargoItemsErrors[index][suffixName] = hasError
    this.setState({ cargoItems, cargoItemsErrors, excessChargeableWeightText })
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

  toggleAggregatedCargo () {
    this.setState(prevState => ({ aggregated: !prevState.aggregated }))
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

  incrementNextStageAttemps () {
    this.setState(prevState => (
      { nextStageAttempts: prevState.nextStageAttempts + 1 }
    ))
  }

  handleNextStage () {
    const {
      origin, destination, selectedDay, incoterm
    } = this.state
    if (
      (!origin.nexus_id && !this.state.has_pre_carriage) ||
      (!destination.nexus_id && !this.state.has_on_carriage) ||
      (!addressFieldsAreValid(origin) && this.state.has_pre_carriage) ||
      (!addressFieldsAreValid(destination) && this.state.has_on_carriage) ||
      this.state.addressFormsHaveErrors
    ) {
      this.incrementNextStageAttemps()
      Details.scrollTo('map')

      return
    }
    if (!selectedDay) {
      this.incrementNextStageAttemps()
      Details.scrollTo('dayPicker')

      return
    }

    if (!incoterm && this.props.tenant.data.scope.incoterm_info_level === 'full') {
      this.incrementNextStageAttemps()
      Details.scrollTo('incoterms')

      return
    }

    if (this.state.aggregated) {
      // TBD
    } else {
      const { shipment } = this.state
      const loadType = camelize(shipment.load_type)
      const errorIdx = Details.errorsAt(this.state[`${loadType}sErrors`])

      if (errorIdx > -1) {
        this.incrementNextStageAttemps()
        Details.scrollTo(`${errorIdx}-${loadType}`)

        return
      }
    }

    const shipment = {
      id: this.state.shipment.id,
      origin,
      destination,
      incoterm,
      selected_day: selectedDay,
      trucking: this.state.shipment.trucking,
      cargo_items_attributes: this.state.cargoItems,
      containers_attributes: this.state.containers,
      aggregated_cargo_attributes: this.state.aggregated && this.state.aggregatedCargo
    }

    this.props.getOffers({ shipment })
  }

  returnToDashboard () {
    this.props.shipmentDispatch.getDashboard(true)
  }

  handleCarriageChange (target, value, options) {
    const carriage = target.replace('has_', '')

    // Break out of function, in case the change should not apply, based on the tenant scope.
    // const { scope } = this.props.tenant.data
    // const carriageOptionScope = scope.carriage_options[carriage][this.state.shipment.direction]
    // const changeShouldApply = carriageOptionScope === 'optional' || (options && options.force)
    // if (!changeShouldApply) return

    this.setState({ [target]: value }, () => this.updateIncoterms())

    // Update trucking details according to toggle
    const { shipment } = this.state
    const artificialEvent = { target: {} }

    if (!value) {
      // Set truckType to '', if carriage is toggled off
      artificialEvent.target.id = `${carriage}-`
    } else if (!shipment.trucking[carriage].truck_type) {
      // Set first truckType, if carriage is toggled on and truckType is empty
      const truckType = this.truckTypes[this.state.shipment.load_type][0]
      artificialEvent.target.id = `${carriage}-${truckType}`
    }

    if (!artificialEvent.target.id) return
    this.handleTruckingDetailsChange(artificialEvent)
  }
  handleIncotermResults (results) {
    if (results.length === 1) {
      this.setIncoTerm(results[0])
    }
    this.setState({ incotermsArray: results })
  }
  updateIncoterms () {
    const { direction } = this.props.shipmentData.shipment
    // eslint-disable-next-line camelcase
    const { has_pre_carriage, has_on_carriage } = this.state
    getRequests.incoterms(direction, has_pre_carriage, has_on_carriage, (incotermResults) => {
      this.handleIncotermResults(incotermResults)
    })
  }
  handleNextStageDisabled () {
    this.setState(prevState => ({
      shakeClass: {
        noDangerousGoodsConfirmed: noDangerousGoodsCondition(prevState) ? '' : 'apply_shake',
        stackableGoodsConfirmed: stackableGoodsCondition(prevState) ? '' : 'apply_shake'
      }
    }))
    setTimeout(() => {
      this.setState({
        shakeClass: {
          noDangerousGoodsConfirmed: '',
          stackableGoodsConfirmed: ''
        }
      })
    }, 1000)
  }

  handleTruckingDetailsChange (event) {
    const [carriage, truckType] = event.target.id.split('-')
    this.setState(prevState => ({
      shipment: {
        ...prevState.shipment,
        trucking: {
          ...prevState.shipment.trucking,
          [carriage]: { truck_type: truckType }
        }
      }
    }))
  }

  toggleModal (name) {
    const { modals } = this.state
    modals[name].show = !modals[name].show
    this.setState({ modals })
  }

  updateFilteredRouteIndexes (filteredRouteIndexes) {
    this.setState({ filteredRouteIndexes })
  }
  shouldProceedToCargo () {
    const { origin, destination } = this.state
    debugger // eslint-disable-line
    if ((origin.nexus_id || origin.street_address) &&
    (destination.nexus_id || destination.street_address)) {
      this.props.setStep(3)
    }
  }

  render () {
    const {
      tenant, user, shipmentData, shipmentDispatch, messages, showRegistration, step
    } = this.props

    const { modals, filteredRouteIndexes } = this.state
    const { theme, scope } = tenant.data
    let cargoDetails
    if (showRegistration) this.props.hideRegistration()
    if (!shipmentData.shipment || !shipmentData.cargoItemTypes) return ''

    if (this.state.aggregated) {
      cargoDetails = (
        <ShipmentAggregatedCargo
          aggregatedCargo={this.state.aggregatedCargo}
          handleDelta={(event, hasError) => this.handleAggregatedCargoChange(event, hasError)}
          nextStageAttempt={this.state.nextStageAttempts > 0}
          theme={theme}
          scope={scope}
          stackableGoodsConfirmed={this.state.stackableGoodsConfirmed}
        />
      )
    } else if (shipmentData.shipment.load_type === 'container') {
      cargoDetails = (
        <ShipmentContainers
          containers={this.state.containers}
          addContainer={this.addNewContainer}
          handleDelta={this.handleContainerChange}
          deleteItem={this.deleteCargo}
          nextStageAttempt={this.state.nextStageAttempts > 0}
          theme={theme}
          scope={scope}
          toggleModal={name => this.toggleModal(name)}
        />
      )
    } else if (shipmentData.shipment.load_type === 'cargo_item') {
      cargoDetails = (
        <ShipmentCargoItems
          cargoItems={this.state.cargoItems}
          addCargoItem={this.addNewCargoItem}
          handleDelta={this.handleCargoItemChange}
          deleteItem={this.deleteCargo}
          nextStageAttempt={this.state.nextStageAttempts > 0}
          theme={theme}
          scope={scope}
          availableCargoItemTypes={formatCargoItemTypes(shipmentData.cargoItemTypes)}
          maxDimensions={shipmentData.maxDimensions}
          availableMotsForRoute={this.state.availableMotsForRoute}
          toggleModal={name => this.toggleModal(name)}
        />
      )
    }

    const routeIds = shipmentData.itineraries ? shipmentData.itineraries.map(route => route.id) : []

    const mapBox = (
      <GmapsLoader
        theme={theme}
        setTargetAddress={this.setTargetAddress}
        allNexuses={shipmentData.allNexuses}
        component={LocationDetails}
        handleCarriageChange={(...args) => this.handleCarriageChange(...args)}
        has_on_carriage={this.state.has_on_carriage}
        has_pre_carriage={this.state.has_pre_carriage}
        origin={this.state.origin}
        destination={this.state.destination}
        nextStageAttempts={this.state.nextStageAttempts}
        handleAddressChange={this.handleAddressChange}
        shipmentData={shipmentData}
        routeIds={routeIds}
        setNotesIds={(e, t) => this.setNotesIds(e, t)}
        shipmentDispatch={shipmentDispatch}
        prevRequest={this.props.prevRequest}
        handleSelectLocation={this.handleSelectLocation}
        scope={scope}
        selectedTrucking={this.state.shipment.trucking}
        handleTruckingDetailsChange={this.handleTruckingDetailsChange}
        filteredRouteIndexes={filteredRouteIndexes}
        updateFilteredRouteIndexes={this.updateFilteredRouteIndexes}
        reusedShipment={this.props.reusedShipment}
        hideMap={this.props.hideMap}
      />
    )

    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''

    const styleTagJSX = theme ? <style>{toggleCSS(theme)}</style> : ''

    return (
      <div
        className="layout-row flex-100 layout-wrap no_max SHIP_DETAILS layout-align-start-start"
        style={{ minHeight: '1800px' }}
      >
        {flash}
        {modals &&
          Object.keys(modals)
            .filter(modalName => modals[modalName].show)
            .map(modalName => modals[modalName].jsx)}
        { step === 2 ? <div className="layout-row flex-100 layout-wrap">{mapBox}</div> : '' }
        { step === 3
          ? <div className={`layout-row flex-100 layout-wrap layout-align-center ${styles.cargo_sec}`}>
            {shipmentData.shipment.load_type === 'cargo_item' && (
              <div className="content_width_booking layout-row layout-wrap layout-align-center">
                <div
                  className={
                    `${styles.toggle_aggregated_sec} ` +
                  'flex-50 layout-row layout-align-space-around-center'
                  }
                >
                  <h3
                    className={this.state.aggregated ? 'pointy' : ''}
                    style={{ opacity: this.state.aggregated ? 0.4 : 1 }}
                    onClick={() => this.setAggregatedCargo(false)}
                  >
                  Cargo Units
                  </h3>
                  <Toggle
                    className="flex-none aggregated_cargo"
                    id="aggregated_cargo"
                    name="aggregated_cargo"
                    checked={this.state.aggregated}
                    onChange={() => this.toggleAggregatedCargo()}
                  />
                  <h3
                    className={this.state.aggregated ? '' : 'pointy'}
                    style={{ opacity: this.state.aggregated ? 1 : 0.4 }}
                    onClick={() => this.setAggregatedCargo(true)}
                  >
                  Total Dimensions
                  </h3>
                </div>
              </div>
            )}
            <div className="flex-100 layout-row layout-align-center-center">
              {cargoDetails}
            </div>
          </div>
          : '' }
        { step === 4 ? <div
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
            <div className="flex-60 layout-row layout-wrap layout-align-start-center">
              {this.state.aggregated && (
                <div
                  className={
                    `${this.state.shakeClass.stackableGoodsConfirmed} flex-100 ` +
                    'layout-row layout-align-start-center'
                  }
                  style={{ marginBottom: '15px' }}
                >
                  <div className="flex-10 layout-row layout-align-start-start">
                    <Checkbox
                      theme={theme}
                      onChange={() =>
                        this.setState({
                          stackableGoodsConfirmed: !this.state.stackableGoodsConfirmed
                        })
                      }
                      size="30px"
                      name="stackable_goods_confirmation"
                      checked={this.state.stackableGoodsConfirmed}
                    />
                  </div>
                  <div className="flex">
                    <p style={{ margin: 0, fontSize: '14px', width: '100%' }}>
                      I hereby confirm that my cargo consists of stackable items exclusively.
                      <br />
                      <span style={{ fontSize: '11px', width: '100%' }}>
                        (Should you wish to ship non-stackable cargo, please select{' '}
                        {"'Cargo Units'"})
                      </span>
                    </p>
                  </div>
                </div>
              )}
              {!(
                this.state.cargoItems.some(cargoItem => cargoItem.dangerous_goods) ||
                this.state.containers.some(container => container.dangerous_goods)
              ) && (
                <div
                  className={
                    `${this.state.shakeClass.noDangerousGoodsConfirmed} flex-100 ` +
                    'layout-row layout-align-start-center'
                  }
                >
                  <div className="flex-10 layout-row layout-align-start-start">
                    <Checkbox
                      theme={theme}
                      onChange={() =>
                        this.setState({
                          noDangerousGoodsConfirmed: !this.state.noDangerousGoodsConfirmed
                        })
                      }
                      size="30px"
                      name="no_dangerous_goods_confirmation"
                      checked={this.state.noDangerousGoodsConfirmed}
                    />
                  </div>
                  <div className="flex">
                    <p style={{ margin: 0, fontSize: '14px' }}>
                        I hereby confirm that none of the specified cargo units contain{' '}
                      <span
                        className="emulate_link blue_link"
                        onClick={() => this.toggleModal('dangerousGoodsInfo')}
                      >
                          dangerous goods
                      </span>
                        .
                    </p>
                  </div>
                </div>
              )}
            </div>
            <div className="flex layout-row layout-wrap layout-align-end">
              <div className="flex-100 layout-row layout-align-end">
                <RoundButton
                  text="Get Offers"
                  handleNext={this.handleNextStage}
                  handleDisabled={() => this.handleNextStageDisabled()}
                  theme={theme}
                  active={getOffersBtnIsActive(this.state)}
                  disabled={!getOffersBtnIsActive(this.state)}
                />
              </div>
              <div className="flex-100 layout-row layout-align-end">
                <p style={{ fontSize: '14px', width: '317px' }}>
                  { this.state.excessChargeableWeightText }
                </p>
              </div>
            </div>
          </div>
        </div> : '' }
        {user &&
          !user.guest && (
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
              <div
                className={
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
          </div>
        )}
        {styleTagJSX}
      </div>
    )
  }
}

Details.propTypes = {
  shipmentData: PropTypes.shipmentData.isRequired,
  getOffers: PropTypes.func.isRequired,
  messages: PropTypes.arrayOf(PropTypes.objectOf(PropTypes.string)),
  setStage: PropTypes.func.isRequired,
  setStep: PropTypes.func.isRequired,
  prevRequest: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  reusedShipment: PropTypes.shape({
    shipment: PropTypes.shipment
  }),
  shipmentDispatch: PropTypes.shape({
    goTo: PropTypes.func,
    getDashboard: PropTypes.func
  }).isRequired,
  bookingSummaryDispatch: PropTypes.shape({
    update: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant.isRequired,
  user: PropTypes.user.isRequired,
  showRegistration: PropTypes.bool,
  hideMap: PropTypes.bool,
  hideRegistration: PropTypes.func,
  step: PropTypes.number.isRequired
}

Details.defaultProps = {
  prevRequest: null,
  messages: [],
  reusedShipment: null,
  showRegistration: false,
  hideRegistration: null,
  hideMap: false
}

export default Details
