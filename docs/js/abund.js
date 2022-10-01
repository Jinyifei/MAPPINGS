  "use strict"
   //
   // v1.0.0b8
   //
   //
   // globals
   //
  var offset    = 0.000;
  var zeta      = 0.000;
  var logValues = 1; // 0 for linear values display, 1 display logs
  var logZeta   = 1; // 0 for linear zeta, 1 zeta shown as log

  // internally zeta, offset and values are log_10 and loh[H] = 0.0000

  var aboutStr  = "Solar\, Asplund et al 2009";
  //
  // can use Charts-minbar.js if loaded, ignore if not
  //
  var haveCharts = 0;
  var b1 = null;
  var b2 = null;
  // previous values, single undo buffer
  // solar 2009 reference values
  var elem = [
      "H ",
      "He",
      "Li",
      "Be",
      "B ",
      "C ",
      "N ",
      "O ",
      "F ",
      "Ne",
      "Na",
      "Mg",
      "Al",
      "Si",
      "P ",
      "S ",
      "Cl",
      "Ar",
      "K ",
      "Ca",
      "Sc",
      "Ti",
      "V ",
      "Cr",
      "Mn",
      "Fe",
      "Co",
      "Ni",
      "Cu",
      "Zn"
  ];
  var atwei = [
      1.007940,
      4.002602,
      6.941000,
      9.012182,
      10.81100,
      12.01070,
      14.00670,
      15.99940,
      18.99840,
      20.17970,
      22.98977,
      24.30500,
      26.98154,
      28.08550,
      30.97376,
      32.06500,
      35.45300,
      39.94800,
      39.09830,
      40.07800,
      44.95591,
      47.86700,
      50.94150,
      51.99610,
      54.93805,
      55.84500,
      58.93320,
      58.69340,
      63.54600,
      65.38000
  ];
  //
  var sol = [
      0.000, -1.070, -10.95, -10.62, -9.30, -3.57, -4.17, -3.31, -7.44, -4.07, -5.76, -4.40, -5.55, -4.49, -6.59, -4.88, -6.50, -5.60, -6.97, -5.66, -8.85, -7.05, -8.07, -6.36, -6.57, -4.50, -7.01, -5.78, -7.81, -7.44
  ];
  var pre = [
      0.000, -1.070, -10.95, -10.62, -9.30, -3.57, -4.17, -3.31, -7.44, -4.07, -5.76, -4.40, -5.55, -4.49, -6.59, -4.88, -6.50, -5.60, -6.97, -5.66, -8.85, -7.05, -8.07, -6.36, -6.57, -4.50, -7.01, -5.78, -7.81, -7.44
  ];

  function log10( x ) {
    return Math.log(x)/Math.LN10;
  }
    //----------------------------------------------------------------------
   // Preset JSON file access
   //----------------------------------------------------------------------
  function RequestJSONArr(url) {
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
      xreq.onreadystatechange = function () {
          if (xreq.readyState == 4 && xreq.status == 200) {
              var src = JSON.parse(xreq.responseText);
              CallBackFunction(src, url);
          }
      }
      xreq.open("GET", url, true);
      xreq.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      xreq.send(null);
  }
  function CallBackFunction(src, url) {
      var n = sol.length;
      var x = new Array(n);
      // prepare abundances for submit
      if (url == 'abund/solar.json') aboutStr = "Solar\, Asplund et al 2009";
      if (url == 'abund/solar2005AGS.json') aboutStr = "Solar\, Asplund et al 2005";
      if (url == 'abund/solar2003L-Li.json') aboutStr = "Solar\, Lodders 2003, Li/160.0";
      if (url == 'abund/solar1998GS.json') aboutStr = "Solar\, Grevesse \& Sauval 1998";
      if (url == 'abund/solar1992F.json') aboutStr = "Solar\, Feldman 1992";
      if (url == 'abund/solar1989AG.json') aboutStr = "Solar\, Anders \& Grevesse 1989";
      if (url == 'abund/solar1982AE-Li.json') aboutStr = "Solar\, Anders \& Ebihara 1982, Meteoric Li/160 B,Be/2";
      if (url == 'abund/solar1972A.json') aboutStr = "Solar\, AQ3 Allen 1972";
      if (url == 'abund/Z005.json') aboutStr = "D13 HII region grid z=0.05";
      if (url == 'abund/Z010.json') aboutStr = "D13 HII region grid z=0.10";
      if (url == 'abund/Z020.json') aboutStr = "D13 HII region grid z=0.20";
      if (url == 'abund/Z030.json') aboutStr = "D13 HII region grid z=0.30";
      if (url == 'abund/Z050.json') aboutStr = "D13 HII region grid z=0.50";
      if (url == 'abund/Z100.json') aboutStr = "D13 HII region grid z=1.00";
      if (url == 'abund/Z200.json') aboutStr = "D13 HII region grid z=2.00";
      if (url == 'abund/Z300.json') aboutStr = "D13 HII region grid z=3.00";
      if (url == 'abund/Z500.json') aboutStr = "D13 HII region grid z=5.00";
      if (url == 'abund/concord2014.json')  aboutStr = "Solar Vicinity Concordance 2014";
      if (url == 'abund/cosmic2012NP.json') aboutStr = "B-Star Solar Vicinity, Nieve \& Przybilla 2012";
      if (url == 'abund/proto2003L.json') aboutStr = "Proto Solar, Lodders 2003";
      if (url == 'abund/solvic.json') aboutStr = "Solar Vicinity, Russell 1989";
      if (url == 'abund/lmc.json') aboutStr = "LMC, Russell 1992";
      if (url == 'abund/smc.json') aboutStr = "SMC, Russell 1989";
      var d = document.getElementById("fileid");
      d.value = aboutStr
      //
      // pull out values from json object, skipping missing elements
      // with -12.0 abundances.
      // json object names must match elem exactly, including spaces.
      //
      // fill in all sol-12.0
      for (var i = 0; i < n; i++) {
          x[i] = Math.max(-16.0, sol[i] - 12.0);
      }
      // override with json entries
      for (var j = 0; j < sol.length; j++) {
          // check each against all elements,
          // input can be in any order as
          // a consequence.
          var entID = elem[j];
          var xe = src[entID];
          if (!(typeof xe === 'undefined')) {
              if (!(xe === null)) x[j] = xe;
          }
      }
      SetValues(x);
      var z = 0.000;
      SetLogZeta(z);
  }
  //----------------------------------------------------------------------
  // .abn File uploading and parsing
  //----------------------------------------------------------------------
  function ParseABNFile(evt) {
      var fileString = evt.target.result;
      if (fileString.indexOf('%') >= 0) {
          var n = sol.length;
          var lines = fileString.split('\n');
          var len = lines.length;
          var headerLines = 0;
          var k = 0;
          while ((k < len) && (lines[k].charAt(0) == '%')) {
              k++;
          }
          headerLines = k;
          len -= (k + 2);
          if ((headerLines >= 1) && (len > 0)) {
              var start = (headerLines + 2);
              var foundValues = false;
              var x = new Array(n);
              var title = lines[headerLines].substr(0, 80);
              var nEntries = parseInt(lines[headerLines + 1].trim());
              if ((nEntries > 0) && (nEntries <= n) && (nEntries <= len)) {
                  var end = start + nEntries;
                  for (var i = 0; i < n; i++) {
                      x[i] = Math.max(-16.0, sol[i] - 12.0);
                  }
                  for (var i = start; i < end; i++) {
                      var row = lines[i].trim().split(" ");
                      if (row.length >= 2) {
                          var j = parseInt(row[0]) - 1;
                          if ((j >= 0) && (j < n)) {
                              var last = row.length - 1;
                              var f = parseFloat(row[last]);
                              if (isFinite(f)) {
                                  if (f > 1.0) f = 1.0;
                                  if (f > 0.0) f = Math.log(f) / Math.LN10;
                                  x[j] = (f > -16.0) ? f : -16.0;
                                  foundValues = true;
                              }
                          }
                      }
                  }
              }
              if (foundValues) {
                  aboutStr = title;
                  document.getElementById("fileid").value = title;
                  zeta  = 1.000;
                  document.getElementById("zgas").value = zeta;
                  SetValues(x);
              }
          }
      }
  }
  function StartRead(evt) {
      var file = document.getElementById("file").files[0];
      if (file) {
          var reader = new FileReader();
          reader.onload = ParseABNFile;
          reader.readAsText(file, "UTF-8");
      }
  }
  //----------------------------------------------------------------------
  function FixOffsets(val) {
      var n = sol.length;
      var x = new Array(n);
      GetValues(x); // get x as log{H} = 0.000
      //
      // always prepare for submit as offset = 0,
      // but keep zeta scaling
      //
      // always prepare for submit as
      // log[H] = 0.000
      //
      offset    = 0.000;
      logValues = 1;
      //
      SetValues(x); // set fields so submit can find them
  }
  function SetOffset (val) {
      //
      // radio buttons in display area, set edit area radio
      // buttons to match
      //
      var n = sol.length;
      var x = new Array(n);
      GetValues(x); // always get x as log[H] = 0.000
      if (val == '0') {
          document.getElementById("rbed01").checked = true;
          offset = 0.000;
          logValues = 0;
      }
      if (val == '1') {
          document.getElementById("rbed02").checked = true;
          offset = 0.000;
          logValues = 1;
      }
      if (val == '2') {
          document.getElementById("rbed03").checked = true;
          offset = 12.000;
          logValues = 1;
      }
      SetValues(x); // display x with offests/scaling
  }
  function SetOffset2(val) {
      //
      // radio buttons in edit area, set display radio
      // buttons to match
      //
      var n = sol.length;
      var x = new Array(n);
      GetValues(x); // always get x as log[H] = 0.000
      if (val == '0') {
          document.getElementById("rbda01").checked = true;
          offset = 0.000;
          logValues = 0;
      }
      if (val == '1') {
          document.getElementById("rbda02").checked = true;
          offset = 0.000;
          logValues = 1;
      }
      if (val == '2') {
          document.getElementById("rbda03").checked = true;
          offset = 12.000;
          logValues = 1;
      }
      SetValues(x); // display x with offests/scaling
  }
