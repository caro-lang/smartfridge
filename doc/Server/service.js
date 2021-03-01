$( document ).ready(function() {
    httpGet("cmd=gaq");
});

function httpGet(parameter)
{
    var theUrl = "http://smartfridge5.chickenkiller.com:8080/smartfridge/service";//+parameter;
    //if(Session("token")!=null)
    //theUrl += "&token="+Session("token");
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "POST", theUrl, true ); // false for synchronous request
    //xmlHttp.setRequestHeader("cmd","gaq");
    xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlHttp.send( parameter );
    xmlHttp.onreadystatechange = function(){
        if(xmlHttp.readyState == XMLHttpRequest.DONE && xmlHttp.status == 200) {
            json = JSON.parse(xmlHttp.responseText);
            for (var index = 0; index < json.elementList.length; index++) {
                $("#content").append(json.elementList[index].name+"<br>");
                
            }
            
        }        
    }
}

