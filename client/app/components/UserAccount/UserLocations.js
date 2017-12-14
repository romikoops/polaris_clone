import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';
import defaults from '../../styles/default_classes.scss';
import { EditLocation } from './EditLocation';

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
            <div key={op.id} className={'flex-33'}>
                <div className={`${styles['location-box']}`}>
                    <div className={`${styles.header}`}>
                        {op.primary ? (
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
                                        onClick={() => makePrimary(op.id)}
                                    >
                                        Set as primary
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>
                    <div className={`${styles.content}`}>
                        {op.geocoded_address}
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
                                    this.props.destroyLocation(op.id)
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

        this.state = {
            // activeView: 'allLocations'
            activeView: 'editLocation'
        };

        this.toggleActiveView = this.toggleActiveView.bind(this);
    }

    componentDidMount() {
        this.props.getLocations();
    }

    toggleActiveView(key) {
        this.setState({
            activeView: key
        });
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
                    <EditLocation
                        theme={this.props.theme}
                        toggleActiveView={this.toggleActiveView}
                        locationId={undefined}
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
