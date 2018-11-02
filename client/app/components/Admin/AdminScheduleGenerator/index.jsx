import React, { Component } from 'react'
import { connect } from 'react-redux'
import Select from 'react-select'
import { bindActionCreators } from 'redux'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import styled from 'styled-components'
import 'react-day-picker/lib/style.css'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../../prop-types'
import '../../../styles/select-css-custom.scss'
import { moment, getApiHost, adminSchedules as schedTip } from '../../../constants'
import { adminActions } from '../../../actions'
import { RoundButton } from '../../RoundButton/RoundButton'
import { authHeader, capitalize } from '../../../helpers'
import styles from '../Admin.scss'
import WeekdayCheckboxes from './WeekdayCheckboxes'

class AdminScheduleGenerator extends Component {
  static camelToCaps (string) {
    return string
      .split('_')
      .map(x => capitalize(x))
      .join(' ')
  }
  constructor (props) {
    super(props)
    this.state = {
      startDate: moment()
        .add(10, 'd')
        .format('DD/MM/YYYY'),
      endDate: moment()
        .add(375, 'd')
        .format('DD/MM/YYYY'),
      weekdays: {
        1: false,
        2: false,
        3: true,
        4: false,
        5: false,
        6: false,
        7: false
      },
      stopIntervals: []
    }
    this.handleDayChange = this.handleDayChange.bind(this)
    this.setItinerary = this.setItinerary.bind(this)
    this.setMoT = this.setMoT.bind(this)
    this.setVehicleType = this.setVehicleType.bind(this)
    this.handleDuration = this.handleDuration.bind(this)
    this.genSchedules = this.genSchedules.bind(this)
    this.getStopsForItinerary = this.getStopsForItinerary.bind(this)
    this.toggleWeekdays = this.toggleWeekdays.bind(this)
  }
  componentWillMount () {
    if (this.props.itinerary.id) {
      const { itinerary } = this.props
      this.setItinerary({
        value: itinerary.id,
        label: `${itinerary.name} (${itinerary.mode_of_transport})`,
        mot: itinerary.mode_of_transport
      })
    }
  }
  componentDidMount () {
    const { hubs, adminDispatch, itinerary } = this.props
    adminDispatch.getVehicleTypes(itinerary.id)
    if (!hubs) {
      adminDispatch.getHubs(false)
    }
  }

  setItinerary (ev) {
    const { adminDispatch } = this.props
    this.getStopsForItinerary(ev.value)
    adminDispatch.getVehicleTypes(ev.value)
    this.setState({ itinerary: ev, mot: ev.mot })
  }

