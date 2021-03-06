//jointjs to handle svg canvas and actions on it
var graph = new joint.dia.Graph;
var counter = 0;
var selected_flag = false;
var selected_element = null;
var selected_element_properties_id = null;

var paper = new joint.dia.Paper({
  el: $('#paper'),
  gridSize: 1,
  model: graph
});

// colors
var subject   = "#428bc0";
var object    = "#c07742";
var predicate = "#b642c0";
var attribute = "#4cc042";
var adverb    = "#424cc0";

// Hash of properties
var boxProperties = {
  '1': {
    'value': 'podmet',
    'level-2': {
      '1': {'value': 'vyjadrený'},
      '2': {'value': 'nevyjadrený'}
    }
  },

  '2': {
    'value': 'prísudok',
    'level-2': {
      '1': {
        'value': 'slovesný',
        'level-3': {
          '1': {'value': 'plonovyznamové'},
          '2': {'value': 'neplnovyznamové'}
        }
      },
      '2': {
        'value': 'slovesno-menný'
      }
    }
  },

  '3': {
    'value': 'predmet',
    'level-2': {
      '1': {'value': 'nominatív'},
      '2': {'value': 'genitív'},
      '3': {'value': 'datív'},
      '4': {'value': 'akuzatív'},
      '5': {'value': 'lokál'},
      '6': {'value': 'inštrumentál'}
    }
  },

  '4': {
    'value': 'prívlastok',
    'level-2': {
      '1': {'value': 'zhodný'},
      '2': {'value': 'nezhodný'}
    }
  },

  '5': {
    'value': 'príslovkové určenie',
    'level-2': {
      '1': {'value': 'miesto'},
      '2': {'value': 'čas'},
      '3': {'value': 'spôsob'},
      '4': {'value': 'príčina'}
    }
  }
};

var connectionProperties = {
  'prisudzovaci': {},
  'priradovaci': {},
  'podradovaci': {}
};


var buildData = function(data){
  var result = [];

  if(data) {
    $.each(data, function (key, value) {
      result.push(
        {
          id: key,
          text: value['value']
        }
      );
    });
  }

  return result;
};

var clearSelectedElementReference = function(){
  selected_flag = false;
  selected_element = null;
  selected_element_properties_id = null;
};

paper.on('blank:pointerdown', function(evt, x, y) {
  if(selected_element != null) {
    selected_element.attr({
      polygon: { stroke: selected_element.attr('polygon').fill }
    });

    var element = getElementFromModel(selected_element)
    //on mouseout hide delete button
    $('#'+element.id + ' circle.delete-button').css('visibility', 'hidden');

    //on mouseout hide delete text button
    $('#'+element.id + ' circle.delete-text').css('visibility', 'hidden');

   clearSelectedElementReference();
   deactivateEditBox();
  }
});


