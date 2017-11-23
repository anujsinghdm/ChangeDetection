declare variable $_USER       := xdmp:get-current-user();
declare variable $_USERNAME   := xdmp:get-request-field("USERNAME");
declare variable $_PASSWORD   := xdmp:get-request-field("PASSWORD");



declare function local:InputFields()
{
  <form action="default.xqy" onsubmit="return SendForm();" method="post" id="login">

      <div class="LoginInnerPanel">
        <div class="LoginLine">User name</div>
        <div class="LoginLineContinued"><input id="USERNAME" name="USERNAME" size="21" style="font-family:sans-serif;font-size:14px"/></div>
        <div class="LoginLine">Password</div>
        <div class="LoginLineContinued"><input id="PASSWORD" name="PASSWORD" size="21" style="font-family:sans-serif;font-size:14px" type="password" /></div>
        <div class="LoginLine">          
          <input type="image" src="images/loginbutton.jpg"/>
        </div>
      </div>
  </form>
};


xdmp:add-response-header("Pragma", "No-Cache")

,

xdmp:set-response-content-type("text/html")

,


"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>"

,



<html>
  <head>
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <link rel="stylesheet" type="text/css" href="main.css?refresh{current-dateTime()}" />

    <script type="text/javascript" src="js/Javascript.js">&#160;</script>

    <script language="JavaScript">

      function SendForm()
      {{
         var USERNAME = document.getElementById("USERNAME").value;
         var PASSWORD = document.getElementById("PASSWORD").value;

         if ( USERNAME == null ) USERNAME = "";
         if ( PASSWORD == null ) PASSWORD = "";

         var EncryptedUserName = "";
         var EncryptedPassword = "";

         if ( PASSWORD == "" )
         {{
           alert("Please enter a password");

           return false;
         }}

         if ( USERNAME == "" )
         {{
           alert("Please enter a user name");

           document.getElementById("USERNAME").value = "[name here]";

           return false;
         }}


         EncryptedUserName = EncryptUserName(USERNAME);
         EncryptedPassword = EncryptPassword(PASSWORD);

         document.getElementById("USERNAME").value = EncryptedUserName;
         document.getElementById("PASSWORD").value = EncryptedPassword;

         return true;
      }}

    </script>
  </head>

  <body>

    <div class="headtext" style="font-size:36px;color:#808080"><b>KUL FRAMEWORK</b></div>
    

    <div class="LoginPanel">
      {
        if ( not($_USERNAME) )
        then
          local:InputFields()
        else
          let $_ := xdmp:log($_USERNAME)
          let $_ := xdmp:log($_PASSWORD)
          return
          if ( xdmp:login($_USERNAME, $_PASSWORD) )
          then
            (
            xdmp:set-session-field("user",$_USERNAME),
            xdmp:redirect-response( "main.xqy" )
            )
          else
            (: LOGIN FAILURE  - Cause = password or user name wrong :)
            <div>
              {
                local:InputFields()
              }
              <div class="LoginError">FAILED - Please try again</div>
            </div>
      }
    </div>

    <div class="Footer">
      <div class="Para">&#169; {fn:substring(xs:string(fn:current-date()),1,4)} KUL Framework All Rights Reserved</div>
    </div>
  </body>
</html>