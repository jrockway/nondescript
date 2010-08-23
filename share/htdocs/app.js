var load = 0;
function loading(is_done){
    if(is_done){
        load--;
        if(load == 0){
            $('#loading').hide();
        }
    }
    else {
        $('#loading').show();
        load++;
    }
}

function start_loading(){
    loading(false);
}

function get_done_loading_cb(){
    return function () { loading(true) };
}

function publish(key, value) {
    $.ajax({
        type: "PUT",
        url: "/objects/" + key,
        data: value,
        success: get_done_loading_cb(),
        error:   get_done_loading_cb(),
        contentType: "application/json",
        dataType: "json"
    });
}

$(function() {
    $("#publish_button").click(function() {
        start_loading();
        publish($("#publish_key").val(), $("#publish_value").val());
    });
});

function subscribe(key, cb){
    var s = new DUI.Stream();

    s.listen('application/json', function(payload) {
        var obj = jQuery.parseJSON(payload);
        cb(obj);
    });

    s.load("/subscriptions/" + key);
}

var value_history = {};

function append_getter(){
    $("#subscribe_table").append(
        '<tr id="subscribe_row">'+
        '<td><input type="text" id="subscribe_set" name="subscribe_set" /></td>'+
        '<td><input type="text" id="subscribe_key" name="subscribe_key" /></td>'+
        '<td id="result_area">' +
        '<input type="button" id="subscribe_button" name="subscribe_button" value="+" />'+
        '</td>'+
        '</tr>'
    );

    $("#subscribe_button").click(function(){
        var set = $("#subscribe_set").val();
        var key = $("#subscribe_key").val();

        if(set && key){
            var result = "result_for_" + set + "___" + key;
            result = result.replace(".","__");
            $("#subscribe_row").replaceWith("<tr><td>" + set + "</td><td>" + key + '</td><td id="'+ result+'">Waiting...</td></tr>');
            subscribe(set, function(obj){
                if(value_history[set] == undefined){
                    value_history[set] = {};
                }
                if(value_history[set][key] == undefined){
                    value_history[set][key] = [];
                }
                value_history[set][key].push(obj[key]);
                $("#"+result).html(
                    '<span class="current">'+
                        obj[key] +
                        '</span><span class="sparkline"></span>'
                );
                $("#"+result+" .sparkline").sparkline(value_history[set][key]);
            });
            append_getter();
        }
    });
}

$(function(){ append_getter() });
