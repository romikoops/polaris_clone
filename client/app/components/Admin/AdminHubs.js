import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminHubsIndex, AdminHubView, AdminHubForm} from './';
import styles from './Admin.scss';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Switch, Route } from 'react-router-dom';
import { RoundButton } from '../RoundButton/RoundButton';
import { adminActions } from '../../actions';
import { TextHeading } from '../TextHeading/TextHeading';
import { adminHubs as tooltip } from '../../constants';
import { Tooltip } from '../Tooltip/Tooltip';
// import {v4} from 'node-uuid';
// import FileUploader from '../../components/FileUploader/FileUploader';
class AdminHubs extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedHub: false,
            currentView: 'open',
            newHub: false
        };
        this.viewHub = this.viewHub.bind(this);
        this.backToIndex = this.backToIndex.bind(this);
        this.toggleNewHub = this.toggleNewHub.bind(this);
        this.saveNewHub = this.saveNewHub.bind(this);
        this.closeModal = this.closeModal.bind(this);
    }
    componentDidMount() {
        const {hubs, adminDispatch, loading} = this.props;
        if (!hubs && ! loading) {
            adminDispatch.getHubs(false);
        }
    }
    viewHub(hub) {
        const { adminDispatch } = this.props;
        adminDispatch.getHub(hub.id, true);
        this.setState({selectedHub: true});
    }
    backToIndex() {
        const { dispatch, history } = this.props;
        this.setState({selectedHub: false});
        dispatch(history.push('/admin/hubs'));
    }
    toggleNewHub() {
        this.setState({newHub: !this.state.newHub});
    }
    closeModal() {
        this.setState({newHub: false});
    }
    saveNewHub(hub, location) {
        const { adminDispatch } = this.props;
        adminDispatch.saveNewHub(hub, location);
    }

    render() {
        const {selectedHub} = this.state;
        const {theme, hubs, hub, hubHash, adminDispatch} = this.props;
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
                    text="New Hub"
                    active
                    handleNext={this.toggleNewHub}
                    iconClass="fa-plus"
                />
            </div>);
        const title = selectedHub ?
            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                <div className="flex-none">
                    <TextHeading theme={theme} size={1} text="Hub Overview" />
                </div>
                <Tooltip icon="fa-info-circle" theme={theme} toolText={tooltip.overview} />
                {selectedHub ? backButton : ''}
            </div>
            : <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                <div className="flex-none">
                    <TextHeading theme={theme} size={1} text="Hubs" />
                </div>
                <Tooltip icon="fa-info-circle" theme={theme} toolText={tooltip.overview} />
                {newButton}
            </div>;
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                    {title}
                </div>
                { this.state.newHub ? <AdminHubForm theme={theme} close={this.closeModal} saveHub={this.saveNewHub}/> : ''}
                <Switch className="flex">
                    <Route
                        exact
                        path="/admin/hubs"
                        render={props => <AdminHubsIndex theme={theme} hubs={hubs} hubHash={hubHash} adminDispatch={adminDispatch} {...props} viewHub={this.viewHub} />}
                    />
                    <Route
                        exact
                        path="/admin/hubs/:id"
                        render={props => <AdminHubView theme={theme} hubs={hubs} hubHash={hubHash} hubData={hub} adminActions={adminDispatch} {...props} />}
                    />
                </Switch>
            </div>
        );
    }
}
AdminHubs.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};

function mapStateToProps(state) {
    const {authentication, tenant, admin } = state;
    const { user, loggedIn } = authentication;
    const { clients, hubs, hub } = admin;

    return {
        user,
        tenant,
        loggedIn,
        hubs,
        hub,
        clients
    };
}
function mapDispatchToProps(dispatch) {
    return {
        adminDispatch: bindActionCreators(adminActions, dispatch)
    };
}

export default connect(mapStateToProps, mapDispatchToProps)(AdminHubs);
