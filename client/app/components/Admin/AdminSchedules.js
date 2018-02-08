import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminTripPanel } from './';
import AdminScheduleGenerator from './AdminScheduleGenerator';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
// import {v4} from 'node-uuid';
import styled from 'styled-components';
import FileUploader from '../FileUploader/FileUploader';
import {RoundButton} from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
export class AdminSchedules extends Component {
    constructor(props) {
        super(props);
        console.log(props);
        this.state = {
            showList: true,
            filters: {
                hub: false,
                mot: false,
                sort: false
            },
            motFilter: {value: false, label: false},
            sortFilter: {value: false, label: false},
            hubFilter: {value: false, label: false},
            panelViewer: {}
        };
        this.toggleView = this.toggleView.bind(this);
        this.setMoTFilter = this.setMoTFilter.bind(this);
        this.setSortFilter = this.setSortFilter.bind(this);
        this.setHubFilter = this.setHubFilter.bind(this);
        this.toggleShowPanel = this.toggleShowPanel.bind(this);
    }
    toggleView() {
        this.setState({showList: !this.state.showList});
    }
    setMoTFilter(mot) {
        if (!mot) {
            this.setState({
                motFilter: {value: false, label: false},
                filters: {
                    ...this.state.filters,
                    mot: false
                }
            });
        } else {
            this.setState({
                motFilter: mot,
                filters: {
                    ...this.state.filters,
                    mot: true
                }
            });
        }
    }
    setSortFilter(sorter) {
        if (!sorter) {
            this.setState({
                sortFilter: {value: false, label: false},
                filters: {
                    ...this.state.filters,
                    sort: false
                }
            });
        } else {
            this.setState({
                sortFilter: sorter,
                filters: {
                    ...this.state.filters,
                    sort: true
                }
            });
        }
    }
    setHubFilter(hub) {
        if (!hub) {
            this.setState({
                hubFilter: {value: false, label: false},
                filters: {
                    ...this.state.filters,
                    hub: false
                }
            });
        } else {
            this.setState({
                hubFilter: hub,
                filters: {
                    ...this.state.filters,
                    hub: true
                }
            });
        }
    }
    getItinerary(sched) {
        return this.props.scheduleData.itineraries.filter(x => x.id === sched.itinerary_id)[0];
    }
    toggleShowPanel(id) {
        if (!this.state.panelViewer[id]) {
            this.props.adminDispatch.getLayovers(id);
        }
        this.setState({panelViewer: {
            ...this.state.panelViewer,
            [id]: !this.state.panelViewer[id]
        }});
    }

    getItinerariesForHub(hub) {
        const filteredItineraries = this.props.scheduleData.itineraries.filter(x => x.hubs.indexOf(hub) > -1);
        return filteredItineraries.map(x => x.id);
    }