//----------------------------------------------------------------------
  function ShowHideSummary() {
      var d = document.getElementById("summary");
      var b = document.getElementById("sumbutton");
      var v = d.style.display;
      if (v == 'none') {
          d.style.display = 'block';
          b.innerHTML = "Hide";
          UpdateDisplayValues();
      } else {
          d.style.display = 'none';
          b.innerHTML = "Show…";
          UpdateDisplayValues();
      }
  }
//----------------------------------------------------------------------
  function SetLinearZetaFromLog(){
      var d = document.getElementById("zgas");
      var z = parseFloat(d.value);
      if ( isFinite(z) ) {
          zeta = z;
          var linZeta = Math.pow(10.0,zeta);
          if ( isFinite(linZeta) ) {
              linZeta = (linZeta < 0.0)? 1.0e-6: linZeta;
              d.value = linZeta.toFixed(5);
          }
      }
      document.getElementById("zetatitle").innerHTML="ζ =";
      document.getElementById("zetaabout").innerHTML="ζ>0.0, (ζ=1.0: no change) ";
  }
  function SetLogZetaFromLinear(){
      var d = document.getElementById("zgas");
      var z = parseFloat(d.value);
      if ( isFinite(z) ) {
          var linZeta = (z <= 0.0)? 1.0e-6: z;
          zeta    = log10(linZeta);
          d.value = zeta.toFixed(5);
      }
      document.getElementById("zetatitle").innerHTML="Log[ζ] =";
      document.getElementById("zetaabout").innerHTML="Log[ζ] > -6.0, (Log[ζ]=0.0: no change) ";
  }
  function GetZeta(){
      var d = document.getElementById("zgas");
      var z = parseFloat(d.value);
      if ( isFinite(z) ) {
         if ( logZeta == 0 ){
          var linZeta = (z <= 0.0)? 1.0e-6: z;
          zeta    = log10(linZeta);
         } else {
          zeta    = z;
         }
      }
  }
  function SetLinZeta(z){
      var d = document.getElementById("zgas");
      if ( isFinite(z) ) {
          var linZeta = (z <= 0.0)? 1.0e-6: z;
          zeta    = log10(linZeta);
         DisplayZeta();
      }
  }
  function SetLogZeta(z){
      var d = document.getElementById("zgas");
      if ( isFinite(z) ) {
         zeta    = z;
         DisplayZeta();
      }
  }
  function SetZetaStyle(check) {
      if (check.checked == true) {
          logZeta   = 1;
          SetLogZetaFromLinear();
      } else {
          logZeta   = 0;
          SetLinearZetaFromLog();
      }
  }
  function DisplayZeta(){
      var d = document.getElementById("zgas");
      if ( logZeta == 0 ) {
         var linZeta = Math.pow(10.0,zeta);
         d.value = linZeta.toFixed(5);
      } else {
          d.value = zeta.toFixed(5);
      }
  }
  function EstimateZeta(){
      var n = sol.length;
      var x = new Array( n );
      GetValues( x );
      var linZeta = ComputeZGas( x );
      if (isFinite(linZeta)){
         SetLinZeta(linZeta);
      }
  }
