
xdmp:set-response-content-type("text/html")

,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,

xdmp:invoke('./Operation.xqy')
,
<html>
<head>
<link rel="stylesheet" type="text/css" href="main.css?refresh{current-dateTime()}" />
</head>
    <body>
    <form action="/default.xqy">
      <input class="home" type="submit" value="Log Out" onclick="javascript:return confirm('Are you sure you want to log out?');"/>
    </form>
    <P>
        <b>Enter URLs for both versions of datasets</b>
    </P>
    <form action="/operation.xqy">
      <input type="hidden" name="mode" value="load"/>
      <label for="url">Dataset to upload in MarkLogic triple store</label>  
      <input type="text" name="url" class="inputbox"/>            
      <div>
      <input type="submit" name="urls" class="inputbox" value="SUBMIT"/>
      </div>
    </form>
    </body>
</html>