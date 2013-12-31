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

    //hard code default week for now, should be 'current week'
    $('.week-bar button')[5].click();
});

function get_button_week(button) {
  return button.text().match(/\d+/)[0];
};