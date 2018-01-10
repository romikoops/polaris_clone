import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminTruckingIndex, AdminTruckingView} from './';
import styles from './Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminTrucking extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedRoute: false,
            currentView: 'open'
        };
        this.viewTrucking = this.viewTrucking.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
    }
    viewTrucking(hub) {
        const { adminDispatch, trucking } = this.props;
        const {truckingHubs, truckingPrices} = trucking;
        const hubTable = truckingHubs.filter(th => th._id === String(hub.id))[0];
        const pricing = truckingPrices[hubTable._id];
        adminDispatch.viewTrucking(hubTable, pricing);
        this.setState({selectedRoute: true});
    }

    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedRoute: false});
        dispatch(history.push('/admin/routes'));
    }

    render() {
        const {selectedRoute} = this.state;
        const {theme, adminDispatch, trucking, hubHash, loading, truckingDetail} = this.props;
        if (!trucking) {
            return '';
        }
        const { truckingHubs } = trucking;
        const relHubs = truckingHubs.map(th => {
            return hubHash[parseInt(th._id, 10)];
        });
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
        const title = selectedRoute ? 'Trucking Overview' : 'Trucking';
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle} >{title}</p>
                    {selectedRoute ? backButton : ''}
                </div>
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/trucking"
                        render={props => <AdminTruckingIndex theme={theme} truckingHubs={truckingHubs} hubs={relHubs} {...props} adminDispatch={adminDispatch} loading={loading} viewTrucking={this.viewTrucking} />}
                    />
                    <Route
                        exact
                        path="/admin/trucking/:id"
                        render={props => <AdminTruckingView theme={theme} hubs={relHubs} hubHash={hubHash} truckingDetail={truckingDetail} loading={loading} adminDispatch={adminDispatch} {...props} />}
                    />
                </Switch>
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
