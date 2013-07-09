var bezierTree;
var expandSingle;
var expandRecursively;
var collapse;
var collapseLeafs;
var update;
var collapseNonElements;
var showElementsOnly;
var showElementsAndAttributes;
var showAll;
var root;

var margin = {top: 20, right: 60, bottom: 20, left: 60},
    width = 2000 - margin.right - margin.left,
    height = 1080 - margin.top - margin.bottom;

showElementsOnly = function (){
  if(collapse != undefined && update != undefined){
    d3.selectAll('g.node').each(expandSingle);
    d3.selectAll('g.node').each(collapseLeafs);
    d3.selectAll('.element').each(collapseNonElements);
    update(bezierTree);
  }
}

showElementsAndAttributes = function (){
  if(collapse != undefined && update != undefined){
    d3.selectAll('g.node').each(expandRecursively);
    d3.selectAll('g.node').each(collapseLeafs);
    update(bezierTree);
  }
}

showAll = function(){
  if(expandRecursively != undefined && update != undefined){
    d3.selectAll('g.node').each(expandRecursively);
    update(bezierTree);
  }
}

function renderBezierTree(filePath) {
  var selectedDbName = $(".in.collapse").attr("id");
  // Set the default "Elements Only" radio button
  $('.elementsAndAttributes[db-name='+selectedDbName+']').prop("checked",true);
  // Set the "Facet" radio button for the database
  $("#facets-"+selectedDbName).prop("checked",true);

  var i = 0,
      duration = 750;

  var tree = d3.layout.tree()
    .size([height, width]);

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.y, d.x]; });

  // Remove any previous drawn svg's
  d3.select("svg").remove();

  var svg = d3.select("#treeChart").append("svg")
      .attr("height", height + margin.top + margin.bottom)
      .attr("width", width + margin.right + margin.left)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  var dataTree = {};

  d3.xml(filePath, "application/xml", function(xml) {
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

    bezierTree = dataTree;
    sort(bezierTree);

    root = dataTree;
    root.x0 = height / 2;
    root.y0 = 0;

    expandRecursively = function(d) {
      if (d._children) {
        d.children = d._children;
        d.children.forEach(expandRecursively);
        d._children = null;
      }
    }

    expandSingle = function(d) {
      if (d._children) {
        d.children = d._children;
        d._children = null;
      }
    }

    collapse = function(d) {
      if (d.children) {
        d._children = d.children;
        d._children.forEach(collapse);
        d.children = null;
      }
    }

    collapseLeafs = function(d) {
      if(d.children && d.children.length >0){
        d.children.forEach(collapseLeafs);
      }
      if(d.hasLeaves){
        collapse(d);
      }
    }

    collapseNonElements = function (d) {
      if (hasAttrElements(d)){
        collapse(d);
      }
    }

    collapseNonElementsRecursive = function (d) {
      collapseNonElements(d);
      if (d.children) {
        d.children.forEach(collapseNonElementsRecursive);
      };
    }

    root.children.forEach(collapseLeafs);

    update(root);
  });

  update = function(source) {
    // compute the new height
    var levelWidth = [1];
    var childCount = function(level, n) {
      if(n.children && n.children.length > 0) {
        if(levelWidth.length <= level + 1) levelWidth.push(0);
        levelWidth[level+1] += n.children.length;
        n.children.forEach(function(d) {
          childCount(level + 1, d);
        });
      }
    };
    childCount(0, root);

    // compute the new width for the svg
    var maxDepth=0, longestNodeText=0;
    var deepestNonCollapse = function (depth, node) {
      if(node.children && node.children.length > 0) {
        depth += 1;
        node.children.forEach(function (n) {
          deepestNonCollapse(depth,n);
          if(depth>maxDepth){
            maxDepth = depth;
          }
          var nodeTextWidth = n.name.getWidth();
          if(nodeTextWidth>longestNodeText){
            longestNodeText = nodeTextWidth;
          }
        });
      }
    }
    deepestNonCollapse(0, root);

    // Depth is zero based so 1 is added
    maxDepth = maxDepth+1 ;
    var newWidth = maxDepth ? (maxDepth*200) : width; // 200 pixels per deep level
    var newHeight = d3.max(levelWidth) * 20; // 20 pixels per line
    newWidth = newWidth + longestNodeText; // for the longest leaf node
    d3.select('svg').attr('height', newHeight+100);
    d3.select('svg').attr('width', newWidth);

    // Space between each node =  200
    // tree.size(height, nodes interdistances)
    var nodesSpacing = 200;
    tree = tree.size([newHeight, nodesSpacing]);

    // Compute the new tree layout.
    var nodes = tree.nodes(root).reverse(),
        links = tree.links(nodes);

    // Update the nodes…
    var node = svg.selectAll("g.node")
        .data(nodes, function(d) { return d.id || (d.id = ++i); });

    // Enter any new nodes at the parent's previous position.
    var nodeEnter = node.enter().append("g")
        .attr("class", function(d) { return "node " + (d.nodeType ? d.nodeType : "element") + " " + (d.hasLeaves ? "hasLeaves" : ""); })
        .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
        .on("click", click);

    // Node Text Displacment
    var x_disp = 10,
        y_disp = -6,
        dy_disp = "-.25em",
        count_x_disp = 10,
        count_y_disp = -6;
        text_x_disp = 3;

    nodeEnter.append("circle")
        .attr("class", "node-marker")
        .attr("r", 1e-6)
        .style("fill", function(d) { 
          if (hasChildren(d) && isCollapsed(d))
            return "orange";
          else if (!hasChildren(d))
            return "white";
          else
            return "#E6E6E6";
        })
        .style("stroke", function(d) { 
          if (hasChildren(d) && isCollapsed(d))
            return "orange";
          else
            return "#E6E6E6";
        });

    // Node count rect
    nodeEnter.append("rect")
        .attr("class", "countTextBox")  
        .attr("x", function(d) { return -(count_x_disp + (""+d.count).getWidth()); })
        .attr("y", count_y_disp)
        .attr("rx", "2")
        .attr("ry", "2")
        .attr("width", function(d) { return (""+d.count).getWidth() })
        .attr("height", "12");

    // Node count
    nodeEnter.append("text")
        .attr("class", "countText")
        .attr("x", function(d) { return -(count_x_disp); })
        .attr("y", text_x_disp)
        .attr("dy", 0)
        .attr("text-anchor", "end")
        .text(function(d) { return numberCommaDelimitedFormat(d.count) ; })
        .style("fill-opacity", 1e-6);

    var maxNodeTextLength = 20; // 20 character max 17 + 3 dots
    // Node name rect
    nodeEnter.append("rect")
        .attr("class", "nameTextBox")  
        .attr("x", x_disp )
        .attr("y", y_disp)
        .attr("rx", "2")
        .attr("ry", "2")
        .attr("width", function(d) {
          return (d.name.length > maxNodeTextLength && d.depth != (maxDepth-1) ) ? (d.name.substring(0,maxNodeTextLength-3)+"...").getWidth() : d.name.getWidth()
        })
        .attr("height", "12");
    
    // Node name text
    nodeEnter.append("text")
        .classed("nameText",true)  
        .attr("class", function (d) {
          return d.nodeType;
        })
        .attr("x", count_x_disp)
        .attr("y", 3)
        .attr("text-anchor", "start")
        .attr("tooltip", function (d) {
          return (d.name.length > maxNodeTextLength && d.depth != (maxDepth-1) ) ? "tooltip" : "";
        })
        .attr("data-original-title",function (d) {
          return (d.name.length > maxNodeTextLength && d.depth != (maxDepth-1) ) ? d.name : "";
        })
        .attr("data-container",function (d) {
          return (d.name.length > maxNodeTextLength && d.depth != (maxDepth-1) ) ? "body" : "";
        })
        .text(function(d) {
          return (d.name.length > maxNodeTextLength && d.depth != (maxDepth-1) ) ? (d.name.substring(0,maxNodeTextLength-3)+"...") : d.name
        });

    // Transition nodes to their new position.
    var nodeUpdate = node.transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    nodeUpdate.select("circle")
        .attr("r", 4.5)
        .style("fill", function(d) { 
          if (hasChildren(d) && isCollapsed(d))
            return "orange";
          else if (!hasChildren(d))
            return "white";
          else
            return "#E6E6E6";
        })
        .style("stroke", function(d) { 
          if (hasChildren(d) && isCollapsed(d))
            return "orange";
          else
            return "#E6E6E6";
        });

    nodeUpdate.select("text.nodeName")
        .attr("x", function(d) { return -d.name.getWidth(); })
        .attr("dy", dy_disp)
        .attr("text-anchor", "start")
        .style("fill-opacity", 1);

    // Transition exiting nodes to the parent's new position.
    var nodeExit = node.exit().transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
        .remove();

    nodeExit.select("text")
        .style("fill-opacity", 1e-6);

    // Update the links…
    var link = svg.selectAll("path.link")
        .data(links, function(d) { return d.target.id; });

    // Enter any new links at the parent's previous position.
    link.enter().insert("path", "g")
        .attr("class", "link")
        .attr("d", function(d) {
          var o = {x: source.x0, y: source.y0};
          return diagonal({source: o, target: o});
        });

    // Transition links to their new position.
    link.transition()
        .duration(duration)
        .attr("d", diagonal);

    // Transition exiting nodes to the parent's new position.
    link.exit().transition()
        .duration(duration)
        .attr("d", function(d) {
          var o = {x: source.x, y: source.y};
          return diagonal({source: o, target: o});
        })
        .remove();

    // Stash the old positions for transition.
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });

    $("text[tooltip='tooltip']").tooltip();

    if($("#treeChart").HasHorizontalScrollBar()){
      $("#topScroll").show();
    }else{
      $("#topScroll").hide();
    }
    
    // Set the width of the dummyContent div inside the topScroll div to make it scrollable
    $("#dummyContent").width($('svg').width());
  }

  // Toggle children on click.
  function click(d) {
    var zeroChildren = false;
    if (d.children) {
      zeroChildren = (d.children.length==0);
      d._children = d.children;
      d.children = null;
    } else {
      zeroChildren = (d._children.length==0);
      d.children = d._children;
      d._children = null;
    }
    if (!zeroChildren){
      update(d);
    }
  }
}

