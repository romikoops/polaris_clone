import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { moment } from '../../constants';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styled from 'styled-components';
import { Checkbox } from '../Checkbox/Checkbox';
export class AdminScheduleGenerator extends Component {
    constructor(props) {
        super(props);
        this.state = {
            startDate: moment().add(10, 'd').format('DD/MM/YYYY'),
            endDate: moment().add(375, 'd').format('DD/MM/YYYY'),
            weekdays: {
                '1': false,
                '2': false,
                '3': true,
                '4': false,
                '5': false,
                '6': false,
                '7': false
            },
            duration: 30
        };
        this.selectHub = this.selectHub.bind(this);
        this.deselectHub = this.deselectHub.bind(this);
    }
    toggleWeekdays(ev) {
        console.log(ev);
    }
    render() {
        const {theme, routes } = this.props;
        const {weekdays, startDate, endDate, duration} = this.state;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const future = {
            after: new Date(),
        };
        const filterMoTOptions = [
            {value: 'rail', label: 'Rail'},
            {value: 'air', label: 'Air'},
            {value: 'ocean', label: 'Ocean'}
        ];
        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        const routeOptions = routes.map((rt) => {
            return {value: rt.id, label: rt.name};
        });
        return(
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                        <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Auto Generate</p>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className="flex-25 layout-row layout-wrap layout-align-center-start">
                            <DayPickerInput
                                name="startdate"
                                placeholder="DD/MM/YYYY"
                                format="DD/MM/YYYY"
                                value={startDate}
                                className={styles.dpb_picker}
                                onDayChange={this.handleDayChange}
                                modifiers={future}
                            />
                            <DayPickerInput
                                name="enddate"
                                placeholder="DD/MM/YYYY"
                                format="DD/MM/YYYY"
                                value={endDate}
                                className={styles.dpb_picker}
                                onDayChange={this.handleDayChange}
                                modifiers={future}
                            />
                        </div>
                        <div className="flex-25 layout-row layout-align-start-center">
                            <StyledSelect
                                name="routes"
                                className={`${styles.select}`}
                                value={this.state.routeForSched}
                                options={routeOptions}
                                onChange={this.setRoute}
                            />
                        </div>
                        <div className="flex-25 layout-row layout-align-start-center">
                            <StyledSelect
                                name="mot-filter"
                                className={`${styles.select}`}
                                value={this.state.genMoT}
                                options={filterMoTOptions}
                                onChange={this.setMoT}
                            />
                        </div>
                        <div className="flex-25 layout-row layout-align-start-center">
                            <input type="number" value={duration} onChange={this.setDuration}/>
                        </div>
                        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="1" checked={weekdays['1']} />
                                <p className="flex-none">Monday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="2" checked={weekdays['2']} />
                                <p className="flex-none">Tuesday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="3" checked={weekdays['3']} />
                                <p className="flex-none">Wednesday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="4" checked={weekdays['4']} />
                                <p className="flex-none">Thursday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="5" checked={weekdays['5']} />
                                <p className="flex-none">Friday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="6" checked={weekdays['6']} />
                                <p className="flex-none">Saturday</p>
                            </div>
                            <div className="flex-25 layout-row layout-align-start-center">
                                <Checkbox onChange={this.toggleWeekdays} name="7" checked={weekdays['7']} />
                                <p className="flex-none">Sunday</p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        );
    }
}
AdminScheduleGenerator.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    routes: PropTypes.array
};
