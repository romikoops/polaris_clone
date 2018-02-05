import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminClientsIndex, AdminClientView} from './';
import styles from './Admin.scss';
// import {v4} from 'node-uuid';
import { withRouter } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
import { ValidatedInput } from '../ValidatedInput/ValidatedInput';
import reactTriggerChange from 'react-trigger-change';

class AdminClients extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedClient: false,
            currentView: 'open',
            newClientBool: false,
            newClient: {},
            errors: {
                companyName: true,
                firstName: true,
                lastName: true,
                email: true,
                phone: true,
                street: true,
                number: true,
                zipCode: true,
                city: true,
                country: true,
                password: true,
                password_confirmation: true
            },
            newClientAttempt: false
        };
        this.toggleNewClient = this.toggleNewClient.bind(this);
        this.handleFormChange = this.handleFormChange.bind(this);
        this.saveNewClient = this.saveNewClient.bind(this);
        this.viewClient = this.viewClient.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.handleClientAction = this.handleClientAction.bind(this);
        this.errorsExist = this.errorsExist.bind(this);
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
    toggleNewClient() {
        this.setState({
            newClientBool: !this.state.newClientBool,
            newClientAttempt: false
        });
    }
    handleFormChange(event, hasError) {
        const { name, value } = event.target;
        const { errors } = this.state;

        const newClient = this.state.newClient;
        if (this.tmpNewClient) {
            Object.assign(newClient, this.tmpNewClient);
            Object.assign(errors, this.tmpErrors);
            this.tmpNewClient = null;
        }

        if (hasError !== undefined) errors[name] = hasError;

        if (name === 'password' && this.passwordConfirmationInput) {
            this.tmpNewClient = {
                ...this.state.newClient,
                [name]: value
            };
            this.tmpErrors = Object.assign({}, errors);
            reactTriggerChange(this.passwordConfirmationInput);
        } else {
            this.setState({
                newClient: {
                    ...newClient,
                    [name]: value
                },
                errors
            });
        }
    }

    errorsExist(errorsObjects) {
        let returnBool = false;
        errorsObjects.forEach(errorsObj => {
            if (Object.values(errorsObj).indexOf(true) > -1) returnBool = true;
        });
        return returnBool;
    }

    saveNewClient() {
        this.setState({ newClientAttempt: true });
        if (this.errorsExist([this.state.errors])) return;

        const { newClient } = this.state;
        const { adminDispatch } = this.props;
        adminDispatch.newClient(newClient);
        this.toggleNewClient();
    }

    render() {
        const { newClient, newClientBool } = this.state;
        const { theme, clients, hubs, client, adminDispatch } = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const newButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="New"
                    active
                    handleNext={this.toggleNewClient}
                    iconClass="fa-plus"
                />
            </div>);
        const newClientBox = (
            <div className={`flex-none layout-row layout-wrap layout-align-center-center ${styles.new_contact}`}>
                <div className={`flex-none layout-row layout-wrap layout-align-center-center ${styles.new_contact_backdrop}`} onClick={this.toggleNewClient}>
                </div>
                <div className={`flex-none layout-row layout-wrap layout-align-start-start ${styles.new_contact_content}`}>
                    <div className={` ${styles.contact_header} flex-100 layout-row layout-align-space-between-center`}>
                        <div className="flex-none layout-row layout-align-start-center">
                            <i className="fa fa-user flex-none clip" style={textStyle}></i>
                            <p className="flex-none">New Client</p>
                        </div>
                        <div className="flex-none layout-row layout-align-start-center" onClick={this.toggleNewClient}>
                            <i className="fa fa-times flex-none clip pointy" style={textStyle}></i>
                        </div>
                    </div>
                    <ValidatedInput
                        className={styles.input_100}
                        type="text"
                        value={newClient.companyName}
                        name={'companyName'}
                        placeholder="Company Name *"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_50}
                        type="text"
                        value={newClient.firstName}
                        name="firstName"
                        placeholder="First Name *"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_50}
                        type="text"
                        value={newClient.lastName}
                        name="lastName"
                        placeholder="Last Name *"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_50}
                        type="text"
                        value={newClient.email}
                        name="email"
                        placeholder="Email *"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations={{
                            minLength: 2,
                            matchRegexp: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                        }}
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long',
                            matchRegexp: 'Invalid email'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_50}
                        type="text"
                        value={newClient.phone}
                        name="phone"
                        placeholder="Phone *"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_street}
                        type="text"
                        value={newClient.street}
                        name="street"
                        placeholder="Street"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_no}
                        type="text"
                        value={newClient.number}
                        name="number"
                        placeholder="Number"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_zip}
                        type="text"
                        value={newClient.zipCode}
                        name="zipCode"
                        placeholder="Postal Code"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_cc}
                        type="text"
                        value={newClient.city}
                        name="city"
                        placeholder="City"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />
                    <ValidatedInput
                        className={styles.input_cc}
                        type="text"
                        value={newClient.country}
                        name="country"
                        placeholder="Country"
                        onChange={this.handleFormChange}
                        firstRenderInputs={!this.state.newClientAttempt}
                        validations="minLength:2"
                        validationErrors={{
                            isDefaultRequiredValue: 'Must not be blank',
                            minLength: 'Must be at least two characters long'
                        }}
                        required
                    />

                    <div className="flex-100 layout-row">
                        <div className="flex-50 layout-row layout-wrap">
                            <ValidatedInput
                                className={styles.input_100}
                                type="password"
                                value={newClient.password}
                                name={'password'}
                                placeholder="Password *"
                                onChange={this.handleFormChange}
                                firstRenderInputs={!this.state.newClientAttempt}
                                validations="minLength:8"
                                validationErrors={{
                                    isDefaultRequiredValue: 'Must not be blank',
                                    minLength: 'Must be at least 8 characters long'
                                }}
                                required
                            />
                        </div>
                        <div className="flex-50 layout-row layout-wrap">
                            <ValidatedInput
                                inputRef={(input) => { this.passwordConfirmationInput = input; }}
                                className={styles.input_100}
                                type="password"
                                value={newClient.password_confirmation}
                                name={'password_confirmation'}
                                placeholder="Password Confirmation *"
                                onChange={this.handleFormChange}
                                firstRenderInputs={!this.state.newClientAttempt}
                                validations={{ matchesPassword: (values, value) => {
                                    const client = this.tmpNewClient || newClient;
                                    return client.password === value;
                                }}}
                                validationErrors={{
                                    matchesPassword: 'Must match password',
                                    isDefaultRequiredValue: 'Must not be blank'
                                }}
                                required
                            />
                        </div>
                    </div>

                    <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
                        <RoundButton
                            theme={theme}
                            size="small"
                            active
                            text="Save"
                            handleNext={this.saveNewClient}
                            iconClass="fa-floppy-o"
                        />
                    </div>
                </div>
            </div>
        );
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Clients</p>
                    { newButton }
                </div>
                { newClientBool ? newClientBox  : ''}
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/clients"
                        render={props => <AdminClientsIndex theme={theme} handleClientAction={this.handleClientAction} clients={clients} hubs={hubs} adminDispatch={adminDispatch} viewClient={this.viewClient} {...props} />}
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
    const { authentication, tenant, admin } = state;
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

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminClients));