// identify active element
graph.on('add', function () {
  var last = $('.Element').last();
  var txt = $('.box-content').last();
  var deleteBox = $('.delete-button').last();
  var deleteText = $('.delete-text').last();

  if (last.size() != 0) {
    d3.select("#" + last[0].id)
      .on("mouseover", function () {
        activeElement = toModel(this);
        originalColor = activeElement.attr("polygon").fill
        activeElement.attr({
          polygon: { stroke: 'orange' }
        });
        validContainer = true;

        // bring activeElement to top
        activeElement.toFront();

        //on mouseover show delete button
        deleteBox.css('visibility', 'visible');

        //on mouseover delete text button visible
        deleteText.css('visibility', 'visible');
      })
      .on("mouseout", function () {
        if(selected_element != activeElement) {
          activeElement.attr({
            polygon: { stroke: originalColor }
          });

          //on mouseout hide delete button
          deleteBox.css('visibility', 'hidden');

          //on mouseout hide delete text button
          deleteText.css('visibility', 'hidden');
        }
        validContainer = false;
        activeElement = null;
        originalColor = null;
      })
      //.on("dblclick", function () {
      //  initializeBoxModal(activeElement);
      //})
      .on("click", function () {
        if(selected_element != null) {
          selected_element.attr({
            polygon: { stroke: selected_element.attr('polygon').fill }
          });

          var element = getElementFromModel(selected_element);
          //on mouseout hide delete button
          $('#' + element.id + ' circle.delete-button').css('visibility', 'hidden');

          //on mouseout hide delete text button
          $('#' + element.id + ' circle.delete-text').css('visibility', 'hidden');

          selected_flag = false;
          selected_element_properties_id = null;

          deactivateEditBox();
        }

        if(selected_element != toModel(this)){
          selected_flag    = true;
          selected_element = toModel(this);

          // make edit-properties visible
          var properties = selected_element.attr('rect').class.split(' ').filter(Boolean);
          selected_element_properties_id = $('#' + this.id + ' .properties').attr('id');

          activateEditBox(properties[1], properties[2], properties[3]);
        }
        else{
          selected_flag    = false;
          selected_element = null;
          selected_element_properties_id = null;

          deactivateEditBox();
        }

      });
//        d3.select('#'+txt.attr('id'))
//            .on("mouseover", function() {
//                deleteText.css('visibility', 'visible');
//            })
//            .on("mouseout", function() {
//                deleteText.css('visibility', 'hidden');
//            });

  }
  d3.selectAll('.delete-button')
    .on("mousedown", function () {
//      TODO move to a function

      activeElement.attr('text').text.split(" ").map(function(item){
        $('span.text-draggable').filter(function () {
          return $(this).text() == item
        }).draggable('enable');
      });
      activeElement.remove();
      activeElement = null;

      if(selected_element){
        clearSelectedElementReference();
        deactivateEditBox();
      }
    });

  //not present yet
  d3.selectAll('.toolbox-button')
    .on("mousedown", function () {
      //TODO edit element properties
    });
  d3.selectAll('.delete-text')
    .on("mousedown", function () {
      activeElement.attr('text').text.split(" ").map(function(item){
        $('span.text-draggable').filter(function () {
          return $(this).text() == item
        }).draggable('enable');
      });

      activeElement.attr({'text': { text: "" }});

      activeElement.attr({ '.delete-text': { 'ref-x': 0, 'ref-y': 0 } })
    });
//  d3.selectAll('.link')
//    .on('dblclick', function(){
//      d3.event.preventDefault();
//      $('#connection-editing').modal('show');
//    });
});

