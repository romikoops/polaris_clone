import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';
import defaults from '../../styles/default_classes.scss';
import { EditLocation } from './EditLocation';
import EditLocationWrapper from '../../hocs/EditLocationWrapper';
import { v4 } from 'node-uuid';
const LocationView = (locInfo, makePrimary, toggleActiveView, destroyLocation, editLocation) => [
    <div
        key="addLocationButton"
        className={`${defaults.pointy} flex-33`}
        onClick={() => toggleActiveView('newLocation')}
    >
        <div
            className={`${styles['location-box']} ${
                styles['new-address']
            } layout-row layout-align-center-center layout-wrap`}
        >
            <div className="layout-row layout-align-center flex-100">
                <div className={`${styles['plus-icon']}`} />
            </div>

            <div className="layout-row layout-align-center flex-100">
                <h3>Add location</h3>
            </div>
        </div>
    </div>,
    locInfo.map(op => {
        return (
            <div key={v4()} className={'flex-33'}>
                <div className={`${styles['location-box']}`}>
                    <div className={`${styles.header}`}>
                        {op.user.primary ? (
                            <h3 className={`${styles.standard}`}>Primary</h3>
                        ) : (
                            <div className="layout-row layout-wrap">
                                <div className="layout-row flex-80">
                                    <h3 className={`${styles.other}`}>Other</h3>
                                </div>
                                <div className="layout-row flex-20 layout-align-end">
                                    <div
                                        className={`${styles.makePrimary} ${
                                            defaults.pointy
                                        }`}
                                        onClick={() => makePrimary(op.location.id)}
                                    >
                                        Set as primary
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                    <div className={`${styles.content} layout-row layout-wrap layout-align-start-start`}>
                        <p className="flex-100">{op.location.street_number} {op.location.street} </p>
                        <p className="flex-100">{op.location.city} </p>
                        <p className="flex-100">{op.location.zip_code} </p>
                        <p className="flex-100">{op.location.country} </p>
                    </div>
                    <div className={`${styles.footer}`}>
                        <div className="layout-row layout-align-center-center">
                            <span className={`${defaults.emulate_link}`} onClick={() => editLocation(op.location)}>
                                Edit
                            </span>
                            &nbsp; | &nbsp;
                            <span
                                className={`${defaults.emulate_link}`}
                                onClick={() =>
                                    destroyLocation(op.location.id)
                                }
                            >
                                Delete
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        );
    })
];

export class UserLocations extends Component {
    constructor(props) {
        super(props);
        console.log(props);
        this.state = {
            activeView: 'allLocations'
            // activeView: 'editLocation'
        };
        this.saveLocation = this.saveLocation.bind(this);
        this.toggleActiveView = this.toggleActiveView.bind(this);
        this.destroyLocation = this.destroyLocation.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.editLocation = this.editLocation.bind(this);
        this.saveLocationEdit = this.saveLocationEdit.bind(this);
    }

    componentDidMount() {
        this.props.setNav('locations');
    }

    destroyLocation(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.destroyLocation(user.id, locationId, false);
    }

    saveLocationEdit(location) {
        const { userDispatch, user } = this.props;
        userDispatch.editUserLocation(user.id, location);
        this.setState({activeView: 'allLocations'});
    }

    editLocation(location) {
        this.setState({
            activeView: 'editLocation',
            editLocation: location
        });
    }

    toggleActiveView(key) {
        this.setState({
            activeView: key
        });
    }
    saveLocation(data) {
        const { userDispatch, user } = this.props;
        userDispatch.newUserLocation(user.id, data);
        this.toggleActiveView();
    }

    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.id, locationId);
    }

    render() {
        const locInfo = this.props.locations;

        let activeView;
        switch (this.state.activeView) {
            case 'allLocations':
                activeView = locInfo
                    ? LocationView(
                        locInfo,
                        this.makePrimary,
                        this.toggleActiveView,
                        this.destroyLocation,
                        this.editLocation
                    )
                    : undefined;
                break;
            case 'addLocation':
                activeView = undefined;
                break;
            case 'newLocation':
                activeView = (
                    <EditLocationWrapper
                        theme={this.props.theme}
                        component={EditLocation}
                        toggleActiveView={this.toggleActiveView}
                        locationId={undefined}
                        saveLocation={this.saveLocation}
                    />
                );
                break;
            case 'editLocation':
                activeView = (
                    <EditLocationWrapper
                        theme={this.props.theme}
                        component={EditLocation}
                        toggleActiveView={this.toggleActiveView}
                        locationId={undefined}
                        location={this.state.editLocation}
                        saveLocation={this.saveLocationEdit}
                    />
                );
                break;
            default:
                activeView = LocationView(locInfo);
        }

        return (
            <div className="layout-row flex-100 layout-wrap">{activeView}</div>
        );
    }
}

UserLocations.propTypes = {
    user: PropTypes.object
};
