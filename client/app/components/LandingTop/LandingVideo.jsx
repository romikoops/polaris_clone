import React from 'react'
import styles from './LandingVideo.scss'

const LandingVideo = (props) => {
  return (
    <div className={props.className}>
      <video preload="metadata" autoPlay={true} muted={true} loop={true} className={styles.landing_video}>
        <source src={props.url} type="video/mp4" />
        Your browser does not support the video tag.
      </video>
      <div className={styles.landing_video_content}>
        {props.children}
      </div>
    </div>
  )
}

export default LandingVideo;