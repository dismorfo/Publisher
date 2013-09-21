YUI().use('node', 'event', 'tabview', 'pjax', 'panel', 'io', 'dd-plugin', 'uploader', function (Y) {
    
    var pjax = new Y.Pjax()
      , tabview = new Y.TabView({srcNode:'#collections'})
      , body = Y.one('body');
     
    function onStart() {
        Y.log('Start loading io content');
    }
    
    function onSuccess() {
        Y.log('Success');
    }    
    
    function onPjaxLoad(t, n) {
    	
    	var id, node, selected = Y.one('li.yui3-tab-selected a');
    	
    	if (selected) {
    	  id = selected.getAttribute('data-id');
    	  node = Y.one("#" + id );
    	  if (node) {
    	    Y.one("#" + id).removeClass("io-loading").set("innerHTML", t.responseText);
    	  }
        }
    }

    function onTabClick(e) {
        
        var name = e.currentTarget.getAttribute('data-name');
        
        this.navigate(e.currentTarget.getAttribute('data-uri'));
        
        Y.all('span.archive').each(function() {
            this.set('innerHTML', name);	  
        });
        
    }

    tabview.after('render', function() {
        var uri, identifier, selected, liSelected;
        
        liSelected = Y.one('.selected');
        
        selected = Y.one('.selected a');
        
        uri = selected.getAttribute('data-uri');
        
        collection = selected.getAttribute('data-id');
        
        // get the index of the active node
        activeIndex = selected ? Y.all('#collections > ul > li').indexOf(liSelected) : 0;
    	
        tabview.selectChild(activeIndex);
        
    });
    
    pjax.on('load', onPjaxLoad);

    pjax.on('io:success', onSuccess);

    Y.on('io:start', onStart);

    body.delegate('click', onTabClick, 'a.tab', pjax);

    tabview.render();
    
});