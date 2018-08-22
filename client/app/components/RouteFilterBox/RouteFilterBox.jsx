import React, { Component } from 'react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import PropTypes from '../../prop-types'
import '../../styles/day-picker-custom.css'
import { moment, LOAD_TYPES } from '../../constants'
import { switchIcon, capitalize, gradientTextGenerator } from '../../helpers'
import styles from './RouteFilterBox.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { Checkbox } from '../Checkbox/Checkbox'

export class RouteFilterBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectedDay: props.departureDate
        ? moment(props.departureDate).format('DD/MM/YYYY')
        : moment().format('DD/MM/YYYY'),
      selectedOption: {
        air: true,
        ocean: true,
        truck: true,
        rail: true
      }
    }
    this.editFilterDay = this.editFilterDay.bind(this)
    this.handleOptionChange = this.handleOptionChange.bind(this)
    this.setFilterDuration = this.setFilterDuration.bind(this)
  }
  setFilterDuration (event) {
    const dur = event.target.value
    this.props.setDurationFilter(dur)
  }
  editFilterDay (day) {
    this.props.setDepartureDate(day)
  }
  handleOptionChange (changeEvent, target) {
    this.setState({
      selectedOption: {
        ...this.state.selectedOption,
        [target]: changeEvent
      }
    })
    this.props.setMoT(changeEvent, target)
  }
  render () {
    const {
      theme, pickup, shipment, availableMotKeys, cargos
    } = this.props
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
    const motCheckBoxKeys = Object.keys(availableMotKeys)
    const motCheckBoxes = motCheckBoxKeys.map(mKey => (
      <div className="radio layout-row layout-align-none-center" style={{ margin: '2px 0' }}>
        <Checkbox
          onChange={e => this.handleOptionChange(e, mKey)}
          checked={this.state.selectedOption[mKey]}
          theme={theme}
          disabled={motCheckBoxKeys.length === 1}
        />
        <label className="flex-none">
          {switchIcon(mKey)}
          {capitalize(mKey)}
        </label>
      </div>
    ))
    const imgLCL = { backgroundImage: `url(${LOAD_TYPES[0].img})` }
    const imgFCL = { backgroundImage: `url(${LOAD_TYPES[1].img})` }
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    return (
      <div className={styles.filterbox}>
        <div className={styles.shipment_summary}>
          <div>
            <TextHeading theme={theme} size={4} text="Shipment Summary" />
          </div>
          <div className={`flex-100 layou-wrap ${styles.dpb}`}>
            <div className="layout-row flex-100">
              <i className={shipment.has_pre_carriage ? 'fa fa-check clip' : 'fa fa-times'} style={shipment.has_pre_carriage ? textStyle : { color: '#E0E0E0' }} />
              <span>Pre-carriage</span>
            </div>
            <div className="layout-row flex-100">
              <i className={shipment.has_on_carriage ? 'fa fa-check clip' : 'fa fa-times'} style={shipment.has_on_carriage ? textStyle : { color: '#E0E0E0' }} />
              <span>On-carriage</span>
            </div>
          </div>
        </div>
        <div className={styles.pickup_date}>
          <div>
            <TextHeading theme={theme} size={4} text={pickup ? 'Pick-up Date' : 'Closing Date'} />
          </div>
          <div className={`flex-none layout-row ${styles.dpb}`}>
            <div className={`flex-none layout-row layout-align-center-center ${styles.dpb_icon}`}>
              <i className="flex-none fa fa-calendar" />
            </div>
            <DayPickerInput
              placeholder="DD/MM/YYYY"
              formatDate={formatDate}
              parseDate={parseDate}
              format="DD/MM/YYYY"
              className={styles.dpb_picker}
              value={this.state.selectedDay}
              onDayChange={this.editFilterDay}
              dayPickerProps={dayPickerProps}
            />
          </div>
        </div>
        <div className={styles.mode_of_transport}>
          <div>
            <TextHeading theme={theme} size={4} text="Mode of transport" />
          </div>
          {motCheckBoxes}
        </div>
        <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.cargos_recap}`}>
          {cargos.map(cargo => (
            <div className="flex-100 layout-row layout-align-start-center">
              <div>x{cargo.quantity}</div>
              <div className={styles.cargo_img} style={shipment.load_type === 'cargo_item' ? imgLCL : imgFCL} />
            </div>
          ))}
        </div>
        <div>
          <p style={{ fontSize: '10px', marginTop: '0' }}>* Transit time (T/T) not guaranteed</p>
          <p style={{ fontSize: '10px', marginTop: '0' }}>** You will be invoiced in local currency based on the exchange rate valid at the time</p>

        </div>
      </div>
    )
  }
}
RouteFilterBox.propTypes = {
  departureDate: PropTypes.number,
  theme: PropTypes.theme,
  cargos: PropTypes.arrayOf(PropTypes.any),
  setDurationFilter: PropTypes.func.isRequired,
  setMoT: PropTypes.func.isRequired,
  setDepartureDate: PropTypes.func.isRequired,
  pickup: PropTypes.bool,
  shipment: PropTypes.objectOf(PropTypes.any),
  availableMotKeys: PropTypes.objectOf(PropTypes.bool)
}

RouteFilterBox.defaultProps = {
  departureDate: 0,
  theme: 0,
  pickup: false,
  cargos: [],
  shipment: {},
  availableMotKeys: {}
}

export default RouteFilterBox
