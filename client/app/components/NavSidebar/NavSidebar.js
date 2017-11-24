import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './NavSidebar.scss';
import Style from 'style-it';

export class NavSidebar extends Component {
    constructor(props) {
        super(props);

        this.state = {
            activeLink: 'profile'
        };

        this.toggleActiveClass = this.toggleActiveClass.bind(this);
    }

    toggleActiveClass(key) {
        this.setState({ activeLink: key });
    }

    render() {
        const navLinks = this.props.navLinkInfo.map(op => {
            return (
                <div
                    key={op.key}
                    className={[
                        styles['menu-item'],
                        op.key === this.state.activeLink ? 'active' : null
                    ].join(' ')}
                    onClick={() => this.toggleActiveClass(op.key)}
                >
                    {op.text}
                </div>
            );
        });

        return (
            <div>
                <Style>
                    {`
                        .active::before {
                            position: absolute;
                            top: 0;
                            bottom: 0;
                            left: 0;
                            width: 2px;
                            content: '';
                            background-color: ${
                                this.props.theme.colors.primary
                            };
                         }
                    `}
                </Style>

                <nav className={styles.menu}>
                    <h3 className={styles['menu-heading']}>Account Settings</h3>
                    {navLinks}
                </nav>
            </div>
        );
    }
}

NavSidebar.propTypes = {
    theme: PropTypes.object,
    navLinkInfo: PropTypes.array
};