// initialize callbacks on select menus and save button
$(document).ready(function() {
  $('#level-1-select').on('change', function (e) {
    populateProperties('level-2', 'Doplňujúca vlastnosť', buildData(boxProperties[e.val]['level-2']));
    $('#level-3-properties').attr('hidden', 'hidden');
  });

  $('#level-2-select').on('change', function (e) {
    var level_1 = $('#level-1-select').select2('val');
    populateProperties('level-3', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2'][e.val]['level-3']));
  });

  $('#level-3-select').on('change', function (e) {

  });

  $('#save-properties').click(function(){
    properties = 'properties';
    properties += ' ' + ($('#level-1-select').select2('val') || '0');
    properties += ' ' + ($('#level-2-select').select2('val') || '0');
    var level_3 = $('#level-3-select').select2('val');
    if(typeof level_3 == "string"){
      properties += ' ' + level_3;
    }else{
      properties += ' ' + '0';
    }

    selected_element.attr({ rect: { class: properties }});

    var newColor = items_hash[$('#level-1-select').select2('val')];
    selected_element.attr('polygon').fill   = newColor;
    selected_element.attr('polygon').stroke = newColor;

    graph.fromJSON(graph.toJSON());
    initializeGraph();
  });

  $('body').on('click', '#submit-task', function(){
    saveResult('2');
  });
  $('body').on('click', '#back', function(){
    saveResult('1');
  })
});

var populateProperties = function(identifier, title, data, value){
  if(data.length > 0) {
    var selectElement = $('#' + identifier + '-select');

    $('#' + identifier + '-title').text(title);

    selectElement.select2('destroy');
    selectElement.select2({data: data});
    selectElement.select2('val', value);

    $('#' + identifier + '-properties').removeAttr('hidden');
  }
};

var activateEditBox = function(level_1, level_2,  level_3){
  $('#properties-title').removeClass('text-muted');
  $('#save-properties').removeAttr('disabled');
  $('#level-1-properties').removeAttr('hidden');

  populateProperties('level-1', 'Vetný člen', buildData(boxProperties), level_1);
  populateProperties('level-2', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2']), level_2);
  if(level_2 != '0') {
    populateProperties('level-3', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2'][level_2]['level-3']), level_3);
  }
};

var deactivateEditBox = function(){
  $('#properties-title').addClass('text-muted');

  $('#level-1-select').select2('destroy');
  $('#level-2-select').select2('destroy');
  $('#level-3-select').select2('destroy');

  $('#level-1-properties').attr('hidden', 'hidden');
  $('#level-2-properties').attr('hidden', 'hidden');
  $('#level-3-properties').attr('hidden', 'hidden');

  $('#save-properties').attr('disabled', 'disabled');
};

//var initializeBoxModal = function(activeEl) {
//  var txt = d3.select('g>#' + activeEl.attributes.attrs.text.id);
//
//  var editableId = txt.node().parentNode.parentNode.id
//  var id = txt.node().parentNode.parentNode.id;
//  var properties = activeEl.attr('rect').class.split(' ');
//
//  if($(d3.select('#' + id).node()).attr('class').indexOf("Element") >= 0) {
//    $('#box').attr('class', editableId);
//
//    $('#sentence-element').val(properties[1]);
//    $('#gramatical-case').val(properties[2]);
//  }else{
//    $('#connection').attr('class', editableId);
//
//    $('#connection-type').val(properties[1]);
//  }
//
//  $('#box-editing').modal('show');
//};

var initializeText = function () {
  $('.text-draggable.disabled').draggable("disable");
}

var initializeGraph = function () {
  var boxes = $('.Element');

  var canvas = $('svg');
  canvas.attr('width', canvas.parent().width());
  canvas.attr('height', canvas.parent().height());

//  var background = new joint.shapes.erd.EntityBoundary({ size: { width: canvas.parent().width(), height: canvas.parent().height() },position: { x: 0, y: 0 }, attrs: { polygon: { fill: 'white', stroke: 'white' }}});
//  graph.addCell(background);

  boxes.each(function (index) {
    d3.select(this)
      .on("mouseover", function () {
        activeElement = toModel(this);
        originalColor = activeElement.attr("polygon").fill
        activeElement.attr({
          polygon: { stroke: 'orange' }
        });
        validContainer = true;

        // bring activeElement to top
        activeElement.toFront();

        //on mouseover show delete button
        $(d3.select('#' + this.id).select('.delete-button').node()).css('visibility', 'visible');

        //on mouseover delete text button visible
        $(d3.select('#' + this.id).select('.delete-text').node()).css('visibility', 'visible');
      })
      .on("mouseout", function () {
        if(selected_element != activeElement) {
          activeElement.attr({
            polygon: { stroke: originalColor }
          });

          //on mouseover show delete button
          $(d3.select('#' + this.id).select('.delete-button').node()).css('visibility', 'hidden');

          //on mouseover delete text button visible
          $(d3.select('#' + this.id).select('.delete-text').node()).css('visibility', 'hidden');
        }
        validContainer = false;
        activeElement = null;
        originalColor = null;

      })
      //.on("dblclick", function () {
      //  initializeBoxModal(activeElement);
      //})
      .on("click", function () {
        if(selected_element != null) {
          selected_element.attr({
            polygon: { stroke: selected_element.attr('polygon').fill }
          });

          var element = getElementFromModel(selected_element)
          //on mouseout hide delete button
          $('#'+element.id + ' circle.delete-button').css('visibility', 'hidden');

          //on mouseout hide delete text button
          $('#'+element.id + ' circle.delete-text').css('visibility', 'hidden');

          selected_flag = false;
          selected_element_properties_id = null;

          deactivateEditBox();
        }

        if(selected_element != toModel(this)){
          selected_flag    = true;
          selected_element = toModel(this);

          // make edit-properties visible
          var properties = selected_element.attr('rect').class.split(' ').filter(Boolean);
          selected_element_properties_id = $('#' + this.id + ' .properties').attr('id');

          activateEditBox(properties[1], properties[2], properties[3]);
        }
        else{
          selected_flag    = false;
          selected_element = null;
          selected_element_properties_id = null;

          deactivateEditBox();
        }



      });
  });
  d3.selectAll('.delete-button')
    .on("mousedown", function () {
    //      TODO move to a function

      activeElement.attr('text').text.split(" ").map(function(item){
        $('span.text-draggable').filter(function () {
          return $(this).text() == item
        }).draggable('enable');
      });

      activeElement.remove();
      activeElement = null;

      if(selected_element){
        clearSelectedElementReference();
        deactivateEditBox();
      }
    });
  d3.selectAll('.toolbox-button')
    .on("mousedown", function () {
      //TODO edit element properties
    });
  d3.selectAll('.delete-text')
    .on("mousedown", function () {
      activeElement.attr('text').text.split(" ").map(function(item){
        $('span.text-draggable').filter(function () {
          return $(this).text() == item
        }).draggable('enable');
      });

      activeElement.attr({'text': { text: "" }});

      activeElement.attr({ '.delete-text': { 'ref-x': 0, 'ref-y': 0 } });
      //var txt = $("text:contains('" + activeElement.attr('text').text + "')");
      //var x = txt.width()
      //activeElement.attr({ '.delete-text': { 'ref-x': x } })
    });
//  d3.selectAll('.link')
//    .on('dblclick', function(){
//      d3.event.preventDefault();
//      $('#connection-editing').modal('show');
//    });
};

var diagram = joint.shapes.nlp;

var element = function (elm, x, y, color) {
  var sentenceElement = '';

  switch(rgbToHex(color)) {
    case subject: sentenceElement = '1';
      break;
    case predicate: sentenceElement = '2';
      break;
    case object: sentenceElement = '3';
      break;
    case attribute: sentenceElement = '4';
      break;
    case adverb: sentenceElement = '5';
      break;
  }

  var cell = new elm({ position: { x: x, y: y }, attrs: { rect: { class: 'properties ' + sentenceElement + ' 0 0' }, text: { text: '', id: 'txt-' + counter }, polygon: { fill: color, stroke: color }}});

//  TODO set mouse position

  graph.addCell(cell);
  cell.on('change:position', function() {})
  counter++;

  return cell;
};

var link = function (elm, id) {
  var coordinates = elm.get('position');

  var newLink = new joint.dia.Link({
    source: { id: elm.id },
    target: {
      x: coordinates.x + 220,
      y: coordinates.y - 20
    }
  });

  newLink.label(0, {
    position: .5,
    attrs: {
      rect: { fill: 'white' },
      text: { fill: '#428bc0', text: connections[id] }
    }
  });
  graph.addCell(newLink);
  return newLink;
};


//d3js and jquery to handle drag and drop events to svg canvas

var items = [
  ["podmet", subject],
  ["prísudok", predicate],
  ["predmet", object],
  ["prívlastok", attribute],
  ["príslovkové určenie", adverb]
];


var items_hash = {
  "1": subject,
  "2": predicate,
  "3": object,
  "4": attribute,
  "5": adverb
};

var connections = {
  'assignative': "prisudzovací",
  'determinative': "určovací",
  'predicative': "priraďovací"
};

var boxes_menu = d3.select('div .itemized#boxes');
var lines_menu = d3.select('div .itemized#lines');
var color = null;
var activeElement = null;
var originalColor = null;
var validContainer = false;
var dropped = false;

// create boxes in boxes_menu for sentence parts
boxes_menu.selectAll("div .item-box")
  .data(items)
  .enter()
  .append('div')
  .attr('class', 'item-box draggable')
  .style('background-color', function (d) {
    return d[1];
  })
  .append('p')
  .attr('class', 'item-text')
  .text(function (d) {
    return d[0];
  });

//set draggable elements
$(document).ready(function () {
  //dragable rectangles
  $(".draggable").draggable({
    zIndex: 1000,
    helper: "clone",
    revert: "invalid",
    revertDuration: '200'
  })
    .on("dragstart", getColor)
    .on("dragstop", createElement);


  //draggable text
  $(".text-draggable").draggable({
    helper: "clone",
    revertDuration: '200',
    start: function (event, ui) {
      $(this).draggable("option", "revert", "invalid");

    },
    drag: function (event, ui) {
      if (validContainer) {
        $(this).draggable("option", "revert", false);
      }
    }
  })
    .on("dragstop", function () {
      appendText(this.id, $(this).text());
      if (dropped) {
        $(this).draggable('disable');
      }
      dropped = false;
    });

  //dragable lines
  $(".line-draggable").draggable({
    helper: 'clone',
    revertDuration: '200',
    start: function (event, ui) {
      $(this).draggable("option", "revert", "invalid");
    },
    drag: function (event, ui) {
      if (validContainer) {
        $(this).draggable("option", "revert", false);
        validContainer = false;
      }
    }
  })
    .on("dragstart", getColor)
    .on("dragstop", createElement);

//droppable container
  $(".myContainer").droppable({
    accept: ".draggable"
  });
//    $(".accept-text").droppable();


  // load graph
//    $.get( window.location.pathname.replace('edit', '') + "loadGraph", function( data ) {
//
//        alert( "Load was performed." );
//    });
});

$(document).ready(function () {
  graphString = $("div[data-value]").attr('data-value');
  if(isJsonString(graphString)){
    loadGraph(JSON.parse(graphString));
    initializeGraph();
    initializeText();
  }
});

$(document).ready(function() {
  $('body').keypress(function(event) {
    if(event.charCode == 127 && selected_element){
//      TODO move to a function
      selected_element.attr('text').text.split(" ").map(function(item){
        $('span.text-draggable').filter(function () {
          return $(this).text() == item
        }).draggable('enable');
      });

      selected_element.remove();
      selected_element = null;
      selected_element_id = null;
      selected_flag = false;

      deactivateEditBox();
    }
  });
});

//$(document).ready(function () {
//  var canvas = $('svg');
//  canvas.attr('width', canvas.parent().width());
//  canvas.attr('height', canvas.parent().height());
//});

var getColor = function () {
  color = $('.ui-draggable-dragging').css("background-color");
};

var createElement = function () {
  if ($('.ui-draggable-dragging').prop("class").indexOf("item-box") >= 0) {
    d3.select("#v_5")
      .on("mouseover", function () {
        var coordinates = d3.mouse(d3.select("#v_5")[0].pop());
        var el = element(diagram.Element, coordinates[0], coordinates[1], color);
      });
  }
  if ((activeElement != null) && ($('.ui-draggable-dragging').prop("class").indexOf("line-draggable") >= 0)) {
    var id = $('.ui-draggable-dragging span').attr('id');
    link(activeElement, id);
  }


  d3.select("body").on("mousemove", function () {
    d3.select("#v_5")
      .on("mouseover", null);
  });
};

var getElementFromModel = function(model){
  var element = null;

  $.each($('.element'), function(key, value){
    if(value.attributes['model-id'].value == model.id){
      element = value;
    }
  });

  return element;
};

var toModel = function (element) {
  var model = null;
  graph.get('cells').find(function (cell) {
    if (cell.id == element.attributes[1].value) {
      model = cell;
    }
  });

  return model;
};

var appendText = function (id, text) {
  if (activeElement != null) {
//    activeElement.attr('text').text.split(" ").map(function(item){
//      $('span.text-draggable').filter(function () {
//        return $(this).text() == item
//      }).draggable('enable');
//    });
    var new_text = activeElement.attr('text').text + " " + text
    activeElement.attr({ text: { text: new_text, id: id }});

    var txt = $("text:contains('" + activeElement.attr('text').text + "')");
    var x = txt.width()
    activeElement.attr({ '.delete-text': { 'ref-x': x } })

    dropped = true;
  }
};

var saveResult = function (state) {
  url = window.location.pathname.replace('edit', '');
  data = JSON.stringify(graph.toJSON());

  $.ajax({
    url: url,
    type: 'PATCH',
    data: {
      graph: data,
      state: state
    },
    async: true
  });
};

var loadGraph = function (json) {
  graph.fromJSON(json);
}

//var circleDelete = function (x, y) {
//  return new joint.shapes.basic.Circle({
//    position: { x: x, y: y },
//    size: { width: 16, height: 16 },
//    attrs: { text: { text: 'x' }, circle: { fill: 'red', class: 'delete-button' } },
//    name: 'deleteCircle'
//  });
//}
//
//var circleToolbox = function (x, y) {
//  return new joint.shapes.basic.Circle({
//    position: { x: x, y: y },
//    size: { width: 16, height: 16 },
//    attrs: { text: { text: 't' }, circle: { fill: 'green', class: 'toolbox-button' } },
//    name: 'toolboxCircle'
//  });
//}

$(document).ready(function worker() {
  url = window.location.pathname.replace('edit', '');
  data = JSON.stringify(graph.toJSON());

  $.ajax({
    url: url,
    type: 'PATCH',
    data: {
      graph: data,
      state: '1'
    },
    async: true,
    complete: function () {
      // Schedule the next request when the current one's complete
      setTimeout(worker, 10000);
    }
  });
});

// utilities

function componentToHex(c) {
  var hex = c.toString(16);
  return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(rgbString) {
  var s = rgbString.replace('rgb(', '');
  s = s.replace(')', '');
  s = s.replace(',', '');
  s = s.replace(',', '');

  var numericalValues = s.split(' ');

  return "#" + componentToHex(parseInt(numericalValues[0])) + componentToHex(parseInt(numericalValues[1])) + componentToHex(parseInt(numericalValues[2]));
}

function hexToRgb(hex) {
  var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return "rgb(" + parseInt(result[1], 16) + ", " + parseInt(result[2], 16) + ", " + parseInt(result[3], 16) + ")";
}

function isJsonString(str) {
  try {
    JSON.parse(str);
  } catch(e) {
    return false;
  }
  return true;
}
