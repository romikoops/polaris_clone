import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { moment } from '../../constants';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styled from 'styled-components';
import { adminActions } from '../../actions';
// import { moTOptions } from '../../constants';
// import { dispatch } from 'react-redux';
import { Checkbox } from '../Checkbox/Checkbox';
import {RoundButton} from '../RoundButton/RoundButton';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import { BASE_URL } from '../../constants';
import { authHeader } from '../../helpers';
import ReactTooltip from 'react-tooltip';
import { adminSchedules as schedTip } from '../../constants';

class AdminScheduleGenerator extends Component {
    constructor(props) {
        super(props);
        console.log(props);
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
            duration: 30,
            stopIntervals: []
        };
        this.handleDayChange = this.handleDayChange.bind(this);
        this.setItinerary = this.setItinerary.bind(this);
        this.setMoT = this.setMoT.bind(this);
        this.setVehicleType = this.setVehicleType.bind(this);
        this.handleDuration = this.handleDuration.bind(this);
        this.genSchedules = this.genSchedules.bind(this);
        this.getStopsForItinerary = this.getStopsForItinerary.bind(this);
        this.handleIntervalChange = this.handleIntervalChange.bind(this);
    }
    componentDidMount() {
        const { hubs, vehicleTypes, adminDispatch} = this.props;
        if (!vehicleTypes) {
            adminDispatch.getVehicleTypes(false);
        }
        if (!hubs) {
            adminDispatch.getHubs(false);
        }
    }
    handleIntervalChange(ev) {
        const {name, value} = ev.target;
        const stops = this.state.stopIntervals;
        stops[name] = value;
        this.setState({stopIntervals: stops});
    }
    toggleWeekdays(ord) {
        this.setState({weekdays: {...this.state.weekdays, [ord]: !this.state.weekdays[ord]}});
    }
    handleDayChange(ev) {
        this.setState({startHub: moment(ev).format('DD/MM/YYYY')});
    }
    setItinerary(ev) {
        this.getStopsForItinerary(ev.value);
        this.setState({itinerary: ev, mot: ev.mot});
    }

    setMoT(ev) {
        this.setState({mot: ev});
    }
    setVehicleType(ev) {
        this.setState({vehicleType: ev});
    }
    handleDuration(ev) {
        const {name, value} = ev.target;
        this.setState({[name]: value});
    }
    getStopsForItinerary(itineraryId) {
        fetch(`${BASE_URL}/admin/itineraries/${itineraryId}/stops`, {
            method: 'GET',
            headers: authHeader()
        }).then(promise => {
            promise.json().then(response => {
                console.log(response.data);
                const stops = response.data;
                this.setState({stops});
            });
        });
    }
    genSchedules() {
        const {adminDispatch} = this.props;
        const {itinerary, startDate, endDate, weekdays, stopIntervals, vehicleType} = this.state;
        const  ordinalArray = [];
        Object.keys(weekdays).forEach(key => {
            if (weekdays[key]) {
                ordinalArray.push(parseInt(key, 10));
            }
        });
        debugger;
        const req = {
            itinerary: itinerary.value,
            steps: stopIntervals,
            startDate,
            endDate,
            weekdays: ordinalArray,
            vehicleTypeId: vehicleType.value
        };

        adminDispatch.autoGenSchedules(req);
    }
    render() {
        const {theme, hubs, vehicleTypes, itineraries } = this.props;
        const {weekdays, startDate, endDate, mot, vehicleType, stops, stopIntervals} = this.state;

        const future = {
            after: new Date(),
        };
        console.log('mot', mot);
        const vehicleTypeOptions = [];
        if (vehicleTypes && mot) {
            vehicleTypes.forEach((vt) => {
                if (vt.mode_of_transport === mot) {
                    vehicleTypeOptions.push( {value: vt.id, label: vt.name ? vt.name : vt.mode_of_transport + '_default'});
                }
                if (vt.is_default && !vehicleType && vt.mode_of_transport === mot) {
                    this.setState({vehicleType: {value: vt.id, label: vt.name ? vt.name : vt.mode_of_transport + '_default'}});
                }
            });
        }
        const itineraryList = [];
        if (itineraries) {
            itineraries.forEach(itin => {
                itineraryList.push({value: itin.id, label: `${itin.name} (${itin.mode_of_transport})`, mot: itin.mode_of_transport});
            });
        }
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

        const vehicleSelect = mot ? (<StyledSelect

            name="mot-type"
            className={`${styles.select}`}
            value={this.state.vehicleType}
            options={vehicleTypeOptions}
            onChange={this.setVehicleType}
        />) : '';

        const stopIntervalInputs = stops ? stops.map((s, i) =>  {
            return stops[i + 1] ? (
                <div key={s.id} className="flex-none layout-row layout-align-start-start layout-wrap">
                    <div className="flex-100 layout-row layout-align-start-center">
                        <p className="flex-none">{hubs[s.hub_id].data.name}</p>
                        <p className="flex-none">-></p>
                        <p className="flex-none">{hubs[stops[i + 1].hub_id].data.name}</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center input_box_full">
                        <input type="number" min="1" value={stopIntervals[i]} name={i} placeholder="Days" onChange={this.handleIntervalChange}/>
                    </div>
                </div>
            ) : '';
        }) : '';

        return(
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                        <p className={` ${styles.sec_header_text} flex-none`} >
                        Auto Generate
                            <i className="fa fa-info-circle" data-for="autoGenTooltip" data-tip={schedTip.auto_generate} />
                            <ReactTooltip className={styles.tooltip} id="autoGenTooltip" />
                        </p>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Route</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className="flex-60 layout-row layout-align-start-center">
                                <StyledSelect
                                    name="starthub"
                                    className={`${styles.select}`}
                                    value={this.state.itinerary}
                                    options={itineraryList}
                                    onChange={this.setItinerary}
                                />
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Vehicle Type</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">

                            <div className="flex-60 layout-row layout-align-start-center">
                                {vehicleSelect}
                            </div>
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Journey Times</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            {stopIntervalInputs}
                        </div>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  >Set Effective Period and Duration</p>
                        </div>
                        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                            <div className={`flex-40 layout-row layout-wrap layout-align-center-start ${styles.dpb_picker}`}>
                                <DayPickerInput
                                    name="startdate"
                                    placeholder="Start Date"
                                    datePickerProps={{format: 'DD/MM/YYYY'}}
                                    value={startDate}
                                    onDayChange={this.handleDayChange}
                                    modifiers={future}
                                />
                            </div>
                            <div className={`flex-40 layout-row layout-wrap layout-align-center-start ${styles.dpb_picker}`}>
                                <DayPickerInput
                                    name="enddate"
                                    placeholder="End Date"
                                    datePickerProps={{format: 'DD/MM/YYYY'}}
                                    value={endDate}
                                    onDayChange={this.handleDayChange}
                                    modifiers={future}
                                />
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
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('1')} name="1" checked={weekdays['1']} />
                                    <p className="flex-none">Mon</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('2')} name="2" checked={weekdays['2']} />
                                    <p className="flex-none">Tue</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('3')} name="3" checked={weekdays['3']} />
                                    <p className="flex-none">Wed</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('4')} name="4" checked={weekdays['4']} />
                                    <p className="flex-none">Thu</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('5')} name="5" checked={weekdays['5']} />
                                    <p className="flex-none">Fri</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('6')} name="6" checked={weekdays['6']} />
                                    <p className="flex-none">Sat</p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <Checkbox theme={theme} onChange={() => this.toggleWeekdays('7')} name="7" checked={weekdays['7']} />
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

function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}
function mapStateToProps(state) {
    const { admin } = state;
    const { vehicleTypes} = admin;
    return {
        vehicleTypes
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminScheduleGenerator);
