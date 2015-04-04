// load only on task-edit view
if ($('#edit-task').length != 0) {
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
  var subject = "#428bc0";
  var object = "#c07742";
  var predicate = "#b642c0";
  var attribute = "#4cc042";
  var adverb = "#424cc0";

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
//--------------------------------------------------------------
// svg canvas operations and initialization

  var paper = new joint.dia.Paper({
    el: $('#paper'),
    gridSize: 1,
    model: graph
  });

  var element = function (elm, x, y, color, sentenceElement) {
    var cell = new elm({
      position: {x: x, y: y},
      attrs: {
        rect: {class: 'properties ' + sentenceElement + ' 0 0'},
        text: {text: ''},
        polygon: {fill: color, stroke: color}
      }
    });

    cell.attr({text: {transform: ''}});
    cell.attr({circle: {transform: ''}});

    graph.addCell(cell);

    return cell;
  };

  var link = function (linkType, elm, id) {
    var coordinates = elm.get('position');

    var newLink = new linkType({
      source: {id: elm.id},
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

  // TODO consider moving to document.ready
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

  var initializeDraggableElements = function () {
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
  };
//  ---------------------------------------------------
// Updating element properties
//  ---------------------------------------------------
  var reflectPropertiesChange = function () {
    properties = 'properties';
    properties += ' ' + ($('#level-1-select').select2('val') || '0');
    properties += ' ' + ($('#level-2-select').select2('val') || '0');
    var level_3 = $('#level-3-select').select2('val');
    if (typeof level_3 == "string") {
      properties += ' ' + level_3;
    } else {
      properties += ' ' + '0';
    }

    selected_element.attr({rect: {class: properties}});

    var newColor = items_hash[$('#level-1-select').select2('val')];
    selected_element.attr('polygon').fill = newColor;
    selected_element.attr('polygon').stroke = newColor;

    graph.fromJSON(graph.toJSON());
    initializeGraph();
  };

  var initializePropertiesBox = function () {
    $('#level-1-select').on('change', function (e) {
      populateProperties('level-2', 'Doplňujúca vlastnosť', buildData(boxProperties[e.val]['level-2']));
      $('#level-3-properties').attr('hidden', 'hidden');
      reflectPropertiesChange();
    });

    $('#level-2-select').on('change', function (e) {
      var level_1 = $('#level-1-select').select2('val');
      populateProperties('level-3', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2'][e.val]['level-3']));
      reflectPropertiesChange();
    });

    $('#level-3-select').on('change', function (e) {
      reflectPropertiesChange();
    });
  };

  var populateProperties = function (identifier, title, data, value) {
    if (data.length > 0) {
      var selectElement = $('#' + identifier + '-select');

      $('#' + identifier + '-title').text(title);

      selectElement.select2('destroy');
      selectElement.select2({data: data});
      selectElement.select2('val', value);

      $('#' + identifier + '-properties').removeAttr('hidden');
    }
  };

  var activateEditBox = function (level_1, level_2, level_3) {
    $('#properties-title').removeClass('text-muted');
    $('#save-properties').removeAttr('disabled');
    $('#level-1-properties').removeAttr('hidden');

    populateProperties('level-1', 'Vetný člen', buildData(boxProperties), level_1);
    populateProperties('level-2', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2']), level_2);
    if (level_2 != '0') {
      populateProperties('level-3', 'Doplňujúca vlastnosť', buildData(boxProperties[level_1]['level-2'][level_2]['level-3']), level_3);
    }
  };

  var deactivateEditBox = function () {
    $('#properties-title').addClass('text-muted');

    $('#level-1-select').select2('destroy');
    $('#level-2-select').select2('destroy');
    $('#level-3-select').select2('destroy');

    $('#level-1-properties').attr('hidden', 'hidden');
    $('#level-2-properties').attr('hidden', 'hidden');
    $('#level-3-properties').attr('hidden', 'hidden');

    $('#save-properties').attr('disabled', 'disabled');
  };

//  -----------------------------------------------------
// AJAX events
//  -----------------------------------------------------
  var saveCanvas = function () {
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
        setTimeout(saveCanvas, 10000);
      }
    });
  };

//  ------------------------------------------------------
//  Run all that is needed on document.ready
//  ------------------------------------------------------
  $(document).ready(function () {
    $('body').on('click', '#submit-task', function () {
      saveResult('2');
    });
    $('body').on('click', '#back', function () {
      saveResult('1');
    });

    initializeDraggableElements();
    initializePropertiesBox();
    saveCanvas();
  });
}
