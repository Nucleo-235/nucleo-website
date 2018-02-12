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
//= require bootstrap-sprockets
//= require best_in_place
//= require inplace_editing
//= require slick
//= require utils
//= require cloning
//= require desktop

$(document).ready(function() {
  /* Activating Inplace Editor */
  InplaceEditingManager.bindAll();

  var currentStrategy = desktopStrategy;
  currentStrategy.onTurningOn();

  $('.open-menu').click(function(e) {
    e.preventDefault();

    // $('nav#menu').show()
    $('nav#menu').addClass('shown');
    $('html').css('overflow', 'hidden');
    $('body').css('overflow', 'hidden');
    return false;
  });

  $('.close-menu').click(function(e) {
    return currentStrategy.closeMenu(e);
  });

  $('.open-portfolio').click(function(e) {
    return currentStrategy.openPortfolio(e, this);
  });
  $('.close-portfolio').click(function(e) {
    return currentStrategy.closePortfolio(e, this);
  });
  $('.close-all').click(function(e) {
    var menuEventResult = currentStrategy.closeMenu(e, this);
    var portfolioEventResult = currentStrategy.closePortfolio( { }, null);

    return menuEventResult && portfolioEventResult;
  });

  $('.open-project').click(function(e) {
    return currentStrategy.openProject(e, this);
  });

  $('.open-new-project').click(function(e) {
    return currentStrategy.openNewProject(e, this);
  });
  $('.open-related-portfolio').click(function(e) {
    return currentStrategy.openRelatedPortfolio(e, this);
  });

  $('#portfolio .move-to-next').click(function(e) {
    return currentStrategy.nextProject(e, this);
  });

  $('#portfolio .move-to-previous').click(function(e) {
    return currentStrategy.previousProject(e, this);
  });

  $('nav#menu .internal a').click(function(e) {
    $('nav#menu').removeClass('shown');
    $('html').css('overflow', '');
    $('body').css('overflow', '');

    $('nav#menu .internal a').removeClass('active');
  });

  $('section#people ul').slick({
    autoplay: true,
    arrows: false,
  });
  $(document).on( 'scroll', function(){
     if (($('section#people ul').offset().top - window.innerHeight + 250) < window.pageYOffset) {
        $('section#people ul').slick('slickPlay');
     } else {
        $('section#people ul').slick('slickPause');
     }
   });

  $('section#people .goto-next').click(function(e) {
    e.preventDefault();

    $('section#people ul').slick('slickNext');

    return false;
  });

  if (window.location.hash == '#portfolio') {
    currentStrategy.openPortfolio();
  } else if (window.location.hash.length > 1) {
    var found = $(window.location.hash);
    if (found && found.length > 0 && found.hasClass('project-item')) {
      currentStrategy.openProjectWithLink(this, null, window.location.hash);
    }
  }
});

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

$( document ).ready(function() {
  var lastViewHash = null;
  var lastScrollHash = null;

  function logPage(path) {
    if (typeof gtag !== 'undefined') {
      console.log('logPage', path);
      gtag('config', window.GA_CODE, {'page_path': path});
    } else {
      console.log('logPage local', path);
    }
  }

  function logIfNew(newHash) {
    if (newHash != lastViewHash) {
      lastViewHash = newHash;
      logPage(window.RELATIVE_PAGE_PATH_HASHED(newHash));
    }
  }

  function logScroll(scrollHash) {
    lastScrollHash = scrollHash;
    setTimeout(function() {
      logIfNew(lastScrollHash);
    }, 100);
  }

  $('.open-menu').click(function(e) {
    logIfNew("#menu");
  });

  $(window).on('hashchange', function() {
    //.. work ..
    logIfNew(window.location.hash);
  });

  var menu = $('nav#menu');
  var portifa = $('#portfolio');
  var scrollDelay = 800;
  var timeout = null;
  $(window).bind('scroll',function(){
    clearTimeout(timeout);
    timeout = setTimeout(function(){
      // console.log('scrolling stopped');

      if (menu.hasClass('shown') || portifa.hasClass('shown'))
        return; // no need to check scrolling
      
      $('.waypoint').each(function(index) {
        if (isPartialScrolledIntoView(this, 0.50)) {
          // console.log("isPartialScrolledIntoView", this.id)
          logScroll("#" + this.id);
        }
      });
    }, scrollDelay);
  });

  $("#what_we_do ul li .open-portfolio").click(function() {
    var item = $(this);
    var dataEventId = item.attr("data-event-id");
    console.log('event open-portfolio', dataEventId);
    gtag('event', 'open-portfolio', { 'source': dataEventId, });
  });

  $("#contact .content .links .email").click(function() {
    console.log('event email-clicked');
    gtag('event', 'email-clicked', { 'source': "contact", });
  });

  $("#contact .content .links .telephone").click(function() {
    console.log('event phone-clicked');
    gtag('event', 'telephone-clicked', { 'source': "contact", });
  });
});



function isPartialScrolledIntoView(elem, percentage)
{
    var docViewHeight = $(window).height();
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + docViewHeight;

    var elemHeight = $(elem).height();
    var elemTop = $(elem).offset().top;
    var elemBottom = elemTop + elemHeight;

    var isTopWithin = elemTop >= docViewTop;
    var isBottomWithin = elemBottom <= docViewBottom;

    if ((isTopWithin && isBottomWithin) || (!isTopWithin && !isBottomWithin)) {
      return true;
    } else {
      if (isTopWithin) {
        // console.log('isTopWithin', (elemBottom - (elemHeight * percentage)) <= docViewBottom);
        return (elemBottom - (elemHeight * percentage)) <= docViewBottom;
      } else {
        // console.log('isBottomWithin', (elemTop + (elemHeight * percentage)) >= docViewTop);
        return (elemTop + (elemHeight * percentage)) >= docViewTop;
      }
    }
}