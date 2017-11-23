import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ChooseShipment } from '../../components/ChooseShipment/ChooseShipment';
import { ShopStageView } from '../../components/ShopStageView/ShopStageView';
import { ShipmentDetails } from '../../components/ShipmentDetails/ShipmentDetails';
import { ChooseRoute } from '../../components/ChooseRoute/ChooseRoute';
import { BookingDetails } from '../../components/BookingDetails/BookingDetails';

import { connect } from 'react-redux';
import { OPEN_SHIPMENT_TYPES, SHIPMENT_STAGES } from '../../constants';
import { shipmentActions } from '../../actions/shipment.actions';
import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';

import './OpenShop.scss';

class OpenShop extends Component {
    constructor(props) {
        super(props);
        this.tenant = this.props.tenant;
        console.log(this.props);
        this.state = {
            shipmentOptions: OPEN_SHIPMENT_TYPES,
            shipmentStages: SHIPMENT_STAGES,
            shipment: this.props.shipment,
            stageTracker: {},
            shopType: 'Open Shop',
            contacts: {
                shipper: {},
                consignee: {},
                notifyees: []
            }
        };
        this.selectShipmentType = this.selectShipmentType.bind(this);
        this.setShipmentData = this.setShipmentData.bind(this);
        this.selectShipmentRoute = this.selectShipmentRoute.bind(this);
        this.setShipmentContacts = this.setShipmentContacts.bind(this);
    }
    componentDidUpdate() {
        // const { match } = this.props;
        // debugger;
        // if (!this.props.shipment && match.params.shipmentId) {
        //     const { dispatch } = this.props;
        //     dispatch(shipmentActions.fetchShipmentIfNeeded(match.params.shipmentId));
        // } else if (this.props.shipment && this.props.shipment.data && match.params.shipmentId && this.props.shipment.data.id !== match.params.shipmentId) {
        //     const { dispatch } = this.props;
        //     dispatch(shipmentActions.fetchShipmentIfNeeded(match.params.shipmentId));
        // }
    }

    getShipment() {
        const { dispatch, user } = this.props;
        dispatch(shipmentActions.newShipment(user.data, 'openlcl'));
    }

    selectShipmentType(type) {
        // const { history } = this.props;
        this.getShipment();
        this.setState({ stageTracker: { shipmentType: type, stage: 1 } });
        // history.push('/open/shipment_details');
    }
    selectShipmentStage(stage) {
        this.setState({ stageTracker: { stage: stage } });
    }
    setShipmentData(data) {
        const { dispatch, history } = this.props;
        dispatch(shipmentActions.setShipmentDetails(data));
        this.setState({
            stageTracker: { shipmentType: data.load_type, stage: 2 }
        });
        history.push('/open/' + data.shipment.id + '/choose_route');
    }
    setShipmentContacts(data) {
        const { dispatch, history } = this.props;
        dispatch(shipmentActions.setShipmentDetails(data));
        this.setState({
            stageTracker: { shipmentType: data.load_type, stage: 2 }
        });
        history.push('/open/' + data.shipment.id + '/finish_booking');
    }

    selectShipmentRoute(obj) {
        const { dispatch, history } = this.props;
        const { schedule, total } = obj;
        const req = {
            schedules: [schedule],
            total,
            shipment: this.props.shipment.shipment
        };
        dispatch(shipmentActions.setShipmentRoute(req));
        history.push(
            '/open/' + this.props.shipment.shipment.id + '/booking_details'
        );
    }

    render() {
        // const loggedIn = this.props.loggedIn ? this.props.loggedIn : false;
        // const theme = this.props.tenant.theme;
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };

        const route1 = this.props.match.url + '/:shipmentId/shipment_details';
        const route2 = this.props.match.url + '/:shipmentId/choose_route';
        const route3 = this.props.match.url + '/:shipmentId/booking_details';
        return (

            <div className="layout-row flex-100 layout-wrap">
                <ShopStageView
                    shopType={this.state.shopType}
                    match={this.props.match}
                    theme={this.props.theme}
                    stages={this.state.shipmentStages}
                    currentStage={this.state.stageTracker.stage}
                    setStage={this.selectShipmentStage}
                />
                <Route
                    exact
                    path={this.props.match.url}
                    render={props => (
                        <ChooseShipment
                            {...props}
                            theme={this.props.theme}
                            shipmentTypes={this.state.shipmentOptions}
                            selectShipment={this.selectShipmentType}
                        />
                    )}
                />
                <Route
                    path={route1}
                    render={props => (
                        <ShipmentDetails
                            {...props}
                            theme={this.props.theme}
                            shipment={this.props.shipment}
                            setShipmentDetails={this.setShipmentData}
                        />
                    )}
                />
                <Route
                    path={route2}
                    render={props => (
                        <ChooseRoute
                            {...props}
                            chooseRoute={this.selectShipmentRoute}
                            theme={this.props.theme}
                            shipmentData={this.props.shipment}
                        />
                    )}
                />
                <Route
                    path={route3}
                    render={props => (
                        <BookingDetails
                            {...props}
                            nextStage={this.setShipmentContacts}

                            theme={this.props.theme}
                            shipmentData={this.props.shipment}
                        />
                    )}
                />
            </div>
        );
    }
}

OpenShop.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

OpenShop.defaultProps = {
    stageTracker: {
        stage: 0,
        shipmentType: ''
    }
};

function mapStateToProps(state) {
    const { users, authentication, tenant, shipment } = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        users,
        tenant,
        loggedIn,
        shipment
    };
}

export default withRouter(connect(mapStateToProps)(OpenShop));
