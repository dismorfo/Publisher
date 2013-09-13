YUI().use('node', 'event', 'tabview', 'io', 'io-queue', 'pjax', function (Y) {
    
    var tabview = new Y.TabView({srcNode:'#collections'});
    
    var body = Y.one('body');
    
    function onStart() {
        Y.log('Loading tab content');
    }

    function onSuccess(t, n) {
    	var id, node, selected = Y.one('li.yui3-tab-selected a');
    	if (selected) {
    	  id = selected.getAttribute('data-id');
    	  node = Y.one("#" + id );
    	  if (node) {
    	    Y.one("#" + id ).removeClass("io-loading").set("innerHTML", n.response);	
    	  }
        }
    }

    function onClick(e) {
        // e.halt();
    }
    
    function onTabClick(e) {
      this.navigate(e.currentTarget.getAttribute('data-uri'));
    }

    tabview.after('render', function() {
        var uri, identifier, selected, liSelected;

        
        liSelected = Y.one('.selected');
        
        selected = Y.one('.selected a');
        
        uri = selected.getAttribute('data-uri');
        
        // get the index of the active node
        activeIndex = selected ? Y.all('#collections > ul > li').indexOf(liSelected) : 0;
    	
        tabview.selectChild(activeIndex);

    	Y.io.queue(uri + '?pjax=1');
    	
    });
    
    var pjax = new Y.Pjax(); 
    
    pjax.on('load', function(e){ Y.log('pjax load')});

    Y.io.header("X-PJAX","true");
    
    Y.on('io:success', onSuccess);    
    
    Y.on('io:start', onStart);
    
    body.delegate('click', onClick, 'table a');
    
    body.delegate('click', onTabClick, 'a.tab', pjax);

    Y.io.queue.start();

    tabview.render();

});