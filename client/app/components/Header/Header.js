import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import { NavDropdown } from '../NavDropdown/NavDropdown';
import styles from './Header.scss';
// import accountIcon from '../../assets/images/icons/person-dark.svg';
import defs from '../../styles/default_classes.scss';
import { Redirect } from 'react-router';
import { LoginRegistrationWrapper } from '../LoginRegistrationWrapper/LoginRegistrationWrapper';
import { Modal } from '../Modal/Modal';
import MessageCenter from '../../containers/MessageCenter/MessageCenter';
import { appActions, messagingActions } from '../../actions';
import { accountIconColor } from '../../helpers';
import { bindActionCreators } from 'redux';
const iconColourer = accountIconColor;
class Header extends Component {
    constructor(props) {
        super(props);
        this.state = {
            redirect: false,
            showLogin: false,
            showMessages: false
        };
        this.goHome = this.goHome.bind(this);
        this.toggleShowLogin = this.toggleShowLogin.bind(this);
        this.toggleShowMessages = this.toggleShowMessages.bind(this);
    }
    componentDidMount() {
        const { messageDispatch, messages } = this.props;
        if (!messages) {
            messageDispatch.getUserConversations();
        }
    }
    goHome() {
        this.setState({redirect: true});
    }
    toggleShowLogin() {
        this.setState({
            showLogin: !this.state.showLogin
        });
    }
    toggleShowMessages() {
        this.setState({
            showMessages: !this.state.showMessages
        });
    }
    render() {
        const { user, theme, tenant, currencies, appDispatch, invert, unread } = this.props;

        const dropDownText = user && user.data  ? user.data.first_name + ' ' + user.data.last_name : '';
        // const dropDownImage = accountIcon;
        const accountLinks = [
            {
                url: '/account',
                text: 'Account',
                fontAwesomeIcon: 'fa-cog',
                key: 'settings'
            },
            {
                url: '/signout',
                text: 'Sign out',
                fontAwesomeIcon: 'fa-sign-out',
                key: 'signOut'
            }
        ];
        const currLinks = currencies ? currencies.map((c) => {
            c.select = () => appDispatch.setCurrency(c.key);
            return c;
        }) : [];
        const adjIcon = iconColourer(invert ? '#FFFFFF' : '#000000');
        if (this.state.redirect) {
            return <Redirect push to="/" />;
        }
        const dropDown = (
            <NavDropdown
                dropDownText={dropDownText}
                dropDownImage={adjIcon}
                linkOptions={accountLinks}
                invert={invert}
            />
        );
        const currDropDown = (
            <NavDropdown
                dropDownText={user && user.data ? user.data.currency : ''}
                linkOptions={currLinks}
                invert={invert}
            />
        );
        const alertStyle = unread > 0 ? styles.unread : styles.all_read;
        const mail = (
            <div className={`flex-none layout-row layout-align-center-center ${styles.mail_box}`} onClick={this.toggleShowMessages}>
                <span className={`${alertStyle} flex-none`}>{unread}</span>
                <i className="fa fa-envelope-o"></i>
            </div>
        );
        let logoUrl = '';
        let logoStyle;
        if (theme && theme.logoWide) {
            logoUrl = theme.logoWide;
            logoStyle = styles.wide_logo;
        } else if (theme && theme.logoLarge) {
            logoUrl = theme.logoLarge;
            logoStyle = styles.logo;
        }
        const textColour = invert ? 'white' : 'black';
        const dropDowns = <div className="layout-row layout-align-space-around-center">{dropDown}{currDropDown}{mail}</div>;
        const loginPrompt = <a className={defs.pointy} style={{color: textColour}} onClick={this.toggleShowLogin}>Log in</a>;
        const rightCorner = user && user.data && !user.data.guest ? dropDowns : loginPrompt;
        const loginModal = (
            <Modal
                component={
                    <LoginRegistrationWrapper
                        LoginPageProps={{theme}}
                        RegistrationPageProps={{theme, tenant}}
                        initialCompName="LoginPage"
                    />
                }
                width="40vw"
                verticalPadding="60px"
                horizontalPadding="40px"
                parentToggle={this.toggleShowLogin}
            />
        );
        return (
            <div
                className={`${
                    styles.header
                } layout-row flex-100 layout-wrap layout-align-center`}
            >
                <div className="flex layout-row layout-align-start-center">
                    {this.props.menu}
                </div>
                <div className={`${defs.content_width} layout-row flex-none`}>
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img
                            src={logoUrl}
                            className={logoStyle}
                            alt=""
                            onClick={this.goHome}
                        />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        {rightCorner}
                    </div>
                </div>
                 <div className="flex layout-row layout-align-start-center">
                </div>
                { this.state.showLogin ? loginModal : '' }
                { this.state.showMessages ? <MessageCenter close={this.toggleShowMessages}/> : '' }
            </div>
        );
    }
}

Header.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

function mapStateToProps(state) {
    const { authentication, tenant, shipment, app, messaging } = state;
    const { user, loggedIn } = authentication;
    const { unread, messages } = messaging;
    const { currencies } = app;
    return {
        user,
        tenant,
        loggedIn,
        shipment,
        currencies,
        unread,
        messages
    };
}
function mapDispatchToProps(dispatch) {
    return {
        appDispatch: bindActionCreators(appActions, dispatch),
        messageDispatch: bindActionCreators(messagingActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(Header);
