import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ChooseShipment } from '../../components/ChooseShipment/ChooseShipment';
import Header from '../../components/Header/Header';
import styles from './Shop.scss';
import { bindActionCreators } from 'redux';
import { ShopStageView } from '../../components/ShopStageView/ShopStageView';
import { ShipmentDetails } from '../../components/ShipmentDetails/ShipmentDetails';
import { ChooseRoute } from '../../components/ChooseRoute/ChooseRoute';
import { Loading } from '../../components/Loading/Loading';
import { BookingDetails } from '../../components/BookingDetails/BookingDetails';
import { BookingConfirmation } from '../../components/BookingConfirmation/BookingConfirmation';
import { connect } from 'react-redux';
import { SHIPMENT_TYPES, SHIPMENT_STAGES } from '../../constants';
import { shipmentActions } from '../../actions/shipment.actions';
import { Route } from 'react-router';
import { withRouter } from 'react-router-dom';
import { LoginRegistrationWrapper } from '../../components/LoginRegistrationWrapper/LoginRegistrationWrapper';
import { Modal } from '../../components/Modal/Modal';

import './Shop.scss';

class Shop extends Component {
    constructor(props) {
        super(props);

        this.tenant = this.props.tenant;

        this.state = {
            shipmentOptions: SHIPMENT_TYPES,
            shipmentStages: SHIPMENT_STAGES,
            shipment: this.props.shipment,
            stageTracker: {},
            shopType: 'Booking',
            contacts: {
                shipper: {},
                consignee: {},
                notifyees: []
            },
            showRegistration: false
        };
        this.selectShipmentType = this.selectShipmentType.bind(this);
        this.setShipmentData = this.setShipmentData.bind(this);
        this.selectShipmentRoute = this.selectShipmentRoute.bind(this);
        this.setShipmentContacts = this.setShipmentContacts.bind(this);
        this.selectShipmentStage = this.selectShipmentStage.bind(this);
        this.selectShipmentStageAndGo = this.selectShipmentStageAndGo.bind(this);
        this.toggleShowRegistration = this.toggleShowRegistration.bind(this);
        this.hideRegistration = this.hideRegistration.bind(this);
    }

    shouldComponentUpdate(nextProps) {
        const { loggingIn, registering, loading } = nextProps;
        return loading || !(loggingIn || registering);
    }

    getShipment(type) {
        const { shipmentDispatch } = this.props;
        shipmentDispatch.newShipment(type);
    }

    selectShipmentType(type) {
        this.getShipment(type);
    }

    selectShipmentStage(stage) {
        this.setState({ stageTracker: { stage: stage } });
    }
    selectShipmentStageAndGo(stage) {
        const { history, bookingData } = this.props;
        const activeId = bookingData.activeShipment;
        this.setState({ stageTracker: { stage: stage.step } });
        if (stage.step === 1) {
            history.push('/booking/');
        } else {
            history.push('/booking/' + activeId + stage.url);
        }
    }

    setShipmentData(data) {
        const { shipmentDispatch} = this.props;
        shipmentDispatch.setShipmentDetails(data);
        // this.setState({
        //     stageTracker: { shipmentType: data.shipment.load_type, stage: 2 }
        // });
    }

    setShipmentContacts(data) {
        const { shipmentDispatch } = this.props;
        shipmentDispatch.setShipmentContacts(data);
        // this.setState({
        //     stageTracker: { shipmentType: data.load_type, stage: 4 }
        // });
        // history.push('/booking/' + data.shipment.id + '/finish_booking');
    }

    toggleShowRegistration(req) {
        this.setState({
            showRegistration: !this.state.showRegistration,
            req: req
        });
    }

    hideRegistration() {
        this.setState({
            showRegistration: false,
        });
    }

    selectShipmentRoute(obj) {
        const { shipmentDispatch, bookingData } = this.props;
        const { schedule, total } = obj;
        const shipmentData = bookingData.response.stage2;
        const req = {
            schedules: [schedule],
            total,
            shipment: shipmentData.shipment
        };
        if (this.props.user.data.guest) {
            this.toggleShowRegistration(req);
            return;
        }
        console.log('Not Guest');
        shipmentDispatch.setShipmentRoute(req);
    }

    render() {
        // const loggedIn = this.props.loggedIn ? this.props.loggedIn : false;
        // const theme = this.props.tenant.theme;
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };

