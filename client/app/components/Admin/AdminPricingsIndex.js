import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { Redirect } from 'react-router';
import { AdminRouteTile, AdminClientTile } from './';
// import { pricingNames } from '../../constants/admin.constants';
import {v4} from 'node-uuid';
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
        this.setRoute = this.setRoute.bind(this);
        this.viewAllRoutes = this.viewAllRoutes.bind(this);
        this.viewAllClients = this.viewAllClients.bind(this);
        this.viewClient = this.viewClient.bind(this);
    }
    setRoute(route) {
        this.setState({selectedPricing: route});
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
    render() {
        const {theme, hubs, pricingData, clients } = this.props;
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
        const {pricings, routes} = pricingData;
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.setRoute}/>);
        }
        let clientsArr;
        if (clients) {
            clientsArr = clients.map((c) => <AdminClientTile key={v4()} client={c} theme={theme} handleClick={() => this.viewClient(c)}/>);
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
                    <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-none layout-row layout-align-center-center" onClick={this.viewAllRoutes}>
                            <p className="flex-none">See all</p>
                        </div>
                    </div>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                        <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                            {clientsArr}
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-none layout-row layout-align-center-center">
                            <p className="flex-none">See all</p>
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
