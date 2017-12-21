import React, {Component} from 'react';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import styles from '../ActiveRoutes/ActiveRoutes.scss';
export class Carousel extends Component {
    render() {
      if (!this.props.slides) {
        return '';
      }
        const settings = {
            dots: true,
            autoplay: true,
            infinite: true,
            slidesToShow: 4,
            arrows: true
        };
        const slides = this.props.slides.map((route) => {
            const divStyle = {
                backgroundImage: 'url(' + route.image + ')'
            };
            return (
                <div key={route.name} className={styles.slick_slide + ' flex-none layout-row layout-align-center-center'} style={divStyle}>
                    <div className="flex-none layout-column layout-align-center-center">
                        <h2 className={styles.city + ' flex-none'}> {route.header} </h2>
                        <h5 className={styles.country + ' flex-none'}> {route.subheader} </h5>
                    </div>
                </div>
            );
        });
        return (
            <div className={`flex-100 layout-row ${styles.slider_container}`}>
                <Slider {...settings}>
                    {slides}
                </Slider>
            </div>
        );
    }
}
