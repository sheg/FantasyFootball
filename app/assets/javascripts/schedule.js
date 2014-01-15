$(function() {
    $('.week-bar').on('click', 'button', function() {
        var $this = $(this)
        $this.closest('.week-bar').find('button').removeClass('highlight');
        $this.addClass('highlight');
        var selected_week = $(".game-" + get_button_week($this));
        selected_week.addClass('enable');
        if($('.schedule-games').hasClass('enable')) {
            $('.schedule-games').hide();
            $('.enable').show();
            $('.schedule-games').removeClass('enable');
        }
    });

    $("#team_id").on('change', function() {
        var selected_option = $(this).val();
        var endpoint = "/leagues/schedule/";
        var url = endpoint + selected_option;
        if(selected_option == "0") {
            console.log("cheese")
        } else {
            $.ajax(url, {
                success: function(response) {
                    var team_id = response["id"];
                    window.location.href = endpoint + team_id;
                    console.log(team_id);

                },
                error: function(response) {
                    console.log(response);
                }
            });
        }
    });

    //hard code default week for now, should be 'current week'
    if(window.location.pathname.match(/\/leagues\/\d+\/schedule/)) {
        $('.week-bar button')[5].click();
    }
});

function get_button_week(button) {
  return button.text().match(/\d+/)[0];
};