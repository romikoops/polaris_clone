import { camelize } from './stringTools';

export const isEmpty = (obj) => {
  for(const key in obj) {
    if(obj.hasOwnProperty(key)) {
      return false;
    }
  }
  return true;
};

export const camelizeKeys = (obj) => {
	const newObj = {};
	Object.keys(obj).forEach(k => {
		newObj[camelize(k)] = obj[k];
	});
	return newObj;
};

export const deepCamelizeKeys = (obj) => {
	if (!obj || Object.keys(obj).length === 0) return obj;

	const newObj = {};
	Object.keys(obj).forEach(k => {
		newObj[camelize(k)] = deepCamelizeKeys(obj[k]);
		console.log(newObj);
	});
	return newObj;
};
