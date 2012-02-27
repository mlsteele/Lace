// V2D
// This version includes a strange implementation of norm and normEq
// As well as length and angle

(function(){
  
  var V2D = function V2D(x,y) {
    this.x = x;
    this.y = y;
  };
  
  V2D.ofPolar = function(rads, length) {
    return new V2D(length * Math.cos(rads), length * Math.sin(rads));
  }
  
  V2D.prototype.clone = function() {
    return new V2D(this.x, this.y);
  };
  
  V2D.prototype.zero = function() {
    this.x = 0;
    this.y = 0;
    return this;
  };
  
  V2D.prototype.plusEq = function(v) {
    this.x += v.x;
    this.y += v.y;
    return this;
  };
  
  V2D.prototype.subEq = function(v) {
    this.x -= v.x;
    this.y -= v.y;
    return this;
  };
  
  V2D.prototype.mulEq = function(s) {
    this.x *= s;
    this.y *= s;
    return this;
  };
  
  V2D.prototype.plus = function(v) {
    return (new V2D(
      this.x + v.x,
      this.y + v.y
    ));
  };
  
  V2D.prototype.sub = function(v) {
    return (new V2D(
      this.x - v.x,
      this.y - v.y
    ));
  };
  
  V2D.prototype.mul = function(s) {
    return (new V2D(
      this.x * s,
      this.y * s
    ));
  };
  
  V2D.prototype.div = function(s) {
    return (new V2D(
      this.x / s,
      this.y / s
    ));
  };
  
  // Note: In attempt to patch up the degenerate case,
  //       the norm of the zero vector will return a random norm
  V2D.prototype.normEq = function() {
    var len = this.length();
    if (len !== 0) {
      this.x /= len;
      this.y /= len;
      return this;
    } else {
      this.x = Math.random();
      this.y = Math.random();
      return this.normEq();
    }
  };

  V2D.prototype.norm = function() {
    v = new V2D(this.x, this.y);
    return v.normEq();
  };
  
  V2D.prototype.length = function() {
    return Math.sqrt(this.x*this.x + this.y*this.y);
  };
  
  V2D.prototype.angle = function() {
    return Math.atan2(this.y, this.x);
  }
  
  V2D.prototype.print = function() {
    console.log(
      'x: ' + (Math.round(this.x*10)/10) +' '+
      'y: ' + (Math.round(this.y*10)/10)
    );
    return this;
  };
  
  V2D.prototype.printf = function() {
    console.log(
      'new V2D(' + this.x + ', ' + this.y + ')'
    );
    return this;
  };
  
  window.Lace = window.Lace || {};
  window.Lace.V2D = V2D;
  
})();
