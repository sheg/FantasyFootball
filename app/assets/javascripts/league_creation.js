$(function() {

  $("#entry-slider").on('change', function() {
    var newValue = $('#entry-slider').val();
    $("#extracted-fee-amount").html("$" + newValue);
  });

  $("#draft-date").datepicker({ dateFormat: 'yy-mm-dd' });
  $("#timepicker1").timepicker();
});