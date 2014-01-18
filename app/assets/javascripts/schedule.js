var dynamic_schedule = {
  init: function() {
    $('.week-bar').on('click', 'button', this.selectAndHighlightButton);
    $("#team_id").on('change', this.chooseSchedule);
  },

  selectAndHighlightButton: function() {
    var $this = $(this);
    var schedule_games = $('.schedule-games');
    $this.closest('.week-bar').find('button').removeClass('highlight');
    $this.addClass('highlight');
    var selected_week = $(".game-" + get_button_week($this));
    selected_week.addClass('enable');

    if(schedule_games.hasClass('enable')) {
      schedule_games.hide();
      $('.enable').show();
      schedule_games.removeClass('enable');
    }

    function get_button_week(button) {
      return button.text().match(/\d+/)[0];
    }
  },

  chooseSchedule: function() {
    var $this = $(this);
    var last_option = $this.find("option").last().val();
    var selected_option = $this.val();
    var endpoint = "/leagues/schedule/";
    var all_url = endpoint + last_option;
    var selected_url = endpoint + selected_option;
    if(selected_option == "All") {
      $.ajax(all_url, {
        dataType: 'json',
        contentType: 'application/json',
        success: function(response) {
          var league_id = response["id"];
          window.location.href = "/leagues/"+league_id+"/schedule";
        }
      });
    } else { window.location.href = selected_url; }
  }
}

$(function() {
  dynamic_schedule.init();

  //hard code default week for now, should be 'current week'
  if(is_all_schedule_path(window.location.pathname)) {
    $('.week-bar button')[5].click();
  }

  function is_all_schedule_path(path) {
    return path.match(/\/leagues\/\d+\/schedule/);
  }
});