import React, {Component} from 'react';
import PropTypes from 'prop-types';
import {ChooseShipment} from '../../components/ChooseShipment/ChooseShipment';
import {ShopStageView} from '../../components/ShopStageView/ShopStageView';
import {ShipmentDetails} from '../../components/ShipmentDetails/ShipmentDetails';
import {ChooseRoute} from '../../components/ChooseRoute/ChooseRoute';
import { connect } from 'react-redux';
import { OPEN_SHIPMENT_TYPES, SHIPMENT_STAGES } from '../../constants';
import { shipmentActions } from '../../actions/shipment.actions';
import { Route } from 'react-router';

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
            stageTracker: {
            },
            shopType: 'Open Shop'
        };
        this.selectShipmentType = this.selectShipmentType.bind(this);
    }
    // componentDidUpdate(prevProps) {
    //     if (!this.props.shipment && this.state.stageTracker.stage > 0) {
    //         const { dispatch } = this.props;
    //         dispatch(fetchTenantIfNeeded(selectedSubdomain));
    //     }
    // }

    getShipment() {
        const { dispatch, user } = this.props;
        dispatch(shipmentActions.newShipment(user.data, 'openlcl'));
    }

    selectShipmentType(type) {
        const { history } = this.props;
        this.getShipment();
        this.setState({stageTracker: {shipmentType: type, stage: 1}});
        history.push('/open/shipment_details');
    }
    selectShipmentStage(stage) {
        this.setState({stageTracker: {stage: stage}});
    }
    setShipmentData(data) {
        const type = 'openlcl';
        const { dispatch, history, user } = this.props;
        dispatch(shipmentActions.setShipmentDetails(user.data, data, type));
        this.setState({stageTracker: {shipmentType: type, stage: 1}});
        history.push('/open/choose_route');
    }

    render() {
        // const loggedIn = this.props.loggedIn ? this.props.loggedIn : false;
        // const theme = this.props.tenant.theme;
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        const route1 = this.props.match.url + '/shipment_details';
        const route2 = this.props.match.url + '/choose_route';
        return (
        <div className="layout-row flex-100 layout-wrap" >
            <ShopStageView shopType={this.state.shopType} theme={this.props.theme} stages={this.state.shipmentStages} currentStage={this.state.stageTracker.stage} setStage={this.selectShipmentStage} />
            <Route exact path={this.props.match.url} render={props => <ChooseShipment {...props}  theme={this.props.theme} shipmentTypes={this.state.shipmentOptions} selectShipment={this.selectShipmentType}/>}/>
            <Route exact path={route1} render={props => <ShipmentDetails {...props}  theme={this.props.theme} shipment={this.props.shipment} setShipmentDetails={this.setShipmentData} />}/>
            <Route exact path={route2} render={props => <ChooseRoute {...props}  theme={this.props.theme} />}/>
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

export default connect(mapStateToProps)(OpenShop);
