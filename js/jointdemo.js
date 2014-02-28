var graph = new joint.dia.Graph;

var paper = new joint.dia.Paper({
    el: $('#paper'),
    width: 800,
    height: 600,
    gridSize: 1,
    model: graph,
    elementView: GridMovementView
});

var erd = joint.shapes.erd;

var element = function(elm, x, y, label) {
    var cell = new elm({ position: { x: x, y: y }, attrs: { text: { text: label }}});
    graph.addCell(cell);
    return cell;
};

var link = function(elm1, elm2) {
    var myLink = new joint.dia.Link({ source: { id: elm1.id }, target: { id: elm2.id }});
    graph.addCell(myLink);
    return myLink;
};

var employee = element(erd.Entity, 100, 200, "Employee");
var salesman = element(erd.Entity, 100, 400, "Salesman");
var wage = element(erd.WeakEntity, 530, 200, "Wage");
var paid = element(erd.IdentifyingRelationship, 350, 190, "gets paid");
var isa = element(erd.ISA, 125, 300, "ISA");
var number = element(erd.Key, 0, 90, "number");
var nameEl = element(erd.Normal, 75, 30, "name");
var skills = element(erd.Multivalued, 150, 90, "skills");
var amount = element(erd.Derived, 440, 80, "amount");
var date = element(erd.Normal, 590, 80, "date");
var plate = element(erd.Key, 405, 500, "plate");
var car = element(erd.Entity, 430, 400, "Company car");
var uses = element(erd.Relationship, 300, 390, "uses");

link(employee, paid);
link(employee, number);
link(employee, nameEl);
link(employee, skills);
link(employee, isa);
link(isa, salesman);
link(salesman, uses);
link(car, uses);
link(car, plate);
link(wage, paid);
link(wage, amount);
link(wage, date);
var lnk = new joint.dia.Link({ source: { id: wage.id }, target: { x: 20, y: 20 }});
graph.addCell(lnk);

var GridMovementView = joint.dia.ElementView.extend({
     pointerdown: function(evt, x, y){
         var position = this.model.get('position');
//         var size = this.model.get.size('size');
        joint.dia.ElementView.prototype.pointerdown.apply(this, [evt, x, y]);
     },
     
     pointermove: function(evt, x, y){
         var position = function(){
             var grid = 40;
           var pos = this.model.get('position');
           var x   = pos.x % grid + (Math.floor(pos.x/grid) * 20);
           var y   = pos.y % grid + (Math.floor(pos.y/grid) * 20);
         };
         joint.dia.ElementView.prototype.pointermove.apply(this, [evt, position()[0], position()[1]]);
     }
});