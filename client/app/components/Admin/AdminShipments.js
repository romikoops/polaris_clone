import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminShipmentView, AdminShipmentsIndex } from './';
import { bindActionCreators } from 'redux';
// import {v4} from 'node-uuid';
import { connect } from 'react-redux';
// import { withRouter } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { Switch, Route } from 'react-router-dom';
import { adminActions } from '../../actions';
class AdminShipments extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedShipment: false,
            currentView: 'open'
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.handleShipmentAction = this.handleShipmentAction.bind(this);
    }
    viewShipment(shipment) {
        const { adminDispatch } = this.props;
        adminDispatch.getShipment(shipment.id, true);
        this.setState({selectedShipment: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedShipment: false});
        dispatch(history.push('/admin/shipments'));
    }
    handleShipmentAction(id, action) {
        const { adminDispatch } = this.props;
        adminDispatch.confirmShipment(id, action);
    }

    render() {
        console.log(this.props.match);
        const {selectedShipment} = this.state;
        const { theme, hubs, shipments, clients, shipment } = this.props;
        // debugger;
        if (!shipments || !hubs || !clients) {
            return <h1>NO SHIPMENTS DATA</h1>;
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const backButton = (<div className="flex-none layout-row">
            <RoundButton
                theme={theme}
                size="small"
                text="Back"
                handleNext={this.backToIndex}
                iconClass="fa-chevron-left"
            />
        </div>);

        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Shipments</p>
                    {selectedShipment ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/shipments"
                        render={props => <AdminShipmentsIndex theme={theme} handleShipmentAction={this.handleShipmentAction} clients={clients} hubs={hubs} shipments={shipments} viewShipment={this.viewShipment} {...props} />}
                    />
                    <Route
                        exact
                        path="/admin/shipments/:id"
                        render={props => <AdminShipmentView theme={theme} hubs={hubs} handleShipmentAction={this.handleShipmentAction} shipmentData={shipment} clients={clients} {...props} />}
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
