import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './RouteOption.scss';
import Style from 'style-it';
import { moment } from '../../constants';

export class RouteOption extends Component {
    constructor(props) {
        super(props);
        this.choose = this.choose.bind(this);
    }
    choose() {
        this.props.selectOption(this.props.route);
    }

    render() {
        const { theme, isPrivate, route } = this.props;
        const iconStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(left, ' +
                      theme.colors.primary +
                      ',' +
                      theme.colors.secondary +
                      ')'
                    : 'black'
        };

        return (
            <div
                className={`option flex-gt-sm-30 flex-100 layout-row layout-wrap layout-align-space-between-center b_border ${
                    styles.option
                }`}
                onClick={this.choose}
            >
                <div
                    className={
                        'flex-100 layout-row layout-align-start-center ' +
                        styles.op_content
                    }
                >
                    {isPrivate ? (
                        <i className="fa fa-star flex-none" style={iconStyle} />
                    ) : (
                        <i
                            className="fa fa-users flex-none"
                            style={iconStyle}
                        />
                    )}
                    <p className="flex-offset-5 flex-none">
                        {route.route.name}
                    </p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between-center">
                    <p className={'flex-none ' + styles.date}>Next departure</p>
                    <p className={'flex-none ' + styles.date}>
                        {moment(route.next).format('lll')}
                    </p>
                </div>

                {theme ? (
                    <Style>
                        {`
                            .b_border {
                                box-shadow: 0 0 7px ${theme.colors.secondary}28;
                            }
                            &:hover {
                                margin: 4.8px 5.1px 5.2px 4.9px;
                                box-shadow: 1.3px 2.6px 4px 0 ${
                                    theme.colors.secondary
                                }48;
                            }
                        `}
                    </Style>
                ) : (
                    ''
                )}
            </div>
        );
    }
}
RouteOption.propTypes = {
    theme: PropTypes.object,
    route: PropTypes.object,
    selectOption: PropTypes.func,
    isPrivate: PropTypes.bool
};
