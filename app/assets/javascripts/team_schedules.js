var team_schedule = {
  init: function() {
    $("#team_id").change(this.chooseSchedule);
  },

  chooseSchedule: function() {
    var $this = $(this);
    var selected_option = $this.val();
    $.ajax("/leagues/2/teams/schedule", {
      data: { 'team_id': selected_option, 'use_json': 'json' },
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
});