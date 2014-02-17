var items = [["podmet", "red"], ["prisudok", "yellow"], ["predmet", "green"], ["privlastok", "#33CCFF"]];
var menu = d3.select('div .itemized');
var color = null;
var activeElement = null;
var text = null;

var svg = d3.select('div .myContainer')
        .append('svg')
        .attr("class", "canvas");


//var drag = d3.behavior.drag()
//    .on("drag", move);

//function dragclick(){
//    alert("clicked!");
//}
//function dragmove(d) {
//  d3.select(this)
//      .attr("cx", d.x = Math.max(radius, Math.min(width - radius, d3.event.x)))
//      .attr("cy", d.y = Math.max(radius, Math.min(height - radius, d3.event.y)));
//}


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
            .on("dragstop", getCoordinates);

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
    $(".accept-text").droppable();
});

var getColor = function() {
    color = $('.ui-draggable-dragging').css("background-color");
};
var getCoordinates = function() {
    d3.select(".canvas")
            .on("mouseover", function() {
                var coordinates = d3.mouse(d3.select(".canvas")[0].pop());
                var newElement = d3.select(".canvas").append("g")
                        .attr("transform", "translate(" + coordinates[0] + "," + coordinates[1] + ")");

                newElement.append("rect")
                        .attr("width", 200)
                        .attr("height", 50)
                        .style("fill", color)
                        .on("mouseover", function() {
                            activeElement = this.parentNode;
                        })
                        .on("mouseout", function() {
                            activeElement = null;
                        })
                        .call(d3.behavior.drag().on("drag", move));
            });
            d3.select("body").on("mousemove", function() {
                d3.select(".canvas")
                        .on("mouseover", null);
            });
//      d3.select(".canvas").on("mouseover", null);
};

//function move(){
//    var dragged = d3.select(this);
//    dragged.filter(function(d){return d.selected;})
//            .attr("x", function(d){ return d.x += d3.event.dx; })
//            .attr("y", function(d){ return d.y += d3.event.dy; });
//}

var appendText = function() {
    if (activeElement != null) {
        d3.select(activeElement).append("text")
                .text(text)
                .attr({
                    x:80,
                    y:25
                });
        
        text = null;
    }
}

function move() {
    var dragTarget = d3.select(this);
    dragTarget.attr("x", function() {
        return +dragTarget.attr("x") + d3.event.dx;
    })
            .attr("y", function() {
                return +dragTarget.attr("y") + d3.event.dy;
            });
            
    var dragText = d3.select(this.parentNode.childNodes[1]);
    dragText.attr("x", function() {
        return +dragText.attr("x") + d3.event.dx;
    })
            .attr("y", function() {
                return +dragText.attr("y") + d3.event.dy;
            });
}