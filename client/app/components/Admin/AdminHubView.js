import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminScheduleLine, AdminHubTile, AdminRouteTile, AdminChargePanel} from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
export class AdminHubView extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubData, hubs, hubHash, adminActions} = this.props;
        // debugger;s
        if (!hubData) {
            return '';
        }
        const { hub, relatedHubs, routes, schedules, serviceCharges} = hubData;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const relHubs = [];
        relatedHubs.forEach((hubObj) => {
            if (hubObj.id !== hub.id) {
              relHubs.push( <AdminHubTile key={v4()} hub={hubHash[hubObj.id]} theme={theme} handleClick={() => adminActions.getHub(hubObj.id, true)} />);
            }
        });

        const routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={() => adminActions.getRoute(rt.id, true)}/>);
        console.log(routes);
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
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Service Charges </p>
                    </div>
                    <AdminChargePanel key={v4()} hub={hubHash[hub.id]} theme={theme} charge={serviceCharges} />
                </div>
                 <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Routes </p>
                    </div>
                    {routesArr}
                </div>
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
