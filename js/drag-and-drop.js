 
//-------------------------------------------------
// Functional draft of a dragAll plugin 
//-------------------------------------------------
 
(function(){d3.experiments = {};
 
d3.experiments.dragAll = function() {
    this.on("mousedown", function(){grab(this, event)})
        .on("mousemove", function(){drag(this, event)})
        .on("mouseup", function(){drop(this, event)});
};
 
var trueCoordX = null,
    trueCoordY = null,
    grabPointX = null,
    grabPointY = null,
    dragTarget = null;
 
function grab(element, event){
    dragTarget = event.target;
    //// send the grabbed element to top
    dragTarget.parentNode.appendChild( dragTarget );
    d3.select(dragTarget).attr("pointer-events", "none");
    //// find the coordinates
    var transMatrix = dragTarget.getCTM();
    grabPointX = trueCoordX - Number(transMatrix.e);
    grabPointY = trueCoordY - Number(transMatrix.f);
};
 
function drag(element, event){
    var newScale = vizSVG.node().currentScale;
    var translation = vizSVG.node().currentTranslate;
    trueCoordX = (event.clientX - translation.x)/newScale;
    trueCoordY = (event.clientY - translation.y)/newScale;
    if (dragTarget){
        var newX = trueCoordX - grabPointX;
        var newY = trueCoordY - grabPointY;
        d3.select(dragTarget).attr("transform", "translate(" + newX + "," + newY + ")");
    }
};
 
function drop(element, event){
    if (dragTarget){
        d3.select(dragTarget).attr("pointer-events", "all");
        var targetElement = event.target;
        if(targetElement != vizSVG.node()){
            console.log(dragTarget.id + ' has been dropped on top of ' + targetElement.id);
        }
        dragTarget = null;
    }
};
})();
 