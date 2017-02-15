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

  function replaceCloneIDs(projectTemplate, newDataID, originalDataID) {
    var changeUrlItems = projectTemplate.find('*[data-bip-url]');
    $.each( changeUrlItems, function( index, value ) {
      $(value).attr('data-bip-url', $(value).attr('data-bip-url').replace(originalDataID, newDataID));
    });

    var changeFormActionItems = projectTemplate.find('form[action]');
    $.each( changeFormActionItems, function( index, value ) {
      $(value).attr('action', $(value).attr('action').replace(originalDataID, newDataID));
      $(value).attr('id', newDataID + '_form_' + index);
    });
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

  function cloneItem(template, newData, newDataId) {
    var clone = template.clone();
    clone.attr('id', newDataId);
    clone.removeClass('template');

    replaceCloneIDs(clone, newDataId, $(template).attr('id'));
    return clone;
  }

  function getClonedTemplate(elementId) {
    var clone = $('#' + elementId).clone();
    clone.attr('id', '__template__');
    clone.addClass('template');

    replaceCloneIDs(clone, '__template__', elementId);
    return clone;
  }

  var projectListContainer = $('#portfolio .project-list');
  var projectIDs = getProjectIDs();
  var currentOpenProjectID = projectIDs.length > 0 ? projectIDs[0] : null;
  var projectTemplate = currentOpenProjectID != null ? getClonedTemplate(currentOpenProjectID, projectListContainer) : null;

  var desktopStrategy = {
    openNewProject: function(e, self) {
      preventDefaultWithHash(e, self);

      $('#new-project').show();
      $('#new-project').addClass('shown');

      return false;
    },
    openPortfolio: function(e, self) {
      preventDefaultWithHash(e, self);

      $('.project-list').hide();
      $('#portfolio nav').show();

      $('#portfolio').show();
      $('#portfolio').addClass('shown');
      // $('body').addClass('noscroll');

      return false;
    },
    openProject: function(e, self) {
      preventDefaultWithHash(e, self);

      function doShow(projectID, element) {
        if (currentOpenProjectID) {
        // substituir por "slide out" ou só comentar, já que o novo vai ser colocado no lugar
          $('#' + currentOpenProjectID).hide();
        }

        $('#portfolio nav').hide();
        $('#new-project').hide();

        $('.project-list').show();
        element.show();
        currentOpenProjectID = projectID;
      }

      var link = $(self);
      var projectIDWithHash = link.attr("href");
      var projectID = projectIDWithHash.substring(1);
      var existentElement = $(projectIDWithHash);
      if (existentElement && existentElement.length > 0) {
        doShow(projectID, existentElement)
      } else {
        link.addClass('loading');
        $.get({ url: '/projects/' + projectID + '.json', contentType: "application/json;", dataType: "json" })
          .done(function(data) {
            var project = data;
            var clonedElement = cloneItem(projectTemplate, project, project.slug);
            setNewProjectValues(clonedElement, project);

            link.removeClass('loading');
            link.removeClass('error');

            clonedElement.appendTo(projectListContainer);
            doShow(projectID, clonedElement);
          })
          .fail(function(error) {
            link.removeClass('loading');
            link.addClass('error');
            console.log(error);
          })
          .always(function() {
          });
      }
    },
    closePortfolio: function(e, self) {
      preventDefaultIfPossible(e);

      $('#project').hide();
      $('#portfolio').hide();
      $('#portfolio').removeClass('shown');
      $('body').removeClass('noscroll');

      return false;
    },
    onTurningOn: function() {

    },
    onTurningOff: function() {

    }
  }
  var currentStrategy = desktopStrategy;

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