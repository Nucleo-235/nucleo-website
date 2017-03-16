function preventDefaultIfPossible(e) {
  try {
    e.preventDefault();
  } catch(ex) { }
}

function preventDefaultWithHash(e, self) {
  preventDefaultIfPossible(e);
  var link = $(self);
  if (link && link.length > 0)
    window.location.hash = link.attr('href');
}

function nextOrFirst(item, selector) {
  var next = item.next(selector);
  if (!next || next.length == 0)
    next = $(item.parent().children(selector)[0]);
  else
    next = $(next[0]);
  return next;
}

function previousOrLast(item, selector) {
  var previous = item.prev(selector);
  if (!previous || previous.length == 0) {
    var list = item.parent().children(selector);
    previous = $(list[list.length - 1]);
  } else {
    previous = $(previous[previous.length - 1]);
  }
  return previous;
}

function stopVideos(videoSelector) {
  var frames = $(videoSelector);
  for (var i = 0; i < frames.length; i++) {
    var frame = $(frames[i]);

    // saves the current iframe source
    var vidsrc = frame.attr('src');

    // sets the source to nothing, stopping the video
    frame.attr('src',''); 

    // sets it back to the correct link so that it reloads immediately on the next window open
    frame.attr('src', vidsrc);
  }
}