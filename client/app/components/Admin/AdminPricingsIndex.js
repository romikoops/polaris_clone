import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminRouteTile, AdminClientTile } from './AdminRouteTile';
// import { pricingNames } from '../../constants/admin.constants';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminPricingsIndex extends Component {
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
        const {theme, hubs, pricingData, clients } = this.props;
        // const { selectedRoute } = this.state;
        if (!pricingData) {
            return '';
        }
        const {pricings, routes} = pricingData;
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.setRoute}/>);
        }
        let clientsArr;
        if (clients) {
            clientsArr = clients.map((c) => <AdminClientTile key={v4()} client={c} theme={theme} handleClick={this.setRoute}/>);
        }
       const dedUrl = '';
       const openUrl = '';
       console.log(pricings);
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
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
                    <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                            {routesArr}
                        </div>
                    </div>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                            {clientsArr}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
AdminPricingsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
