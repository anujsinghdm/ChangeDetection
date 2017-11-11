declare namespace LOCAL = "intel";



declare variable $_USER       := xdmp:get-current-user();
declare variable $_USERNAME   := translate( xdmp:get-request-field("USERNAME"), "0123456789nEcjdfsghiklaboKqrtRTuvDxzAeBCpFGmHPIJLwMOQNSYUVWyXZ", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
declare variable $_PASSWORD   := translate( xdmp:get-request-field("PASSWORD"), "0123456789nEcjdfsghiklaboKqrtRTuvDxzAeBCpFGmHPIJLwMOQNSYUVWyXZ", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");

xdmp:set-response-content-type("text/html")

,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,



<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <link rel="stylesheet" type="text/css" href="main.css" />

    <script type="text/javascript" src="js/Javascript.js">&#160;</script>

    
  </head>

  <body>
    <form action="/default.xqy">
      <input class="home" type="submit" value="Log Out" onclick="javascript:return confirm('Are you sure you want to log out?');"/>
    </form>   
    
    <div class="Panel">
       <a href="Ingest.xqy">Ingest datasets</a><br/>       
    </div>
    
    <div class="Panel">
       <a href="Operation.xqy?mode=extractfeatures">Feature Extraction</a><br/>       
    </div>
    
    <div class="Panel">
       <a href="Operation.xqy?mode=changedetection">Change detection and classification</a><br/>       
    </div>

  </body>
</html>