//----------------------------------------------------------------------
  function UndoZetaScaling(){
       var n = sol.length;
       var x = new Array( n );
       GetValues( x );
       for ( var index = 0; index < n; index++ ) {
           x[index] = pre[index];
       }
       SetValues( x );
  }

  function ApplyZetaScaling(){
    GetZeta();
    if ( isFinite(zeta) ){
       var linZeta = Math.pow( 10.0, zeta );
       var fillmissing  = document.getElementById("fillmissing").checked;
//       var cnscaling    = document.getElementById("cnscaling").checked;
//       var libbescaling = document.getElementById("libbescaling").checked;
//       var oxyscaling   = document.getElementById("oxyscaling").checked;
//       var alphaenhance = document.getElementById("alphaenhance").checked;
//       var ironenhance  = document.getElementById("ironenhance").checked;
       var n = sol.length;
       var x = new Array( n );
       GetValues( x );
       for ( var index = 0; index < n; index++ ) {
           pre[index] = x[index];
       }
       if ( fillmissing ) {
          for ( var index = 1; index < n; index++ ) {
               var logSol  = sol[index];
               if ( x[ index ] <= -15.0 ) {
                  if ( index == 1 ) {
                      var linHe  = 0.0737 + 0.0234*linZeta;
                      x[ index ] = Math.log(linHe)/Math.LN10;
                  } else {
                      x[ index ] = logSol + zeta;
                  }
               }
           }
       } else {
          for ( var index = 1; index < n; index++ ) {
               var logSol  = x[index];
               if ( index == 1 ) {
                   var linHe   = Math.pow( 10.0, x[1] );
                   var deltaHe = linHe - 0.0737;
                   deltaHe     = (deltaHe < 0.0)? 0.0 : deltaHe;
                   linHe       = 0.0737 + (deltaHe*linZeta);
                   linHe       = (linHe < 0.0)? 0.0737: linHe
                   x[ index ] = Math.log(linHe)/Math.LN10;
               } else {
                   x[ index ] = logSol + zeta;
               }
           }
       }
       SetValues( x );
    }
  }
