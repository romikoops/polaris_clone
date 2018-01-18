import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styled, { keyframes } from 'styled-components';
import styles from './FloatingMenu.scss';

export class FloatingMenu extends Component {
    constructor(props) {
        super(props);
        this.state = {
            expand: true
        };
        this.toggleMenu = this.toggleMenu.bind(this);
    }
    toggleMenu() {
        this.setState({expand: !this.state.expand});
    }

    render() {
        const {
            Comp,
            theme
        } = this.props;
        const rotateIcon = keyframes` 
               /* 0%, 100% {
                    font-size: 20px;

                }*/
                0% {
                    *{
                        font-size: 30px;
                        background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.secondary + ',' + theme.colors.brightSecondary + ')' : 'black'
                    }
                }
               /* 0% {
                    transform: rotateZ(360deg);
                    transform-origin: 50% 50%;
                    transform-style: preserve-3D;

                }*/
        `;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const Title = styled.div`
            letter-spacing: 3px;
        `;
        const AnimIcon = styled.div`
            :hover {animation: ${rotateIcon} 1.5s linear;}
            ${Title}:hover & {animation: ${rotateIcon} 1.5s linear;}
        `;
        const currentStyle = this.state.expand ? styles.open : styles.closed;
        const wrapperStyle = this.state.expand ? styles.wrapper_max : styles.wrapper_min;
        return (
            <div className={`flex-none layout-row layout-wrap layout-align-center-start ${styles.wrapper} ${wrapperStyle}`}>
                <Title className="flex-100 layout-row layout-align-start-center pointy" onClick={this.toggleMenu}>
                    <AnimIcon className={`flex-none layout-row layout-align-center-center ${styles.icon_circle}`}>
                        <i className="fa fa-bars flex-none clip" style={textStyle}/>
                    </AnimIcon>
                    <div className="flex layout-row layout-align-start-center">
                        <h4 className="flex-none no_m">MENU</h4>
                    </div>
                </Title>
                <div className={`flex-100 layout-row ${styles.menu_content} ${currentStyle}`}>
                    {Comp}
                </div>

            </div>
        );
    }
}

FloatingMenu.propTypes = {
    theme: PropTypes.object,
    navLinkInfo: PropTypes.array
};
