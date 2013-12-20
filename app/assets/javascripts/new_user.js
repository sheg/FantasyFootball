$(function() {
    $('.control-group').on("blur", ".email", function() {
        var $this = $(this);
        $this.val($this.val().trim());
        var control_group = $this.closest('.control-group');
        var error_span = "";
        var success_handler = function(response) {
            if(response == null || response == 1) {
                control_group.addClass("error");
                control_group.find("." + error_span).addClass('help-inline');
            } else {
                control_group.removeClass("error");
            }
            adjust_submit($this.closest("form").find(".btn-primary"));
        };

        control_group.find('span').removeClass('help-inline');
        if($this.val().length == 0) {
            error_span = "error-required";
            success_handler(null);
        } else if(!$this.val().match(/^[\w+\-.]+@[a-z\d\-.]+\.[a-z]+$/i)) {
            error_span = "error-invalid-format";
            success_handler(null);
        } else {
            error_span = "error-taken";
            $.ajax("/users/email_exists/" + $this.val(), {
                success: success_handler
            });
        }
    });
//    $('.control-group-password').on("keyup", "input", function() {
//        var control_group = $(this).closest(".control-group-password");
//        var password = control_group.find('.password');
//        var password_confirmation = control_group.find('.password-confirmation');
//        if(password.val() !=  password_confirmation.val()) {
//            control_group.addClass("error");
//            control_group.find(".password-mismatch").addClass('help-inline');
//        } else {
//            control_group.removeClass("error");
//        }
//    });

    $('.control-group-password').on("change", "input", function() {
        var control_group = $(this).closest(".control-group-password");
        var password = control_group.find('.password');
        var password_confirmation = control_group.find('.password-confirmation');
        if(password.val().length < 6) {
            control_group.addClass("error");
            control_group.find(".password-short").addClass('help-inline');
        } else {
            control_group.removeClass("error");
        }
    });
});

function adjust_submit(button) {
    var form = button.closest("form");
    var errors = form.find(".error");
    if(errors.length > 0) {
        button.attr("disabled", "disabled");
        button.addClass("disabled");
    } else {
        button.removeAttr("disabled");
        button.removeClass("disabled");
    }
}