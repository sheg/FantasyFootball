var league_schedule = {
  init: function() {
    $('.week-bar').on('click', 'button', this.selectAndHighlightButton);
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
  }
};

$(function() {
  league_schedule.init();

  //hard code default week for now, should use 'current week' ... when we arrive to it
  if ($('.week-bar button').length > 0) {
    $('.week-bar button')[5].click();
  }
});