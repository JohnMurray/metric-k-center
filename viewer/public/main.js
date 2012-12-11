$(document).ready(function() {
  $("#result_selection").change(function() {
    var run_id = $(this).val();
    update_run_selection(run_id);
  });

  $("#run_selection").change(function() {
    var run_id = $("#result_selection").val();
    var k = parseInt($(this).val());
    update_gen_number(run_id, k);
  });

  $("#render_button").click(function () {
    get_run_data(send_to_render);
  });
});


/*
 * Update the run-selection dropdown w/ data from the
 * server when the result-selection dropdown is changed.
 */
function update_run_selection(run_id) {
  $.ajax({
      url: '/runs',
      type: 'post',
      data: {run_id: run_id},
      success: function(data) {
        json = JSON.parse(data);
        $("#run_selection").find('option').remove();

        ks = json.ks;
        for (var i = 0; i < ks.length; i++) {
          var op = $("<option />").text(ks[i]);
          $("#run_selection").append(op);
        };
      }
    });
}


/*
 * Update the generation number when the run-selection
 * dropdown is changed
 */
function update_gen_number(run_id, k) {
  $.ajax({
      url: '/gen-numbers',
      type: 'post',
      data: {run_id: run_id, k: k},
      success: function(data) {
        json = JSON.parse(data);
        $("#gen_number").find('option').remove();

        var generations = json.generation_numbers;
        for (var i = 0; i < generations.length; i++) {
          var op = $("<option />").text(generations[i]);
          $("#gen_number").append(op);
        };
      }
    });
}


/*
 * Get the run-data from the server based on the current
 * result-selection and run-selection.
 */
function get_run_data(on_fetch) {
  var run_id = $("#result_selection").val();
  var k = parseInt($("#run_selection").val());
  var gen = parseInt($("#gen_number").val());

  $.ajax({
    url: '/run-data',
    type: 'post',
    data: {
      run_id: run_id,
      k: k,
      generation: gen
    },
    success: on_fetch
  });
}

/*
 * Intermediary callback that will be used to transfer data
 * from the fetch to the render-method in a parsed format.
 */
function send_to_render(string_data) {
  var json_data = JSON.parse(string_data);
  render(json_data);
}

/*
 * Given (parsed) data, render the result to the render_box
 * (div). 
 */
function render(data) {
  var width = 700;
  var height = 500;
  if (typeof paper != 'undefined') { paper.remove(); }
  paper = new Raphael("render_box", width, height);

  // draw the nodes
  node_lookup = new Object();
  for (var i = 0; i < data.length; i++) {
    var node = data[i];
    var coord = node.coord;
    var x = (coord.x / 10000.0) * width;
    var y = (coord.y / 10000.0) * height;

    node.display_x = x;
    node.display_y = y;

    node_lookup[node.name] = node;

    if (node.s == null) {
      var circle = paper.circle(x, y, 10);
      circle.attr('fill', '#37A8D1')
    }
    else {
      var circle = paper.circle(x, y, 5);
      circle.attr('fill', '#ddd');
    }
  };

  for (var i = 0; i < data.length; i++) {
    var node = data[i];

    if (node.s == null) { continue; }

    var node_to = node_lookup[node.s];
    var move_str = "M" + node.display_x + "," + node.display_y;
    var to_str = "L" + node_to.display_x + "," + node_to.display_y;

    var line = paper.path(move_str + to_str);
    line.attr('stroke', '#37A8D1')
  };
}