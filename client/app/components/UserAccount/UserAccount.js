import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';

class UserProfile extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserProfile</h1>;
    }
}

class UserLocations extends Component {
    constructor(props) {
        super(props);

        console.log(this.props);
    }

    componentDidMount() {
        this.props.getLocations();
    }

    render() {
        const locInfo = this.props.locations;

        const locations = locInfo
            ? locInfo.map(op => {
                  return (
                      <div key={op.id} className={'flex-33'}>
                          <div className={`${styles['location-box']}`}>
                              <div className={`${styles.header}`}>
                                  {op.isPrimary ? (
                                      <h3 className={`${styles.standard}`}>
                                          Standard
                                      </h3>
                                  ) : (
                                      <h3 className={`${styles.other}`}>
                                          Other
                                      </h3>
                                  )}
                              </div>
                              <div className={`${styles.content}`}>
                                  {op.geocoded_address}
                              </div>
                              <div className={`${styles.footer}`}>
                                  <div className="layout-row layout-align-center-center">
                                      <span>Edit</span>
                                      &nbsp; | &nbsp;
                                      <span>Delete</span>
                                  </div>
                              </div>
                          </div>
                      </div>
                  );
              })
            : '';

        return (
            <div className="layout-row flex-100 layout-wrap">
                <div className={'flex-33'}>
                    <div
                        className={`${styles['location-box']} ${
                            styles['new-address']
                        } layout-row layout-align-center-center layout-wrap`}
                    >
                        <div className="layout-row layout-align-center flex-100">
                            <div className={`${styles['plus-icon']}`} />
                        </div>

                        <div className="layout-row layout-align-center flex-100">
                            <h3>Add address</h3>
                        </div>
                    </div>
                </div>

                {locations}
            </div>
        );
    }
}

class UserEmails extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserEmails</h1>;
    }
}

class UserPassword extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserPassword</h1>;
    }
}

class UserBilling extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        return <h1>UserBilling</h1>;
    }
}

export { UserProfile, UserLocations, UserEmails, UserPassword, UserBilling };

UserProfile.propTypes = {
    user: PropTypes.object
};

UserLocations.propTypes = {
    user: PropTypes.object
};

UserEmails.propTypes = {
    user: PropTypes.object
};

UserPassword.propTypes = {
    user: PropTypes.object
};

UserBilling.propTypes = {
    user: PropTypes.object
};
