import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';
import defaults from '../../styles/default_classes.scss';

export class UserLocations extends Component {
    constructor(props) {
        super(props);

        this.state = {
            showLocations: true,
            showAddLocationForm: false,
            showEditLocationForm: false
        };

        this.showLocations = this.showLocations.bind(this);
        this.showAddLocationForm = this.showAddLocationForm.bind(this);
        this.showEditLocation = this.showEditLocation.bind(this);
    }

    componentDidMount() {
        this.props.getLocations();
    }

    showLocations() {
        this.setState({
            showLocations: true,
            showAddLocationForm: false,
            showEditLocationForm: false
        });
    }

    showAddLocationForm() {
        this.setState({
            showLocations: false,
            showAddLocationForm: true,
            showEditLocationForm: false
        });
    }

    showEditLocation() {
        this.setState({
            showLocations: false,
            showAddLocationForm: false,
            showEditLocationForm: true
        });
    }

    render() {
        if (false) {
            this.showLocations();
            this.showAddLocationForm();
            this.showEditLocation();
        }
        const locInfo = this.props.locations;
        const locations = locInfo
            ? locInfo.map(op => {
                return (
                    <div key={op.id} className={'flex-33'}>
                        <div className={`${styles['location-box']}`}>
                            <div className={`${styles.header}`}>
                                {op.primary ? (
                                    <h3 className={`${styles.standard}`}>
                                          Primary
                                    </h3>
                                ) : (
                                    <div className="layout-row layout-wrap">
                                        <div className="layout-row flex-80">
                                            <h3 className={`${styles.other}`}>
                                                  Other
                                            </h3>
                                        </div>
                                        <div className="layout-row flex-20 layout-align-end">
                                            <div
                                                className={`${
                                                    styles.makePrimary
                                                } ${defaults.pointy}`}
                                                onClick={() =>
                                                    this.props.makePrimary(
                                                        op.id
                                                    )
                                                }
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
                                    <span
                                        className={`${defaults.emulate_link}`}
                                    >
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
            : '';

        return (
            <div className="layout-row flex-100 layout-wrap">
                <div className={`${defaults.pointy} flex-33`}>
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

                        {locations}
                    </div>
                </div>
            </div>
        );
    }
}

UserLocations.propTypes = {
    user: PropTypes.object
};