//----------------------------------------------------------------------
  function ShowManualEdit() {
      var d = document.getElementById("manual");
      var v = d.style.display;
      if (v == 'none') {
          d.style.display = 'block';
          UpdateDisplayValues();
      }
  }
  function HideManualEdit() {
      var d = document.getElementById("manual");
      var v = d.style.display;
      if (v != 'none') {
          d.style.display = 'none';
      }
  }
  function SetManualValues() {
      var n = sol.length;
      var x = new Array(n);
      GetValues(x); // get edit fields x as log[H] = 0.000 from edit fields
      var d = document.getElementById("manual");
      var v = d.style.display;
      if (v != 'none') {
          d.style.display = 'none';
      }
      SetValues(x); // sets and displays values according to scaling
  }
  function SetJSONValues(url) {
      RequestJSONArr(url);
  }
//----------------------------------------------------------------------
  function ComputeZGas(x) {
      //
      // only count elements > [X/H] > -6
      //
      var n = x.length;
      var count = 0;
      var zmt = 0.0;
      for (var index = 5; index < n; index++) {
          if ((x[index] - sol[index]) >= -6.0) {
              count += 1;
              zmt = zmt + Math.pow(10.0, x[index] - sol[index]);
          }
      }
      return (zmt / (1.0 * count));
  }
  function ComputeMu(x) {
      var mu = [1.0, 1.0, 1.0, 1.0];
      var n = x.length;
      var ai = 1.0;
      var nsum = 0.0;
      var nsum2 = 0.0;
      var msum = 0.0;
      var msum2 = 0.0;
      for (var index = 0; index < n; index++) {
          if (x[index] > -16.0) {
              var idx = index + 1;
              ai = Math.pow(10.0, x[index]);
              nsum += ai
              nsum2 += ai * idx;
              msum += ai * atwei[index];
              msum2 += ai * idx * 5.485799e-04;
          }
      }
      mu[0] = msum / nsum;
      mu[1] = (msum + msum2) / (nsum2 + nsum);
      mu[2] = msum;
      mu[3] = nsum;
      return mu;
  }
  function ComputeMassFractions(x) {
      var n = x.length;
      var ai = 0.0;
      var msum = 0.0;
      var mi = [1.0, 0.0, 0.0];
      for (var index = 0; index < n; index++) {
          if (x[index] > -16.0) {
              ai = Math.pow(10.0, x[index]);
              msum += ai * atwei[index];
          }
      }
      if (msum > 0.0) {
          for (var index = 0; index < 2; index++) {
              if (x[index] > -16.0) {
                  ai = Math.pow(10.0, x[index]);
                  mi[index] = ai * atwei[index] / msum;
              }
          }
      }
      mi[2] = 1.0 - (mi[0] + mi[1]);
      return mi;
  }
