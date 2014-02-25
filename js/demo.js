var items = [["podmet", "red"], ["prisudok", "yellow"], ["predmet", "green"], ["privlastok", "#33CCFF"]];
var menu = d3.select('div .itemized');
var color = null;
var activeElement = null;
var text = null;

var svg = d3.select('div .myContainer')
        .append('svg')
        .style("cursor", "default")
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
                        }).call(d3.behavior.drag().on("drag", move));
                        
                newElement.append("circle")
                        .attr("cx", 0)
                        .attr("cy", 25)
                        .attr("r",  10).call(d3.behavior.drag().on("drag", move));
                newElement.append("circle")
                        .attr("cx", 200)
                        .attr("cy", 25)
                        .attr("r",  10).call(d3.behavior.drag().on("drag", move));
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
}

function move() {
    var dragTarget = d3.select(this);
    dragTarget.attr("x", function() {
        return +dragTarget.attr("x") + d3.event.dx;
    })
            .attr("y", function() {
                return +dragTarget.attr("y") + d3.event.dy;
            });
            
    var dragText = d3.select(this.parentNode.childNodes[3]);
    dragText.attr("x", function() {
        return +dragText.attr("x") + d3.event.dx;
    })
            .attr("y", function() {
                return +dragText.attr("y") + d3.event.dy;
            });
            
    var dragCircleLeft  = d3.select(this.parentNode.childNodes[1]);
    var dragCircleRight = d3.select(this.parentNode.childNodes[2]);
    
    dragCircleLeft.attr("cx", function(){ return +dragCircleLeft.attr("cx") + d3.event.dx; })
                  .attr("cy", function(){ return +dragCircleLeft.attr("cy") + d3.event.dy; });
          
    dragCircleRight.attr("cx", function(){ return +dragCircleRight.attr("cx") + d3.event.dx; })
                   .attr("cy", function(){ return +dragCircleRight.attr("cy") + d3.event.dy; });
}

var drag_line = svg.append('svg:path')
        .attr('class', 'dragline')
        .attr('d', 'M0,0L0,0');
