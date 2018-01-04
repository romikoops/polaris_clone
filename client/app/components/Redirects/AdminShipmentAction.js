import React, { Component } from 'react';
import { LoginPage } from '../../containers/LoginPage/LoginPage';
import { Modal } from '../../components/Modal/Modal';
import { bindActionCreators } from 'redux';
import { adminActions } from '../../actions';
import { withRouter } from 'react-router-dom';
import { connect } from 'react-redux';

class AdminShipmentAction extends Component {
    constructor(props) {
        super(props);
        this.state = {
            showLogin: false
        };
        this.handleAction = this.handleAction.bind(this);
        this.toggleShowLogin = this.toggleShowLogin.bind(this);
    }
    componentDidMount() {
        const { user, loggedIn, adminDispatch } = this.props;
        if (!user || !loggedIn || user.data.guest) {
            this.toggleShowLogin();
        } else if (user && user.data.role_id === 2) {
            adminDispatch.goTo('/');
        } else {
            this.handleAction();
        }
    }
    componentDidUpdate() {
        const { user, loggedIn } = this.props;
        if (user && loggedIn && user.data.role_id === 1) {
            this.handleAction();
        }
    }
    handleAction() {
        const { match, location, adminDispatch } = this.props;
        const uuid = match.params.uuid;
        const query = new URLSearchParams(location.search);
        const action = query.get('action');
        if (action === 'edit') {
            adminDispatch.getShipment(uuid, true);
        } else {
            adminDispatch.confirmShipment(uuid, action, true);
        }
    }
    toggleShowLogin() {
        this.setState({
            showLogin: !this.state.showLogin
        });
    }
    render() {
        const { theme, loading } = this.props;
        const loginModal = (
            <Modal
                component={
                    <LoginPage
                        theme={theme}
                        noRedirect={true}
                    />
                }
                parentToggle={this.toggleShowLogin}
            />
        );
        return(


            <div className="layout-fill">
                { this.state.showLogin && !loading ? loginModal : '' }
            </div>
        );
    }
}


function mapStateToProps(state) {
    const { authentication, tenant} = state;
    const { user, loggedIn } = authentication;
    return {
        user,
        tenant,
        theme: tenant.data.theme,
        loggedIn
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(AdminShipmentAction));
