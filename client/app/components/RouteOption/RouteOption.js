import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './RouteOption.scss';
import Style from 'style-it';
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
        // debugger;
        return (
            <div className={`option flex-none layout-row layout-wrap layout-align-start-center ${styles.option}`} onClick={this.choose}>
                <div className={`${styles.op_type} b_border flex-none layout-row`}>
                    {isPrivate ? 'Dedicated Pricing' : 'Public Pricing'}
                </div>
              <h4 className="flex-none">{route.name}</h4>
              {theme ? <Style>
                                  {`
                                     .b_border {
                                          border-bottom: 0.75px solid ${theme.colors.secondary};
                                      }
                                      .option::hover {
                                         box-shadow: 2px 1px 2px 1px ${theme.colors.secondary};
                                       }
                                  `}
                              </Style> : ''}
            </div>
        );
    }
}
RouteOption.PropTypes = {
    theme: PropTypes.object,
    route: PropTypes.object,
    selectOption: PropTypes.func,
    isPrivate: PropTypes.bool
};
