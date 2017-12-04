import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {v4} from 'node-uuid';
// import { CSSTransitionGroup } from 'react-transition-group';
import styled, { keyframes } from 'styled-components';
import styles from './Loading.scss';
export class Loading extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { theme } = this.props;
        const logo = theme && theme.logoLarge ? theme.logoLarge : '';
        const kfLogo = keyframes` 
                0% {
                  transform: rotateY(0deg);
                  content:url(${logo});
                }
                50% {
                  transform: rotateY(360deg);
                  content:url('https://assets.itsmycargo.com/assets/logos/logo_box.png');
                }
        `;
        const kfDot = keyframes`
                0%, 100% {
                  height: 10px;
                  width: 10px;
                  background: ${theme.colors.primary};
                }
                50% {
                  height: 20px;
                  width: 20px;
                  background: ${theme.colors.secondary};
                }
        `;
        // const Logo = () => {
        //     return <img src={logo} alt="" className={`flex-none ${styles.logo}`}/>;
        // };
        // const FlipLogo = styled(Logo)`
        //     animation: ${kfLogo} 2s linear infinite;
        // `;
        const FlipLogo = styled.img`
            animation: ${kfLogo} 10s linear infinite;
            height: 150px;
            width: 150px;
            -webkit-box-flex: 0;
            -webkit-flex: 0 0 auto;
            flex: 0 0 auto;
            box-sizing: border-box;
        `;
        const AnimDot = styled.div`
            animation: ${kfDot} 2s linear infinite;
            animation-delay: ${props => props.delay ? props.delay + 's' : 0};
            background-color: theme && theme.colors ? theme.colors.primary : 'darkslategrey';
            border-radius: 50%;
            height: 15px;
            width: 15px;
            -webkit-box-flex: 0;
            -webkit-flex: 0 0 auto;
            flex: 0 0 auto;
            box-sizing: border-box;
        `;
        const dots = [];
        for (let i = 3; i >= 0; i--) {
            dots.push(<AnimDot key={v4()} delay={i}/>);
        }

        // const logoFlipStyle = {
        //     animationName: 'spin_logo',
        //     animationDuration: '2s',
        //     animationIterationCount: 'infinte'
        // };

        return (
            <div
                className={`layout-row layout-align-center-center ${styles.loader_box}`}
            >
                {/* <CSSTransitionGroup
                    transitionName="loader_anim"
                    transitionAppear
                    transitionAppearTimeout={500}
                    transitionEnterTimeout={750}
                    transitionLeaveTimeout={750}
                > */}
                    <div
                        className={`layout-column layout-align-center-center ${
                            styles.loader
                        }`}
                    >
                        {/* <img src={logo} alt="" className={`flex-none ${styles.logo}`} style={logoFlipStyle}/> */}
                        <FlipLogo />
                        <div className={`flex-none layout-row layout-align-space-between-center ${styles.dot_row}`}>
                            {dots}
                            {/* <div className={`${styles.dot1} flex-none`} style={dotStyle}></div>
                            <div className={`${styles.dot2} flex-none`} style={dotStyle}></div>
                            <div className={`${styles.dot3} flex-none`} style={dotStyle}></div> */}
                        </div>

                    </div>
                {/* </CSSTransitionGroup> */}
            </div>
        );
    }
}

Loading.propTypes = {
    theme: PropTypes.object,
    text: PropTypes.string

};
