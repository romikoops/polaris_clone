import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AdminClientTile.scss';
export class AdminClientTile extends Component {
    constructor(props) {
        super(props);
        this.handleLink = this.handleLink.bind(this);
        this.clickEv = this.clickEv.bind(this);
    }
    handleLink() {
        const {target, navFn} = this.props;
        console.log('NAV ' + target);
        navFn(target);
    }
    clickEv() {
        const {handleClick, client } = this.props;
        if (handleClick) {
            handleClick(client);
        }
    }
    render() {
        const { theme, client} = this.props;
        if (!client) {
            return '';
        }
        const gradientStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${
                        theme.colors.secondary
                    })`
                    : 'black'
        };
        return(
            <div className={`flex-none ${styles.client_card} layout-row pointy`} onClick={this.clickEv}>
                <div className={`${styles.content} flex-100 layout-row layout-align-center-start`}>
                    <div className="flex-95 layout-row layout-wrap layout-align-start-start">
                        <div className={`flex-100 layout-row layout-align-space-around-center ${styles.client_subheader}`}>
                            <i className="flex-none fa fa-user" style={gradientStyle}/>
                            <p className="flex-90">Name</p>
                        </div>
                        <div className={`flex-100 layout-row layout-align-start-center ${styles.client_text}`}>
                            <h4 className="flex-90 flex-offset-10"> {client.first_name} {client.last_name} </h4>
                        </div>
                        <div className={`flex-100 layout-row layout-align-space-around-center ${styles.client_subheader}`}>
                            <i className="flex-none fa fa-envelope" style={gradientStyle}/>
                            <p className="flex-90">Email</p>
                        </div>
                        <div className={`flex-100 layout-row layout-align-start-center ${styles.client_text}`}>
                            <p className="flex-90 flex-offset-10">{ client.email }</p>
                        </div>
                        <div className={`flex-100 layout-row layout-align-space-around-center ${styles.client_subheader}`}>
                            <i className="flex-none fa fa-building" style={gradientStyle}/>
                            <p className="flex-90">Company</p>
                        </div>
                        <div className={`flex-100 layout-row layout-align-start-center ${styles.client_text}`}>
                            <p className="flex-90 flex-offset-10">{ client.company_name }</p>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
AdminClientTile.propTypes = {
    theme: PropTypes.object,
    client: PropTypes.object,
    navFn: PropTypes.func,
    handleClick: PropTypes.func
};
