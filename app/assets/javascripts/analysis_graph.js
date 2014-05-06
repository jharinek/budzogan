//jointjs to handle svg canvas and actions on it
var graph = new joint.dia.Graph;

//TODO (jharinek) supply custom Element view
var paper = new joint.dia.Paper({
    el:       $('#paper'),
    gridSize: 80,
    model:    graph
});

paper.on('cell:pointerdblclick', function(cellView, evt, x, y) {
    link(cellView.model);
});

// identify active element
graph.on('add', function() {
    var last = $('.Entity').last();
    if(last.size() != 0){
        d3.select("#"+last[0].id)
            .on("mouseover", function() {
                activeElement = toModel(this);
                originalColor = activeElement.attr("polygon").fill
                activeElement.attr({
                   polygon: { stroke: 'orange' }
                });
                validContainer = true;


            })
            .on("mouseout", function() {
                activeElement.attr({
                    polygon: { stroke: originalColor }
                });
                activeElement  = null;
                originalColor  = null;
                validContainer = false;

            })
    }
});

var diagram = joint.shapes.erd;

var element = function(elm, x, y, color) {
    var cell = new elm({ position: { x: x, y: y }, attrs: { text: { text: "" }, polygon: { fill: color, stroke: color }}});
    var circle = circleDelete(x-5, y-5);
    var toolbox = circleToolbox(x+12,y-5);

    cell.embed(circle);
    cell.embed(toolbox)

    graph.addCell(cell);
    graph.addCell(circle);
    graph.addCell(toolbox);

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
var text = null;
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
        .on("dragstart", function() {
            text = $(this).text()
        })
        .on("dragstop", function() {
            appendText();
            if(dropped){
              $(this).draggable('disable');
              dropped = false;
            }
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
});

var getColor = function() {
    color = $('.ui-draggable-dragging').css("background-color");
};

var createElement = function () {
    if ($('.ui-draggable-dragging').prop("class").indexOf("item-box") >= 0) {
        d3.select("#v_5")
            .on("mouseover", function () {
                var coordinates = d3.mouse(d3.select("#v_5")[0].pop());
                element(diagram.Entity, coordinates[0], coordinates[1], color);
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

var appendText = function() {
    if (activeElement != null) {
        activeElement.attr({ text: { text: text }});
        dropped=true;
    }
    text = null;
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
    markup: '<g class="rotatable"><g class="scalable"><polygon class="outer"><circle class="delete-button"/></polygon><polygon class="inner"/></g><text/></g>',

    defaults: joint.util.deepSupplement({

        type: 'erd.EntityDeletable',
        size: { width: 150, height: 60 },
        attrs: {
            '.delete-button': {
                fill: 'blue', stroke: 'blue',
                ref: '.outer', 'ref-x': .5, 'ref-y': .5,
                'x-alignment': 'right', 'y-alignment': 'top',
                size: { width: 20, height: 20 }
            }
        }

    }, joint.shapes.erd.Entity.prototype.defaults)
});


// Create a custom element.
// ------------------------

joint.shapes.html = {};
joint.shapes.html.Element = joint.shapes.erd.Entity.extend({
    defaults: joint.util.deepSupplement({
        type: 'html.Element'
    }, joint.shapes.erd.Entity.prototype.defaults)
});

// Create a custom view for that element that displays an HTML div above it.
// -------------------------------------------------------------------------

joint.shapes.html.ElementView = joint.dia.ElementView.extend({

    template: [
        '<div class="html-element">',
        '<button class="delete">x</button>',
        '</div>'
    ].join(''),

    initialize: function() {
        _.bindAll(this, 'updateBox');
        joint.dia.ElementView.prototype.initialize.apply(this, arguments);

        this.$box = $(_.template(this.template)());
        // Prevent paper from handling pointerdown.
        this.$box.find('input,select').on('mousedown click', function(evt) { evt.stopPropagation(); });
        // This is an example of reacting on the input change and storing the input data in the cell model.
        this.$box.find('input').on('change', _.bind(function(evt) {
            this.model.set('input', $(evt.target).val());
        }, this));
        this.$box.find('select').on('change', _.bind(function(evt) {
            this.model.set('select', $(evt.target).val());
        }, this));
        this.$box.find('select').val(this.model.get('select'));
        this.$box.find('.delete').on('click', _.bind(this.model.remove, this.model));
        // Update the box position whenever the underlying model changes.
        this.model.on('change', this.updateBox, this);
        // Remove the box when the model gets removed from the graph.
        this.model.on('remove', this.removeBox, this);

        this.updateBox();
    },
    render: function() {
        joint.dia.ElementView.prototype.render.apply(this, arguments);
        this.paper.$el.prepend(this.$box);
        this.updateBox();
        return this;
    },
    updateBox: function() {
        // Set the position and dimension of the box so that it covers the JointJS element.
        var bbox = this.model.getBBox();
        // Example of updating the HTML with a data stored in the cell model.
        this.$box.find('label').text(this.model.get('label'));
        this.$box.find('span').text(this.model.get('select'));
        this.$box.css({ width: bbox.width, height: bbox.height, left: bbox.x, top: bbox.y, transform: 'rotate(' + (this.model.get('angle') || 0) + 'deg)' });
    },
    removeBox: function(evt) {
        this.$box.remove();
    }
});

var circleDelete = function(x, y) {
    return new joint.shapes.basic.Circle({
    position: { x: x, y: y },
    size: { width: 16, height: 16 },
    attrs: { text: { text: 'x' }, circle: { fill: 'red' } },
    name: 'deleteCircle'
    });
}

var circleToolbox = function(x, y) {
    return new joint.shapes.basic.Circle({
    position: { x: x, y: y },
    size: { width: 16, height: 16 },
    attrs: { text: { text: 't' }, circle: { fill: 'green' } },
    name: 'toolboxCircle'
    });
}
