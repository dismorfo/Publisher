YUI({
    classNamePrefix: 'pure'
}).use('gallery-sm-menu', function (Y) {
	
    var a = Y.one('#horizontal-menu')
        b = Y.one('#std-menu-items');
    
    if (a && b) {
        var horizontalMenu = new Y.Menu({
            container         : '#horizontal-menu',
            sourceNode        : '#std-menu-items',
            orientation       : 'horizontal',
            hideOnOutsideClick: false,
            hideOnClick       : false
        });
        horizontalMenu.render();
        horizontalMenu.show();
    }
});