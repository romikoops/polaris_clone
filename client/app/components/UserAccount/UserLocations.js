import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';
import defaults from '../../styles/default_classes.scss';
import { EditLocation } from './EditLocation';
import EditLocationWrapper from '../../hocs/EditLocationWrapper';
const LocationView = (locInfo, makePrimary, toggleActiveView) => [
    <div
        key="addLocationButton"
        className={`${defaults.pointy} flex-33`}
        onClick={() => toggleActiveView('editLocation')}
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
            <div key={op.user.id} className={'flex-33'}>
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
                            <span className={`${defaults.emulate_link}`}>
                                Edit
                            </span>
                            &nbsp; | &nbsp;
                            <span
                                className={`${defaults.emulate_link}`}
                                onClick={() =>
                                    this.props.destroyLocation(op.user.id)
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
    }

    componentDidMount() {
        this.props.setNav('locations');
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

    render() {
        const locInfo = this.props.locations;

        let activeView;
        switch (this.state.activeView) {
            case 'allLocations':
                activeView = locInfo
                    ? LocationView(
                          locInfo,
                          this.props.makePrimary,
                          this.toggleActiveView
                      )
                    : undefined;
                break;
            case 'addLocation':
                activeView = undefined;
                break;
            case 'editLocation':
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
