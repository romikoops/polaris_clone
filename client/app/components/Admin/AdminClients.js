import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminClientsIndex, AdminClientView} from './';
import styles from './Admin.scss';
// import {v4} from 'node-uuid';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
class AdminClients extends Component {
     constructor(props) {
        super(props);
        this.state = {
            selectedClient: false,
            currentView: 'open'
        };
        this.viewClient = this.viewClient.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.handleClientAction = this.handleClientAction.bind(this);
    }
    viewClient(client) {
        const { adminDispatch } = this.props;
        adminDispatch.getClient(client.id, true);
        this.setState({selectedClient: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedClient: false});
        dispatch(history.push('/admin/clients'));
    }
    handleClientAction(id, action) {
        const { adminDispatch } = this.props;
        adminDispatch.confirmShipment(id, action);
    }

    render() {
        const {selectedClient} = this.state;
        const {theme, clients, hubs, client} = this.props;
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
        return(
             <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Clients</p>
                    {selectedClient ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/clients"
                        render={props => <AdminClientsIndex theme={theme} handleClientAction={this.handleClientAction} clients={clients} hubs={hubs}  viewClient={this.viewClient} {...props} />}
                    />
                    <Route
                        exact
                        path="/admin/clients/:id"
                        render={props => <AdminClientView theme={theme} hubs={hubs} handleClientAction={this.handleClientAction} clientData={client} {...props} />}
                    />
                </Switch>
            </div>
        );
    }
}
AdminClients.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    clients: PropTypes.array
};
function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, shipment, shipments, hubs, client } = admin;

    return {
        user,
        tenant,
        loggedIn,
        clients,
        shipments,
        shipment,
        hubs,
        client
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminClients);
