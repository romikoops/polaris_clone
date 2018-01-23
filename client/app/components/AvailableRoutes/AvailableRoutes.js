import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { RouteSelector } from '../RouteSelector/RouteSelector';
export class AvailableRoutes extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.startBooking = this.startBooking.bind(this);
        this.routeSelected = this.routeSelected.bind(this);
    }
    componentDidMount() {
    }
    viewShipment(shipment) {
        const { userDispatch } = this.props;
        userDispatch.getShipment(shipment.id, true);
        this.setState({selectedShipment: true});
    }
    startBooking() {
        this.props.userDispatch.goTo('/booking');
    }
    prepShipment(shipment, user, hubsObj) {
        shipment.clientName = user ? `${user.first_name} ${user.last_name}` : '';
        shipment.companyName = user ? `${user.company_name}` : '';
        const hubKeys = shipment.schedule_set[0].hub_route_key.split('-');
        shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : '';
        shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : '';
        return shipment;
    }

    dynamicSort(property) {
        let sortOrder = 1;
        let prop;
        if(property[0] === '-') {
            sortOrder = -1;
            prop = property.substr(1);
        } else {
            prop = property;
        }
        return (a, b) => {
            const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop];
            const result2 = result1 ? 1 : 0;
            return result2 * sortOrder;
        };
    }
    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.id, locationId);
    }
    routeSelected() {

    }
    render() {
        const { user, theme, routes  } = this.props;
        if (!user) {
            return (
                <div>
                    <h1>Gone smoking '()___)_))__________)</h1>
                </div>
            );
        }
        return(
            <RouteSelector
                user={ user }
                theme={ theme }
                routes={ routes }
                routeSelected={this.routeSelected}
            />
        );
    }
}
AvailableRoutes.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
