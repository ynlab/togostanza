function draw(_id,_fileName,_dataset,_opts,_rootName,_tag,_link,_tips,_width,_height,selection) {
  var userAgent = window.navigator.userAgent.toLowerCase();
  var m = [0, 1000, 0, 1000],
      i = 0,
      root;
  var vbox_x = 0;
  var vbox_y = 0;
  var vbox_width = vbox_default_width = m[1];
  var vbox_height = vbox_default_height = m[3];
  var tree = d3.layout.tree()
      .size([_width, _height]);
  var vis = d3.select("#"+_id).append("svg:svg")
         .attr("viewBox","" + parseInt(vbox_x) + " " + parseInt(vbox_y) + " " + parseInt(vbox_width) + " " + parseInt(vbox_height) + "");

  var div = d3.select("#"+_id);
  div.append("tooltip")
      .attr("id","tooltip");
  d3.json(_fileName,function(jsonfile) {
    var json = sparql2tree(jsonfile[_dataset], _opts,_rootName);
    root = json;
    root.x0 = vbox_height / 2;
    root.y0 = 0;
    update(root);
    d3.select('svg').attr("xmlns", d3.ns.prefix.svg).attr("xmlns:xmlns:xlink", d3.ns.prefix.xlink);
  });
  function update(source) {
    var duration = d3.event && d3.event.altKey ? 5000 : 500;

    var diagonal = d3.svg.diagonal()
        .projection(function(d) { return [d.y, d.x]; });


    // Compute the new tree layout.
    var nodes = tree.nodes(root).reverse();

    // Normalize for fixed-depth.
    nodes.forEach(function(d) { d.y = d.depth * 220; });
    nodes.forEach(function(d) {
      if (d['MEO ID'] == selection) {
        vbox_x = (d.y) - (vbox_default_width/2);
        vbox_y = (d.x) - (vbox_default_height/2) + 200;
        console.log('vbox_x=' + parseInt(vbox_x) + '/vbox_y=' + parseInt(vbox_y) + 'vbox_width=' + parseInt(vbox_width) + '/vbox_height=' + parseInt(vbox_height));
        return vis.attr("viewBox","" + parseInt(vbox_x) + " " + parseInt(vbox_y) + " " + parseInt(vbox_width) + " " + parseInt(vbox_height) + "");
      }
    });
    // Update the nodes…
    var node = vis.selectAll("g.node")
        .data(nodes, function(d) { return d.id || (d.id = ++i); });

    // Enter any new nodes at the parent's previous position.
    var nodeEnter = node.enter().append("svg:g")
        .attr("class", "node")
        .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
        .attr("id",function(d) { return (d[_tag]?d[_tag]:''); });

    
    nodeEnter.append("svg:circle")
        .attr("r", 1e-6)
        .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; })
        .on("click", function(d) {
          var url = (d[_link]?d[_link]:'');
          if (url.length > 0) {
            parent.location.href = url;
            parent.location.target = '_top';
          }
        });
    
    nodeEnter.append("svg:text")
        .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
        .attr("dy", ".35em")
        .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
        .text(function(d) { return d.name; })
        .style("fill-opacity", 1e-6)
        .on("click", function(d) {
          var url = (d[_link]?d[_link]:'');
          if (url.length > 0) {
            parent.location.href = url;
            parent.location.target = "_top";
          }
        });
    
    // Transition nodes to their new position.
    var nodeUpdate = node.transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    nodeUpdate.select("circle")
        .attr("r", 4.5)
        .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

    nodeUpdate.select("text")
        .style("fill-opacity", 1);

    // Transition exiting nodes to the parent's new position.
    var nodeExit = node.exit().transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
        .remove();

    nodeExit.select("circle")
        .attr("r", 1e-6);

    nodeExit.select("text")
        .style("fill-opacity", 1e-6);

    // Update the links…
    var link = vis.selectAll("path.link")
        .data(tree.links(nodes), function(d) { return d.target.id; });

    // Enter any new links at the parent's previous position.
    link.enter().insert("svg:path", "g")
        .attr("class", "link")
        .attr("d", function(d) {
          var o = {x: source.x0, y: source.y0};
          return diagonal({source: o, target: o});
        })
      .transition()
        .duration(duration)
        .attr("d", diagonal);

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
    add_tooltips_event();
  }
  
  //displays tooltip
  function add_tooltips_event() {
      tooltips = d3.select("tooltip");
      if (tooltips) {
        tooltips = d3.select("tooltip").append("table").attr("class", "tooltip").style("visibility", "hidden");
      }
      d3.selectAll("circle")
        .on("mousemove", function (d) {
        tooltips.transition().duration(200).style("opacity", 1.0);
        if (userAgent.indexOf("msie") == -1) {
          tooltips.html(function () {
            var tooltiptext = "";
            for (var key in _tips) {
              tooltiptext += ("<tr><td valign=\"top\">" + key + ": </td><td valign=\"top\">" + (d[key]?d[key]:"") + "</td></tr>");
            }
            return tooltiptext;
          })
        } else {
          tooltips.text(function () {
            var tooltiptext = "";
            for (var key in _tips) {
              tooltiptext += key + ":" + (d[key]?d[key]:"") + " ";
            }
            return tooltiptext;
          })
        }
        tooltips
          .style("left", (d3.event.pageX + 15) + "px")
          .style("top", (d3.event.pageY - 50) + "px")
          .style("visibility", "visible");
        })
        .on("mouseout", function (d) {
        tooltips.transition().duration(200).style("visibility", "hidden");
        })
        .on("mousedown", function (d) {
        tooltips.transition().duration(200).style("visibility", "hidden");
        });
      d3.selectAll("text")
        .on("mousemove", function (d) {
        tooltips.transition().duration(200).style("opacity", 1.0);
        if (userAgent.indexOf("msie") == -1) {
          tooltips.html(function () {
            var tooltiptext = "";
            for (var key in _tips) {
              tooltiptext += ("<tr><td valign=\"top\">" + key + ": </td><td valign=\"top\">" + (d[key]?d[key]:"") + "</td></tr>");
            }
            if (tooltiptext.length > 0) {
              tooltiptext = tooltiptext.slice(0, -2);
            }
            return tooltiptext;
          })
        } else {
          tooltips.text(function () {
            var tooltiptext = "";
            for (var key in _tips) {
              tooltiptext += key + ":" + (d[key]?d[key]:"") + " ";
            }
            if (tooltiptext.length > 0) {
              tooltiptext = tooltiptext.slice(0, -2);
            }
            return tooltiptext;
          })
        }
        tooltips
          .style("left", (d3.event.pageX + 15) + "px")
          .style("top", (d3.event.pageY - 50) + "px")
          .style("visibility", "visible");
        })
        .on("mouseout", function (d) {
        tooltips.transition().duration(200).style("visibility", "hidden");
        })
        .on("mousedown", function (d) {
        tooltips.transition().duration(200).style("visibility", "hidden");
        });
  }
  
  var drag = d3.behavior.drag().on("drag", function(d) {
      vbox_x -= d3.event.dx;
      vbox_y -= d3.event.dy;
      //vbox_width -= d3.event.dx;
      //vbox_height -= d3.event.dy;
      console.log('vbox_x=' + parseInt(vbox_x) + '/vbox_y=' + parseInt(vbox_y) + 'vbox_width=' + parseInt(vbox_width) + '/vbox_height=' + parseInt(vbox_height));
      return vis.attr("viewBox","" + parseInt(vbox_x) + " " + parseInt(vbox_y) + " " + parseInt(vbox_width) + " " + parseInt(vbox_height) + "");
  });
  vis.call(drag);
}

