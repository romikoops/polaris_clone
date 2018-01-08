import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { Redirect } from 'react-router';
import { AdminRouteTile } from './';
import { history } from '../../helpers';
// import { pricingNames } from '../../constants/admin.constants';
import { AdminSearchableRoutes } from './AdminSearchables';
import {v4} from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';
export class AdminPricingsRouteIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedPricing: null,
            currentView: 'open',
            redirect: false
        };
        this.backToIndex = this.backToIndex.bind(this);
        this.viewRoute = this.viewRoute.bind(this);
    }

    backToIndex() {
        // debugger;
        // this.setState({redirect: true});
        history.goBack();
    }

    viewRoute(route) {
        const {adminTools} = this.props;
        adminTools.getRoutePricings(route.id, true);
    }

    render() {
        const {theme, hubs, routes } = this.props;
        // const { selectedPricing } = this.state;
        if (!routes) {
            return '';
        }
        if (this.state.redirect) {
            return <Redirect push to="/admin/pricings" />;
        }
        const backButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="Back"
                    handleNext={this.backToIndex}
                    iconClass="fa-chevron-left"
                />
            </div>
        );
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={() => this.viewRoute(rt)}/>);
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Route Pricings</p>
                    {backButton}
                </div>
                <AdminSearchableRoutes routes={routes} theme={theme} hubs={hubs} handleClick={this.viewRoute} sideScroll={false} />
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        {routesArr}
                    </div>
                </div>
            </div>
        );
    }
}
AdminPricingsRouteIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
