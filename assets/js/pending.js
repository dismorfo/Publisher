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

function validateUpload(){
                valid = true;
                if (document.getElementById('eadDir').value == 'select'){
         		alert("Please select an archive from the drop down box");
                        valid = false;
                }
                if (document.getElementById('eadFile').value == ''){
         		alert("Please select a file by clicking on the Browse button");
                        valid = false;
                }
            return valid;
}