// Toggle children.
function toggle(d) {
  if (d.children) {
    d._children = d.children;
    d.children = null;
  } else {
    d.children = d._children;
    d._children = null;
  }
}

function sparql2tree(data, opts, root) {
  var tree = d3.map();
  var component = new Array();
  var parent = blanch = true;
  for (var data_i = 0; data_i < data.length; data_i++) {
    var blanch = {};
    parent = (data[data_i][opts.parent]?data[data_i][opts.parent]:root);
    
    // sets attributes
    for (var key in opts) {
        blanch[key] = data[data_i][opts[key]];
    }
    // links parent-child relation
    if (tree.has(parent)) {
      component = tree.get(parent);
    } else {
      component = new Array();
    }
    component.push(blanch);
    tree.set(parent, component);
  }
  function traverse(nodes) {
    var hash = new Array();
    if (nodes) {
      if (nodes.length > 1) {
        for (var index = 0 ; index < nodes.length ; index++) {
          var node = nodes[index];
          var result = {};
          for (var key in node) {
            if (key != 'children') {
              result[key] = node[key];
            } else {
              if (tree.get(node[key])) {
                //console.log(key);
                //console.log(node[key]);
                //console.log(tree.get(node[key]));
                result['size'] = tree.get(node[key]).length;
                result[key] = traverse(tree.get(node[key]));
              }
            }
          }
          hash.push(result);
        }
      } else if (nodes.length == 1)  {
        var node = nodes[0];
        var result = {};
        for (var key in node) {
          if (key != 'children') {
            result[key] = node[key];
          } else {
            if (tree.get(node[key])) {
              result['size'] = tree.get(node[key]).length;
              result[key] = traverse(tree.get(node[key]));
            }
          }
        }
        hash.push(result);
      }
    }
    return hash;
  }
  var result = {};
  for (var index = 0 ; index < tree.get(root).length ; index++) {
    var node = tree.get(root)[index];
    for (var key in node) {
      if (key != 'children') {
        result[key] = node[key];
      } else {
        if (tree.get(node[key])) {
          result['size'] = tree.get(node[key]).length;
          result[key] = traverse(tree.get(node[key]));
        }
      }
    }
  }
  return result;
}
