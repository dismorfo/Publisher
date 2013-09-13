YUI({
    classNamePrefix: 'pure'
}).use('gallery-sm-menu', function (Y) {
	
    var a = Y.one('#horizontal-menu');
    var b = Y.one('#std-menu-items');
    
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

YUI().use("uploader", "json-parse", function(Y) {
    
    var overallProgress = Y.one("#overallProgress");
    
    if (overallProgress) {
    
    Y.one("#overallProgress").set("text", "Uploader type: " + Y.Uploader.TYPE);
    
    if (Y.Uploader.TYPE != "none" && !Y.UA.ios) {

        var uploader = new Y.Uploader({
        	width: "250px",
            height: "35px",
            multipleFiles: true,
            swfURL: "http://yui.yahooapis.com/3.12.0/build/uploader/assets/flashuploader.swf?t=" + Math.random(),
            uploadURL: "/publisher/cgi/uploadFiles.php",
            simLimit: 2,
            withCredentials: false
        });
        
       var uploadDone = false;

       uploader.render("#selectFilesButtonContainer");

       uploader.after("fileselect", function (event) {

          var fileList = event.fileList;
          var fileTable = Y.one("#filenames tbody");
          
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
                                    "<td class='filesize'>" + fileInstance.get("size") + "</td>" +
                                    "<td class='percentdone'>Hasn't started yet</td>");
                             });
       });

       uploader.on("uploadprogress", function (event) {
            var fileRow = Y.one("#" + event.file.get("id") + "_row");
                fileRow.one(".percentdone").set("text", event.percentLoaded + "%");
       });

       uploader.on("uploadstart", function (event) {
            uploader.set("enabled", false);
            Y.one("#uploadFilesButton").addClass("yui3-button-disabled");
            Y.one("#uploadFilesButton").detach("click");
       });

       uploader.on("uploadcomplete", function (event) {

       	    var parsedResponse = Y.JSON.parse(event.data);

            var fileRow = Y.one("#" + event.file.get("id") + "_row");
                fileRow.one(".percentdone").set("text", parsedResponse.msg);

       });

       uploader.on("totaluploadprogress", function (event) {
           Y.one("#overallProgress").setHTML("Total uploaded: <strong>" + event.percentLoaded + "%" + "</strong>");
       });

       uploader.on("alluploadscomplete", function (event) {
           
           uploader.set("enabled", true);
           
           uploader.set("fileList", []);
           
           Y.one("#uploadFilesButton").removeClass("yui3-button-disabled");
           
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
    }

});

YUI().use('node', 'event', 'tabview', 'transition', 'io', "json-parse", 'io-queue', 'querystring-parse-simple', function (Y) {
    
    var tabview = new Y.TabView({srcNode:'#collections'});
    
    var body = Y.one('body');
    
    function onSubmit(e) {
    	
    	e.halt();
    	
        var currentTarget = e.currentTarget, valid = true, msg = '', text = '';
        
        var eadFile = Y.one('#eadfile').get('value');
        
        var eadDir = Y.one('#eaddir').get('value');
        
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
    
    function onStart() {
        Y.log('Loading tab content');
    }

    function onSuccess(t, n) {
    	var selected = Y.one('li.yui3-tab-selected a')
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
    	
    	Y.log(selected)
    	
        // get the index of the active node
        // activeIndex = selected ? Y.all('#collections > ul > li').indexOf(selected) : 0;
    	
        // tabview.selectChild(activeIndex);
    	
    	// Y.io.queue(uri + '&pjax=1');
    	
    });

    Y.io.header("X-PJAX","true");
    
    Y.on('io:success', onSuccess);    
    
    Y.on('io:start', onStart);
    
    body.delegate('submit', onSubmit, 'form#upload-ead');
    
    body.delegate('click', onClick, 'table a');
    
    body.delegate('click', onTabClick, 'a.tab');

    Y.io.queue.start();

    tabview.render();

});

//copied over from http://www.degraeve.com/reference/simple-ajax-example.php
//made minor changes
//esha datta: 8/20/07

//calls specified script. strURL is specified in the calling program

function callScript(id,strURL,action){
	alert(id);
    //initializing vars used for ajax
    var xmlHttpReq = false;
    var self = this;
    // Mozilla/Safari
    if (window.XMLHttpRequest) {
        self.xmlHttpReq = new XMLHttpRequest();
    }
    // IE
    else if (window.ActiveXObject) {
        self.xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
    }
    self.xmlHttpReq.open('POST', strURL, true);
    self.xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    if (action == 'publish'){
    //calling function to tweak button and cgi output displays
    display(id,'button','inProgress');
    callPublish(id,self,action);
    }
    if (action == 'remove'){
    //calling function to tweak button and cgi output displays
	alert(id);
    display(id,'button','inProgress');
    callRemove(id,self,action);
    }


}

function callUpload(id,self,action){
    self.xmlHttpReq.onreadystatechange = function() {
        if (self.xmlHttpReq.readyState == 4) {
            updatepage(id,self.xmlHttpReq.responseText);
        }
    }
    self.xmlHttpReq.send(getquerystring(id,action));

}

function callPublish(id,self,action) {
	alert(id + self + action);
    self.xmlHttpReq.onreadystatechange = function() {
        if (self.xmlHttpReq.readyState == 4) {
            updatepage(id,self.xmlHttpReq.responseText);
            display(id,'button','completed');
        }
    }
    self.xmlHttpReq.send(getquerystring(id,action));
}

function callRemove(id,self,action) {
    self.xmlHttpReq.onreadystatechange = function() {
        if (self.xmlHttpReq.readyState == 4) {
            updatepage(id,self.xmlHttpReq.responseText);
            display(id,'button','completed');
        }
    }
    self.xmlHttpReq.send(getquerystring(id,action));
}

//gets query string from requesting page
function getquerystring(id,action) {
    qryStr='';
    if (action == 'publish'){
    	qryStr = "eadFile="+escape(id);
    }
    else if(action == 'remove'){
      qryStr = "eadFile="+escape(id);
    }
    else if(action == 'upload'){
      qryStr = "dir="+document.getElementById('eadDir').value;
      qryStr += "&ead="+document.getElementById('eadFile').value;
      alert(qryStr);
    }
    return qryStr;
}

//replaces whatever is in requested id with  response string
function updatepage(id,str){
    document.getElementById(id).innerHTML = str;
    document.getElementById(id).style.textAlign = 'left';
}

//turns on and off depending on cgi state
function display(id,name,state){
    	var tdButton = document.getElementsByName(name);
	if (state == 'inProgress'){
    		document.getElementById(id).innerHTML='Working....';
    		document.getElementById(id).style.backgroundColor='yellow';
    		document.getElementById(id+'-button').style.backgroundColor='yellow';
    		for(var i=0; i<tdButton.length; i++){
        		tdButton[i].style.display='none';
    		}
	}
	if (state == 'completed'){
    		for(var i=0; i<tdButton.length; i++){
		 	if (tdButton[i].style.backgroundColor != 'yellow'){
        		tdButton[i].style.display='block';
			}
    		}
	}
}