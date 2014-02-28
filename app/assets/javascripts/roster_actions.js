$(function() {

  $(".weekly-league-info").on('click', '.roster-action', function(event) {
    event.preventDefault();
    $this = $(this);
    $this.closest('tr').removeClass('success');
    $this.closest('tr').addClass('success');
  });
});