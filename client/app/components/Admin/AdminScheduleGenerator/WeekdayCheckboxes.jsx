import React from 'react'
import moment from 'moment'
import Checkbox from '../../Checkbox/Checkbox'
import PropTypes from '../../../prop-types'

const WeekdayCheckbox = ({
  theme, toggleWeekdays, weekdays, weekday
}) => (
  <div className="flex layout-row layout-align-start-center">
    <Checkbox
      id={`weekdays-${weekday}`}
      theme={theme}
      onChange={() => toggleWeekdays(weekday)}
      name={weekday}
      checked={weekdays[weekday]}
    />
    <label htmlFor={`weekdays-${weekday}`} className="offset-5 pointy">
      <p>{moment.weekdaysShort()[weekday]}</p>
    </label>
  </div>
)

const WeekdayCheckboxes = props => (
  Array(7).fill().map((_, i) => <WeekdayCheckbox {...props} weekday={i + 1} />)
)

WeekdayCheckbox.propTypes = {
  theme: PropTypes.theme.isRequired,
  toggleWeekdays: PropTypes.func.isRequired,
  weekdays: PropTypes.arrayOf(PropTypes.number).isRequired,
  weekday: PropTypes.number.isRequired
}

export default WeekdayCheckboxes
