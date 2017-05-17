var projectListContainer = null;
var projectIDs = null;
var currentOpenProjectID = null;
var projectTemplate = null;
var slickStarted = false;

function startSlick() {
  if (!slickStarted) {
    // $('.spin-loading').css('display', 'flex');
    $('#portfolio .project-list .project-slick').slick({
      autoplay: false,
      arrows: false,
      infinite: true,
      adaptiveHeight: true
    });

     $('#portfolio .project-list .project-slick').on('afterChange', function(event, slick, currentSlide){
      if (currentOpenProjectID) {
        window.location.hash = '#' + currentOpenProjectID;
        $(window).scrollTop(0);
        $('.spin-loading').css('display', 'none');
      }
    });
     slickStarted = true;
  }
}

function doOpenPortfolio() {

  $('.current-page').addClass('shown');
  $('.current-page .open-portfolio').addClass('shown');
  $('.open-related-portfolio').removeClass('shown');

  $('#portfolio').show();
  $('#portfolio').addClass('shown');
  // $('body').addClass('noscroll');

  startSlick();
}

var desktopStrategy = {
  closeMenu: function(e, self) {
    preventDefaultWithHash(e, self);

    // $('nav#menu').hide();
    $('nav#menu').removeClass('shown');
    $('html').css('overflow', '');
    $('body').css('overflow', '');

    return false;
  },
  openNewProject: function(e, self) {
    preventDefaultWithHash(e, self);

    $('#new-project').show();
    $('#new-project').addClass('shown');

    return false;
  },
  openPortfolio: function(e, self) {
    preventDefaultWithHash(e, self);

    $('.project-container').hide();
    $('#portfolio nav').show();
    doOpenPortfolio();

    return false;
  },
  openRelatedPortfolio: function(e, self) {
    this.openPortfolio(e, self);
  },
  nextProject: function(e, self) {
    preventDefaultIfPossible(e);
    var link = $(self);
    this.openProjectWithLink(e, link, link.attr("href"), 'slickNext');
    return false;
  },
  previousProject: function(e, self) {
    preventDefaultIfPossible(e);
    var link = $(self);
    this.openProjectWithLink(e, link, link.attr("href"), 'slickPrev');
    return false;
  },
  openProject: function(e, self) {
    preventDefaultWithHash(e, link);
    $('.spin-loading').css('display', 'flex');
    var link = $(self);
    return this.openProjectWithLink(e, link, link.attr("href"));
  },
  openProjectWithLink: function(e, link, projectIDWithHash, slideAnimation) {
    doOpenPortfolio();

    function doShow(projectID, element) {
      var indexOfProject = projectIDs.indexOf(projectID);
      var previousItemId = (indexOfProject < 1) ? projectIDs[projectIDs.length - 1] : projectIDs[indexOfProject - 1];
      var nextItemId = (indexOfProject == (projectIDs.length - 1)) ? projectIDs[0] : projectIDs[indexOfProject + 1];

      $('.project-container .move-to-previous').attr('href', '#' + previousItemId);
      $('.project-container .move-to-next').attr('href', '#' + nextItemId);

      $('#portfolio nav').hide();
      $('#new-project').hide();

      $('.open-related-portfolio').addClass('shown');
      $('.project-container').show();

      if (currentOpenProjectID) {
        stopVideos('#'+ currentOpenProjectID + ' .vimeo_project_content iframe');
        stopVideos('#'+ currentOpenProjectID + ' .youtube_project_content iframe');
        $('#' + currentOpenProjectID).removeClass('shown');
      }
      currentOpenProjectID = projectID;

      var index = element.attr('data-slick-index');
      if (slideAnimation) {
        $('#portfolio .project-list .project-slick').slick(slideAnimation);
      } else
        $('#portfolio .project-list .project-slick').slick('slickGoTo', index);
    }

    var projectID = projectIDWithHash.substring(1);
    var existentElement = $(projectIDWithHash);
    if (existentElement && existentElement.length > 0) {
      doShow(projectID, existentElement)
    } else {
      if (link)
        link.addClass('loading');
      $.get({ url: '/projects/' + projectID + '.json', contentType: "application/json;", dataType: "json" })
        .done(function(data) {
          var project = data;
          var clonedElement = cloneItem(projectTemplate, project, project.slug);
          setNewProjectValues(clonedElement, project);

          if (link) {
            link.removeClass('loading');
            link.removeClass('error');
          }

          clonedElement.appendTo(projectListContainer);
          InplaceEditingManager.bindAll('#' + project.slug);
          doShow(projectID, clonedElement);
        })
        .fail(function(error) {
          if (link) {
            link.removeClass('loading');
            link.addClass('error');
          }
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
    $('.open-related-portfolio').removeClass('shown');

    if (self)
      window.location.hash = '';

    return false;
  },
  initBackToTop: function() {
    // browser window scroll (in pixels) after which the "back to top" link is shown
    var offset = 300,
    //browser window scroll (in pixels) after which the "back to top" link opacity is reduced
    offset_opacity = 1200,
    offset_hide_element = $('#footer')[0].getBoundingClientRect().top,
    //duration of the top scrolling animation (in ms)
    scroll_top_duration = 700,
    //grab the "back to top" link
    $back_to_top = $('.cd-top');

    //hide or show the "back to top" link
    $(window).scroll(function(){
      ( $(this).scrollTop() > offset ) ? $back_to_top.addClass('cd-is-visible') : $back_to_top.removeClass('cd-is-visible cd-fade-out');
      offset_hide_element = $('#footer')[0].getBoundingClientRect().top;
      if( $(this).scrollTop() > offset_hide_element ) { 
        $back_to_top.addClass('cd-hide');
      } else if( $(this).scrollTop() > offset_opacity ) { 
        $back_to_top.addClass('cd-fade-out');
        $back_to_top.removeClass('cd-hide');
      } else {
        $back_to_top.removeClass('cd-fade-out');
        $back_to_top.removeClass('cd-hide');
      }
    });

    //smooth scroll to top
    $back_to_top.on('click', function(event){
      event.preventDefault();
      $('body,html').animate({
        scrollTop: 0 ,
        }, scroll_top_duration
      );
    });
  },
  onTurningOn: function() {
    projectListContainer = $('#portfolio .project-list .project-slick');
    projectIDs = getProjectIDs();
    currentOpenProjectID = projectIDs.length > 0 ? projectIDs[0] : null;
    projectTemplate = currentOpenProjectID != null ? getClonedTemplate(currentOpenProjectID, projectListContainer) : null;

    $('section#people .goto-next').click(function(e) {
      e.preventDefault();

      $('section#people ul').slick('slickNext');

      return false;
    });

    this.initBackToTop();
  },
  onTurningOff: function() {

  }
}
