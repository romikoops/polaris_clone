import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminScheduleLine, AdminHubTile } from './';
import { AdminSearchableRoutes } from './AdminSearchables';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
export class AdminHubView extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    componentDidMount() {
        const { hubData,  loading, adminActions, match } = this.props;
        if (!hubData && !loading) {
            adminActions.getHub(parseInt(match.params.id, 10), false);
        }
    }
    render() {
        const {theme, hubData, hubs, hubHash, adminActions} = this.props;
        // ;s
        if (!hubData) {
            return '';
        }
        const { hub, relatedHubs, routes, schedules} = hubData;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const relHubs = [];
        relatedHubs.forEach((hubObj) => {
            if (hubObj.id !== hub.id) {
                relHubs.push( <AdminHubTile key={v4()} hub={hubHash[hubObj.id]} theme={theme} handleClick={() => adminActions.getHub(hubObj.id, true)} />);
            }
        });


        const schedArr = schedules.map((sched) => {
            return <AdminScheduleLine key={v4()} schedule={sched} hubs={hubHash} theme={theme}/>;
        });
        console.log(hubs);
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>{hub.name}</p>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Related Hubs</p>
                    </div>
                    {relHubs}
                </div>
                <AdminSearchableRoutes routes={routes} theme={theme} hubs={hubs} adminDispatch={adminActions} sideScroll />
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Schedules </p>
                    </div>
                    {schedArr}
                </div>
            </div>
        );
    }
}
AdminHubView.propTypes = {
    theme: PropTypes.object,
    hubHash: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array,
    adminActions: PropTypes.object
};