//----------------------------------------------------------------------
  function DisplaySummary( x ) {
      var n = x.length;
      var d = document.getElementById("summary")
      var v = d.style.display;
      if (v != 'none') {
          var w = d.clientWidth;
          var cols = Math.ceil(w * 0.005882352941176471); // width/170px
          var sTable;
          var tableText = "";
          var ai = 0.0;
          var si = 0.0;
          var zgas = 1.0;
          var zen = 1.0;
          var mu_neu = 0.0;
          var mu_ion = 0.0;
          var mu_hi = 0.0;
          var xi = [1.0, 0.0, 0.0];
          var mu = [1.0, 1.0, 1.0, 1.0];
          zgas = ComputeZGas(x);
          mu = ComputeMu(x);
          xi = ComputeMassFractions(x);
          mu_neu = mu[0]
          mu_ion = mu[1];
          mu_hi = mu[2];
          zen = mu[3];
          sTable = document.getElementById("sumtable");
          tableText = "Elemental Abundances by Number\n";
          if (logValues == 1) {
              tableText += "Relative to log[H] = " + offset.toPrecision(4) + "\n";
          } else {
              tableText += "Relative to H = 1.000\n";
          }
          tableText += "Source: " + aboutStr + "\n";
          for (index = 0; index < cols; index++) {
              tableText += "---------------";
          }
          tableText += "\n";
          for (var index = 0; index < n; index++) {
              var col = (index % cols);
              if (logValues == 1) {
                  ai = x[index] + offset;
                  if (col == 0) tableText += "  ";
                  if (ai < 0.0) {
                      tableText += elem[index] + ": " + ai.toPrecision(5) + "   ";
                  } else {
                      tableText += elem[index] + ":  " + ai.toPrecision(5) + "   ";
                  }
              } else {
                  ai = Math.pow(10.0, x[index]);
                  if (col == 0) tableText += "  ";
                  if (x[index] >= -9.0) {
                      tableText += elem[index] + ": " + ai.toExponential(3) + "   ";
                  } else {
                      tableText += elem[index] + ": " + ai.toExponential(3) + "  ";
                  }
              }
              if (col == (cols - 1)) tableText += "\n";
          }
          if (col != (cols - 1)) tableText += "\n";
          for (var index = 0; index < cols; index++) {
              tableText += "---------------";
          }
          tableText += "\n";
          if (cols < 4) {
              tableText += "[Fe/H]: " + (x[25] - sol[25]).toFixed(4) + "\n";
              tableText += " [O/H]: " + (x[7] - sol[7]).toFixed(4) + "\n";
              tableText += " [O]+12: " + (x[7] + 12.0).toFixed(4) + "\n";
              tableText += "⟨Zgas⟩A>5: " + zgas.toPrecision(4) + " x Solar\n";
              tableText += "ni/nH: " + zen.toFixed(5) + "\n";
              tableText += "X: " + xi[0].toFixed(5) + " Y: " + xi[1].toFixed(5) +
                  " Z: " + xi[2].toFixed(5) + "\n"
              tableText += "µ_neu: " + mu_neu.toFixed(5) + "\n";
              tableText += "µ_ion: " + mu_ion.toFixed(5) + "\n";
              tableText += "µ_H: " + mu_hi.toFixed(5) + "\n";
          } else {
              tableText += "[Fe/H]: " + (x[25] - sol[25]).toFixed(4);
              tableText += " [O/H]: " + (x[7] - sol[7]).toFixed(4);
              tableText += " [O]+12: " + (x[7] + 12.0).toFixed(4) + "\n";
              tableText += "⟨Zgas⟩A>5: " + zgas.toFixed(4) + " x Solar; ";
              tableText += "ni/nH: " + zen.toFixed(5) + "\n";
              tableText += "X: " + xi[0].toFixed(5) + " Y: " + xi[1].toFixed(5) +
                  " Z: " + xi[2].toFixed(5) + "\n"
              tableText += "µ_neu: " + mu_neu.toFixed(5);
              tableText += "  µ_ion: " + mu_ion.toFixed(5);
              tableText += "  µ_H: " + mu_hi.toFixed(5) + "\n";
          }
          for (var index = 0; index < cols; index++) {
              tableText += "---------------";
          }
          sTable.innerHTML = tableText;
      }
      if (haveCharts == 1) {
          if (b1) b1.update();
          if (b2) b2.update();
      }
  }
