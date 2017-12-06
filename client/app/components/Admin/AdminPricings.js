import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminRouteTile } from './AdminRouteTile';
// import { pricingNames } from '../../constants/admin.constants';
import { AdminPricePanel } from './AdminPricePanel';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminPricings extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedRoute: null,
            currentView: 'open'
        };
        this.setRoute = this.setRoute.bind(this);
    }
    setRoute(route) {
        this.setState({selectedRoute: route});
    }
    render() {
        const {theme, hubs, pricingData } = this.props;
        const { selectedRoute } = this.state;
        if (!pricingData) {
            return '';
        }
        const {pricings, routes} = pricingData;
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.setRoute}/>);
        }
        console.log(pricings, hubs);
        console.log(this.props);
        const openUrl = '/admin/open_pricings/train_and_ocean_pricings/process_csv';
        const dedUrl = '/admin/pricings/train_and_ocean_pricings/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const priceArr = [];
        if (selectedRoute) {
            pricings.open.forEach(pr =>  {
                if (pr.route_id === selectedRoute.id) {
                    priceArr.push(<AdminPricePanel pricing={pr} theme={theme} />);
                }
            });
            pricings.dedicated.forEach(pr =>  {
                if (pr.route_id === selectedRoute.id) {
                    priceArr.push(<AdminPricePanel pricing={pr} theme={theme} />);
                }
            });
        }
        const pricingView = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                {priceArr}
            </div>
        );


        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>pricings</p>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-50 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex">Upload Dedicated Pricings Sheet</p>
                        <FileUploader theme={theme} url={dedUrl} type="xlsx" text="Dedicated Pricings .xlsx"/>
                    </div>
                    <div className={`flex-50 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex">Upload Open Pricings Sheet</p>
                        <FileUploader theme={theme} url={openUrl} type="xlsx" text="Open Pricings .xlsx"/>
                    </div>
                </div>


                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {selectedRoute ? pricingView : routesArr }
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
