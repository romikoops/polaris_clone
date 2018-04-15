import React, { Component } from 'react'
import styles from '../Card.scss'



// if there are no states
function CardTitle (props) {
  const {
    titles,
    faIcon
  } = props
  return (
    <div className="card-title-pricing">
      <div className="center-items">
        <i className={`fa fa-${faIcon}`}></i>
        <div>
          <h5>{titles}</h5>
          <p>Routes</p>
        </div>
      </div>
    </div>
  )
}


// class CardTitle extends Component {
//   constructor (props) {
//     super(props)
//   }

//   // hello () {
//   //   return "Hello"
//   // }

//   render () {
//     const {
//       title,
//       faIcon
//     } = this.props
//     return (
//       <div className="card-title-pricing">
//         <div className="center-items">
//           <i className="ooo">{faIcon}</i>
//           <div>
//             <h5>{title}</h5>
//             <p>Routes</p>
//           </div>
//         </div>
//       </div>
//       )
//   }
// }



// //  component using variable
// const cardTitle = (
//   <div className="card-title-pricing">
//     <div className="center-items">
//       <i className="ooo">stuff</i>
//       <div>
//         <h5>wohoo</h5>
//         <p>Routes</p>
//       </div>
//     </div>
//   </div>
// )



export default CardTitle




