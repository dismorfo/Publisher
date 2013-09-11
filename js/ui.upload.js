YUI().use('node', 'event', 'transition', 'io', "json-parse", 'io-queue', 'querystring-parse-simple', function (Y) {
    
    var body = Y.one('body');
    
    function onSubmit(e) {
    	
    	e.halt();
    	
        var currentTarget = e.currentTarget, valid = true, msg = '', text = '', eadFile, eadDir;

        eadFile = Y.one('#eadfile').get('value');

        eadDir = Y.one('#eaddir').get('value');

        if (eadDir === 'none') {
        	msg = 'Please select an archive from the drop down box';
        	text ='<div class="alert alert-danger"><strong>Oh snap!</strong> ' + msg + ' and try submitting again.</div>';            
            Y.one('.msg').append(text);
            valid = false;
        }

        if (eadFile === '') {
            msg = 'Please select a file by clicking on the Browse button';
            text ='<div class="alert alert-danger"><strong>Oh snap!</strong> ' + msg + ' and try submitting again.</div>';
            Y.one('.msg').append(text);
            valid = false;
        }
        
        if (valid) {
            Y.io(currentTarget.get('action'), {
                method: 'POST',
                data: 'eadfile=' + eadFile + '&eaddir=' + eadDir,
                form: {
                  id: Y.one('form#upload-ead'),
                  enctype : 'multipart/form-data',
                  useDisabled: true,
                  upload: true
               },                
               on: {
                    success: function (id, result) {
                    	
                    	var cssClass = 'alert ';
                    	
                       // protected against malformed JSON response
                       try {
                           var parsedResponse = Y.JSON.parse(result.responseText);

                           if (parsedResponse.code === "9") {
                           	 cssClass += 'alert-danger';
                           }
                           
                           Y.one('.msg').append('<div class="' + cssClass + '"><strong>Oh snap!</strong> ' + parsedResponse.msg + '</div>');

                       }
                       catch (e) {
                           Y.log("JSON Parse failed!");
                           return;
                       }
                    },
                    failure: function (id, result) {
                    	Y.log('fail');
                    }
                }
            });
        }

    }
    
    Y.io.header("X-PJAX","true");
    
    Y.on('io:success', onSuccess);    
    
    Y.on('io:start', onStart);
    
    body.delegate('submit', onSubmit, 'form#upload-ead');
    
});