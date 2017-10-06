// In Dart, anything preceeded by an underscore (_) is a private function/variable

import 'dart:math';

class LocationOccupied implements Exception {}

class World {

  int _width;
  int _height;
  int tick;
  Map<String, Cell> _cells = {};
  List<List<int, int>> _cached_directions = [
    [-1, 1],  [0, 1],  [1, 1], // above
    [-1, 0],           [1, 0], // sides
    [-1, -1], [0, -1], [1, -1] // below
  ];

  World(this._width, this._height) {
    this.tick = 0;

    _populate_cells();
    _prepopulate_neighbours();
  }

  void tick_() {
    // First determine the action for all cells
    this._cells.forEach((key, cell) {
      var alive_neighbours = this._alive_neighbours_around(cell);
      if (!cell.alive && alive_neighbours == 3) {
        cell.next_state = 1;
      } else if (alive_neighbours < 2 || alive_neighbours > 3) {
        cell.next_state = 0;
      }
    });

    // Then execute the determined action for all cells
    this._cells.forEach((key, cell) {
      if (cell.next_state == 1) {
        cell.alive = true;
      } else if (cell.next_state == 0) {
        cell.alive = false;
      }
    });

    this.tick += 1;
  }

  // Implement first using string concatination. Then implement any
  // special string builders, and use whatever runs the fastest
  String render() {
    // The following works but is slower
    // var rendering = '';
    // for (var y = 0; y <= this._height; y++) {
    //   for (var x = 0; x <= this._width; x++) {
    //     var cell = this._cell_at(x, y);
    //     rendering += cell.to_char();
    //   }
    //   rendering += "\n";
    // }
    // return rendering;

    // The following was the fastest method
    var rendering = [];
    for (var y = 0; y <= this._height; y++) {
      for (var x = 0; x <= this._width; x++) {
        var cell = this._cell_at(x, y);
        rendering.add(cell.to_char());
      }
      rendering.add("\n");
    }
    return rendering.join("");

    // The following works but is slower
    // var rendering = new StringBuffer();
    // for (var y = 0; y <= this._height; y++) {
    //   for (var x = 0; x <= this._width; x++) {
    //     var cell = this._cell_at(x, y);
    //     rendering.write(cell.to_char());
    //   }
    //   rendering.write("\n");
    // }
    // return rendering.toString();
  }

  void _populate_cells() {
    var rng = new Random();
    for (var y = 0; y <= this._height; y++) {
      for (var x = 0; x <= this._width; x++) {
        var alive = (rng.nextDouble() <= 0.2);
        this._add_cell(x, y, alive);
      }
    }
  }

  void _prepopulate_neighbours() {
    this._cells.forEach((key, cell) {
      this._neighbours_around(cell);
    });
  }

  Cell _add_cell(int x, int y, [bool alive = false]) {
    if (this._cell_at(x, y) != null) {
      throw new LocationOccupied();
    }

    var cell = new Cell(x, y, alive);
    this._cells["$x-$y"] = cell;
    return this._cell_at(x, y);
  }

  Cell _cell_at(int x, int y) {
    return this._cells["$x-$y"];
  }

  List<Cell> _neighbours_around(Cell cell) {
    if (!cell.neighbours) {
      cell.neighbours = [];
      for (var set in this._cached_directions) {
        var neighbour = this._cell_at(
          (cell.x + set[0]),
          (cell.y + set[1])
        );
        if (neighbour != null) {
          cell.neighbours.add(neighbour);
        }
      }
    }

    return cell.neighbours;
  }

  // Implement first using filter/lambda if available. Then implement
  // foreach and for. Retain whatever implementation runs the fastest
  int _alive_neighbours_around(Cell cell) {
    // The following works but is slower
    // var neighbours = this._neighbours_around(cell);
    // return neighbours.where(
    //   (neighbour) => neighbour.alive
    // ).length;

    // The following also works but is slower
    // var alive_neighbours = 0;
    // var neighbours = this._neighbours_around(cell);
    // neighbours.forEach((neighbour) {
    //   if (neighbour.alive) {
    //     alive_neighbours += 1;
    //   }
    // });
    // return alive_neighbours;

    // The following was the fastest method
    var alive_neighbours = 0;
    var neighbours = this._neighbours_around(cell);
    for (var i = 0; i < neighbours.length; i++) {
      var neighbour = neighbours[i];
      if (neighbour.alive) {
        alive_neighbours += 1;
      }
    }
    return alive_neighbours;
  }

}

class Cell {

  int x;
  int y;
  bool alive;
  int next_state = null;
  List<Cell> neighbours = null;

  Cell(this.x, this.y, [this.alive = false]) {}

  String to_char() {
    return this.alive ? 'o' : ' ';
  }

}
