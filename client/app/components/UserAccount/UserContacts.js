import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { UserContactsIndex, UserContactsView } from './';
import styles from './UserAccount.scss';
// import {v4} from 'node-uuid';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { userActions } from '../../actions';
class UserContacts extends Component {
     constructor(props) {
        super(props);
        this.state = {
            selectedContact: false,
            currentView: 'open'
        };
        this.viewContact = this.viewContact.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.handleClientAction = this.handleClientAction.bind(this);
    }
    viewContact(contact) {
        const { userDispatch } = this.props;
        userDispatch.getContact(contact.id, true);
        this.setState({selectedContact: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedContact: false});
        dispatch(history.push('/admin/contacts'));
    }
    handleClientAction(id, action) {
        const { userDispatch } = this.props;
        userDispatch.confirmShipment(id, action);
    }

    render() {
        const {selectedContact} = this.state;
        const {theme, contacts, hubs, contactData, userDispatch, loading} = this.props;
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
                    <h3 className={` ${styles.sec_title_text} flex-none clip`} style={textStyle} >Contacts</h3>
                    {selectedContact ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/account/contacts"
                        render={props => <UserContactsIndex theme={theme} loading={loading} handleClientAction={this.handleClientAction} contacts={contacts} hubs={hubs} userDispatch={userDispatch} viewContact={this.viewContact} {...props} />}
                    />
                    <Route
                        exact
                        path="/account/contacts/:id"
                        render={props => <UserContactsView theme={theme} loading={loading} hubs={hubs} handleClientAction={this.handleClientAction} userDispatch={userDispatch} contactData={contactData} {...props} />}
                    />
                </Switch>
            </div>
        );
    }
}
UserContacts.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    contacts: PropTypes.array
};
function mapStateToProps(state) {
    const {authentication, tenant, users } = state;
    const { user, loggedIn } = authentication;
    const { contactData, dashboard, hubs, loading } = users;
    const { contacts } = dashboard;

    return {
        user,
        tenant,
        loggedIn,
        contacts,
        hubs,
        contactData,
        loading
    };
}
function mapDispatchToProps(dispatch) {
    return {
        userDispatch: bindActionCreators(userActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(UserContacts);
