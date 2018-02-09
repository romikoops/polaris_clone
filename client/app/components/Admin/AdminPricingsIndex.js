import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { Redirect } from 'react-router';
// import { AdminRouteTile, AdminClientTile } from './';
import { AdminSearchableRoutes, AdminSearchableClients } from './AdminSearchables';
// import { pricingNames } from '../../constants/admin.constants';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminPricingsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedPricing: null,
            currentView: 'open',
            redirectRoutes: false,
            redirectClients: false
        };
        this.viewAllRoutes = this.viewAllRoutes.bind(this);
        this.viewAllClients = this.viewAllClients.bind(this);
        this.viewClient = this.viewClient.bind(this);
        this.viewRoute = this.viewRoute.bind(this);
    }

    viewAllRoutes() {
        this.setState({redirectRoutes: true});
    }
    viewAllClients() {
        this.setState({redirectClients: true});
    }
    viewClient(client) {
        const {adminTools} = this.props;
        adminTools.getClientPricings(client.id, true);
    }
    viewRoute(route) {
        const {adminTools} = this.props;
        adminTools.getItineraryPricings(route.id, true);
    }
    render() {
        const {theme, hubs, pricingData, clients, adminTools } = this.props;
        // const { selectedPricing } = this.state;
        if (!pricingData) {
            return '';
        }

        if (this.state.redirectRoutes) {
            return <Redirect push to="/admin/pricings/routes" />;
        }
        if (this.state.redirectClients) {
            return <Redirect push to="/admin/pricings/clients" />;
        }
        const {itineraries} = pricingData;
        const lclUrl = '/admin/pricings/ocean_lcl_pricings/process_csv';
        const fclUrl = '/admin/pricings/ocean_fcl_pricings/process_csv';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-50 layout-row layout-wrap layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex-100">Upload LCL Pricings Sheet</p>
                        <FileUploader theme={theme} url={lclUrl} type="xlsx" text="Dedicated Pricings .xlsx"/>
                    </div>
                    <div className={`flex-50 layout-row layout-wrap layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex-100">Upload FCL Pricings Sheet</p>
                        <FileUploader theme={theme} url={fclUrl} type="xlsx" text="Open Pricings .xlsx"/>
                    </div>
                </div>
                <AdminSearchableRoutes itineraries={itineraries} theme={theme} hubs={hubs} handleClick={this.viewRoute} seeAll={() => adminTools.goTo('/admin/pricings/routes')}/>
                <AdminSearchableClients theme={theme} clients={clients} handleClick={this.viewClient} seeAll={() => adminTools.goTo('/admin/pricings/clients')}/>
            </div>
        );
    }
}
AdminPricingsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
