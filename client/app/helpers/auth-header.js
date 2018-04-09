export function authHeader () {
  // return authorization header with jwt token
  // const user = JSON.parse(localStorage.getItem('user'));
  // if (user && user.token) {
  //     return { 'Authorization': 'Bearer ' + user.token };
  // }
  const aHeader = JSON.parse(window.localStorage.getItem('authHeader'))
  if (aHeader) {
    return aHeader
  }
  return {}
}

export default authHeader
