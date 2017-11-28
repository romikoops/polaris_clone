import React, {Component} from 'react';
import PropTypes from 'prop-types';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import { moment } from '../../constants';
import { RoundButton } from '../RoundButton/RoundButton';
import styles from './RouteFilterBox.scss';
export class RouteFilterBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
          selectedDay: moment().format()
        };
        this.editFilterDay = this.editFilterDay.bind(this);
        this.handleOptionChange = this.handleOptionChange.bind(this);
    }
    editFilterDay(event) {
        this.props.handleDayChange(event.day);
    }
    handleOptionChange(changeEvent) {
        this.setState({
            selectedOption: changeEvent.target.value
        });
    }
    render() {
        const { theme } = this.props;
        return (
          <div className={`${styles.filterbox} flex-100 layout-row layout-wrap`}>
            <div className={styles.pickup_date}>
              <div className="">
                  <p> Pickup date </p>
                  <DayPickerInput
                    placeholder="DD/MM/YYYY"
                    format="DD/MM/YYYY"
                    value={this.state.selectedDay}
                    onDayChange={this.editFilterDay}
                  />
              </div>
              <div className={styles.mode_of_transport}>
                <p>Mode of transport</p>
                <div className="radio">
                  <label >
                    <input type="radio" value="air" checked={this.state.selectedOption === 'air'} onChange={this.handleOptionChange}/>
                    <i className="fa fa-plane"/>
                    Air
                  </label>
                </div>
                <div className="radio">
                  <label >
                    <input type="radio" value="ocean" checked={this.state.selectedOption === 'ocean'} onChange={this.handleOptionChange}/>
                    <i className="fa fa-ship"/>
                    Ocean
                  </label>
                </div>
              </div>
              <div className={styles.transit_time}>
                <p>Transit time</p>
                <input type="range"/>
                <div className={styles.transit_time_labels}>
                  <p>20 days</p>
                  <p>100 days</p>
                </div>
              </div>
              <RoundButton size="small" text="save filter" theme={theme} active/>
            </div>
          </div>
        );
    }
}
RouteFilterBox.PropTypes = {
    theme: PropTypes.object,
    handleDayChange: PropTypes.func
};
