YUI().use('node', 'event', 'transition', 'io', "json-parse", 'io-queue', 'querystring-parse-simple', 'panel', 'dd-plugin', function (Y) {

    var panel, dialog;
    
    dialog = new Y.Panel({
        contentBox : Y.Node.create('<div id="dialog" />'),
        bodyContent: '<div class="message icon-warn">Are you sure you want to [take some action]?</div>',
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
        if (this.callback){
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
    
    Y.one('body').delegate('submit', function(e) {
    	
      e.halt();
      
      var eadFile = Y.one('#eadfile').get('value');

      var eadDir = Y.one('#eaddir').get('value');
      
      var valid = true;
      
      var msg = '';
      
      var text = '';
      
      var panel_body = Y.one('#panelContent .yui3-widget-bd');

      if (eadDir === 'none') {
          msg = 'Please select an archive from the drop down box';
          text ='<strong>Oh snap!</strong> ' + msg + ' and try submitting again.';
          panel_body.set('innerHTML', text);
          panel.headerContent = 'Oh snap!';
          panel.show();
          valid = false;
      }

      if (eadFile === '') {
          msg = 'Please select a file by clicking on the Browse button';
          text ='<strong>Oh snap!</strong> ' + msg + ' and try submitting again.';
          panel_body.set('innerHTML', text);
          panel.show();
          valid = false;
      }
        
      if (valid) {
          // set the content you want in the message
          Y.one('#dialog .message').set('className', 'message icon-question').set('innerHTML', 'Are you sure you want to upload <strong>' + eadFile.split(/(\\|\/)/g).pop()  + '</strong> file as part of <strong>' + eadDir + '</strong> archives?</p>');
    
          // set the callback to reference a function
          dialog.callback = onSubmit;      
      
          dialog.show();
          
      }
                       
    }, 'form#upload-ead');  

    
    function onSubmit(e) {
        var form = Y.one('form#upload-ead');
        
        var panel_body = Y.one('#panelContent .yui3-widget-bd');

        Y.io(form.get('action'), {
            method: 'POST',
            headers: {
                'PJAX': 'true',
            },
            form: {
                id: form,
                enctype : 'multipart/form-data',
                useDisabled: true,
                upload: true
            },                
            on: {
               	start: function(id, result) {
               		Y.one('#upload-ead').hide();
               	    panel_body.set('innerHTML', '<p>Making sure that the magic happen, this can take up to few minutes, please wait.</p>');
               	    panel.show();
               	},
               	end: function(id, result) {
               	    Y.one('#upload-ead').show();
               	},
               	complete: function(id, result) {
                    panel_body.set('innerHTML',  result.responseText);
                    Y.one('#eadfile').set('value', '');
                    panel.show();
               	}
            }
        });
    }
    
});