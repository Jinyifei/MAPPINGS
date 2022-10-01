"use strict"
//
// v1.0.0b10
//
//
// globals
//
var count  = 1;
var target = "";

//----------------------------------------------------------------------
// Polling output file
//----------------------------------------------------------------------

function UrlExists(url) {
  if (typeof XMLHttpRequest === "undefined") {
	  XMLHttpRequest = function () {
		  try {
			  return new ActiveXObject("Msxml2.XMLHTTP.6.0");
		  } catch (e) {}
		  try {
			  return new ActiveXObject("Msxml2.XMLHTTP.3.0");
		  } catch (e) {}
		  try {
			  return new ActiveXObject("Microsoft.XMLHTTP");
		  } catch (e) {}
		  throw new Error("This browser does not support XMLHttpRequest.");
	  };
  }
	var xreq = new XMLHttpRequest();
	xreq.open('HEAD', url, false);
	xreq.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xreq.send(null);
	return xreq.status!=404;
}

function progressBar( ) {
    if (count > 20) {
			document.getElementById("waiting").style.visibility="hidden";
			document.getElementById("ready").style.visibility="visible";
            return;
    }
    if ( UrlExists(target) ) {
			document.getElementById('CoolProgress').value = 20;
			document.getElementById("waiting").style.visibility="hidden";
			document.getElementById("ready").style.visibility="visible";
            return
    }
    count = (count+1) % 20;
    document.getElementById('CoolProgress').value = count++;
    setTimeout(function(){
        progressBar();
    }, 1000 )
}

function startProgress( targetzip ) {
    document.getElementById("timestamp").innerHTML=Date();
	document.getElementById("waiting").style.visibility="visible";
	document.getElementById("ready").style.visibility="hidden";
	target = targetzip
	progressBar();
	return
}
//----------------------------------------------------------------------
