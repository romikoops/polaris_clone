import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminScheduleLine, AdminHubTile } from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
export class AdminRouteView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            scheduleLimit: 20
        };
    }
    render() {
        const {theme, routeData, hubHash, adminActions} = this.props;
        // debugger;s
        if (!routeData) {
            return '';
        }
        const { route, startHubs, endHubs, hubRoutes, schedules} = routeData;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };

        const startHubArr = startHubs.map((hubObj) => {
            return (<AdminHubTile key={v4()} hub={hubHash[hubObj.id]} theme={theme} handleClick={() => adminActions.getHub(hubObj.id, true)} />);
        });
        const endHubArr = endHubs.map((hubObj) => {
            return (<AdminHubTile key={v4()} hub={hubHash[hubObj.id]} theme={theme} handleClick={() => adminActions.getHub(hubObj.id, true)} />);
        });
        const HubRouteRow = ({hubRoute, hHash}) => {
            return (
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-33 layout-row layout-align-start-center">
                        <p className="flex-none">{hHash[hubRoute.starthub_id].data.name}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-start-center">
                        <p className="flex-none">{hHash[hubRoute.endhub_id].data.name}</p>
                    </div>
                    <div className="flex-33 layout-row layout-align-start-center">
                        <p className="flex-none">{hubRoute.mode_of_transport}</p>
                    </div>
                </div>
            );
        };
        const hubRoutesArr = hubRoutes.map((hr) => {
            return <HubRouteRow hubRoute={hr} hHash={hubHash} />;
        });
        // const routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={() => adminActions.getRoute(rt.id, true)}/>);
        console.log(hubRoutes);
        const schedArr = schedules.map((sched, i) => {
            if (i <= this.state.scheduleLimit) {
                return <AdminScheduleLine key={v4()} schedule={sched} hubs={hubHash} theme={theme}/>;
            }
            return '';
        });

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>{route.name}</p>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Related Hubs</p>
                    </div>
                    <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                        {startHubArr}
                    </div>
                    <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                        {endHubArr}
                    </div>

                </div>
               {/* <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Service Charges </p>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-around-start">
                        <div className="flex-45 layout-row layout-wrap layout-align-center-start">
                            {exportArr}
                        </div>
                        <div className="flex-45 layout-row layout-wrap layout-align-center-start">
                            {importArr}
                        </div>
                    </div>
                </div>*/}
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Routes </p>
                    </div>
                    {hubRoutesArr}
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
AdminRouteView.propTypes = {
    theme: PropTypes.object,
    hubHash: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array,
    adminActions: PropTypes.object
};
