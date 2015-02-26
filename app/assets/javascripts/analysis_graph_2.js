//--------------------------------------------------------------
// variables initialization

// help variables
var graph = new joint.dia.Graph;
var diagram = joint.shapes.nlp;
var activeElement = null;
var selected_flag = false;
var selected_element = null;
var selected_element_properties_id = null;

// elements colors
var subject   = "#428bc0";
var object    = "#c07742";
var predicate = "#b642c0";
var attribute = "#4cc042";
var adverb    = "#424cc0";

// Properties hash
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

//--------------------------------------------------------------
// Utilities

var getColor = function () {
  color = $('.ui-draggable-dragging').css("background-color");
};

//--------------------------------------------------------------
// svg canvas operations and initialization

var paper = new joint.dia.Paper({
  el: $('#paper'),
  gridSize: 1,
  model: graph
});

var element = function (elm, x, y, color, sentenceElement) {
  var cell = new elm({ position: { x: x, y: y }, attrs: { rect: { class: 'properties ' + sentenceElement + ' 0 0' }, text: { text: '' }, polygon: { fill: color, stroke: color }}});

  cell.attr({text: {transform: ''}});
  cell.attr({circle: {transform: ''}});

  graph.addCell(cell);

  return cell;
};

var link = function (linkType, elm, id) {
  var coordinates = elm.get('position');

  var newLink = new linkType({
    source: { id: elm.id },
    target: {
      x: coordinates.x + 220,
      y: coordinates.y - 20
    }
  });

  //newLink.label(0, {
  //  position: .5,
  //  attrs: {
  //    rect: { fill: 'white' },
  //    text: { fill: '#428bc0', text: connections[id] }
  //  }
  //});

  graph.addCell(newLink);

  return newLink;
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

//--------------------------------------------------------------
// d3js to create elements in menu

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

//--------------------------------------------------------------
// jquery to initialize environment

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
});
