function getScope (tenant) {
  return (tenant && tenant.data && tenant.data.scope)
}

export default function isQuote (tenant) {
  const scope = getScope(tenant)
  if (!scope) return false

  return scope.closed_quotation_tool || scope.open_quotation_tool
}
