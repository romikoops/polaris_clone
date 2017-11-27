import './LandingTopAuthed.scss';
import React, { Component } from 'react';
import PropTypes            from 'prop-types';
import { CardLinkRow }      from '../CardLinkRow/CardLinkRow';
import Header               from '../Header/Header';

export class LandingTopAuthed extends Component {
    constructor(props) {
        super(props);
        this.state = {
            shops: [
                {
                    name: 'Open Shop',
                    url: '/open',
                    img: 'https://assets.itsmycargo.com/assets/images/welcome/country/performance.jpg'
                },
                {
                    name: 'Dedicated Shop',
                    url: '/dedicated',
                    img: 'https://assets.itsmycargo.com/assets/images/welcome/country/shipping-containers.jpg'
                }
            ]
        };
    }
    render() {
        const {user, theme} = this.props;
        return (
            <div className="landing_top_authed layout-wrap layout-row flex-100 layout-align-center">
            <Header user={user} theme={theme} />
            <div className="layout-row flex-none layout-wrap content-width">
                <div className="flex-100 layout-wrap layout-row">
                    <h3>Choose your shop</h3>
                    <CardLinkRow theme={theme} cardArray={this.state.shops} />
                </div>
            </div>
            </div>
        );
    }
}

LandingTopAuthed.propTypes = {
    theme: PropTypes.object,
    user: PropTypes.object
};