        const { bookingData, theme, match, loading, tenant, user, shipmentDispatch, currencies } = this.props;
        const { request, response, error } = bookingData;
        const route1 = match.url + '/:shipmentId/shipment_details';
        const route2 = match.url + '/:shipmentId/choose_route';
        const route3 = match.url + '/:shipmentId/booking_details';
        const route4 = match.url + '/:shipmentId/finish_booking';
        const loadingScreen = loading ? <Loading theme={theme} /> : '';
        let shipmentId = '';
        if (response && response.stage1 && !response.stage2) {
            shipmentId = response.stage1.shipment.id;
        } else if (response && response.stage1 && response.stage2 && !response.stage3) {
            shipmentId = response.stage2.shipment.id;
        } else if (response && response.stage1 && response.stage2 && response.stage3 && !response.stage4) {
            shipmentId = response.stage3.shipment.id;
        } else if (response && response.stage1 && response.stage2 && response.stage3 && response.stage4) {
            shipmentId = response.stage4.shipment.id;
        }
        // const loginModal = (
        //     <Modal
        //         component={
        //             <RegistrationPage theme={theme} req={this.state.req} user={this.props.user} tenant={this.props.tenant} />
        //         }
        //         parentToggle={this.toggleShowRegistration}
        //     />
        // );
        const { req } = this.state;
        const loginModal = (
            <Modal
                component={
                    <LoginRegistrationWrapper
                        LoginPageProps={{theme, req}}
                        RegistrationPageProps={{theme, tenant, req, user}}
                        initialCompName="RegistrationPage"
                    />
                }
                parentToggle={this.toggleShowRegistration}
            />
        );

        return (
            <div className="layout-row flex-100 layout-wrap">
                {loadingScreen}
                { this.state.showRegistration && !loading ? loginModal : '' }
                <Header theme={this.props.theme} />
                <ShopStageView
                    shopType={this.state.shopType}
                    match={match}
                    theme={theme}
                    stages={this.state.shipmentStages}
                    currentStage={this.state.stageTracker.stage}
                    setStage={this.selectShipmentStageAndGo}
                    shipmentId={shipmentId}
                />
                <Route
                    exact
                    path={match.url}
                    render={props => (
                        <ChooseShipment
                            {...props}
                            theme={theme}
                            shipmentTypes={this.state.shipmentOptions}
                            selectShipment={this.selectShipmentType}
                            setStage={this.selectShipmentStage}
                            messages={error ? error.stage1 : []}
                            shipmentDispatch={shipmentDispatch}
                        />
                    )}
                />
                <Route
                    path={route1}
                    render={props => (
                        <ShipmentDetails
                            {...props}
                            theme={theme}
                            shipmentData={response ? response.stage1 : {}}
                            prevRequest={
                                request && request.stage2 ? request.stage2 : {}
                            }
                            req={
                                request && request.stage1 ? request.stage1 : {}
                            }
                            setShipmentDetails={this.setShipmentData}
                            setStage={this.selectShipmentStage}
                            messages={error ? error.stage2 : []}
                            shipmentDispatch={shipmentDispatch}
                        />
                    )}
                />
                <Route
                    path={route2}
                    render={props => (
                        <ChooseRoute
                            {...props}
                            chooseRoute={this.selectShipmentRoute}
                            theme={theme}
                            shipmentData={
                                response && response.stage2
                                    ? response.stage2
                                    : {}
                            }
                            prevRequest={
                                request && request.stage3 ? request.stage3 : null
                            }
                            req={
                                request && request.stage2 ? request.stage2 : {}
                            }
                            user={user}
                            setStage={this.selectShipmentStage}
                            messages={error ? error.stage3 : []}
                            shipmentDispatch={shipmentDispatch}
                        />
                    )}
                />
                {response && response.stage3 ? (
                    <Route
                        path={route3}
                        render={props => (
                            <BookingDetails
                                {...props}
                                nextStage={this.setShipmentContacts}
                                theme={theme}
                                shipmentData={
                                    response && response.stage3
                                        ? response.stage3
                                        : {}
                                }
                                prevRequest={
                                    request && request.stage4
                                        ? request.stage4
                                        : null
                                }
                                currencies={currencies}
                                setStage={this.selectShipmentStage}
                                messages={error ? error.stage4 : []}
                                tenant={tenant}
                                user={user}
                                shipmentDispatch={shipmentDispatch}
                                hideRegistration={this.hideRegistration}
                            />
                        )}
                    />
                ) : (
                    ''
                )}
                <Route
                    path={route4}
                    render={props => (
                        <BookingConfirmation
                            {...props}
                            theme={theme}
                            tenant={tenant.data}
                            user={user}
                            shipmentData={response ? response.stage4 : {}}
                            setStage={this.selectShipmentStage}
                            shipmentDispatch={shipmentDispatch}
                        />
                    )}
                />
                <div className={`${styles.pre_footer_break} flex-100`}></div>
            </div>
        );
    }
}

Shop.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    bookingData: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

Shop.defaultProps = {
    stageTracker: {
        stage: 0,
        shipmentType: ''
    }
};

function mapStateToProps(state) {
    const { users, authentication, tenant, bookingData, app } = state;
    const { user, loggedIn, loggingIn, registering } = authentication;
    const { currencies } = app;
    const loading = bookingData.loading;
    return {
        user,
        users,
        tenant,
        loggedIn,
        bookingData,
        loggingIn,
        registering,
        loading,
        currencies
    };
}

function mapDispatchToProps(dispatch) {
    return {
        shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
    };
}
export default withRouter(connect(mapStateToProps, mapDispatchToProps)(Shop));
