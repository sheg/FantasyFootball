var league_schedule = {
  init: function() {
    $('.week-bar').on('click', 'a', this.selectAndHighlightButton);
  },

  selectAndHighlightButton: function(event) {
    event.preventDefault();
    var $this = $(this);
    var ajax_url = $this.attr("href");

    $this.closest('.week-bar').find('a').removeClass('highlight');
    $this.addClass('highlight');

    $.ajax(ajax_url, {
      data: { 'use_json': 'json' },
      success: function(response) {
        var weeklyInfo = $(".weekly-league-info");
        weeklyInfo.html(response).show();
        weeklyInfo.trigger("loaded");
        new_url = $(this)[0].url.replace(/\&?use_json[^\&]+/, "");
        history.pushState({}, '', new_url)
      }
    });
  }
};

$(function() {
  league_schedule.init();
  var week_bar = $('.week-bar');
  var week_links = $('.week-bar a');

  if (week_links.length > 0) {
    var current_week = week_bar.data('current-week');
    if(current_week >= 1) {
      week_links[current_week - 1].click();
    } else {
      week_links[0].click();
    }
  }
});