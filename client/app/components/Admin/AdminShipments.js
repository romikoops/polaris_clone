import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminShipmentView, AdminShipmentsIndex } from './';
import { bindActionCreators } from 'redux';
// import {v4} from 'node-uuid';
import { connect } from 'react-redux';
// import { withRouter } from 'react-router-dom';
import { Switch, Route } from 'react-router-dom';
import { adminActions } from '../../actions';
class AdminShipments extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedShipment: null,
            currentView: 'open'
        };
        this.viewShipment = this.viewShipment.bind(this);
    }
    viewShipment(shipment) {
        const { adminDispatch } = this.props;
        adminDispatch.getShipment(shipment.id, true);
    }

    render() {
        console.log(this.props);
        // const {selectedShipment} = this.state;
        const { theme, hubs, shipments, clients, shipment } = this.props;
        // debugger;
        if (!shipments || !hubs || !clients) {
            return <h1>NO SHIPMENTS DATA</h1>;
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };

        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Shipments</p>
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/shipments"
                        render={props => <AdminShipmentsIndex theme={theme} clients={clients} hubs={hubs} shipments={shipments} viewShipment={this.viewShipment} {...props} />}
                    />
                    <Route
                        exact
                        path="/admin/shipments/:id"
                        render={props => <AdminShipmentView theme={theme} hubs={hubs} shipmentData={shipment} clients={clients} {...props} />}
                    />
                </Switch>
            </div>
        );
    }
}
AdminShipments.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    shipments: PropTypes.object,
    shipment: PropTypes.object,
    clients: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, shipment, shipments, hubs } = admin;

    return {
        user,
        tenant,
        loggedIn,
        clients,
        shipments,
        shipment,
        hubs
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminShipments);
