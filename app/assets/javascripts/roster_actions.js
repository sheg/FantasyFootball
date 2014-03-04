$(function() {

  var selectMove = null;
  var swapMove = null;
  var league_id = null;
  var team_id = null;
  var current_week = null;
  var rosterActive = false;

  $('.weekly-league-info').on('loaded', function() {
    league_id = $("#current_league").val();
    team_id = $("#current_team").val();
    current_week = $("#current_week").val();

    var byeRows = $(".player-row .bye").filter(function(index) { return $(this).text() === current_week; }).closest('tr');
    byeRows.addClass("info");
  });

  $('.weekly-league-info').on('click', '.submit-lineup', function() {
    var starterRows = $(".starters-table .player-row")
    var ids = "";

    starterRows.each(function() {
      if($(this).attr('data-player') == "") { return }
      if(ids.length > 0) { ids += "," }

      ids += $(this).attr('data-player');
    });

    var ajaxUrl = "/leagues/"+league_id+"/teams/"+team_id+"/set_lineup"

    $.ajax(ajaxUrl, {
      data: { 'current_week': current_week, 'starters': ids },
      success: function(response) {
        if(response != "") {
          $("#errors").html(response).show();
          $("#success").hide();
        } else {
          $("#success").show();
          $("#errors").html("").hide();
        }
      },

      error: function(response) {
        $("#errors").html(response).show();
        $("#success").hide();
      }
    });
  });

  $(".weekly-league-info").on('click', '.swap-actions .select', function(event) {
    event.preventDefault();
    selectMove = $(this).closest("tr");
    var position = selectMove.attr('data-position');
    var positions = position.split(",");

    $(".player-row .select").hide();
    $(this).closest(".player-row").find(".cancel").show();

    $.each(positions, function(index, position) {
      if(position == "") { return }
      $(".player-row[data-position*='," + position + ",'] .swap").show();
    });

    selectMove.addClass("success");
    $(this).closest(".swap-actions").find('.swap').hide();
  });

  $(".weekly-league-info").on('click', '.swap-actions .swap', function(event) {
    event.preventDefault();
    swapMove = $(this).closest("tr");
    selectMove.removeClass("success");
    selectMove.swap(swapMove);

    $(".weekly-league-info .swap-actions .select").show();
    $(".weekly-league-info .swap-actions .swap").hide();
    $(".weekly-league-info .swap-actions .cancel").hide();

    rosterActive = true;
  });

  $(".weekly-league-info").on('click', '.swap-actions .cancel', function(event) {
    event.preventDefault();
    $(".weekly-league-info .swap-actions .swap").hide();
    $(this).closest(".player-row").find(".cancel").hide();
    $(".weekly-league-info .swap-actions .select").show();
    selectMove.removeClass("success");
  });

  $(window).bind('beforeunload', function() {
    if (rosterActive) {
      return 'Lineup not saved!';
    }
  });

  $.fn.swap = function(other) {
    var thisPosition = $(this).find(".position").html();
    var otherPosition = $(other).find(".position").html();

    $(this).find(".position").html(otherPosition);
    $(other).find(".position").html(thisPosition);

    $(this).replaceWith($(other).after($(this).clone(true)));
  };
});