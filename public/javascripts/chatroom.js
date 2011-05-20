    function addmsg(type, msg){
        $("#messages").append( "<div class='msg "+ type +"'>"+ msg +"</div>");
    }

    function waitForMsg(){
        $.ajax({
            type: "GET",
            url: "/demo/chat",

            async: true,
            cache: false,

            success: function(data){
                addmsg("new", data);
                setTimeout(
                    'waitForMsg()',
                    1000 
                );
            },
            error: function(XMLHttpRequest, textStatus, errorThrown){
                addmsg("error", textStatus + " (" + errorThrown + ")");
                setTimeout(
                    'waitForMsg()', 
                    1500); 
            }
        });
    };


$(document).ready(function() {
  waitForMsg();
});
