import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { AdminHubTile } from '../';
import {v4} from 'node-uuid';
import Fuse from 'fuse.js';
import { MainTextHeading } from '../../TextHeadings/MainTextHeading';
export class AdminSearchableHubs extends Component {
    constructor(props) {
        super(props);
        this.state = {
            hubs: props.hubs
        };
        this.handleSearchChange = this.handleSearchChange.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.seeAll = this.seeAll.bind(this);
    }
    handleClick(hub) {
        const {handleClick, adminDispatch} = this.props;
        if (handleClick) {
            handleClick(hub);
        } else {
            adminDispatch.getHub(hub.id, true);
        }
    }
    seeAll() {
        const {seeAll, adminDispatch} = this.props;
        if (seeAll) {
            seeAll();
        } else {
            adminDispatch.goTo('/hubs');
        }
    }
    handleSearchChange(event) {
        if (event.target.value === '') {
            this.setState({
                hubs: this.props.hubs
            });
            return;
        }
        const search = (key) => {
            const options = {
                shouldSort: true,
                tokenize: true,
                threshold: 0.2,
                location: 0,
                distance: 50,
                maxPatternLength: 32,
                minMatchCharLength: 5,
                keys: [key]
            };
            const fuse = new Fuse(this.props.hubs, options);
            console.log(fuse);
            return fuse.search(event.target.value);
        };

        const filteredHubNames = search('data.name');
        // ;
        this.setState({
            hubs: filteredHubNames
        });
    }
    render() {
        const { theme, seeAll } = this.props;
        const { hubs } = this.state;
        let hubsArr;
        if (hubs) {
            hubsArr = hubs.map((hub) => {
                return  <AdminHubTile key={v4()} hub={hub} theme={theme}  handleClick={this.handleClick}/>;
            });
        }
        const viewType = this.props.sideScroll ?
            (<div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                    {hubsArr}
                </div>
            </div>) :
            (<div className="layout-row flex-100 layout-align-start-center ">
                <div className="layout-row flex-none layout-align-start-center layout-wrap">
                    {hubsArr}
                </div>
            </div>);
        return(
            <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`}>
                    <div className="flex-60 layput-row layout-align-start-center">
                        <MainTextHeading theme={theme} text="Hubs" />
                    </div>
                    <div className={`${styles.input_box} flex-40 layput-row layout-align-start-center`}>
                        <input
                            type="text"
                            name="search"
                            placeholder="Search hubs"
                            onChange={this.handleSearchChange}
                        />
                    </div>
                </div>
                {viewType}
                { seeAll !== false ?
                    <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-none layout-row layout-align-center-center" onClick={this.seeAll}>
                            <p className="flex-none">See all</p>
                        </div>
                    </div> :
                    ''}
            </div>
        );
    }
}
AdminSearchableHubs.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
