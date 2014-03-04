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
    gridSize: 1,
    model:    graph
});

//$('svg').addClass('canvas');

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

var items = [["podmet", "red"], ["prisudok", "yellow"], ["predmet", "green"], ["privlastok", "#33CCFF"]];
var menu = d3.select('div .itemized');
var color = null;
var activeElement = null;
var text = null;

//create boxes in menu for sentence parts
menu.selectAll("div .item")
        .data(items)
        .enter()
        .append('div')
        .attr('class', 'item draggable')
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
            });
//            .on("dragstop", appendText);

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

