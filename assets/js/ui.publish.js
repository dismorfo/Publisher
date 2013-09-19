YUI().use('node', 'event', 'tabview', 'pjax', 'panel', 'io', 'dd-plugin', 'uploader', function (Y) {
    
    var panel 
      , dialog 
      , pjax = new Y.Pjax()
      , tabview = new Y.TabView({srcNode:'#collections'})
      , body = Y.one('body');
     
    dialog = new Y.Panel({
        contentBox : Y.Node.create('<div id="dialog" />'),
        bodyContent: '<div class="message icon-warn"></div>',
        width      : 410,
        zIndex     : 6,
        centered   : true,
        modal      : false, // modal behavior
        render     : '.example',
        visible    : false, // make visible explicitly with .show()
        buttons    : {
            footer: [
                {
                    name  : 'cancel',
                    label : 'Cancel',
                    action: 'onCancel'
                },
                {
                    name     : 'proceed',
                    label    : 'OK',
                    action   : 'onOK'
                }
            ]
        }
    });

    dialog.onCancel = function (e) {
    	
        e.preventDefault();

        this.hide();

        this.callback = false;
        
    }

    dialog.onOK = function (e) {

        e.preventDefault();
        
        this.hide();

        // code that executes the user confirmed action goes here
        if (this.callback) {
           this.callback();
        }

        // callback reference removed, so it won't persist
        this.callback = false;

    }

    // Create the main modal form.
    panel = new Y.Panel({
        srcNode      : '#panelContent',
        headerContent: 'EAD publisher',
        width        : '70%',
        zIndex       : 5,
        centered     : true,
        modal        : true,
        visible      : false,
        render       : true,
        plugins      : [Y.Plugin.Drag]
    });

    panel.addButton({
        value  : 'Ok',
        section: Y.WidgetStdMod.FOOTER,
        action : function (e) {
            e.preventDefault();
            this.hide();
        }
    });     
    
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

        Y.one("#overallProgress").set("text", "Uploader type: " + Y.Uploader.TYPE);
    
        if (Y.Uploader.TYPE != "none" && !Y.UA.ios) {
    	
    	    var uploadDone = false;
    	    
    	    if (uploader) {
    	    	uploader.destroy();
    	    }
    	
            var uploader = new Y.Uploader({
        	    width: "250px",
        	    fileFieldName: 'eadfile',
                height: "35px",
                multipleFiles: true,
                swfURL: "http://yui.yahooapis.com/3.12.0/build/uploader/assets/flashuploader.swf?t=" + Math.random(),
                simLimit: 2,
                withCredentials: false
            });
        
            uploader.render("#selectFilesButtonContainer");

            uploader.after("fileselect", function (event) {

                var fileList = event.fileList
                  , fileTable = Y.one("#filenames tbody");
             
                if (fileList.length > 0 && Y.one("#nofiles")) {
                    Y.one("#nofiles").remove();
                }

                if (uploadDone) {
                    uploadDone = false;
                    fileTable.setHTML("");
                }

                Y.each(fileList, function (fileInstance) {
                    fileTable.append("<tr id='" + fileInstance.get("id") + "_row" + "'>" +
                                     "<td class='filename'>" + fileInstance.get("name") + "</td>" +
                                     "<td class='percentdone'>Hasn't started yet</td>");
                });
            });

            uploader.on("uploadprogress", function (event) {
                var fileRow = Y.one("#" + event.file.get("id") + "_row");
                
                if (event.percentLoaded < 100) {
                    fileRow.one(".percentdone").set("text", event.percentLoaded + "%");
                }
                else {
                	fileRow.one(".percentdone").set("text", "Running transformations");
                }
            });

            uploader.on("uploadstart", function (event) {
            
                uploader.set("enabled", false);

                Y.one("#uploadFilesButton").addClass("pure-button-disabled");
            
                Y.one("#uploadFilesButton").detach("click");

            });

            uploader.on("uploadcomplete", function (event) {
                var fileRow = Y.one("#" + event.file.get("id") + "_row");
                    fileRow.one(".percentdone").set("text", "Finished!");
            });

            uploader.on("totaluploadprogress", function (event) {
                Y.one("#overallProgress").setHTML("Total uploaded: <strong>" + event.percentLoaded + "%" + "</strong>");
            });

            uploader.on("alluploadscomplete", function (event) {
                
                uploader.set("enabled", true);
                
                uploader.set("fileList", []);
                
                Y.one("#uploadFilesButton").removeClass("pure-button-disabled");
                
                Y.one("#uploadFilesButton").on("click", function () {
                    if (!uploadDone && uploader.get("fileList").length > 0) {
                        uploader.uploadAll();
                    }
                });
                
                Y.one("#overallProgress").set("text", "Uploads complete!");
                
                uploadDone = true;
                
            });

            Y.one("#uploadFilesButton").on("click", function () {
                if (!uploadDone && uploader.get("fileList").length > 0) {
                    uploader.uploadAll();
                }
            });
        }
        else {
            Y.one("#uploaderContainer").set("text", "We are sorry, but to use the uploader, you either need a browser that support HTML5 or have the Flash player installed on your computer.");
        }    

    function onPublish(e) {

        e.halt();

        currentTarget = e.currentTarget;

        var action = currentTarget.get('href');
        
        var msg;

        var eadRepo = e.currentTarget.getAttribute('data-repo');

        var eadId = e.currentTarget.getAttribute('data-eadid');

        var panel_body = Y.one('#panelContent .yui3-widget-bd');
        
        function onStart(id, result, a) {
            panel_body.set('innerHTML', 'Making sure that the magic happen, this can take up to few minutes, please wait.');
            panel.show();
        }
        
        function onEnd(id, result) {
        }
        
        function onComplete(id, result) {
            panel_body.set('innerHTML',  result.responseText);
            panel.show();
            if ( currentTarget.getAttribute('data-action') === 'delete') {
              currentTarget.get('parentNode').get('parentNode').remove(true);  
            }
            else if ( currentTarget.getAttribute('data-action') === 'publish') {}
        }
        
        if ( currentTarget.getAttribute('data-action') === 'delete') {
          msg = 'Are you sure you want to ' + currentTarget.getAttribute('data-action') + ' <strong>'+ eadId + '</strong>?';          
        };
        
        if ( currentTarget.getAttribute('data-action') === 'publish') {
          msg = 'Are you sure you want to ' + currentTarget.getAttribute('data-action') + ' <strong>'+ eadId + '</strong> to <strong>production</strong> as part of <strong>' + eadRepo + '</strong> archives?';
        };

        // set the content you want in the message
        Y.one('#dialog .message')
         .set('className', 'message icon-warn')
         .setHTML(msg);

        // set the callback to reference a function
        dialog.callback = function() {        	
            Y.io(action, {
                method: 'POST',
                data: 'eadId=' + eadId + '&eadRepo=' + eadRepo,
                headers: {
                    'PJAX': 'true',
                },
                on: {
               	    start: onStart,
               	    end: onEnd,
               	    complete: onComplete
                }
            });
        }
        
        dialog.show();
    }
    
    function onTabClick(e) {
        
        var name = e.currentTarget.getAttribute('data-name');
        
        var collection = e.currentTarget.getAttribute('data-id');
        
        this.navigate(e.currentTarget.getAttribute('data-uri'));
        
        Y.all('span.archive').each(function() {
            this.set('innerHTML', name);	  
        });
        
        uploader.set("postVarsPerFile", {eaddir: collection, pjax: 1});
        
        uploader.set("uploadURL", e.currentTarget.getAttribute('data-upload'));
        
    }

    tabview.after('render', function() {
        var uri, identifier, selected, liSelected;
        
        liSelected = Y.one('.selected');
        
        selected = Y.one('.selected a');
        
        uri = selected.getAttribute('data-uri');
        
        collection = selected.getAttribute('data-id');
        
        // get the index of the active node
        activeIndex = selected ? Y.all('#collections > ul > li').indexOf(liSelected) : 0;
    	
        uploader.set("postVarsPerFile", {eaddir: collection, pjax: 1});
        
        uploader.set("uploadURL", selected.getAttribute('data-upload'));    	
    	
        tabview.selectChild(activeIndex);
        
    });
    
    pjax.on('load', onPjaxLoad);

    pjax.on('io:success', onSuccess);
    
    Y.on('io:start', onStart);
    
    body.delegate('click', onPublish, 'a.remove');
    
    body.delegate('click', onPublish, 'a.publish');
    
    body.delegate('click', onTabClick, 'a.tab', pjax);

    tabview.render();
    
});