    dynamicSort(property) {
        let sortOrder = 1;
        let prop;
        if(property[0] === '-') {
            sortOrder = -1;
            prop = property.substr(1);
        } else {
            prop = property;
        }
        return function(a, b) {
            const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop];
            const result2 = result1 ? 1 : 0;
            return result2 * sortOrder;
        };
    }
    render() {
        const {theme, hubs, scheduleData, adminDispatch, limit} = this.props;
        const {filters, hubFilter, sortFilter, panelViewer} = this.state;
        if (!scheduleData || !hubs) {
            return '';
        }
        const filterMoTOptions = [
            {value: 'rail', label: 'Rail'},
            {value: 'air', label: 'Air'},
            {value: 'ocean', label: 'Ocean'}
        ];
        const filterSortOptions = [
            {value: 'eta', label: 'ETA'},
            {value: 'etd', label: 'ETD'}
        ];
        const { itineraries, air, train, ocean, itineraryLayovers} = scheduleData;
        const { showList } = this.state;
        const trainUrl = '/admin/train_schedules/process_csv';
        const vesUrl = '/admin/vessel_schedules/process_csv';
        const airUrl = '/admin/air_schedules/process_csv';
        const truckUrl = '/admin/truck_schedules/process_csv';
        const tripArr = [];
        const slimit = limit ? limit : 10;
        let allTrips;
        switch (filters.mot) {
            case 'ocean':
            allTrips = ocean;
            break;
            case 'air':
            allTrips = air;
            break;
            case 'rail':
            allTrips = train;
            break;
            case false:
            allTrips =  [...air, ...ocean, ...train];
            break;
            default:
            allTrips =  [...air, ...ocean, ...train];
            break;
        }
        let itineraryIds;
        if (filters.hub) {
            itineraryIds = this.getItinerariesForHub(hubFilter.value);
        }
        allTrips.forEach((trip, i) => {
            if (filters.hub && itineraryIds.includes(trip.itinerary_id) && i < slimit) {
                tripArr.push(<AdminTripPanel key={v4()} trip={trip} showPanel={panelViewer[trip.id]} toggleShowPanel={this.toggleShowPanel} layovers={itineraryLayovers} adminDispatch={adminDispatch} itinerary={this.getItinerary(trip)} hubs={hubs} theme={theme}/>);
            }
            if (!filters.hub && i < slimit) {
                tripArr.push(<AdminTripPanel key={v4()} trip={trip} showPanel={panelViewer[trip.id]} toggleShowPanel={this.toggleShowPanel} layovers={itineraryLayovers} adminDispatch={adminDispatch} itinerary={this.getItinerary(trip)} hubs={hubs} theme={theme}/>);
            }
        });

        if (filters.sort) {
            tripArr.sort(this.dynamicSort(sortFilter.value));
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
        const hubList = [];
        Object.keys(hubs).forEach(key => {
            hubList.push({value: key, label: hubs[key].data.name});
        });
        const listView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-align-start-center">
                    <div className="flex-33 layout-row layout-align-start-center">
                        <StyledSelect
                            name="mot-filter"
                            className={`${styles.select}`}
                            value={this.state.motFilter}
                            options={filterMoTOptions}
                            onChange={this.setMoTFilter}
                        />
                    </div>
                    <div className="flex-33 layout-row layout-align-start-center">
                        <StyledSelect
                            name="sort-filter"
                            className={`${styles.select}`}
                            value={this.state.sortFilter}
                            options={filterSortOptions}
                            onChange={this.setSortFilter}
                        />
                    </div>
                    <div className="flex-33 layout-row layout-align-start-center">
                        <StyledSelect
                            name="hub-filter"
                            className={`${styles.select}`}
                            value={this.state.hubFilter}
                            options={hubList}
                            onChange={this.setHubFilter}
                        />
                    </div>
                </div>
                {tripArr}
            </div>
        );

        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };


        const genView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Excel Uploads</p>
                    </div>
                    <div className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${styles.sec_upload}`}>
                        <p className="flex-80">Upload Train Schedules Sheet</p>
                        <FileUploader theme={theme} url={trainUrl} type="xlsx" text="Train Schedules .xlsx"/>
                    </div>
                    <div className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${styles.sec_upload}`}>
                        <p className="flex-80">Upload Air Schedules Sheet</p>
                        <FileUploader theme={theme} url={airUrl} type="xlsx" text="Air Schedules .xlsx"/>
                    </div>
                    <div className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${styles.sec_upload}`}>
                        <p className="flex-80">Upload Vessel Schedules Sheet</p>
                        <FileUploader theme={theme} url={vesUrl} type="xlsx" text="Vessel Schedules .xlsx"/>
                    </div>
                    <div className={`flex-50 layout-row layout-align-space-between-center layout-wrap ${styles.sec_upload}`}>
                        <p className="flex-80">Upload Trucking Schedules Sheet</p>
                        <FileUploader theme={theme} url={truckUrl} type="xlsx" text="Truck Schedules .xlsx"/>
                    </div>
                </div>
                <AdminScheduleGenerator theme={theme} itineraries={itineraries} hubs={hubList} />
            </div>
        );

        const currView = showList ? listView : genView;

        const backButton = (<RoundButton theme={theme} text="Back to list" size="small" back iconClass="fa-th-list" handleNext={this.toggleView} />);
        const newButton = (<RoundButton theme={theme} text="New Upload" active size="small" iconClass="fa-plus" handleNext={this.toggleView} />);
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Schedules</p>
                    { showList ? newButton : backButton }
                </div>
                {currView}
            </div>
        );
    }
}
AdminSchedules.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.object,
    scheduleData: PropTypes.object
};
