import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { AdminWizardHubs, AdminWizardServiceCharges, AdminWizardPricings, AdminWizardTrucking, AdminWizardFinished} from './';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../../RoundButton/RoundButton';
import { adminActions } from '../../../actions';
import { TextHeading } from '../../TextHeading/TextHeading';

// import {v4} from 'node-uuid';

class AdminWizard extends Component {
    constructor(props) {
        super(props);
        this.state = {
            stage: 1
        };
        this.start = this.start.bind(this);
    }
    nextStep() {
        this.setState({stage: this.state.stage + 1});
    }
    start() {
        this.props.adminDispatch.goTo('/admin/wizard/hubs');
    }
    uploadHubs() {

    }
    back() {
        history.goBack();
    }

    render() {
        const {theme, adminDispatch, wizard} = this.props;
        let newHubs = [];
        let newScs = [];
        if (wizard) {
            newHubs = wizard.newHubs;
            newScs = wizard.newScs;
        }
        const StartView = ({theme}) => {
            return ( <div className="layout-fill layout-row layout-align-center-center">
                <RoundButton
                    theme={theme}
                    size="small"
                    active
                    text="Begin"
                    handleNext={this.start}
                    iconClass="fa-magic"
                />
            </div>);
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                        <TextHeading theme={theme} size={1} text="Set Up Wizard" />
                    </div>
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                        <p>
                            <TextHeading theme={theme} size={3} text="WARNING: Your existing data might be overwritten!" warning />
                        </p>
                    </div>
                    <Switch className="flex">
                        <Route
                            exact
                            path="/admin/wizard"
                            render={props => <StartView theme={theme} {...props} />}
                        />
                        <Route
                            exact
                            path="/admin/wizard/hubs"
                            render={props => <AdminWizardHubs theme={theme} {...props} adminTools={adminDispatch} newHubs={newHubs}/>}
                        />
                        <Route
                            exact
                            path="/admin/wizard/service_charges"
                            render={props => <AdminWizardServiceCharges theme={theme} {...props} adminTools={adminDispatch} newScs={newScs}/>}
                        />
                        <Route
                            exact
                            path="/admin/wizard/pricings"
                            render={props => <AdminWizardPricings theme={theme} {...props} adminTools={adminDispatch} newScs={newScs}/>}
                        />
                        <Route
                            exact
                            path="/admin/wizard/trucking"
                            render={props => <AdminWizardTrucking theme={theme} {...props} adminTools={adminDispatch} newScs={newScs}/>}
                        />
                        <Route
                            exact
                            path="/admin/wizard/finished"
                            render={props => <AdminWizardFinished theme={theme} {...props} adminTools={adminDispatch} newScs={newScs}/>}
                        />
                    </Switch>
                </div>

            </div>
        );
    }
}
AdminWizard.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, hubs, wizard } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        wizard,
        clients
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminWizard);
