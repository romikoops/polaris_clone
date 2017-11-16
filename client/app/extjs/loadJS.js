/*! loadJS: load a JS file asynchronously. [c]2014 @scottjehl, Filament Group, Inc. (Based on http://goo.gl/REQGQ by Paul Irish). Licensed MIT */
export const loadJSWrapper = (function( w ) {
		const loadJS = function( src, cb ) {
				'use strict';
				const ref = w.document.getElementsByTagName( 'script' )[ 0 ];
				const script = w.document.createElement( 'script' );
				script.src = src;
				script.async = true;
				ref.parentNode.insertBefore( script, ref );
				if (cb && typeof(cb) === 'function') {
					script.onload = cb;
				}
				return script;
	};
	// commonjs
	if( typeof module !== 'undefined' ) {
		module.exports = loadJS;
	} else {
		w.loadJS = loadJS;
	}
}( typeof global !== 'undefined' ? global : this ));
