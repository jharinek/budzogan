/*! JointJS v0.9.2 - JavaScript diagramming library  2014-09-17 

Added by Jozef Harinek
 */

if (typeof exports === 'object') {

    var joint = {
        util: require('../src/core').util,
        shapes: {},
        dia: {
            Element: require('../src/joint.dia.element').Element,
            Link: require('../src/joint.dia.link').Link
        }
    };
}

joint.shapes.nlp = {};

joint.shapes.nlp.Element = joint.dia.Element.extend({
    markup: '<g class="rotatable"><g class="scalable"><polygon class="outer"/><polygon class="inner"/></g><text class="box-content"/><rect/><circle class="delete-button"/><circle class="delete-text"/></g>',
    
    defaults: joint.util.deepSupplement({
        
        type: 'nlp.Element',
        size: { width: 150, height: 60 },
            attrs: {
            '.outer': {
                fill: '#2ECC71', stroke: '#27AE60', 'stroke-width': 2,
                points: '100,0 100,60 0,60 0,0'
            },
            '.inner': {
                fill: '#2ECC71', stroke: '#27AE60', 'stroke-width': 2,
                points: '95,5 95,55 5,55 5,5',
                display: 'none'
            },
            '.box-content': {
                text: '',
                'font-family': 'Arial', 'font-size': 14,
                ref: '.outer', 'ref-x': .5, 'ref-y': .5,
                'x-alignment': 'middle', 'y-alignment': 'middle'
            },
            '.delete-button': {
                fill: 'red', stroke: 'black',
                ref: '.outer', 'ref-x': 145, 'ref-y': 5,
                r: 5,
                visibility: 'hidden'
            },
            '.delete-text': {
                fill: 'red', stroke: 'black',
                ref: '.box-content', 'ref-x': 0, 'ref-y': 0,
                r: 4,
                visibility: 'hidden'
            }
        }

    }, joint.dia.Element.prototype.defaults)
});

joint.shapes.nlp.PredicativeRelationship = joint.dia.Link.extend({
    
        markup: [
        '<path class="connection" fill="url(#predicative-img)" stroke-width="20" />',
        '<path class="marker-source" fill="black" stroke="black" />',
        '<path class="marker-target" fill="black" stroke="black" />',
        '<path class="connection-wrap"/>',
        '<g class="labels"/>',
        '<g class="marker-vertices"/>',
        '<g class="marker-arrowheads"/>',
        '<g class="link-tools"/>'
    ].join(''),
    
    defaults: { type: 'nlp.PredicativeRelationship' },
    
    label: function(value){
        this.set('labels', [{ position: -20, attrs: { text: { dy: -8, text: value }}}]);
    }
});

joint.shapes.nlp.AssignativeRelationship = joint.dia.Link.extend({

    markup: [
        '<path class="connection" stroke="black" stroke-width="5"/>',
        '<path class="marker-source" fill="black" stroke="black" />',
        '<path class="marker-target" fill="black" stroke="black" />',
        '<path class="connection-wrap"/>',
        '<g class="labels"/>',
        '<g class="marker-vertices"/>',
        '<g class="marker-arrowheads"/>',
        '<g class="link-tools"/>'
    ].join(''),
    
    defaults: { type: 'nlp.AssignativeRelationship' }
});

joint.shapes.nlp.DeterminativeRelationship = joint.dia.Link.extend({

    markup: [
        '<path class="connection" stroke="black" stroke-width="3"/>',
        '<path class="marker-source" fill="black" stroke="black" />',
        '<path class="marker-target" fill="black" stroke="black" />',
        '<path class="connection-wrap"/>',
        '<g class="labels"/>',
        '<g class="marker-vertices"/>',
        '<g class="marker-arrowheads"/>',
        '<g class="link-tools"/>'
    ].join(''),

    defaults: { type: 'nlp.DeterminativeRelationship' }
});

if (typeof exports === 'object') {

    module.exports = joint.shapes.nlp;
}
