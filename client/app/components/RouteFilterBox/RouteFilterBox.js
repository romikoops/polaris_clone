import React, { Component } from 'react';
import PropTypes from 'prop-types';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import '../../styles/day-picker-custom.css';
import { moment } from '../../constants';
import { RoundButton } from '../RoundButton/RoundButton';
import styles from './RouteFilterBox.scss';
import styled from 'styled-components';

export class RouteFilterBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedDay: props.departureDate ? moment(props.departureDate).format('DD/MM/YYYY') : moment().format('DD/MM/YYYY'),
            selectedOption: this.props.moT
        };
        this.editFilterDay = this.editFilterDay.bind(this);
        this.handleOptionChange = this.handleOptionChange.bind(this);
        this.setFilterDuration = this.setFilterDuration.bind(this);
    }
    editFilterDay(event) {
        this.props.setDepartureDate(event.day);
    }
    handleOptionChange(changeEvent) {
        this.setState({
            selectedOption: changeEvent.target.value
        });
        this.props.setMoT(changeEvent.target.value);
    }
    setFilterDuration(event) {
        const dur = event.target.value;
        this.props.setDurationFilter(dur);
    }
    render() {
        const { theme, pickup } = this.props;
        const dayPickerProps = {
            disabledDays: {before: new Date(moment().add(7, 'days').format())}
        };
        const StyledRange = styled.div`
            input[type=range]::-webkit-slider-runnable-track {
              width: 100%;
              height: 12px;
              cursor: pointer;
                background: -webkit-linear-gradient(left, ${theme.colors.primary}, ${theme.colors.secondary}) !important;
              border-radius: 1.3px;
              opacity: 0.9;
            }
        `;
        return (
            <div className={styles.filterbox}>
                <div className={styles.pickup_date}>
                    <p> { pickup ? 'Pickup Date' : 'Closing Date' } </p>
                    <div className={'flex-none layout-row ' + styles.dpb}>
                        <div className={'flex-none layout-row layout-align-center-center ' + styles.dpb_icon}>
                            <i className="flex-none fa fa-calendar"></i>
                        </div>
                        <DayPickerInput
                            placeholder="DD/MM/YYYY"
                            format="DD/MM/YYYY"
                            className={styles.dpb_picker}
                            value={this.state.selectedDay}
                            onDayChange={this.editFilterDay}
                            dayPickerProps={dayPickerProps}
                        />
                    </div>
                </div>
                <div className={styles.mode_of_transport}>
                    <p>Mode of transport</p>
                    <div className="radio">
                        <label>
                            <input
                                type="radio"
                                value="air"
                                checked={
                                    this.state.selectedOption === 'air'
                                }
                                onChange={this.handleOptionChange}
                            />
                            <i className="fa fa-plane" />
                            Air
                        </label>
                    </div>
                    <div className="radio">
                        <label>
                            <input
                                type="radio"
                                value="ocean"
                                checked={
                                    this.state.selectedOption === 'ocean'
                                }
                                onChange={this.handleOptionChange}
                            />
                            <i className="fa fa-ship" />
                            Ocean
                        </label>
                    </div>
                </div>
                <StyledRange className={styles.transit_time}>
                    <p>Transit time</p>
                    <input
                        type="range"
                        value={this.props.durationFilter}
                        onChange={this.setFilterDuration}
                    />
                    <div className={styles.transit_time_labels}>
                        <p>20 days</p>
                        <p>100 days</p>
                    </div>
                </StyledRange>
                <RoundButton
                    size="full"
                    text="save filter"
                    theme={theme}
                    active
                />
            </div>
        );
    }
}
RouteFilterBox.propTypes = {
    theme: PropTypes.object,
    setDurationFilter: PropTypes.func,
    setMoT: PropTypes.func,
    setDepartureDate: PropTypes.func,
    durationFilter: PropTypes.number,
    moT: PropTypes.string
};
