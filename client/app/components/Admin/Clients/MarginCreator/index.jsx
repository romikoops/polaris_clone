import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get, groupBy, has } from 'lodash'
import DayPickerInput from 'react-day-picker/lib/src/DayPickerInput'
import {
  formatDate,
  parseDate
} from 'react-day-picker/moment'
import { clientsActions } from '../../../../actions'
import { moment, getTenantApiUrl, cargoClassOptions } from '../../../../constants'
import styles from '../index.scss'
import RoundButton from '../../../RoundButton/RoundButton'
import NamedSelect from '../../../NamedSelect/NamedSelect'
import NamedAsync from '../../../NamedSelect/NamedAsync'
import StandardSelect from '../../../NamedSelect/StandardSelect'
import GreyBox from '../../../GreyBox/GreyBox'
import LoadingSpinner from '../../../LoadingSpinner/LoadingSpinner'
import { authHeader } from '../../../../helpers'

class AdminClientMarginCreator extends Component {
  static dayPickerProps (end) {
    const dayBuffer = end ? 365 : 7

    return {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days'))
      },
      month: new Date(
        moment()
          .add(dayBuffer, 'days')
          .format('YYYY'),
        moment()
          .add(dayBuffer, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }
  }

  static generateNewState (props, state) {
    const { marginFormData } = props
    const { cargo_classes, service_levels, pricings } = marginFormData
    const {
      selectedItineraries, selectedCargoClasses, selectedServiceLevels, attachedToPricing, defaultCargoClasses
    } = state
    let newState = {}
    let cargoClasses = defaultCargoClasses
    let serviceLevels = []

    if (attachedToPricing) {
      const filteredPricings = pricings.filter(p => selectedItineraries.map(it => it.value.id).includes(p.itinerary_id))
      newState = { pricings: filteredPricings }
    } else if (selectedItineraries.length < 1 || get(selectedItineraries, [0, 'value']) === null) {
      newState = {
        cargoClasses: defaultCargoClasses,
        serviceLevels: service_levels
      }
    } else {
      const itineraryIds = selectedItineraries.map(it => get(it, ['value', 'id'], null))
      if (selectedCargoClasses.length < 1 && selectedItineraries) {
        cargoClasses = cargo_classes.filter(cc => itineraryIds.includes(cc.itinerary_id))
      }
      let filteredServiceLevels = service_levels
        .filter(sl => (itineraryIds.includes(sl.itinerary_id)))
      if (selectedCargoClasses.length > 0 && selectedServiceLevels.length < 1) {
        const cargoClasses = selectedCargoClasses.map(cc => get(cc, ['value', 'cargo_class']))
        filteredServiceLevels = filteredServiceLevels.filter(sl => cargoClasses.includes(sl.cargo_class))
      }

      if (selectedCargoClasses.length > 0 && selectedServiceLevels.length > 0) {
        const serviceLevelsById = groupBy(filteredServiceLevels, s => s.tenant_vehicle_id)
        serviceLevels = Object.values(serviceLevelsById).map(v => v[0])
      }

      newState = {
        cargoClasses,
        serviceLevels
      }
    }

    return newState
  }

  static getDerivedStateFromProps (nextProps, prevState) {
    return AdminClientMarginCreator.generateNewState(nextProps, prevState)
  }

  constructor (props) {
    super(props)
    const { t } = props
    this.state = {
      cargoClasses: [],
      serviceLevels: [],
      pricings: [],
      selectedItineraries: [],
      selectedHubs: [],
      selectedCargoClasses: [],
      selectedServiceLevels: [],
      selectedHubDirection: [],
      selectedGroup: null,
      fineFeeValues: {},
      operand: { label: t('admin:percentage'), value: '%' },
      marginValue: 0,
      selectedDates: {
        effective_date: moment(),
        expiration_date: moment().add(1, 'year')
      },
      attachedToPricing: false,
      defaultCargoClasses: cargoClassOptions.map(cc => ({ cargo_class: cc.value, label: cc.label }))
    }
    this.handleMarginValueChange = this.handleMarginValueChange.bind(this)
    this.handleFineMarginValueChange = this.handleFineMarginValueChange.bind(this)
    this.toggleAttachedToPricing = this.toggleAttachedToPricing.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    clientsDispatch.getMarginFormData()
  }

  selectItinerary (n, e) {
    const freshState = {
      cargoClasses: [],
      carriers: [],
      serviceLevels: [],
      pricings: [],
      selectedItineraries: e,
      selectedCargoClasses: [],
      selectedCarrier: [],
      selectedServiceLevels: []
    }
    this.setState(freshState)
    const { clientsDispatch } = this.props
    const itineraryIds = e.map(it => get(it, ['value', 'id'], null))
    clientsDispatch.getMarginFormData(itineraryIds, null)
  }

  selectHub (n, e) {
    const freshState = {
      cargoClasses: [],
      carriers: [],
      serviceLevels: [],
      pricings: [],
      selectedHubs: e,
      selectedCargoClasses: [],
      selectedCarrier: [],
      selectedServiceLevels: []
    }
    this.setState(freshState)
    const { clientsDispatch } = this.props
    clientsDispatch.getMarginFormData()
  }

  selectCounterpartHub (n, e) {
    this.setState({ counterpartHub: e })
  }

  selectHub (n, e) {
    const freshState = {
      cargoClasses: [],
      carriers: [],
      serviceLevels: [],
      pricings: [],
      selectedHubs: e,
      selectedCargoClasses: [],
      selectedCarrier: [],
      selectedServiceLevels: []
    }
    this.setState(freshState)
    const { clientsDispatch } = this.props
    clientsDispatch.getMarginFormData()
  }

  selectCounterpartHub (n, e) {
    this.setState({ counterpartHub: e })
  }

  handleMarginValueChange (e) {
    this.setState({ marginValue: e.target.value })
  }

  handleFineMarginValueChange (fee, e) {
    const { value } = e.target
    this.setState(prevState => ({
      fineFeeValues: {
        ...prevState.fineFeeValues,
        [fee]: {
          ...get(prevState, ['fineFeeValues', fee], {}),
          value
        }
      }
    }))
  }

  handleSelect (type, e) {
    this.setState((prevState) => {
      if (['selectedGroup', 'operand'].includes(type)) {
        return { [type]: e }
      }
      const all = e.filter(t => t.label === 'All')
      let newValues = e
      if (all && e.length > 1) {
        newValues = e.filter(t => t.label !== 'All')
      }

      return { [type]: newValues }
    }, () => {
      this.prepRemainingOptions()
    })
  }

  handleFineFeeSelect (fee, e) {
    this.setState(prevState => ({
      fineFeeValues: {
        ...prevState.fineFeeValues,
        [fee]: {
          ...get(prevState, ['fineFeeValues', fee], {}),
          operand: e
        }
      }
    }))
  }

  handleDayChange (date, target) {
    this.setState({
      selectedDates: {
        ...this.state.selectedDates,
        [target]: date
      }
    })
  }

  handleFineMarginDetails (bool) {
    const { clientsDispatch } = this.props
    const {
      selectedItineraries,
      selectedCargoClasses,
      selectedServiceLevels,
      selectedPricing,
      fineFeeValues,
      selectedHubs,
      counterpartHub,
      selectedHubDirection,
      marginType
    } = this.state
    let newFeeValues
    if (bool) {
      const req = selectedPricing ? {
        pricing_id: get(selectedPricing, ['value', 'id'], null)
      } : {
        marginType,
        directions: selectedHubDirection.map(dir => get(dir, ['value'], null)),
        hub_ids: selectedHubs.map(it => get(it, ['value', 'id'], null)),
        counterpart_hub_id: get(counterpartHub, ['value', 'id'], null),
        itinerary_ids: selectedItineraries.map(it => get(it, ['value', 'id'], null)),
        cargo_classes: selectedCargoClasses.map(cc => get(cc, ['value', 'cargo_class'], 'all')),
        tenant_vehicle_ids: selectedServiceLevels.map(sl => get(sl, ['value', 'tenant_vehicle_id'], 'all')),
        pricing_id: get(selectedPricing, ['value', 'id'], null)
      }

      clientsDispatch.getFinerMarginDetails(req)
      newFeeValues = fineFeeValues
    } else {
      newFeeValues = []
    }

    this.setState({ fineMarginDetail: bool, fineFeeValues: newFeeValues })
  }

  prepRemainingOptions () {
    const newState = AdminClientMarginCreator.generateNewState(this.props, this.state)
    this.setState(newState)
  }

  determineStep () {
    const {
      selectedItineraries,
      selectedCargoClasses,
      selectedServiceLevels,
      selectedDates,
      selectedPricing,
      attachedToPricing,
      selectedGroup,
      selectedHubs,
      attachedTo,
      marginType
    } = this.state
    const { marginFormData } = this.props
    const { targetGroupId } = marginFormData
    if (!targetGroupId && !selectedGroup) {
      return 0
    }
    if (!attachedTo) {
      return 1
    }
    const attachedSelected = (selectedItineraries.length > 0 || selectedHubs.length > 0)
    if (!attachedSelected && selectedCargoClasses.length < 1) {
      return 2
    }

    if (attachedSelected && attachedToPricing && !selectedPricing) {
      return 3
    }
    if (attachedSelected && attachedToPricing && selectedPricing) {
      return 7
    }
    if (attachedSelected && selectedCargoClasses.length < 1) {
      return 3
    }
    if (attachedSelected && selectedCargoClasses.length > 1 &&
      selectedServiceLevels.length < 1 && marginType !== 'trucking') {
      return 4
    }

    if (attachedSelected && selectedCargoClasses.length > 1 &&
      (selectedServiceLevels.length > 1 || marginType === 'trucking') &&
      (!selectedDates.effective_date || !selectedDates.expiration_date)) {
      return 5
    }

    if (attachedSelected && selectedCargoClasses.length > 1 &&
      (selectedServiceLevels.length > 1 || marginType === 'trucking') &&
      (!selectedDates.effective_date || !selectedDates.expiration_date)) {
      return 6
    }

    return 7
  }

  saveMargin () {
    const { clientsDispatch, marginFormData } = this.props
    const { targetGroupId } = marginFormData
    const {
      selectedItineraries,
      selectedCargoClasses,
      selectedServiceLevels,
      operand,
      marginValue,
      fineFeeValues,
      selectedDates,
      selectedGroup,
      selectedPricing,
      selectedHubs,
      selectedHubDirection,
      marginType,
      counterpartHub,
      attachedTo
    } = this.state
    const { effective_date, expiration_date } = selectedDates
    clientsDispatch.createMargin({
      itinerary_ids: selectedItineraries.map(it => get(it, ['value', 'id'], null)),
      cargo_classes: selectedCargoClasses.map(cc => get(cc, ['value', 'cargo_class'], null)),
      tenant_vehicle_ids: selectedServiceLevels.map(sl => get(sl, ['value', 'tenant_vehicle_id'], null)),
      pricing_id: get(selectedPricing, ['value', 'id'], null),
      operand,
      marginValue,
      fineFeeValues,
      groupId: targetGroupId || selectedGroup.value.id,
      effective_date,
      expiration_date,
      hub_ids: selectedHubs.map(h => get(h, ['value', 'id'], null)),
      hub_direction: selectedHubDirection.map(dir => get(dir, ['value'])),
      marginType,
      counterpart_hub: get(counterpartHub, ['value'], null),
      attached_to: attachedTo
    })
    // clientsDispatch.goTo(`/admin/clients/groups/${targetGroupId || selectedGroup.value.id}`)
  }

  toggleAttachedToPricing () {
    this.setState(prevState => ({ attachedToPricing: !prevState.attachedToPricing }), () => {
      this.prepRemainingOptions()
    })
  }

  setAttachment (target) {
    this.setState({ attachedTo: target })
  }

  setMarginType (target) {
    if (target === 'freight') {
      this.setState({ marginType: target })
    } else {
      this.setState({ marginType: target, attachedTo: 'hub' })
    }
  }

  selectHubDirection (target) {
    this.setState({ selectedHubDirection: target })
  }

  render () {
    const { t, theme, marginFormData } = this.props
    const {
      fineFeeData, groups, targetGroupId
    } = marginFormData
    const {
      cargoClasses,
      serviceLevels,
      selectedItineraries,
      selectedPricing,
      selectedCargoClasses,
      selectedServiceLevels,
      operand,
      marginValue,
      fineFeeValues,
      fineMarginDetail,
      selectedDates,
      selectedHubs,
      selectedHubDirection,
      pricings,
      attachedToPricing,
      selectedGroup,
      attachedTo,
      marginType,
      counterpartHub
    } = this.state
    if (!groups) return <LoadingSpinner size="large" />

    const groupOptions = groups.map(g => ({ label: g.name, value: g }))
    const filteredCargoClassOptions = cargoClasses.map(cc => ({ label: t(`common:${cc.cargo_class}`), value: cc }))
    const serviceLevelOptions = serviceLevels.map(sl => ({ label: sl.service_level, value: sl }))
    const pricingOptions = pricings.map(p => ({ label: `(${p.cargo_class}) ${p.carrier} - ${p.service_level}`, value: p }))
    const allItineraries = selectedItineraries.length === 1 && selectedItineraries[0].value === null
    if (selectedCargoClasses.length < 1) {
      filteredCargoClassOptions.unshift({ label: t('common:all'), value: null })
    }

    if (selectedServiceLevels.length < 1) {
      serviceLevelOptions.unshift({ label: t('common:all'), value: null })
    }
    const operandOptions = [
      { label: t('admin:percentage'), value: '%' },
      { label: t('admin:addition'), value: '+' }
    ]
    const hubDirectionOptions = [
      { label: t('admin:import'), value: 'import' },
      { label: t('admin:export'), value: 'export' }
    ]
    const fineFeeFields = fineFeeData && fineFeeData.length > 0
      ? fineFeeData.map(fd => (
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-33">
            <p>{fd}</p>
          </div>
          <div className="flex-33 layout-row layout-align-space-between-center layout-wrap">
            <div className="flex-100">
              <p>{t('admin:chooseMarginType')}</p>
            </div>
            <div className="flex-100 layout-row layout-align-end-center">
              <NamedSelect
                className="flex-100"
                options={operandOptions}
                onChange={e => this.handleFineFeeSelect(fd, e)}
                value={get(fineFeeValues, [fd, 'operand'], {})}
                theme={theme}
              />
            </div>
          </div>
          <div className="flex-33 layout-row layout-align-space-between-center layout-wrap">
            <div className="flex-100">
              <p>{t('admin:chooseMarginAmount')}</p>
            </div>
            <div className="flex-100 layout-row layout-align-end-center input_box_full">
              <input
                type="number"
                step="0.01"
                value={get(fineFeeValues, [fd, 'value'], 0)}
                onChange={e => this.handleFineMarginValueChange(fd, e)}
              />
            </div>
          </div>
        </div>
      )) : [
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-none">
            <p>{t('admin:noFees')}</p>
          </div>
        </div>
      ]

    const step = this.determineStep()
    const selectedBorderStyle = { border: `5px solid ${theme.colors.primary}` }
    const getItineraryOptions = (input) => {
      const requestOptions = {
        method: 'GET',
        headers: { ...authHeader() }
      }

      return window
        .fetch(`${getTenantApiUrl()}/admin/margins/form/itineraries?query=${input}`, requestOptions)
        .then(response => response.json())
        .then(json => ({ options: json.data }))
    }
    const getHubOptions = (input) => {
      const requestOptions = {
        method: 'GET',
        headers: { ...authHeader() }
      }

      return window
        .fetch(`${getTenantApiUrl()}/admin/hubs/search/options?query=${input}`, requestOptions)
        .then(response => response.json())
        .then(json => ({ options: json.data }))
    }

    return (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap padd_20">
        <div className={`flex-100 flex-gt-sm-80 layout-row layout-align-center-center 
        layout-wrap ${styles.margin_creator_wrapper}`}
        >
          <div className={`flex-100 layout-row layout-align-start-center ${styles.header}`}>
            <h1 className="flex-none">Margin Creator</h1>
          </div>
          <div className="flex-100 layout-row layout-wrap">
            { !targetGroupId ? (
              <GreyBox
                contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper}`}
                wrapperClassName={`flex-100 ${styles.option_row}`}
              >
                <div className="flex-33">
                  <p>{t('admin:chooseGroup')}</p>
                </div>
                <div className="flex-33 layout-row layout-align-end-center">
                  <NamedSelect
                    className="flex"
                    options={groupOptions}
                    onChange={e => this.handleSelect('selectedGroup', e)}
                    value={selectedGroup}
                    theme={theme}
                  />
                </div>
              </GreyBox>
            ) : '' }
            <GreyBox
              contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 1 ? styles.option_fade : ''}`}
              wrapperClassName={`flex-100 ${styles.option_row}`}
            >
              { step < 1 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
              <div className="flex-25">
                <p>{t('admin:typeOfMargin')}</p>
              </div>
              <div className="flex-25 layout-row layout-align-end-center">
                <GreyBox
                  contentClassName={`flex-100 layout-row layout-align-center-center 
                    layout-wrap pointy ${styles.box_button}`}
                  wrapperClassName="flex-90"
                  onClick={() => this.setMarginType('trucking')}
                  style={step > 1 && marginType === 'trucking' ? selectedBorderStyle : {}}
                >
                  <p className="flex-none">
                    {t('admin:trucking')}
                  </p>
                </GreyBox>
              </div>
              <div className="flex-25 layout-row layout-align-end-center">
                <GreyBox
                  contentClassName={`flex-100 layout-row layout-align-center-center layout-wrap pointy ${styles.box_button}`}
                  wrapperClassName="flex-90"
                  onClick={() => this.setMarginType('freight')}
                  style={step > 1 && marginType === 'freight' ? selectedBorderStyle : {}}
                >
                  <p className="flex-none">
                    {t('admin:freight')}
                  </p>
                </GreyBox>
              </div>
              <div className="flex-25 layout-row layout-align-end-center">
                <GreyBox
                  contentClassName={`flex-100 layout-row layout-align-center-center layout-wrap pointy ${styles.box_button}`}
                  wrapperClassName="flex-90"
                  onClick={() => this.setMarginType('local_charges')}
                  style={step > 1 && marginType === 'local_charges' ? selectedBorderStyle : {}}
                >
                  <p className="flex-none">
                    {t('admin:localCharges')}
                  </p>
                </GreyBox>
              </div>
            </GreyBox>
            { marginType === 'freight' ? (
              <GreyBox
                contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 1 ? styles.option_fade : ''}`}
                wrapperClassName={`flex-100 ${styles.option_row}`}
              >
                { step < 1 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                <div className="flex-33">
                  <p>{t('admin:attachToHubOrItinerary')}</p>
                </div>
                <div className="flex-33 layout-row layout-align-end-center">
                  <GreyBox
                    contentClassName={`flex-100 layout-row layout-align-center-center 
                    layout-wrap pointy ${styles.box_button}`}
                    wrapperClassName="flex-90"
                    onClick={() => this.setAttachment('hub')}
                    style={step > 1 && attachedTo === 'hub' ? selectedBorderStyle : {}}
                  >
                    <p className="flex-none">
                      {t('admin:hub')}
                    </p>
                  </GreyBox>
                </div>
                <div className="flex-33 layout-row layout-align-end-center">
                  <GreyBox
                    contentClassName={`flex-100 layout-row layout-align-center-center 
                    layout-wrap pointy ${styles.box_button}`}
                    wrapperClassName="flex-90"
                    onClick={() => this.setAttachment('itinerary')}
                    style={step > 1 && attachedTo === 'itinerary' ? selectedBorderStyle : {}}
                  >
                    <p className="flex-none">
                      {t('admin:itinerary')}
                    </p>
                  </GreyBox>
                </div>
              </GreyBox>
            ) : '' }
            {
              attachedTo === 'itinerary'
                ? (
                  <GreyBox
                    contentClassName={`flex-100 layout-row layout-align-space-between-center 
                  layout-wrap ${styles.option_row_wrapper} ${step < 2 ? styles.option_fade : ''}`}
                    wrapperClassName={`flex-100 ${styles.option_row}`}
                  >
                    { step < 2 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                    <div className="flex-33">
                      <p>{t('admin:chooseItinerary')}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-end-center">
                      <NamedAsync
                        classes="flex"
                        value={selectedItineraries}
                        cacheOptions
                        multi
                        autoload={false}
                        loadOptions={getItineraryOptions}
                        onChange={(n, e) => this.selectItinerary(n, e)}
                      />
                    </div>
                  </GreyBox>
                )
                : (
                  <GreyBox
                    contentClassName={`flex-100 layout-row layout-align-space-between-center 
                  layout-wrap ${styles.option_row_wrapper} ${step < 2 ? styles.option_fade : ''}`}
                    wrapperClassName={`flex-100 ${styles.option_row}`}
                  >
                    { step < 2 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                    <div className="flex">
                      <p>{t('admin:chooseHub')}</p>
                    </div>
                    <div className="flex layout-row layout-align-end-center">
                      <StandardSelect
                        className="flex"
                        value={selectedHubDirection}
                        multi
                        options={hubDirectionOptions}
                        onChange={e => this.selectHubDirection(e)}
                      />
                    </div>
                    <div className="flex layout-row layout-align-end-center">
                      <NamedAsync
                        classes="flex"
                        value={selectedHubs}
                        placeholder={t('admin:hub')}
                        cacheOptions
                        multi
                        autoload={false}
                        loadOptions={getHubOptions}
                        onChange={(n, e) => this.selectHub(n, e)}
                      />
                    </div>
                    { marginType === 'local_charges' && selectedHubs.length < 2 ? (
                      <div className="flex layout-row layout-align-end-center">
                        <NamedAsync
                          classes="flex"
                          value={counterpartHub}
                          placeholder={t('admin:counterpartHub')}
                          cacheOptions
                          autoload={false}
                          loadOptions={getHubOptions}
                          onChange={(n, e) => this.selectCounterpartHub(n, e)}
                        />
                      </div>
                    ) : ''}
                  </GreyBox>
                )
            }
            {
              attachedToPricing
                ? (
                  <GreyBox
                    contentClassName={`flex-100 layout-row layout-align-space-between-center 
                    layout-wrap ${styles.option_row_wrapper} ${step < 3 ? styles.option_fade : ''}`}
                    wrapperClassName={`flex-100 ${styles.option_row}`}
                  >
                    { step < 3 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                    <div className="flex-33">
                      <p>{t('admin:choosePricing')}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-end-center">
                      <NamedSelect
                        className="flex-100"
                        style={{ width: '100%' }}
                        options={pricingOptions}
                        value={selectedPricing}
                        onChange={e => this.handleSelect('selectedPricing', e)}
                        theme={theme}
                      />
                    </div>
                  </GreyBox>
                ) : [
                  (<GreyBox
                    contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 3 ? styles.option_fade : ''}`}
                    wrapperClassName={`flex-100 ${styles.option_row}`}
                  >
                    { step < 3 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                    <div className="flex-33">
                      <p>{t('admin:chooseCargoClass')}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-end-center">
                      <StandardSelect
                        className="flex-100"
                        style={{ width: '100%' }}
                        options={filteredCargoClassOptions}
                        value={selectedCargoClasses}
                        multi
                        noName
                        onChange={e => this.handleSelect('selectedCargoClasses', e)}
                        theme={theme}
                      />
                    </div>
                  </GreyBox>),
                  marginType !== 'trucking' ? (
                    <GreyBox
                      contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 4 ? styles.option_fade : ''}`}
                      wrapperClassName={`flex-100 ${styles.option_row}`}
                    >
                      { step < 4 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                      <div className="flex-33">
                        <p>{t('admin:chooseServiceLevel')}</p>
                      </div>
                      <div className="flex-33 layout-row layout-align-end-center">
                        <StandardSelect
                          className="flex-100"
                          options={serviceLevelOptions}
                          onChange={e => this.handleSelect('selectedServiceLevels', e)}
                          value={selectedServiceLevels}
                          multi
                          noName
                          theme={theme}
                        />
                      </div>
                    </GreyBox>
                  ) : '',
                  (<GreyBox
                    contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 5 ? styles.option_fade : ''}`}
                    wrapperClassName={`flex-100 ${styles.option_row}`}
                  >
                    { step < 5 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                    <div className="flex-33">
                      <p>{t('admin:chooseEffectiveDates')}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-end-center">
                      <DayPickerInput
                        name="dayPicker"
                        format="LL"
                        formatDate={formatDate}
                        parseDate={parseDate}
                        placeholder={`${formatDate(new Date())}`}
                        value={moment(selectedDates.effective_date).format('DD/MM/YYYY')}
                        onDayChange={e => this.handleDayChange(e, 'effective_date')}
                        dayPickerProps={AdminClientMarginCreator.dayPickerProps(false)}
                      />
                    </div>
                    <div className="flex-33 layout-row layout-align-end-center">
                      <DayPickerInput
                        name="dayPicker"
                        format="LL"
                        formatDate={formatDate}
                        parseDate={parseDate}
                        placeholder={`${formatDate(new Date())}`}
                        value={moment(selectedDates.effective_date).format('DD/MM/YYYY')}
                        onDayChange={e => this.handleDayChange(e, 'expiration_date')}
                        dayPickerProps={AdminClientMarginCreator.dayPickerProps(true)}
                      />
                    </div>
                  </GreyBox>)
                ]
            }
            { !allItineraries && (selectedCargoClasses.length > 0) && (selectedServiceLevels.length > 0 || marginType === 'trucking')
              ? (
                <GreyBox
                  contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 6 ? styles.option_fade : ''}`}
                  wrapperClassName={`flex-100 ${styles.option_row}`}
                >
                  { step < 6 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                  <div className="flex-33">
                    <p>{t('admin:createIndividualFeeMargins')}</p>
                  </div>
                  <div className="flex-33 layout-row layout-align-end-center">
                    <GreyBox
                      contentClassName={`flex-100 layout-row layout-align-center-center 
                      layout-wrap pointy ${styles.box_button}`}
                      wrapperClassName="flex-90"
                      onClick={() => this.handleFineMarginDetails(false)}
                      style={step > 3 && !fineMarginDetail ? selectedBorderStyle : {}}
                    >
                      <p className="flex-none">
                        {t('common:no')}
                      </p>
                    </GreyBox>
                  </div>
                  <div className="flex-33 layout-row layout-align-end-center">
                    <GreyBox
                      contentClassName={`flex-100 layout-row layout-align-center-center 
                      layout-wrap pointy ${styles.box_button}`}
                      wrapperClassName="flex-90"
                      onClick={() => this.handleFineMarginDetails(true)}
                      style={step > 3 && fineMarginDetail ? selectedBorderStyle : {}}
                    >
                      <p className="flex-none">
                        {t('common:yes')}
                      </p>
                    </GreyBox>
                  </div>
                </GreyBox>
              ) : '' }

            { fineMarginDetail
              ? (
                <GreyBox
                  contentClassName={`flex-100 layout-row layout-align-space-between-center 
                  layout-wrap ${styles.option_row_wrapper}`}
                  wrapperClassName={`flex-100 ${styles.option_row}`}
                >
                  {fineFeeFields}
                </GreyBox>
              ) : [
                (<GreyBox
                  contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 6 ? styles.option_fade : ''}`}
                  wrapperClassName={`flex-100 ${styles.option_row}`}
                >
                  { step < 6 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                  <div className="flex-33">
                    <p>{t('admin:chooseMarginType')}</p>
                  </div>
                  <div className="flex-33 layout-row layout-align-end-center">
                    <NamedSelect
                      className="flex-100"
                      options={operandOptions}
                      onChange={e => this.handleSelect('operand', e)}
                      value={operand}
                      theme={theme}
                    />
                  </div>
                </GreyBox>),
                (<GreyBox
                  contentClassName={`flex-100 layout-row layout-align-space-between-center 
                layout-wrap ${styles.option_row_wrapper} ${step < 6 ? styles.option_fade : ''}`}
                  wrapperClassName={`flex-100 ${styles.option_row}`}
                >
                  { step < 6 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
                  <div className="flex-33">
                    <p>{t('admin:chooseMarginAmount')}</p>
                  </div>
                  <div className="flex-33 layout-row layout-align-end-center input_box_full">
                    <input type="number" step="0.01" value={marginValue} onChange={this.handleMarginValueChange} />
                  </div>
                </GreyBox>)
              ]}
          </div>
          <GreyBox
            contentClassName={`flex-100 layout-row layout-align-space-between-center 
              layout-wrap ${styles.option_row_wrapper} ${step < 6 ? styles.option_fade : ''}`}
            wrapperClassName={`flex-100 ${styles.option_row}`}
          >
            { step < 6 ? <div className={`flex-none ${styles.blocked_off}`} /> : '' }
            <div className="flex-33 layout-row layout-align-start-center">
              <p>{t('admin:saveMargin')}</p>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                handleNext={() => this.saveMargin()}
                text={t('common:save')}
                theme={theme}
                size="full"
                active
              />
            </div>
          </GreyBox>
        </div>
      </div>
    )
  }
}

AdminClientMarginCreator.defaultProps = {
  marginFormData: {}
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { marginFormData, group } = clients
  const { tenant } = app
  const { theme } = tenant

  return {
    marginFormData,
    theme,
    group
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientMarginCreator))
