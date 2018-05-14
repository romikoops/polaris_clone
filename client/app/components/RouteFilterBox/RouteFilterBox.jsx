import React, { Component } from 'react'
// import styled from 'styled-components'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import PropTypes from '../../prop-types'
import '../../styles/day-picker-custom.css'
import { moment } from '../../constants'
import { switchIcon, capitalize } from '../../helpers'
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
        ocean: true
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
      theme, pickup, shipment, availableMotKeys
    } = this.props
    // const StyledRange = styled.div`
    //   input[type='range']::-webkit-slider-runnable-track {
    //     width: 100%;
    //     height: 12px;
    //     cursor: pointer;
    //     background: -webkit-linear-gradient(
    //       left,
    //       ${theme.colors.primary},
    //       ${theme.colors.secondary}
    //     ) !important;
    //     border-radius: 1.3px;
    //     opacity: 0.9;
    //   }
    // `
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
    const motCheckBoxes = Object.keys(availableMotKeys).map(mKey => (
      <div className="radio layout-row layout-align-none-center" style={{ margin: '2px 0' }}>
        <Checkbox
          onChange={e => this.handleOptionChange(e, mKey)}
          checked={this.state.selectedOption[mKey]}
          theme={theme}
        />
        <label className="flex-none">
          {switchIcon(mKey)}
          {capitalize(mKey)}
        </label>
      </div>
    ))

    return (
      <div className={styles.filterbox}>
        <div className={styles.pickup_date}>
          <div>
            <TextHeading theme={theme} size={4} text={pickup ? 'Pickup Date' : 'Closing Date'} />
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
        <div className={styles.haulage}>
          <div>
            <TextHeading theme={theme} size={4} text="Haulage" />
          </div>
          <div className={`${styles.haulage_option} layout-row layout-wrap flex-none`}>
            <div className="flex-100 layout-row layout-align-space-between-center">
              <p className="flex-none five_m">Pre Carriage</p>
              <p className="flex-none five_m">{shipment.has_pre_carriage ? 'Yes' : 'No'}</p>
            </div>
          </div>
          <div className={`${styles.haulage_option} layout-row layout-wrap flex-none`}>
            <div className="flex-100 layout-row layout-align-space-between-center">
              <p className="flex-none five_m">On Carriage</p>
              <p className="flex-none five_m">{shipment.has_on_carriage ? 'Yes' : 'No'}</p>
            </div>
          </div>
        </div>
        <div className={styles.mode_of_transport}>
          <div>
            <TextHeading theme={theme} size={4} text="Mode of transport" />
          </div>
          {motCheckBoxes}
        </div>
        <div>
          <p style={{ fontSize: '12px', marginTop: '0' }}>* Transit time (T/T) not guaranteed</p>
        </div>
        {/* <StyledRange className={styles.transit_time}>
          <TextHeading theme={theme} size={4} text="Estimated Transit Time" />
          <
          <input type="range" value={this.props.durationFilter} onChange={this.setFilterDuration} />
          <div className={styles.transit_time_labels}>
            <p>20 days</p>
            <p>100 days</p>
          </div>
        </StyledRange> */}
      </div>
    )
  }
}
RouteFilterBox.propTypes = {
  departureDate: PropTypes.number,
  theme: PropTypes.theme,
  setDurationFilter: PropTypes.func.isRequired,
  setMoT: PropTypes.func.isRequired,
  setDepartureDate: PropTypes.func.isRequired,
  // durationFilter: PropTypes.number.isRequired,
  pickup: PropTypes.bool,
  shipment: PropTypes.objectOf(PropTypes.any),
  availableMotKeys: PropTypes.objectOf(PropTypes.bool)
}

RouteFilterBox.defaultProps = {
  departureDate: 0,
  theme: 0,
  pickup: false,
  shipment: {},
  availableMotKeys: {}
}

export default RouteFilterBox
