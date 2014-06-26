//jointjs to handle svg canvas and actions on it
var graph = new joint.dia.Graph;

//TODO (jharinek) supply custom Element view
var paper = new joint.dia.Paper({
    el:       $('#paper'),
    gridSize: 80,
    model:    graph
});

//paper.on('cell:pointerdblclick', function(cellView, evt, x, y) {
//    link(cellView.model);
//});

// identify active element
graph.on('add', function() {
    var last = $('.EntityDeletable').last();
    var txt  = $('.box-content').last();
    var deleteBox = $('.delete-button').last();
    var deleteText = $('.delete-text').last();

    if(last.size() != 0){
        d3.select("#"+last[0].id)
            .on("mouseover", function() {
                activeElement = toModel(this);
                originalColor = activeElement.attr("polygon").fill
                activeElement.attr({
                   polygon: { stroke: 'orange' }
                });
                validContainer = true;

                //on mouseover show delete button
                deleteBox.css('visibility', 'visible');

                //on mouseover delete text button visible
                deleteText.css('visibility', 'visible');
            })
            .on("mouseout", function() {
                activeElement.attr({
                    polygon: { stroke: originalColor }
                });

                //on mouseout hide delete button
                deleteBox.css('visibility', 'hidden');

                //on mouseout hide delete text button
                deleteText.css('visibility', 'hidden');

                activeElement  = null;
                originalColor  = null;
                validContainer = false;

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
        .on("mousedown", function(){
            var text = $('#'+activeElement.attr('text').id)
            text.draggable('enable');

            activeElement.remove();
            activeElement = null;
        });
    d3.selectAll('.toolbox-button')
        .on("mousedown", function(){
           //TODO edit element properties
        });
    d3.selectAll('.delete-text')
        .on("mousedown", function(){
            var text = $('#'+activeElement.attr('text').id)
            text.draggable('enable');

            activeElement.attr({'text': { text: "" }});
        });
});

var initializeText = function(){
  $('.text-draggable.disabled').draggable("disable")
}

var initializeGraph = function(){
  var boxes = $('.EntityDeletable')

  boxes.each(function(index){
      d3.select(this)
        .on("mouseover", function() {
          activeElement = toModel(this);
          originalColor = activeElement.attr("polygon").fill
          activeElement.attr({
            polygon: { stroke: 'orange' }
          });
          validContainer = true;

          //on mouseover show delete button
          $(d3.select('#' + this.id).select('.delete-button').node()).css('visibility', 'visible');

          //on mouseover delete text button visible
          $(d3.select('#' + this.id).select('.delete-text').node()).css('visibility', 'visible');
        })
        .on("mouseout", function() {
          activeElement.attr({
            polygon: { stroke: originalColor }
          });

          //on mouseout hide delete button
          $(d3.select('#' + this.id).select('.delete-button').node()).css('visibility', 'hidden');

          //on mouseout hide delete text button
          $(d3.select('#' + this.id).select('.delete-text').node()).css('visibility', 'hidden');

          activeElement  = null;
          originalColor  = null;
          validContainer = false;

        });
  });
  d3.selectAll('.delete-button')
    .on("mousedown", function(){
      var text = $('#'+activeElement.attr('text').id);
      text.draggable('enable');

      activeElement.remove();
      activeElement = null;
    });
  d3.selectAll('.toolbox-button')
    .on("mousedown", function(){
      //TODO edit element properties
    });
  d3.selectAll('.delete-text')
    .on("mousedown", function(){
      var text = $('#'+activeElement.attr('text').id)
      text.draggable('enable');

      activeElement.attr({'text': { text: "" }});
    });
}


var diagram = joint.shapes.erd;

var element = function(elm, x, y, color) {
    var cell = new elm({ position: { x: x, y: y }, attrs: { text: { text: '' }, polygon: { fill: color, stroke: color }}});

    graph.addCell(cell);

    return cell;
};

var link = function(elm) {
    var coordinates = elm.get('position');

    var newLink = new joint.dia.Link({
        source: { id: elm.id },
        target: {
            x: coordinates.x + 220,
            y: coordinates.y - 20
        }
    });
    graph.addCell(newLink);
    return newLink;
};


//d3js and jquery to handle drag and drop events to svg canvas

var items = [["podmet", "red"], ["prísudok", "yellow"], ["predmet", "green"], ["prívlastok", "#33CCFF"]];
var connections = ["prisudzovací", "určovací", "priraďovací"];
var boxes_menu = d3.select('div .itemized#boxes');
var lines_menu = d3.select('div .itemized#lines');
var color = null;
var activeElement = null;
var originalColor = null;
var validContainer = false;
var dropped = false;

// create lines to represent connections between boxes
//lines_menu.selectAll("div .item-line")
//    .data(connections)
//    .enter()
//    .append('div')
//    .attr('class', 'item-line line-draggable')
//    .append('hr')
//    .attr('size', '3');

// create boxes in boxes_menu for sentence parts
boxes_menu.selectAll("div .item-box")
    .data(items)
    .enter()
    .append('div')
    .attr('class', 'item-box draggable')
    .style('background-color', function(d) {
        return d[1];
    })
    .append('p')
    .attr('class', 'item-text')
    .text(function(d) {
        return d[0];
    });

//set draggable elements
$(document).ready(function() {
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
        start: function(event, ui){
            $(this).draggable("option", "revert", "invalid");

        },
        drag: function(event, ui){
            if(validContainer){
                $(this).draggable("option", "revert", false);
            }
        }
    })
        .on("dragstop", function() {
            appendText(this.id, $(this).text());
            if(dropped){
              $(this).draggable('disable');
            }
            dropped=false;
        });

    //dragable lines
    $(".line-draggable").draggable({
        helper: 'clone',
//            function(){
//            var el = $('<span>')
//                .attr('class', 'glyphicon glyphicon-minus')
//                .attr('id', '#dragged-line');
////                .style({
////                    position: 'absolute',
////                    left: 1,
////                    top: 2
////                });
//            return el;
//        },
        revertDuration: '200',
        start: function(event, ui){
            $(this).draggable("option", "revert", "invalid");
        },
        drag: function(event, ui){
            if(validContainer){
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

$(document).ready(function(){
  loadGraph(JSON.parse($("div[data-value]").attr('data-value')));
  initializeGraph();
  initializeText();
});

var getColor = function() {
    color = $('.ui-draggable-dragging').css("background-color");
};

var createElement = function () {
    if ($('.ui-draggable-dragging').prop("class").indexOf("item-box") >= 0) {
        d3.select("#v_5")
            .on("mouseover", function () {
                var coordinates = d3.mouse(d3.select("#v_5")[0].pop());
                element(diagram.EntityDeletable, coordinates[0], coordinates[1], color);
            });
    }
    if((activeElement != null) && ($('.ui-draggable-dragging').prop("class").indexOf("line-draggable") >= 0)) {
        link(activeElement);
    }


    d3.select("body").on("mousemove", function () {
        d3.select("#v_5")
            .on("mouseover", null);
    });
};

var toModel = function(element) {
    var model = null;
    graph.get('cells').find(function(cell) {
        if(cell.id == element.attributes[1].value) {
            model = cell;
        }
    });
    return model;
};

var appendText = function(id, text) {
    if (activeElement != null) {
        $('#'+activeElement.attr('text').id).draggable('enable');
        activeElement.attr({ text: { text: text, id: id }});
        dropped=true;
    }
};

//$(document).mousedown(function(event) {
//    $('#dragged-line').position({
//        my: "left bottom",
//        of: event,
//        collision: "fit"
//    });
//});
//$('body').mousemove(function(event){alert(event.pageX);})

// Define custom Entity element

joint.shapes.erd.EntityDeletable = joint.shapes.erd.Entity.extend({
    markup: [
        '<g class="rotatable">',
        '<g class="scalable">',
        '<polygon class="outer"/>',
        '<polygon class="inner"/>',
        '</g>',
        '<text class="box-content"/>',
        '<circle class="delete-button"/>',
        '<circle class="delete-text"/>',
        '</g>'
    ].join(''),

    defaults: joint.util.deepSupplement({

        type: 'erd.EntityDeletable',
        size: { width: 150, height: 60 },
        attrs: {
            '.delete-button': {
                fill: 'red', stroke: 'black',
                ref: '.outer', 'ref-x': 0, 'ref-y': 0,
                r: 5
            },
            '.delete-text': {
                fill: 'orange', stroke: 'black',
                ref: '.box-content', 'ref-x': 0, 'ref-y': 0,
                r: 4
            }
        }

    }, joint.shapes.erd.Entity.prototype.defaults),

    initialize: function () {

        _.bindAll(this, 'format');
        this.format();
        joint.shapes.erd.Entity.prototype.initialize.apply(this, arguments);
    },

    format: function () {
        var attrs = this.get('attrs');
    }
});

var saveResult = function(){
    url  = window.location.pathname.replace('edit', '');
    data = JSON.stringify(graph.toJSON());

    $.ajax({
        url: url,
        type: 'PATCH',
        data: { graph: data },
        async: true
    });
};

var loadGraph = function(json){
    graph.fromJSON(json);
}

var circleDelete = function(x, y) {
    return new joint.shapes.basic.Circle({
    position: { x: x, y: y },
    size: { width: 16, height: 16 },
    attrs: { text: { text: 'x' }, circle: { fill: 'red', class: 'delete-button' } },
    name: 'deleteCircle'
    });
}

var circleToolbox = function(x, y) {
    return new joint.shapes.basic.Circle({
    position: { x: x, y: y },
    size: { width: 16, height: 16 },
    attrs: { text: { text: 't' }, circle: { fill: 'green', class: 'toolbox-button' } },
    name: 'toolboxCircle'
    });
}

$(document).ready(function worker() {
  url  = window.location.pathname.replace('edit', '');
  data = JSON.stringify(graph.toJSON());

  $.ajax({
    url: url,
    type: 'PATCH',
    data: { graph: data },
    async: true,
    complete: function() {
      // Schedule the next request when the current one's complete
      setTimeout(worker, 10000);
    }
  });
});