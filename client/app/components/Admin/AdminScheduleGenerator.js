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
import {RoundButton} from '../RoundButton/RoundButton';
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
    }
    toggleWeekdays(ev) {
        console.log(ev);
    }
    handleDayChange(ev) {
        console.log(ev);
    }
    setRoute(ev) {
        console.log(ev);
    }
    setMot(ev) {
        console.log(ev);
    }
    handleDuration(ev) {
        const {name, value} = ev.target;
        this.setState({[name]: value});
    }
    render() {
        const {theme, hubs } = this.props;
        const {weekdays, startDate, endDate, duration} = this.state;
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
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
        // const routeOptions = routes.map((rt) => {
        //     return {value: rt.id, label: rt.name};
        // });
        return(
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Auto Generate</p>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Route</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className="flex-33 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="starthub"
                                    className={`${styles.select}`}
                                    value={this.state.routeForSched}
                                    options={hubs}
                                    onChange={this.setHubs}
                                />
                            </div>
                            <div className="flex-33 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="endhub"
                                    className={`${styles.select}`}
                                    value={this.state.routeForSched}
                                    options={hubs}
                                    onChange={this.setHubs}
                                />
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Mode of Transport</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className="flex-33 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="mot"
                                    className={`${styles.select}`}
                                    value={this.state.mot}
                                    options={filterMoTOptions}
                                    onChange={this.setMoT}
                                />
                            </div>
                            <div className="flex-33 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="mot-type"
                                    className={`${styles.select}`}
                                    value={this.state.motType}
                                    options={filterMoTOptions}
                                    onChange={this.setMoT}
                                />
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Effective Period and Duration</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className="flex-33 layout-row layout-wrap layout-align-center-start">
                                <DayPickerInput
                                    name="startdate"
                                    placeholder="Start Date"
                                    format="DD/MM/YYYY"
                                    value={startDate}
                                    className={styles.dpb_picker}
                                    onDayChange={this.handleDayChange}
                                    modifiers={future}
                                />
                            </div>
                            <div className="flex-33 layout-row layout-wrap layout-align-center-start">
                                <DayPickerInput
                                    name="enddate"
                                    placeholder="End Date"
                                    format="DD/MM/YYYY"
                                    value={endDate}
                                    className={styles.dpb_picker}
                                    onDayChange={this.handleDayChange}
                                    modifiers={future}
                                />
                            </div>

                            <div className={`flex-33 layout-row layout-align-start-center ${styles.input_box}`}>
                                <input type="number" value={duration} onChange={this.setDuration}/>
                            </div>
                        </div>

                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Departure Days</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="1" checked={weekdays['1']} />
                                    <p className="flex-none">Mon</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="2" checked={weekdays['2']} />
                                    <p className="flex-none">Tue</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="3" checked={weekdays['3']} />
                                    <p className="flex-none">Wed</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="4" checked={weekdays['4']} />
                                    <p className="flex-none">Thu</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="5" checked={weekdays['5']} />
                                    <p className="flex-none">Fri</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="6" checked={weekdays['6']} />
                                    <p className="flex-none">Sat</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox onChange={this.toggleWeekdays} name="7" checked={weekdays['7']} />
                                    <p className="flex-none">Sun</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className={'layout-row flex-100 layout-wrap layout-align-end-center border_divider'}>
                        <div
                            className={`${
                                styles.btn_sec
                            } layout-row content_width  flex-none layout-wrap layout-align-start-start`}
                        >
                            <RoundButton
                                text="Generate"
                                handleNext={this.genSchedules}
                                iconClass="fa-plus-o"
                                theme={theme}
                                active
                            />
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
