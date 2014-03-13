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

var diagram = joint.shapes.erd;

var element = function(elm, x, y, color) {
    var cell = new elm({ position: { x: x, y: y }, attrs: { text: { text: "" }, polygon: { fill: color }}});
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

// create lines to represent connections between boxes
lines_menu.selectAll("div .item-line")
    .data(connections)
    .enter()
    .append('div')
    .attr('class', 'item-line draggable')
    .append('hr')
    .attr('size', '3');

//set draggable elements
$(document).ready(function() {
    //dragable rectangles
    $(".draggable").draggable({
        zIndex: 1000,
        helper: "clone",
        revert: "invalid"
    })
        .on("dragstart", getColor)
        .on("dragstop", createElement);

    //draggable text
    $(".text-draggable").draggable({
        helper: "clone",
        revert: "invalid",
        zIndex: 1000
    })
        .on("dragstart", function() {
            text = $(this).text()
        })
        .on("dragstop", appendText);

//droppable container
    $(".myContainer").droppable({
        accept: ".draggable"
    });
//    $(".accept-text").droppable();
});

var getColor = function() {
    color = $('.ui-draggable-dragging').css("background-color");
};

var createElement = function() {
    d3.select("#v_5")
        .on("mouseover", function() {
            var coordinates = d3.mouse(d3.select("#v_5")[0].pop());

            element(diagram.Entity, coordinates[0], coordinates[1], color);
        });
    d3.select("body").on("mousemove", function() {
        d3.select("#v_5")
            .on("mouseover", null);
    });
};

var appendText = function() {
    if (activeElement != null) {
        var translatedX = activeElement.childNodes[0].x.baseVal.value;
        var translatedY = activeElement.childNodes[0].y.baseVal.value
        d3.select(activeElement).append("text")
            .text(text)
            .attr({
                x:(80 + translatedX),
                y:(25 + translatedY)
            });

        text = null;
    }
};
