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
    <link rel="stylesheet" type="text/css" href="main.css?refresh{current-dateTime()}" />
    <script type="text/javascript" src="js/Javascript.js">&#160;</script>

    
  </head>

  <body>
    <form action="/default.xqy">
      <input class="home" type="submit" value="Log Out" onclick="javascript:return confirm('Are you sure you want to log out?');"/>
    </form>   
    <ul id="menu-bar">
         <li class="active"><a href="Ingest.xqy">INGEST DATASETS</a></li>
         {
         let $baseVersion := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:base-version
         let $checkBaseVersionPresent := collection(concat('http://marklogic.com/semantics/', $baseVersion))[1]
         let $deleteCollection := fn:concat('http://marklogic.com/semantics/features/delete/', $baseVersion)
         let $deleteCollectionPresent := collection($deleteCollection)[1]
         let $updatedVersion := xdmp:document-get('D:\Trinity\PhD\NextStage\code\config\config.xml')/*:config/*:change-detection/*:updated-version
         let $checkUpdatedVersionPresent := collection(concat('http://marklogic.com/semantics/',$updatedVersion))[1]
         return
           if($checkBaseVersionPresent and $checkUpdatedVersionPresent)
           then
             (
             <li><a href="Operation.xqy?mode=extractfeatures">FEATURE EXTRACTION</a></li>
             ,
             if($deleteCollectionPresent)
             then
               (
                 <li><a href="Operation.xqy?mode=changedetection">CHANGE DETECTION</a></li>
                 ,
                 <li><a href="viewReport.xqy" target="_blank">VIEW REPORT</a></li>
               )
             else ()
             )
           else ()
             
         }
         <li><a href="#">ABOUT</a></li>
         <li><a href="#">CONTACT US</a></li>
        </ul>
  </body>
</html>
