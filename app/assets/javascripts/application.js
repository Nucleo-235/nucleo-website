// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery
//= require bootstrap-sprockets
//= require best_in_place
//= require jquery_ujs
//= require best_in_place
//= require inplace_editing
//= require slick.min

$(document).ready(function() {
  /* Activating Best In Place */
  jQuery(".best_in_place").best_in_place();

  $('.open-menu').click(function(e) {
    e.preventDefault();

    $('nav#menu').show()
    $('nav#menu').addClass('shown');
    return false;
  });

  $('.close-menu').click(function(e) {
    e.preventDefault();

    $('nav#menu').hide();
    $('nav#menu').removeClass('shown');
    return false;
  });

  $('nav#menu .internal a').click(function(e) {
    $('nav#menu').hide();
    $('nav#menu').removeClass('shown');

    $('nav#menu .internal a').removeClass('active');
    $(this).addClass('active');
  });

  $('section#people ul').slick({
    autoplay: true,
    arrows: false,
  });

  $('section#people .goto-next').click(function(e) {
    e.preventDefault();

    $('section#people ul').slick('slickNext');

    return false;
  });
});

function setImagePreview(input, imageElement, noImageElement) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();

        reader.onload = function (e) {
            if (noImageElement)
              noImageElement.hide();
            imageElement.attr('src', e.target.result);
            imageElement.show();
        }

        reader.readAsDataURL(input.files[0]);
    } else {
      if (noImageElement)
        noImageElement.show();
      imageElement.hide();
    }
}