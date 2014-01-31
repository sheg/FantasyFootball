var team_schedule = {
  init: function() {
    $(".team-panel").on("click", this.chooseSchedule);
  },

  chooseSchedule: function() {
    var $this = $(this);
    var team_id = $this.data("team")
    var league_id = $this.data("league");
    var ajax_url = "/leagues/"+league_id+"/teams/schedule";
    $(".team-panel").removeClass("highlight");
    $this.addClass("highlight");

    $.ajax(ajax_url, {
      data: { 'team_id': team_id, 'use_json': 'json' },
      success: function(response) {
        $("#dynamic_team_schedule").html(response).show();
        new_url = $(this)[0].url.replace(/\&?use_json[^\&]+/, "")
        history.pushState({}, '', new_url)
      },
      error: function(response) {
        console.log(response);
      }
    });
  }
};

$(function() {
  team_schedule.init();

  if($(".team-panel").length > 0) {
    $(".team-panel")[0].click();
  }
});