function fillChildrenNames (parent, treeNode) {
  if(parent.childNodes.length > 0){
    var children = parent.childNodes;
    for (var i=0; i<children.length; i++){
      if ( children[i].nodeType == 1 ){
        var obj = {};
        if( children[i].nodeName == "element" ){
          // node.attributes[0] => name="name"
          obj[children[i].attributes[0].nodeName] = children[i].attributes[0].nodeValue;
          // node.attributes[2] => count=<numerical_value>
          obj[children[i].attributes[2].nodeName] = children[i].attributes[2].nodeValue;
          obj["children"] = [];
          treeNode.push(obj);
          fillAttributes(children[i], obj);
          fillTextChildren(children[i], obj);
          fillChildrenNames(children[i], obj["children"]);
        }
      }
    }
  }
}

function fillTextChildren (parent, treeNode) {
  var children = parent.childNodes;
  for (var i=0; i<children.length; i++){
    if( children[i].nodeName == "text" ){
      var entryChilds = children[i].childNodes;
      for (var j=0; j<entryChilds.length; j++) {
        var obj = {};
        if ( entryChilds[j].nodeType == 1 ){
          // Set node name with the entry text value
          obj["name"] = entryChilds[j].childNodes[0].nodeValue;
          // Set node count with count value
          obj[entryChilds[j].attributes[0].nodeName] = entryChilds[j].attributes[0].nodeValue;
          obj["children"] = [];
          obj["_children"] = null;
          obj["nodeType"] = "leaf";
          treeNode["hasLeaves"] = true;
          treeNode["children"].push(obj);
        }
      }
    }
  }
}

