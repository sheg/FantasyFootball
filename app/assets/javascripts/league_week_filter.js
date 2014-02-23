var league_schedule = {
  init: function() {
    $('.week-bar').on('click', 'button', this.selectAndHighlightButton);
  },

  selectAndHighlightButton: function() {
    var $this = $(this);
    var schedule_games = $('.schedule-games');
    $this.closest('.week-bar').find('button').removeClass('highlight');
    $this.addClass('highlight');
    var selected_week_value = $this.data("selected-week");
    var current_league = $this.closest('.week-bar').data("league");
    var selected_week = $(".game-" + selected_week_value);
    selected_week.addClass('enable');

    if(schedule_games.hasClass('enable')) {
      schedule_games.hide();
      $('.enable').show();
      schedule_games.removeClass('enable');
    }
    var current_url = window.location.pathname
    if(current_url.indexOf("standings") != -1) {
      ajax_url = "/leagues/"+current_league+"/standings";
      $.ajax(ajax_url, {
        data: { 'current_week': selected_week_value },
        success: function(response) {
          $("#dynamic_league_standings").html(response).show();
        }
      });
    }
  }
};

$(function() {
  league_schedule.init();

  if ($('.week-bar button').length > 0) {
    var current_week = $('.week-bar').data('current-week');
    if(current_week >= 1) {
      $('.week-bar button')[current_week - 1].click();
    } else {
      $('.week-bar button')[0].click();
    }
  }
});