$(function() {

  $("#draft-date").datepicker({ dateFormat: 'yy-mm-dd' });
  $("#timepicker1").timepicker();

  $("#entry-slider").on('change', function() {
    var newValue = $('#entry-slider').val();
    if(newValue != '0') {
      $("#extracted-fee-amount").html("$" + newValue);
    } else {
      $("#extracted-fee-amount").html("FREE");
    }
  });

  $(".league-type-control").on("click", 'button', function() {
    $(this).closest(".league-type-control").find('button').removeClass('highlight');
    $(this).addClass('highlight');
  });

  $(".ppr-info").on("mouseenter", function() {
     $("#ppr-info-popup").show();
  });

  $(".ppr-info").on("mouseleave", function() {
    $("#ppr-info-popup").hide();
  });
});