//----------------------------------------------------------------------
//
// the internal x values array is always log[H] = 0.00; adjust offsets and logs
// for display formats.  Convert to log[H] when reading, convert to display when setting.
//
  function UpdateDisplayValues() {
      var n = sol.length;
      var x = new Array(n);
      GetValues(x);
      if (haveCharts == 1) {
          if (b1) {
              for (var i = 0; i < n; i++) {
                  b1.datasets[0].bars[i].value = x[i] + offset;
              }
              b1.options.scaleOverride = true;
              b1.options.scaleStartValue = offset - 12.0;
              var d = document.getElementById("legend2");
              if (offset < 1) {
                  d.innerHTML = aboutStr + ", log[X]";
              } else {
                  d.innerHTML = aboutStr + ", log[X] + " + offset.toFixed(1);
              }
          }
          if (b2) {
              var max = (x[0] - sol[0]);
              var min = (x[0] - sol[0]);
              for (var i = 1; i < n; i++) {
                  var z = (x[i] - sol[i]);
                  if (z >= -4.0) {
                      min = (z < min) ? z : min;
                      max = (z > max) ? z : max;
                  }
              }
              max = Math.ceil(max + 0.5);
              min = Math.floor(min - 0.5);
              b2.options.scaleStartValue = min;
              b2.options.scaleOverride = true;
              b2.options.scaleStepWidth = 0.5;
              b2.options.scaleSteps = Math.max(Math.round((max - min) / 0.5), 2);
              var d = document.getElementById("legend1");
              for (var i = 0; i < n; i++) {
                  b2.datasets[0].bars[i].value = Math.max(-5.0, x[i] - sol[i]);
              }
              d.innerHTML = aboutStr + ", [X/H] vs Solar 2009";
          }
      }
      DisplaySummary(x);
  }
  function GetValues(x) {
      var n = x.length;
      for (var index = 0; index < n; index++) {
          var ai = 0.0;
          var idx = index + 1;
          var id = "";
          if (idx < 10) {
              id = "A0" + idx.toString();
          } else {
              id = "A" + idx.toString();
          }
          ai = document.getElementById(id).value;
          if (logValues == 0) {
              ai  = Math.log(ai) / Math.LN10;
          } else {
              ai -= offset; // 0.00 or 12.0
          }
          x[index] = ai;
      }
  }
  function SetValues(x) {
      var n = x.length;
      // scale and display
      for (var index = 0; index < n; index++) {
          var ai = 0.0;
          var idx = index + 1;
          var id;
          if (idx < 10) {
              id = "A0" + idx.toString();
          } else {
              id = "A" + idx.toString();
          }
          if (logValues == 0) {
              ai = Math.pow(10.0, x[index] );
          } else {
              ai = (x[index] + offset);
          }
          if (logValues == 1) {
              document.getElementById(id).value = ai.toPrecision(5);
          } else {
              document.getElementById(id).value = ai.toExponential(4);
          }
      }
      UpdateDisplayValues();
  }
  function InitAndSetSolarValues() {
      var n = sol.length;

      logZeta = 0; // linear zeta
      zeta    = 0.000;
      DisplayZeta();

      haveCharts = 1;
      if (typeof Chart === "undefined") {
          haveCharts = 0;
      }
      if (haveCharts == 1) {
          Chart.defaults.global.animationEasing = "easeOutQuart";
          Chart.defaults.global.animationSteps = 20;
          //  Chart.defaults.global.animation = false;
          Chart.defaults.global.tooltipTemplate =
              "<%if (label){%><%=label%>: <%}%><%= value.toFixed(3) %>";
          Chart.defaults.global.multiTooltipTemplate = "<%= value.toFixed(3) %>";
          //
          // b1 is the yellow absolute values plot, only in logH=0 or logH=12
          //
          var abs = new Array(n);
          for (var i = 0; i < n; i++) {
              abs[i] = (sol[i] + 12.0);
          }
          var colChartDataAbsolute = {
              labels: elem,
              datasets: [{
                  label: "X",
                  fillColor: "rgba(240,240,220,0.4)",
                  strokeColor: "#dda",
                  HighlightFill: "#fff",
                  HighlightStroke: "rgba(240,240,240,1)",
                  data: abs
              }, ]
          }
          var ctx = document.getElementById("absolute").getContext("2d");
          b1 = new Chart(ctx).Bar(colChartDataAbsolute, {
              responsive: true,
              barStrokeWidth: 2,
              barValueSpacing: 0,
              barDatasetSpacing: 0,
              scaleOverride: true,
              scaleSteps: 7,
              scaleStepWidth: 2.0,
              scaleStartValue: 0.0
          });
          //
          // b2 is the blue relative solar values plot
          //
          var diff = new Array(n);
          for (var i = 0; i < n; i++) {
              diff[i] = 0.0;
          }
          var colChartDataRelative = {
              labels: elem,
              datasets: [{
                  label: "X-sol",
                  fillColor: "rgba(220,220,250,0.5)",
                  strokeColor: "#aad",
                  HighlightFill: "#fff",
                  HighlightStroke: "rgba(240,240,240,1)",
                  data: diff
              }, ]
          }
          ctx = document.getElementById("relative").getContext("2d");
          b2 = new Chart(ctx).Bar(colChartDataRelative, {
              responsive: true,
              barStrokeWidth: 2,
              barValueSpacing: 0,
              barDatasetSpacing: 0,
              scaleOverride: true,
              scaleSteps: 10,
              scaleStepWidth: 0.5,
              scaleStartValue: -4.0
          });
      } else {
          // no charts
          document.getElementById("charts").style.display = 'none';
      }
      SetValues(sol); // built in defaults
  }
//----------------------------------------------------------------------
