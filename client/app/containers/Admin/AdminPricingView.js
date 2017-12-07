import React, { Component } from 'react';
import PropTypes from 'prop-types';
import adminStyles from './Admin.scss';
import { AdminRouteTile } from './AdminRouteTile';

// import { AdminPricePanel } from './AdminPricePanel';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminPricingView extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, pricingData } = this.props;
        if (!pricingData) {
            return '';
        }
        const {pricings, routes} = pricingData;
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => <AdminRouteTile hubs={hubs} route={rt} />);
        }
        console.log(pricings, hubs);
        console.log(this.props);
        const openUrl = '/admin/open_pricings/train_and_ocean_pricings/process_csv';
        const dedUrl = '/admin/pricings/train_and_ocean_pricings/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        let pricingArr;
        if (selected) {}
        const dedView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                 <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Dedicated Pricings Sheet</p>
                    <FileUploader theme={theme} url={dedUrl} type="xlsx" text="Dedicated Pricings .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {selectedRoute ? routesArr : pricingView}
                </div>
            </div>
        );
        const openView = (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
               <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Open Pricings Sheet</p>
                    <FileUploader theme={theme} url={openUrl} type="xlsx" text="Open Pricings .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {selectedRoute ? routesArr : pricingView}
                </div>
            </div>
        );
        
        let currView = '';
        switch(currentView) {
            case 'open':
                currView = openView;
                break;
            case 'dedicated':
                currView = dedView;
                break;
            default:
                currView = openView;
                break;
        }

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${adminStyles.sec_title}`}>
                    <p className="flex-none" style={textStyle}>pricings</p>
                </div>
                 <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-33 layout-row layout-align-center-center ${styles.sched_selector}`} onClick={() => this.toggleView('dedicated')}>
                        <i className="fa fa-star flex-none" style={textStyle}></i>
                        <p className="flex-none flex-offset-5"  style={textStyle}> Dedicated Rates </p>
                    </div>
                    <div className={`flex-33 layout-row layout-align-center-center ${styles.sched_selector}`} onClick={() => this.toggleView('open')}>
                        <i className="fa fa-users flex-none" style={textStyle}></i>
                        <p className="flex-none flex-offset-5"  style={textStyle}> Open Rates </p>
                    </div>
                </div>
                
               
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {currView}
                </div>
            </div>
        );
    }
}
AdminPricingView.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
