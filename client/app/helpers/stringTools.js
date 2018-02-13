export const capitalize = (str) => (
  str.charAt(0).toUpperCase() + str.slice(1)
);

export const camelize = (str) => (
	str.replace(/[_.-](\w|$)/g, (_, x) => x.toUpperCase())
);
