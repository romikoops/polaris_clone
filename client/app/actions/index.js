import * as types from './types';
export * from './alert.actions';
export * from './user.actions';
export * from './shipment.actions';
export * from './admin.actions';

export function filterTable(filter) {
    return {
        type: types.FILTER,
        filter
    };
}

export function setTenant(tenant) {
    return {
        type: types.SET_TENANT,
        tenant
    };
}

