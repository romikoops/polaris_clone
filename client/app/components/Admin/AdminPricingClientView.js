import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { AdminScheduleLine, AdminHubTile, AdminImportChargePanel, AdminExportChargePanel } from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
import {}
export class AdminPricingClientView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            scheduleLimit: 20
        };
    }
    render() {
        const {theme, pricingData, clientPricings} = this.props;
        console.log(this.props);
        if (!pricingData || !clientPricings) {
            return '';
        }
        console.log(clientPricings);
        const { routes, pricings, hubRoutes, transportCategories } = pricingData;
        const {client, userPricings} = clientPricings;
        if (!client || !userPricings) {
            return '';
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
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
                        <i className="fa fa-map-signs clip" style={textStyle}></i>
                        <p className="flex-none offset-5">{hubRoute.name}</p>
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
                        <p className="flex-none"> {transport.cargo_class}</p>
                    </div>
                    {panel}

                </div>
            );
        };
        const RoutePricingBox = ({route, hrArr, uPriceObj, pricingsObj, transports}) => {
            // if (!uPriceObj) {
            //     return '';
            // }
            const inner = hrArr.map((hr) => {
                const innerInner = [];
                transports.forEach(tr => {
                    const gKey = hr.id + '_' + tr.id;
                    const pricing = pricingsObj[uPriceObj[gKey]];
                    if (pricing) {
                        innerInner.push(
                            <RPBInner key={v4()} hubRoute={hr} transport={tr} pricing={pricing} them={theme} />
                        );
                    }
                });
                return innerInner;
            });
            return (
                <div key={v4()} className={` ${styles.route_price} flex-100 layout-row layout-wrap layout-align-start-start `}>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <h3 className="flex-none clip"> {route.name} </h3>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        {inner}
                    </div>

                </div>
            );
        };
        const routeBoxes = routes.map((rt) => {
            const relHR = [];
            hubRoutes.forEach(hr => {
                if (hr.route_id === rt.id) {
                    relHR.push(hr);
                }
            });
            return (
                <RoutePricingBox key={v4()} route={rt} hrArr={relHR} pricingsObj={pricings} uPriceObj={userPricings} transports={transportCategories} />
            );
        });

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>{client.first_name} {client.last_name}</p>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {routeBoxes}

                </div>
            </div>
        );
    }
}
AdminPricingClientView.propTypes = {
    theme: PropTypes.object,
    hubHash: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array,
    adminActions: PropTypes.object
};
