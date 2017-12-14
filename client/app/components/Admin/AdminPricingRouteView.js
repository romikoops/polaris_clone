import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminClientTile } from './';
import styles from './Admin.scss';
import { RoundButton } from '../RoundButton/RoundButton';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import {v4} from 'node-uuid';
import {CONTAINER_DESCRIPTIONS} from '../../constants';
import { history } from '../../helpers';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
export class AdminPricingRouteView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            scheduleLimit: 20,
            selectedClient: false
        };
        this.editThis = this.editThis.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.selectClient = this.selectClient.bind(this);
    }
    editThis(pricing) {
        console.log(pricing);
    }
    backToIndex() {
       history.goBack();
    }
    selectClient(client) {
        console.log(client);
        this.setState({selectedClient: client});
    }
    render() {
        const {theme, pricingData, routePricings, hubs, clients} = this.props;
        const {selectedClient} = this.state;
        console.log(this.props);
        if (!pricingData || !routePricings) {
            return '';
        }
        const routeBoxHubs = {startHub: {}, endHub: {}};
        console.log(routePricings);
        const { pricings, hubRoutes, transportCategories } = pricingData;
        const {route, routePricingData} = routePricings;
        if (!route || !routePricingData) {
            return '';
        }
        hubs.forEach(hub => {
            if (hub.location.id === route.origin_nexus_id) {
                routeBoxHubs.startHub = hub;
            }
            if (hub.location.id === route.destination_nexus_id) {
                routeBoxHubs.endHub = hub;
            }
        });
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const backButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="Back"
                    handleNext={this.backToIndex}
                    iconClass="fa-chevron-left"
                />
            </div>);
        const RPBInner = ({hubRoute, pricing, transport}) => {
            const panel = pricing.heavy_wm ?
                (<div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.price_row}`}>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Rate per WM</p>
                        <p className="flex-none">{pricing.wm.rate} {pricing.wm.currency}</p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Minimum WM: </p>
                        <p className="flex-none">{pricing.wm.min} </p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none"> Heavy Weight Surcharge</p>
                        <p className="flex-none">{pricing.heavy_wm.heavy_weight} {pricing.heavy_wm.currency} </p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Minimum Heavy WM</p>
                        <p className="flex-none">{pricing.heavy_wm.heavy_wm_min}</p>
                    </div>
                </div>) :
                (<div className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.price_row}`}>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Rate per Container</p>
                        <p className="flex-none">{pricing.wm.rate} {pricing.wm.currency}</p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Surcharge per Heavy Container</p>
                        <p className="flex-none">{pricing.heavy_kg.heavy_weight} {pricing.heavy_kg.currency} </p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Minimum Heavy Weight</p>
                        <p className="flex-none">{pricing.heavy_kg.heavy_kg_min} kg</p>
                    </div>
                </div>);
            return (
                <div key={v4()} className={` ${styles.hub_route_price} flex-45 layout-row layout-wrap layout-align-center-start`}>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <div className="flex-90 layout-row layout-align-start-center">
                            <i className="fa fa-map-signs clip" style={textStyle}></i>
                            <p className="flex-none offset-5">{hubRoute.name}</p>
                        </div>
                        <div className="flex-10 layout-row layout-align-center-center" onClick={() => this.editThis(pricing)}>
                            <i className="flex-none fa fa-pencil clip" style={textStyle}></i>
                        </div>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">MoT:</p>
                        <p className="flex-none">  {transport.mode_of_transport}</p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Cargo Type: </p>
                        <p className="flex-none">{transport.name}</p>
                    </div>
                    <div className={`flex-95 layout-row layout-align-space-between-center ${styles.price_row_detail}`}>
                        <p className="flex-none">Cargo Class:</p>
                        <p className="flex-none"> {containerDescriptions[transport.cargo_class]}</p>
                    </div>
                    {panel}

                </div>
            );
        };
        const relHR = [];
        hubRoutes.forEach(hr => {
            if (hr.route_id === route.id) {
                relHR.push(hr);
            }
        });
        const RoutePricingBox = ({routeData, hrArr, rPriceObj, pricingsObj, transports, userId}) => {
            const inner = hrArr.map((hr) => {
                const innerInner = [];
                transports.forEach(tr => {
                    const gKey = hr.id + '_' + tr.id;
                    if (rPriceObj[gKey]) {
                        const pricing = pricingsObj[rPriceObj[gKey][userId]];
                        if (pricing) {
                            innerInner.push(
                                <RPBInner key={v4()} hubRoute={hr} transport={tr} pricing={pricing} theme={theme} />
                            );
                        }
                    }
                });
                return innerInner;
            });
            return (
                <div key={v4()} className={` ${styles.route_price} flex-100 layout-row layout-wrap layout-align-start-start `}>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <h3 className="flex-none clip"> {routeData.name} </h3>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        {inner}
                    </div>

                </div>
            );
        };
        const clientTiles = clients.map((cl) => {
            return <AdminClientTile key={v4()} client={cl} theme={theme} handleClick={() => this.selectClient(cl)} />;
        });
        const clientsView = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                    <p className={` ${styles.sec_header_text} flex-none`}  > Open Pricing </p>
                </div>
                {clientTiles}
            </div>
        );
        const clientPriceView = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                    <p className={` ${styles.sec_header_text} flex-none`}  > Dedicated Pricing </p>
                </div>
                 <RoutePricingBox key={v4()} routeData={route} hrArr={relHR} pricingsObj={pricings} rPriceObj={routePricingData} transports={transportCategories} userId={selectedClient.id}/>
            </div>
        );
        // let routeBoxes;
        // if (selectedClient) {
        //     routeBoxes = routes.map((rt) => {

        //         return (
        //             <RoutePricingBox key={v4()} route={rt} hrArr={relHR} pricingsObj={pricings} uPriceObj={userPricings} transports={transportCategories} />
        //         );
        //     });
        // }

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>{route.name}</p>
                    {backButton}
                </div>
                <RouteHubBox hubs={routeBoxHubs} theme={theme}/>
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Open Pricing </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <RoutePricingBox key={v4()} routeData={route} hrArr={relHR} pricingsObj={pricings} rPriceObj={routePricingData} transports={transportCategories} userId="open"/>
                    </div>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Users With Dedicated Pricings </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        {selectedClient ? clientPriceView : clientsView }
                    </div>
                </div>
            </div>
        );
    }
}
AdminPricingRouteView.propTypes = {
    theme: PropTypes.object,
    hubHash: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array,
    adminActions: PropTypes.object
};
