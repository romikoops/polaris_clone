import React, {Component} from 'react';
import PropTypes from 'prop-types';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';

export class RouteFilterBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
          selectedDay: new Date()
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
        return (
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-100 layout-row layout-wrap">
            <div className="layout-row flex-none layout-wrap" >
                <p className="flex-100"> {'Approximate Pickup Date:'} </p>
                <DayPickerInput name="birthday"
                  placeholder="DD/MM/YYYY"
                  format="DD/MM/YYYY"
                  value={this.state.selectedDay}
                  onDayChange={this.editFilterDay} />
            </div>
            <div className="flex-100 layout-row layout-wrap">
              <div className="flex-100 layout-row radio">
                <label >
                  <input type="radio" value="air" checked={this.state.selectedOption === 'air'} onChange={this.handleOptionChange}/>
                  <i className="fa fa-plane"/>
                  Air
                </label>
              </div>
              <div className="flex-100 layout-row radio">
                <label >
                  <input type="radio" value="ocean" checked={this.state.selectedOption === 'ocean'} onChange={this.handleOptionChange}/>
                  <i className="fa fa-ship"/>
                  Ocean
                </label>
              </div>
            </div>
          </div>
        </div>
        );
    }
}
RouteFilterBox.PropTypes = {
    theme: PropTypes.object,
    handleDayChange: PropTypes.func
};
