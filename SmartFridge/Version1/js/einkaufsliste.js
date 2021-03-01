/**
 * Created by Koray on 10.06.17.
 */

$('#product-form').submit(function(eventObject) {
    eventObject.preventDefault(); // Form won't get submitted

    var productname      = $('#productname').val();
    var count            = $('#count').val();

    $('.dataList').append('<tr>' +
        '<td>' + productname + '</td>' +
        '<td>' + count + '</td>' +
        '</tr>');
});