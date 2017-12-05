import React, { Component } from 'react';
import PropTypes from 'prop-types';
import adminStyles from './Admin.scss';
// import { AdminPricePanel } from './AdminPricePanel';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminPricings extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, pricingData } = this.props;
        // const {pricings, routes} = pricingData;
        const hubHash = {};
        hubs.forEach((hub) => {
            hubHash[hub.data.id] = hub;
        });
        const chargeList = [];
        console.log(pricingData);
        // console.log(routes);
        // if (charges && hubs) {
        //     charges.forEach((charge) =>{
        //         console.log(charge.hub_id);
        //         console.log(hubHash[charge.hub_id]);
        //         if (hubHash[charge.hub_id]) {
        //             chargeList.push(<AdminChargePanel key={v4()} hub={hubHash[charge.hub_id]} theme={theme} charge={charge}/>);
        //         }
        //     });
        // }
        console.log(chargeList);
        const openUrl = '/admin/open_pricings/train_and_ocean_pricings/process_csv';
        const dedUrl = '/admin/pricings/train_and_ocean_pricings/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${adminStyles.sec_title}`}>
                    <p className="flex-none" style={textStyle}>pricings</p>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Open Pricings Sheet</p>
                    <FileUploader theme={theme} url={openUrl} type="xlsx" text="Open Pricings .xlsx"/>
                </div>
                <div className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_upload}`}>
                    <p className="flex-none">Upload Dedicated Pricings Sheet</p>
                    <FileUploader theme={theme} url={dedUrl} type="xlsx" text="Dedicated Pricings .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                </div>
            </div>
        );
    }
}
AdminPricings.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
