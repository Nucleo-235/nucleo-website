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
//= require cloning
//= require desktop

$(document).ready(function() {
  /* Activating Inplace Editor */
  InplaceEditingManager.bindAll();

  var currentStrategy = desktopStrategy;
  currentStrategy.onTurningOn();

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

  $('.open-portfolio').click(function(e) {
    return currentStrategy.openPortfolio(e, this);
  });
  $('.close-portfolio').click(function(e) {
    return currentStrategy.closePortfolio(e, this);
  });

  $('.open-project').click(function(e) {
    return currentStrategy.openProject(e, this);
  })

  $('.open-new-project').click(function(e) {
    return currentStrategy.openNewProject(e, this);
  })

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

function preventDefaultIfPossible(e) {
  try {
    e.preventDefault();
  } catch(ex) { }
}

function preventDefaultWithHash(e, self) {
  preventDefaultIfPossible(e);
  window.location.hash = $(self).attr('href');
}

function getProjectIDs() {
  var links = $('#portfolio nav .projects .project a');
  var IDs = [];
  for (var i = 0; i < links.length; i++) {
    var link = $(links[i]);
    IDs.push(link.attr('href').substring(1));
  }
  return IDs;
}

function setNewProjectValues(clonedElement, newData) {
  var element = $(clonedElement);
  if (element.hasClass('admin')) {
    element.find('.name-value span.best_in_place').text(newData.name);
    element.find('.name-value span.best_in_place').attr('data-bip-value');
    element.find('.summary-value span.best_in_place').html(newData.summary_html);
    element.find('.summary-value span.best_in_place').attr('data-bip-value');
    element.find('.image-value img').attr('src', newData.image);
    element.find('.thumb_image-value img').attr('src', newData.thumb_image);
  } else {
    element.find('.name-value').text(newData.name);
    element.find('.summary-value').html(newData.summary_html);
    element.find('.image-value img').attr('src', newData.image);
    element.find('.thumb_image-value img').attr('src', newData.thumb_image);
  }
}