import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
// import { AdminPricePanel } from './AdminPricePanel';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminSchedules extends Component {
    constructor(props) {
        super(props);
        this.state = {
            currentView: 'ocean'
        };
        this.toggleView = this.toggleView.bind(this);
    }
    toggleView(view) {
        this.setState({currentView: view});
    }
    render() {
        const {theme, hubs, schedules } = this.props;
        const { currentView } = this.state;
        // const {pricings, routes} = pricingData;
        const hubHash = {};
        hubs.forEach((hub) => {
            hubHash[hub.data.id] = hub;
        });
        console.log(schedules);
        // if (charges && hubs) {
        //     charges.forEach((charge) =>{
        //         console.log(charge.hub_id);
        //         console.log(hubHash[charge.hub_id]);
        //         if (hubHash[charge.hub_id]) {
        //             chargeList.push(<AdminChargePanel key={v4()} hub={hubHash[charge.hub_id]} theme={theme} charge={charge}/>);
        //         }
        //     });
        // }
        const trainUrl = '/admin/train_schedules/process_csv';
        const vesUrl = '/admin/vessel_schedules/process_csv';
        const airUrl = '/admin/air_schedules/process_csv';
        const railView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Train Schedules Sheet</p>
                    <FileUploader theme={theme} url={trainUrl} type="xlsx" text="Train Schedules .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                </div>
            </div>
        );
        const airView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Air Schedules Sheet</p>
                    <FileUploader theme={theme} url={airUrl} type="xlsx" text="Air Schedules .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                </div>
            </div>
        );
        const oceanView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Vessel Schedules Sheet</p>
                    <FileUploader theme={theme} url={vesUrl} type="xlsx" text="Vessel Schedules .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                </div>
            </div>
        );
        let currView = '';
        switch(currentView) {
            case 'ocean':
                currView = oceanView;
                break;
            case 'air':
                currView = airView;
                break;
            case 'rail':
                currView = railView;
                break;
            default:
                currView = oceanView;
                break;
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-33 layout-row layout-align-center-center ${styles.sched_selector}`} onClick={() => this.toggleView('ocean')}>
                        <i className="fa fa-ship flex-none" style={textStyle}></i>
                        <p className="flex-none flex-offset-5"  style={textStyle}> Ocean </p>
                    </div>
                    <div className={`flex-33 layout-row layout-align-center-center ${styles.sched_selector}`} onClick={() => this.toggleView('rails')}>
                        <i className="fa fa-train flex-none" style={textStyle}></i>
                        <p className="flex-none flex-offset-5"  style={textStyle}> Rail </p>
                    </div>
                    <div className={`flex-33 layout-row layout-align-center-center ${styles.sched_selector}`} onClick={() => this.toggleView('air')}>
                        <i className="fa fa-plane flex-none" style={textStyle}></i>
                        <p className="flex-none flex-offset-5"  style={textStyle}> Air </p>
                    </div>
                </div>
                <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                    <p className="flex-none" style={textStyle}>pricings</p>
                </div>

                {currView}
            </div>
        );
    }
}
AdminSchedules.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