  setMoT (ev) {
    this.setState({ mot: ev })
  }
  setVehicleType (ev) {
    this.setState({ vehicleType: ev })
  }
  getStopsForItinerary (itineraryId) {
    window
      .fetch(`${getApiHost()}/admin/itineraries/${itineraryId}/stops`, {
        method: 'GET',
        headers: authHeader()
      })
      .then((promise) => {
        promise.json().then((response) => {
          const stops = response.data
          this.setState({ stops })
        })
      })
  }
  toggleWeekdays (ord) {
    this.setState(prevState => ({
      weekdays: { ...prevState.weekdays, [ord]: !prevState.weekdays[ord] }
    }))
  }
  handleIntervalChange (ev) {
    const { name, value } = ev.target
    const stops = this.state.stopIntervals
    stops[name] = value
    this.setState({ stopIntervals: stops })
  }
  handleDayChange (ev) {
    this.setState({ startDate: moment(ev).format('DD/MM/YYYY') })
  }
  handleDuration (ev) {
    const { name, value } = ev.target
    this.setState({ [name]: value })
  }
  genSchedules () {
    const { adminDispatch } = this.props
    const {
      itinerary,
      startDate,
      endDate,
      weekdays,
      stopIntervals,
      vehicleType,
      closingDateBuffer
    } = this.state
    const ordinalArray = []
    Object.keys(weekdays).forEach((key) => {
      if (weekdays[key]) {
        ordinalArray.push(parseInt(key, 10))
      }
    })
    const req = {
      itinerary: itinerary.value,
      steps: stopIntervals,
      startDate,
      endDate,
      weekdays: ordinalArray,
      vehicleTypeId: vehicleType.value,
      closing_date: closingDateBuffer
    }

    adminDispatch.autoGenSchedules(req)
  }
  handleClosingDateChange (e) {
    const { value } = e.target
    this.setState({ closingDateBuffer: value })
  }
  render () {
    const {
      theme,
      vehicleTypes,
      itineraries
    } = this.props
    const {
      weekdays,
      startDate,
      endDate,
      mot,
      vehicleType,
      stops,
      stopIntervals,
      closingDateBuffer
    } = this.state

    const future = {
      after: new Date()
    }
    const vehicleTypeOptions = []
    if (vehicleTypes && mot) {
      vehicleTypes.forEach((vt) => {
        const nameWithCarrier = vt.carrier
          ? `${vt.carrier.name} - ${vt.name}`
          : vt.name
        if (vt.mode_of_transport === mot) {
          vehicleTypeOptions.push({
            value: vt.id,
            label: AdminScheduleGenerator.camelToCaps(nameWithCarrier)
          })
        }
        if (vt.is_default && !vehicleType && vt.mode_of_transport === mot) {
          this.setState({
            vehicleType: {
              value: vt.id,
              label: AdminScheduleGenerator.camelToCaps(nameWithCarrier)
            }
          })
        }
      })
    }
    const itineraryList = []
    if (itineraries) {
      itineraries.forEach((itin) => {
        itineraryList.push({
          value: itin.id,
          label: `${itin.name} (${itin.mode_of_transport})`,
          mot: itin.mode_of_transport
        })
      })
    }
    const StyledSelect = styled(Select)`
      .Select-control {
        background-color: #f9f9f9;
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
      }
    `

    const vehicleSelect = mot ? (
      <StyledSelect
        name="mot-type"
        className={`${styles.select} flex-100`}
        value={this.state.vehicleType}
        options={vehicleTypeOptions}
        onChange={this.setVehicleType}
      />
    ) : (
      ''
    )
    const stopIntervalInputs = stops && stops.length > 0 ? (

      stops.map((s, i) =>
        (stops[i + 1] ? (
          <div key={s.id} className="flex-none layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <p className="flex-none">{stops[i].hub.name}</p>
              <p className="flex-none">-></p>
              <p className="flex-none">{stops[i + 1].hub.name}</p>
            </div>
            <div className="flex-100 layout-row layout-align-start-center input_box_full">
              <input
                type="number"
                min="1"
                value={stopIntervals[i]}
                name={i}
                placeholder="Days"
                onChange={ev => this.handleIntervalChange(ev)}
              />
            </div>
          </div>
        ) : (
          ''
        )))
    ) : (
      <p className="flex-none">
        There are no stops available on this route. Please add some on the Routes page or upload a
        new Pricing for the route
      </p>
    )
    const actionButton =
      stops && stops.length > 0 ? (
        <RoundButton
          text="Generate"
          handleNext={this.genSchedules}
          iconClass="fa-plus-o"
          theme={theme}
          active
        />
      ) : (
        <RoundButton text="Generate" iconClass="fa-plus-o" theme={theme} disabled />
      )

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}>
              Auto Generate
              <i
                className="fa fa-info-circle"
                data-for="autoGenTooltip"
                data-tip={schedTip.auto_generate}
              />
              <ReactTooltip className={styles.tooltip} id="autoGenTooltip" effect="solid" />
            </p>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                text="Back"
                className="flex-none"
                handleNext={this.props.toggleNew}
                iconClass="fa-chevron-left"
                theme={theme}
                size="small"
                active
              />
            </div>

          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>Set Route</p>
            </div>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div className="flex-50 layout-row layout-align-start-center">
                <StyledSelect
                  name="startDate"
                  className={`${styles.select} flex-100`}
                  value={this.state.itinerary}
                  options={itineraryList}
                  onChange={this.setItinerary}
                />
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>Set Vehicle Type</p>
            </div>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div className="flex-50 layout-row layout-align-start-center">{vehicleSelect}</div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>Set Journey Times</p>
            </div>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              {stopIntervalInputs}
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>
                Set Effective Period and Duration
              </p>
            </div>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div
                className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                  styles.dpb_picker
                }`}
              >
                <DayPickerInput
                  name="startdate"
                  placeholder="Start Date"
                  datePickerProps={{ format: 'DD/MM/YYYY' }}
                  value={startDate}
                  onDayChange={this.handleDayChange}
                  modifiers={future}
                />
              </div>
              <div
                className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                  styles.dpb_picker
                }`}
              >
                <DayPickerInput
                  name="enddate"
                  placeholder="End Date"
                  datePickerProps={{ format: 'DD/MM/YYYY' }}
                  value={endDate}
                  onDayChange={this.handleDayChange}
                  modifiers={future}
                />
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>
                Set Closing Date <i>(days before departure)</i>
              </p>
            </div>
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className="flex-100 layout-row layout-align-start-center input_box">
                  <input
                    type="number"
                    min="1"
                    value={closingDateBuffer}
                    name="closingDatebuffer"
                    placeholder="Days"
                    onChange={ev => this.handleClosingDateChange(ev)}
                  />
                </div>
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div
              className={`flex-100 layout-row layout-align-space-between-center ${
                styles.sec_subheader
              }`}
            >
              <p className={` ${styles.sec_subheader_text} flex-none`}>Set Departure Days</p>
            </div>

            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <WeekdayCheckboxes theme={theme} toggleWeekdays={this.toggleWeekdays} weekdays={weekdays} />
              </div>
            </div>
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-end-center border_divider">
            <div
              className={`${
                styles.btn_sec
              } layout-row content_width  flex-none layout-wrap layout-align-start-start`}
            >
              {actionButton}
            </div>
          </div>
        </div>
      </div>
    )
  }
}
AdminScheduleGenerator.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getVehicleTypes: PropTypes.func,
    getHubs: PropTypes.func
  }).isRequired,
  itinerary: PropTypes.objectOf(PropTypes.any),
  toggleNew: PropTypes.func.isRequired,
  itineraries: PropTypes.arrayOf(PropTypes.any),
  vehicleTypes: PropTypes.arrayOf(PropTypes.vehicleType)
}

AdminScheduleGenerator.defaultProps = {
  theme: null,
  hubs: [],
  vehicleTypes: [],
  itineraries: [],
  itinerary: {}
}

function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}
function mapStateToProps (state) {
  const { admin } = state
  const { hubs, vehicleTypes } = admin

  return {
    hubs,
    vehicleTypes
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminScheduleGenerator)
