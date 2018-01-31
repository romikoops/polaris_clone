import React, {Component} from 'react';
import {LandingTop} from '../../components/LandingTop/LandingTop';
// import {LandingTopAuthed} from '../../components/LandingTopAuthed/LandingTopAuthed';
import {ActiveRoutes} from '../../components/ActiveRoutes/ActiveRoutes';
import {BlogPostHighlights} from '../../components/BlogPostHighlights/BlogPostHighlights';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import styles from './Landing.scss';
// import defaults from '../../styles/default_classes.scss';
import { RoundButton } from '../../components/RoundButton/RoundButton';
import Loading from '../../components/Loading/Loading';
import { withRouter } from 'react-router-dom';
import { bindActionCreators } from 'redux';
import { userActions, adminActions, authenticationActions } from '../../actions';
import { LoginRegistrationWrapper } from '../../components/LoginRegistrationWrapper/LoginRegistrationWrapper';
import { Modal } from '../../components/Modal/Modal';

class Landing extends Component {
    constructor(props) {
        super(props);
        this.state = {
            showCarousel: false,
            showLogin: false
        };
        this.showCarousel = this.showCarousel.bind(this);
        this.toggleShowLogin = this.toggleShowLogin.bind(this);
    }
    componentDidMount() {
        this.showCarousel();
    }
    shouldComponentUpdate(nextProps) {
        const { loggingIn, registering, loading } = nextProps;
        // ;
        return loading || !(loggingIn || registering);
    }

    showCarousel() {
        this.setState({showCarousel: true});
    }

    toggleShowLogin() {
        this.setState({
            showLogin: !this.state.showLogin
        });
    }

    render() {
        const { loggedIn, theme, user, tenant, userDispatch, authDispatch, adminDispatch } = this.props;
        const { showCarousel } = this.state;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const loadingScreen = this.props.loading ? <Loading theme={theme} /> : '';
        // const loadingScreen = <Loading theme={theme} />;
        const loginModal = (
            <Modal
                component={
                    <LoginRegistrationWrapper
                        LoginPageProps={{theme}}
                        RegistrationPageProps={{theme, tenant}}
                        initialCompName="RegistrationPage"
                    />
                }
                width="40vw"
                verticalPadding="60px"
                horizontalPadding="40px"
                parentToggle={this.toggleShowLogin}
            />
        );
        return (
            <div className={styles.wrapper_landing + ' layout-row flex-100 layout-wrap'} >
                {loadingScreen}
                { this.state.showLogin ? loginModal : '' }
                <LandingTop className="flex-100" user={user} theme={theme} goTo={userDispatch.goTo} toAdmin={adminDispatch.getDashboard} loggedIn={loggedIn} tenant={tenant} authDispatch={authDispatch} />
                <div className={styles.service_box + ' layout-row flex-100 layout-wrap'}>
                    <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>
                        <h2 className="flex-none"> Introducing Online Freight Booking Services  {this.props.loggedIn}
                        </h2>
                    </div>
                    <div className={styles.services_row + ' flex-100 layout-row layout-align-center'}>
                        <div className="layout-row flex-100 flex-gt-sm-80 card layout-align-space-between-center">
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-bolt" aria-hidden="true" style={textStyle}></i>
                                <h3> Instant Booking </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-edit" aria-hidden="true" style={textStyle}></i>
                                <h3> Real Time Quotes </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-binoculars" aria-hidden="true" style={textStyle}></i>
                                <h3>Transparent </h3>
                            </div>
                            <div className={'flex-none layout-column layout-align-center-center ' + styles.service}>
                                <i className="fa fa-clock-o" aria-hidden="true" style={textStyle}></i>
                                <h3>Updates in Real Time </h3>
                            </div>
                        </div>
                    </div>
                </div>
                {showCarousel ? <ActiveRoutes className={styles.mc} theme={theme} /> : ''}
                <BlogPostHighlights theme={theme} />
                <div className={styles.btm_promo + ' flex-100 layout-row'}>
                    <div className={'flex-50 ' + styles.btm_promo_img}>
                    </div>
                    <div className={styles.btm_promo_text + ' flex-50 layout-row layout-align-start-center'}>
                        <div className="flex-80 layout-column">
                            <div className="flex-20 layout-column layout-align-center-start">
                                <h2> Enjoy the most advanced and easy to use booking system on the planet </h2>
                            </div>
                            <div className="flex-40 layout-column layout-align-center-start">
                                <div className="flex layout-row layout-align-start-center">
                                    <i className="fa fa-check"> </i>
                                    <p> Instant Booking </p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <i className="fa fa-check"> </i>
                                    <p> Price Comparison </p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <i className="fa fa-check"> </i>
                                    <p> Fastest Routes </p>
                                </div>
                                <div className="flex layout-row layout-align-start-center">
                                    <i className="fa fa-check"> </i>
                                    <p> Real Time Updates </p>
                                </div>
                            </div>
                            <div className={styles.btm_promo_btn_wrapper + ' flex-20 layout-column layout-align-start-left'}>
                                <RoundButton text="Sign Up" theme={theme} active handleNext={this.toggleShowLogin}/>
                            </div>
                        </div>
                    </div>
                </div>

            </div>


        );
    }
}

Landing.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool
};

function mapDispatchToProps(dispatch) {
    return {
        userDispatch: bindActionCreators(userActions, dispatch),
        adminDispatch: bindActionCreators(adminActions, dispatch),
        authDispatch: bindActionCreators(authenticationActions, dispatch)
    };
}
function mapStateToProps(state) {
    const { users, authentication, tenant } = state;
    const { user, loggedIn, loggingIn, registering, loading } = authentication;
    return {
        user,
        users,
        tenant,
        loggedIn,
        loggingIn,
        registering,
        loading
    };
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Landing));
