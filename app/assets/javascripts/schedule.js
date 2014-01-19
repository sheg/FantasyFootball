var dynamic_schedule = {
  init: function() {
    $('.week-bar').on('click', 'button', this.selectAndHighlightButton);
    $("#team_id").change(this.chooseSchedule);
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
    var all_url = "/teams/"+last_option+"/schedule";
    var selected_url = "/teams/"+selected_option+"/schedule";

    if(selected_option == "All") {
      $.ajax(all_url, {
        dataType: 'json',
        contentType: 'application/json',
        success: function(response) {
          var league_id = response[0]["home_team"]["league_id"];
          window.location.href = "/leagues/"+league_id+"/schedule";
        }
      });
    } else {
//      $(".team-games tr").hide();
//      $.ajax(selected_url, {
//        dataType: 'json',
//        contentType: 'appication/json',
//        success: function(response) {
//          console.log(response);
//          $.each(response, function(index, game) {
//            var $tr = $('<tr>').append(
//              $('<td>').html(game["week"]),
//              $('<td>').html(game["home_team"]["name"]),
//              $('<td>').html(game["away_team"]["name"]),
//              $('<td>').html("128.11 - 120.42"));
//            $(".team-games").append($tr);
//          });
//        }
//      });
      window.location.href = selected_url;
    }
  }
}

$(function() {
  dynamic_schedule.init();

  //hard code default week for now, should use 'current week' ... when we arrive to it
  if(is_all_schedule_path(window.location.pathname)) {
    $('.week-bar button')[5].click();
  }

  function is_all_schedule_path(path) {
    return path.match(/\/leagues\/\d+\/schedule/);
  }
});