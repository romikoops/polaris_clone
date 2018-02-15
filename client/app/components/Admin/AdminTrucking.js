import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminTruckingIndex, AdminTruckingView, AdminTruckingCreator} from './';
import styles from './Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
import { gradientTextGenerator } from '../../helpers';
class AdminTrucking extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedRoute: false,
            currentView: 'open',
            creatorView: false
        };
        this.viewTrucking = this.viewTrucking.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.toggleCreator = this.toggleCreator.bind(this);
    }
    viewTrucking(hub) {
        const { adminDispatch, trucking } = this.props;
        const {truckingHubs, truckingPrices} = trucking;
        const hubTable = truckingHubs.filter(th => th._id === String(hub.id))[0];
        const pricing = truckingPrices[hubTable._id];
        adminDispatch.viewTrucking(hubTable, pricing);
        this.setState({selectedRoute: true});
    }
    toggleCreator() {
        this.setState({creatorView: !this.state.creatorView});
    }
    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedRoute: false});
        dispatch(history.push('/admin/routes'));
    }

    render() {
        const {selectedRoute, creatorView} = this.state;
        const {theme, adminDispatch, trucking, hubHash, loading, truckingDetail} = this.props;
        if (!trucking) {
            return '';
        }
        const { truckingHubs, nexuses } = trucking;
        const relHubs = truckingHubs.map(th => {
            return hubHash[parseInt(th._id, 10)];
        });
        const textStyle =  theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
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
        const newButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="New"
                    active
                    handleNext={this.toggleCreator}
                    iconClass="fa-plus-circle-o"
                />
            </div>);
        const title = selectedRoute ? 'Trucking Overview' : 'Trucking';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >{title}</p>
                    {selectedRoute ? backButton : newButton}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/trucking"
                        render={props => <AdminTruckingIndex theme={theme} nexuses={nexuses} truckingHubs={truckingHubs} hubs={relHubs} {...props} adminDispatch={adminDispatch} loading={loading} viewTrucking={this.viewTrucking} />}
                    />
                    <Route
                        exact
                        path="/admin/trucking/:id"
                        render={props => <AdminTruckingView theme={theme} hubs={relHubs} hubHash={hubHash} truckingDetail={truckingDetail} loading={loading} adminDispatch={adminDispatch} {...props} />}
                    />
                </Switch>
                {creatorView ? <AdminTruckingCreator theme={theme} nexuses={nexuses} adminDispatch={adminDispatch} closeForm={this.toggleCreator} /> : '' }
            </div>
        );
    }
}
AdminTrucking.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { hubs, trucking, truckingDetail, loading } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        trucking,
        loading,
        truckingDetail
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminTrucking);
