var projectListContainer = null;
var projectIDs = null;
var currentOpenProjectID = null;
var projectTemplate = null;

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
    $('.current-page').addClass('shown');
    $('.current-page .open-portfolio').addClass('shown');

    $('#portfolio').show();
    $('#portfolio').addClass('shown');
    // $('body').addClass('noscroll');

    return false;
  },
  openProject: function(e, self) {
    var link = $(self);
    return this.openProjectWithLink(e, link, link.attr("href"));
  },
  openProjectWithLink: function(e, link, projectIDWithHash) {
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
          InplaceEditingManager.bindAll('#' + project.slug);
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
    // $('body').removeClass('noscroll');

    $('.current-page').removeClass('shown');
    $('.current-page .open-portfolio').removeClass('shown');

    window.location.hash = '';

    return false;
  },
  onTurningOn: function() {
    projectListContainer = $('#portfolio .project-list');
    projectIDs = getProjectIDs();
    currentOpenProjectID = projectIDs.length > 0 ? projectIDs[0] : null;
    projectTemplate = currentOpenProjectID != null ? getClonedTemplate(currentOpenProjectID, projectListContainer) : null;
  },
  onTurningOff: function() {

  }
}