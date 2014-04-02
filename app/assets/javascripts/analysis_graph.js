/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

//jointjs to handle svg canvas and actions on it
var graph = new joint.dia.Graph;

//TODO (jharinek) supply custom Element view
var paper = new joint.dia.Paper({
    el:       $('#paper'),
    class: 'canvas',
    gridSize: 80,
    model:    graph
});

//$('svg').addClass('canvas');

paper.on('cell:pointerdblclick', function(cellView, evt, x, y) {
    link(cellView.model);
});

// identify active element
graph.on('add', function() {
    var last = $('.Entity').last();
    if(last.size() != 0){
        d3.select("#"+last[0].id)
            .on("mouseover", function() {
                activeElement = this;
            })
            .on("mouseout", function() {
                activeElement = null;
            })
    }
});

var diagram = joint.shapes.erd;

var element = function(elm, x, y, color) {
    var cell = new elm({ position: { x: x, y: y }, attrs: { text: { text: "A" } }});
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
var text = null;

// create lines to represent connections between boxes
lines_menu.selectAll("div .item-line")
    .data(connections)
    .enter()
    .append('div')
    .attr('class', 'item-line line-draggable')
    .append('hr')
//    .attr('class', 'draggable')
    .attr('size', '3');
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
        revert: "invalid",
        revertDuration: '200',
        zIndex: 1000
    })
        .on("dragstart", function() {
            text = $(this).text()
        })
        .on("dragstop", appendText);

    //dragable lines
    $(".line-draggable").draggable({
        zIndex: 1000,
        helper: "clone",
        revert: "invalid",
        revertDuration: '200'
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
// TODO (jharinek) why this jumps out of scope??
                element(diagram.Entity, coordinates[0], coordinates[1], color);
            });
    }
    if((activeElement != null) && ($('.ui-draggable-dragging').prop("class").indexOf("item-line") >= 0)) {
        var model = toModel(activeElement);
        link(model);
    }


    d3.select("body").on("mousemove", function () {
        d3.select("#v_5")
            .on("mouseover", null);
    });
};

var toModel = function() {
    var model = null;
    graph.get('cells').find(function(cell) {
        if(cell.id == activeElement.attributes[1].value) {
            model = cell;
        }
    });
    return model;
};

var appendText = function() {
    if (activeElement != null) {
        var model       = toModel(activeElement);

        model.attr({ text: { text: text }});
    }
    text = null;
};
