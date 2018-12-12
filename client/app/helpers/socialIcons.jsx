import React from 'react'

export function socialIcons (social, link) {
  let icon
  switch (social) {
    case 'facebook':
      icon = 'fa fa-facebook'
      break
    case 'twitter':
      icon = 'fa fa-twitter'
      break
    case 'linkedin':
      icon = 'fa fa-linkedin'
      break
    case 'youtube':
      icon = 'fa fa-youtube'
      break
    case 'instagram':
      icon = 'fa fa-instagram'
      break
    case 'google_plus':
      icon = 'fa fa-google-plus-g'
      break
    default:
      icon = ''
  }

  return (
    <a
      href={link}
    >
      <i
        className={`${icon} flex-none`}
      />
    </a>
  )
}

export default socialIcons
