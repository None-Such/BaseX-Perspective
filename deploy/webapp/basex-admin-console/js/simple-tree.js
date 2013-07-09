$(document).ready(function(){
  $("a[href='#classic-tree']").parent().click(function () {
    getFileToDraw();
  });
});

var getFileToDraw = function () {
  // Get the name of the selected database
  // $(".in.collapse").attr("id")
  var dbFacetFile = "/basex-admin-console/xml/" + $(".in.collapse").attr("id") + "_facets.xml";
  var dataTree = {};
  d3.xml(dbFacetFile, "application/xml", function(xml) {
    var doc = xml.getElementsByTagName("document-node")[0];
    // Loop till you get the first child node to type "element"
    var i=0;
    while(!(doc.childNodes[i].nodeName == "element")) i++;
    var rootElement = doc.childNodes[i];
    // node.attributes[0] => name="name"
    dataTree[rootElement.attributes[0].nodeName] = rootElement.attributes[0].nodeValue;
    // node.attributes[2] => count=<numerical_value>
    dataTree[rootElement.attributes[2].nodeName] = rootElement.attributes[2].nodeValue;
    dataTree["children"] = [];
    fillChildrenNames(rootElement,dataTree.children);
    drawSimpleTree(dataTree);
  })
}

function drawSimpleTree (treeModel) {
  var treeModel;

  var w = 700,
      h = 900, 
      i = 0,
      barHeight = 20,
      duration = 400,
      root;

  var tree = d3.layout.tree()
      .size([h, 100]);

  var elbow = function (d, i) {
    return "M" + d.source.y + "," + d.source.x
        + "V" + d.target.x + "H" + d.target.y ;
  }

  // Clear classic-tree div content
  d3.select("#classic-tree").html("");

  var vis = d3.select("#classic-tree").append("svg:svg")
      .attr("width", w)
      .attr("height", h)
    .append("svg:g")
      .attr("transform", "translate(20,30)");

  treeModel.x0 = 0;
  treeModel.y0 = 0;
  update(root = treeModel);

  function update(source) {

    // Compute the flattened node list. TODO use d3.layout.hierarchy.
    var nodes = tree.nodes(root);

    var nodeCount = 0;
    
    // Compute the "layout".
    var maxY = 0; // y of farthest node
    var maxX = 0; // x of farthest node
    var widestNode = 0; // Width of widest node
    nodes.forEach(function(n, i) {
      n.x = i * barHeight;
      n.y = n.y / 3;
      nodeCount = i;
      if (n.y > maxY) {
        maxY = n.y;
      }
      if (n.x > maxX) {
        maxX = n.x;
      }
      if (n.name && n.name.getWidth() > widestNode) {
        widestNode = n.name.getWidth();
      }
    });
    // update height of svg
    nodeCount++; // nodeCount is zero based
    d3.select('#classic-tree svg').attr('height', 100 + maxX);
    d3.select('#classic-tree svg').attr('width', 30 + widestNode + maxY);
    
    // Update the nodes…
    var node = vis.selectAll("g.node")
        .data(nodes, function(d) { return d.id || (d.id = ++i); });
    
    var nodeEnter = node.enter().append("svg:g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
        .style("opacity", 1e-6);

    // Enter any new nodes at the parent's previous position.
    nodeEnter.append("svg:circle")
        .attr("r", 4)
        .on("click", click);

    // Node name 
    nodeEnter.append("svg:text")
        .attr("dy", 3.5)
        .attr("dx", 5.5)
        .text(function(d) { return d.name; });
    
    // Node count
    nodeEnter.append("svg:text")
        .attr("class", "countText")
        .attr("dy", -3.5)
        .attr("dx", function(d) { 
          return 5.5 + d.name.getWidth(); 
        })
        .style("fill", "black")
        .text(function(d) { return d.count; });

    // Transition nodes to their new position.
    nodeEnter.transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
        .style("opacity", 1);
    
    node.transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
        .style("opacity", 1)
      .select('circle')
        .style("stroke", function(d) { 
          if (hasChildren(d) && isCollapsed(d))
            return "orange";
          else
            return "#E6E6E6";
        })
        .style("fill", color);
    
    // Transition exiting nodes to the parent's new position.
    node.exit().transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
        .style("opacity", 1e-6)
        .remove();
    
    // Update the links…
    var link = vis.selectAll("path.link")
        .data(tree.links(nodes), function(d) { return d.target.id; });
    
    // Enter any new links at the parent's previous position.
    link.enter().insert("svg:path", "g")
        .attr("class", "link")
        .attr("d", function(d) {
          var o = {x: source.x0, y: source.y0};
          return elbow({source: o, target: o});
        })
      .transition()
        .duration(duration)
        .attr("d", elbow);
    
    // Transition links to their new position.
    link.transition()
        .duration(duration)
        .attr("d", elbow);
    
    // Transition exiting nodes to the parent's new position.
    link.exit().transition()
        .duration(duration)
        .attr("d", function(d) {
          var o = {x: source.x, y: source.y};
          return elbow({source: o, target: o});
        })
        .remove();
    
    // Stash the old positions for transition.
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });
  }

  // Toggle children on click.
  function click(d) {
    if (d.children) {
      d._children = d.children;
      d.children = null;
    } else {
      d.children = d._children;
      d._children = null;
    }
    update(d);
  }

  function color(d) {
    if (hasChildren(d) && isCollapsed(d))
      return "orange";
    else if (!hasChildren(d))
      return "white";
    else
      return "#E6E6E6"; 
  }
}

function updateHiddenColumnsTreeColors (all, hidden) {
  var textNodes = d3.selectAll("#hidden-columns-tree svg g text")
  textNodes.attr("class", function (d) {
    return updateTextNodeClass(d, all, hidden);
  });
}

function updateTextNodeClass (d, all, hidden) {
  if ( all.indexOf(d.name) != -1) {
    if( hidden.indexOf(d.name) !=-1 ){
      return "hidden-node-title modified-pointer";
    } else{ 
      return "shown-node-title modified-pointer";
    }
  }
}