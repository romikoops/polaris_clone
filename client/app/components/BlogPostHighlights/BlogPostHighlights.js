import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './BlogPostHighlights.scss';
import Button from '../Button/Button';
export class BlogPostHighlights extends Component {
    render() {
        const dummyPost = {
            title: 'How Digitalisation is changing shipping',
            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In vel leo dapibus, aliquam metus nec, pulvinar.',
            image: 'https://assets.itsmycargo.com/assets/images/welcome/country/shipping-containers.jpg'
        };
        const dummyPosts = [];
        const theme = this.props.theme;
        for (let i = 2; i >= 0; i--) {
            let divStyle = {
                backgroundImage: 'url(' + dummyPost.image + ')',
            };

            const dbp = (<div key={i} className="blog_post flex-30 layout-column layout-align-center-start" >
                <div className="bp_image flex-33" style={divStyle}>
                </div>
                <div className="flex-66 layout-column layout-align-center-start">
                  <div className="flex-66 layout-column layout-align-center-center bp_text">
                    <h3 className="flex-none"> {dummyPost.title} </h3>
                    <p className="flex-none"> {dummyPost.text} </p>
                  </div>
                  <div className="flex-33 layout-row layout-wrap layout-align-center-center bp_action">
                    <Button theme={theme} text="Read More"/>
                  </div>
                </div>
            </div>);
            dummyPosts.push(dbp);
        }
        return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div className="service_label layout-row layout-align-center-center flex-100">
              <h2 className="flex-none"> Introducing Online LCL Services
              </h2>
          </div>
          <div className="flex-100 flex-gt-sm-75 layout-row layout-align-center-center">
            {dummyPosts}
          </div>
        </div>
      );
    }
}

BlogPostHighlights.propTypes = {
    theme: PropTypes.object
};
