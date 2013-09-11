YUI().use('node', 'event', 'tabview', 'transition', 'io', "json-parse", 'io-queue', 'querystring-parse-simple', function (Y) {
    
    var tabview = new Y.TabView({srcNode:'#collections'});
    
    var body = Y.one('body');
    
    function onStart() {
        Y.log('Loading tab content');
    }

    function onSuccess(t, n) {
    	var selected = Y.one('li.yui3-tab-selected a');
    	if (selected) {
    	  selected.getAttribute('data-id');
          Y.one("#" + selected ).removeClass("io-loading").set("innerHTML", n.response);
        }
    }

    function onClick(e) {
        e.halt();
    }
    
    function onTabClick(e) {
      Y.io.queue(e.currentTarget.getAttribute('data-uri') + '&pjax=1');
    }

    tabview.after('render', function() {
        var uri, identifier, selected;
        
        identifier = Y.QueryString.parse(location.search, "?").identifier;
        
        if (identifier) {
        	selected = Y.one('.archive-' + identifier);
        	if (selected) {
        	  uri = Y.one('.archive-' + identifier).getAttribute('data-uri');
        	}
        }
    	else {
    		selected = Y.one('li.yui3-tab-selected a');
    		if (selected) {
    		  uri = Y.one('li.yui3-tab-selected a').getAttribute('data-uri');
    		}
    	}
    	
        // get the index of the active node
        activeIndex = selected ? Y.all('#collections > ul > li').indexOf(selected) : 0;
    	
        tabview.selectChild(activeIndex);
    	
    	Y.io.queue(uri + '&pjax=1');
    	
    });

    Y.io.header("X-PJAX","true");
    
    Y.on('io:success', onSuccess);    
    
    Y.on('io:start', onStart);
    
    body.delegate('click', onClick, 'table a');
    
    body.delegate('click', onTabClick, 'a.tab');

    Y.io.queue.start();

    tabview.render();

});