function fillAttributes (parent, treeNode) {
  var children = parent.childNodes;
  for (var i=0; i<children.length; i++){
    var attr_obj = {};
    if( children[i].nodeName == "attribute" ){
      // Set attribute "name" to "its value"
      attr_obj[children[i].attributes[0].nodeName] = children[i].attributes[0].nodeValue;
      // Set node count with count value
      attr_obj[children[i].attributes[2].nodeName] = children[i].attributes[2].nodeValue;
      attr_obj["children"] = [];
      var entryChilds = children[i].childNodes;
      for (var j=0; j<entryChilds.length; j++) {
        var entry_obj = {};
        if ( entryChilds[j].nodeType == 1 ){
          // Set node name with the entry text value
          entry_obj["name"] = entryChilds[j].childNodes[0].nodeValue;
          // Set node count with count value
          entry_obj[entryChilds[j].attributes[0].nodeName] = entryChilds[j].attributes[0].nodeValue;
          entry_obj["children"] = [];
          // "Attributes" to be green
          entry_obj["nodeType"] = "leaf";

          // Attribute node to be purple
          attr_obj["nodeType"] = "attr";
          attr_obj["hasLeaves"] = true;
          attr_obj["children"].push(entry_obj);
        }
      }
      treeNode["children"].push(attr_obj);
    }
  }
}

function renderInfoFile (file) {
  d3.xml(file, "application/xml", function(xml) {
    var doc = xml.getElementsByTagName("database")[0];

    // Clear treeChart div
    d3.select("#treeChart").html("");

    var info = d3.select("#info");
    var info_content = "";
    info.html(info_content);

    info_content += "<h3>Database Properties:</h3>";
    var db_properties = doc.getElementsByTagName("databaseproperties")[0];
    info_content = fillChildrenContent(info_content, db_properties.childNodes);

    info_content += "<h3>Resource Properties</h3>";
    var res_properties = doc.getElementsByTagName("resourceproperties")[0];
    info_content = fillChildrenContent(info_content, res_properties.childNodes);

    info_content += "<h3>Indexes</h3>";
    var indexes = doc.getElementsByTagName("indexes")[0];
    info_content = fillChildrenContent(info_content, indexes.childNodes);

    info.html(info_content);
  });
}

function fillChildrenContent (info_content, nodeChildren) {
  for (var i=0; i<nodeChildren.length ; i++){
    var node = nodeChildren[i];
    if(node.nodeType==1){
      info_content +=  "   <b>"+ node.tagName +"</b>"+"    "+ node.textContent +"<br/>";
    }
  }
  return info_content;
}

function hasAttrElements (node){
  var children = node.children;
  if (children) {
    for (var i = 0; i < children.length; i++) {
      var nodeType = children[i].nodeType;
      if(nodeType != undefined && nodeType == "attr"){
        return true;
      }
    }
    return false;
  }
  return false;
}

function hasChildren (node) {
  if (
      (null == node.children && node._children.length == 0) ||
      (null == node._children && node.children.length == 0)
     )
    return false;

  return true;
}

function isCollapsed (node) {
  if (null == node.children && node._children.length > 0)
    return true;
  
  return false;
}

function sort (node){
  while(true){
    node.children.sort(function (a,b) { return b.count - a.count });
    for(var i = 0; i < node.children.length; i++)
      sort(node.children[i]);
    return;
  }
}