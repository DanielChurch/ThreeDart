part of ThreeDart.Math;

/// A math structure for storing a 3D region, like a rectangular cube.
/// This is also used for AABBs (axial alligned bounding boxes).
class Region3 {

  /// The left edge component of the region.
  final double x;

  /// The top edge component of the region.
  final double y;

  /// The front edge component of the region.
  final double z;

  /// The width component of the region.
  final double dx;

  /// The height component of the region.
  final double dy;

  /// The depth component of the region.
  final double dz;

  /// Constructs a new [Region3] instance.
  Region3._(double this.x,  double this.y,  double this.z,
            double this.dx, double this.dy, double this.dz);

  /// Constructs a new [Region3] instance.
  factory Region3(double x, double y, double z, double dx, double dy, double dz) {
    if (dx < 0.0) {
      x = x + dx;
      dx = -dx;
    }
    if (dy < 0.0) {
      y = y + dy;
      dy = -dy;
    }
    if (dz < 0.0) {
      z = z + dz;
      dz = -dz;
    }
    return new Region3._(x, y, z, dx, dy, dz);
  }

  /// Constructs a new [Region3] at the origin.
  factory Region3.zero() =>
    new Region3(0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

  /// Constructs a new [Region3] at the given point, [pnt].
  factory Region3.fromPoint(Point3 pnt, [double dx = 0.0, double dy = 0.0, double dz = 0.0]) =>
    new Region3(pnt.x, pnt.y, pnt.z, dx, dy, dz);

  /// Constructs a new [Region3] from two opposite corners.
  factory Region3.fromCorners(Point3 a, Point3 b) =>
    new Region3(a.x, a.y, a.z, b.x-a.x, b.y-a.y, b.z-a.z);

  /// Constructs a new [Region3] at the given ray.
  factory Region3.fromRay(Ray3 ray) =>
    new Region3(ray.x, ray.y, ray.z, ray.dx, ray.dy, ray.dz);

  /// Constructs a new [Region3] instance given a list of 6 doubles.
  ///
  /// [values] is a list of doubles are in the order x, y, z, dx, dy, then dz.
  factory Region3.fromList(List<double> values) {
    assert(values.length == 6);
    return new Region3(values[0], values[1], values[2], values[3], values[4], values[5]);
  }

  /// Constructs the union of the given regions. If both are null, null is returned.
  factory Region3.union(Region3 a, Region3 b) {
    if (a == null) return b;
    if (b == null) return a;
    double x  = math.min(a.x,      b.x);
    double y  = math.min(a.y,      b.y);
    double z  = math.min(a.z,      b.z);
    double x2 = math.max(a.x+a.dx, b.x+b.dx);
    double y2 = math.max(a.y+a.dy, b.y+b.dy);
    double z2 = math.max(a.z+a.dz, b.z+b.dz);
    return new Region3._(x, y, z, x2-x, y2-y, z2-z);
  }

  /// The center point of the region.
  Point3 get center => new Point3(
    this.x + this.dx/2.0,
    this.y + this.dy/2.0,
    this.z + this.dz/2.0);

  /// Expands the region to include the given point, [pnt].
  Region3 expandWithPoint(Point3 pnt) =>
    this.expand(pnt.x, pnt.y, pnt.z);

  /// Expands the region to include the given location components.
  Region3 expand(double x, double y, double z) {
    double dx = this.dx;
    if (x < this.x) dx = this.dx + (this.x - x);
    else {
      if (x > this.x + this.dx) dx = x - this.x;
      x = this.x;
    }

    double dy = this.dy;
    if (y < this.y) dy = this.dy + (this.y - y);
    else {
      if (y > this.y + this.dy) dy = y - this.y;
      y = this.y;
    }

    double dz = this.dz;
    if (z < this.z) dz = this.dz + (this.z - z);
    else {
      if (z > this.z + this.dz) dz = z - this.z;
      z = this.z;
    }

    return new Region3._(x, y, z, dx, dy, dz);
  }

  /// Gets an list of 6 doubles in the order x, y, z, dx, dy, then dz.
  List<double> toList() =>
    [this.x, this.y, this.z, this.dx, this.dy, this.dz];

  /// The minimum side of the region.
  double get minSide {
    double side = this.dx;
    if (side > this.dy) side = this.dy;
    if (side > this.dz) side = this.dz;
    return side;
  }

  /// The maximum side of the region.
  double get maxSide {
    double side = this.dx;
    if (side < this.dy) side = this.dy;
    if (side < this.dz) side = this.dz;
    return side;
  }

  /// Gets the adjusted point of the given [raw] point.
  /// This point is normalized into the region.
  Point3 adjustPoint(Point3 raw) {
    final double width  = this.dx*0.5;
    final double height = this.dy*0.5;
    final double depth  = this.dz*0.5;
    final double x = raw.x - this.x - width;
    final double y = raw.y - this.y - height;
    final double z = raw.z - this.z - depth;
    return new Point3(x, y, z)*2.0/this.minSide;
  }

  /// Gets the adjusted vector of the given [raw] vector.
  /// This vector is normalized into the region.
  Vector3 adjustVector(Vector3 raw) =>
    raw*2.0/this.minSide;

  /// Determines the location the given point is in relation to the region.
  HitRegion hit(Point3 a) {
    HitRegion region = HitRegion.None;

    if (a.x < this.x) region |= HitRegion.XNeg;
    else if (a.x >= this.x+this.dx) region |= HitRegion.XPos;
    else region |= HitRegion.XCenter;

    if (a.y < this.y) region |= HitRegion.YNeg;
    else if (a.y >= this.y+this.dy) region |= HitRegion.YPos;
    else region |= HitRegion.YCenter;

    if (a.z < this.z) region |= HitRegion.ZNeg;
    else if (a.z >= this.z+this.dz) region |= HitRegion.ZPos;
    else region |= HitRegion.ZCenter;

    return region;
  }

  /// Determines the intersection between the given [ray] and this region.
  /// Will return nil if there is no intersection.
  IntersectionRayRegion3 rayIntersection(Ray3 ray) {
    final double maxx = this.x + this.dx;
    final double maxy = this.y + this.dy;
    final double maxz = this.z + this.dz;

    // Check for point inside box, trivial reject, and determine
    // parametric distance to each front face
    bool inside = true;
    double xt, xn, xp;
    HitRegion xregion;
    if (ray.x < this.x) {
      xt = this.x - ray.x;
      if (xt > ray.dx) return null;
      xt /= ray.dx;
      inside = false;
      xn = -1.0;
      xp = this.x;
      xregion = HitRegion.XNeg;
    } else {
      if (ray.x > maxx) {
        xt = maxx - ray.x;
        if (xt < ray.dx) return null;
        xt /= ray.dx;
        inside = false;
        xn = 1.0;
        xp = maxx;
        xregion = HitRegion.XPos;
      } else {
        xt = -1.0;
      }
    }

    double yt, yn, yp;
    HitRegion yregion;
    if (ray.y < this.y) {
      yt = this.y - ray.y;
      if (yt > ray.dy) return null;
      yt /= ray.dy;
      inside = false;
      yn = -1.0;
      yp = this.y;
      yregion = HitRegion.YNeg;
    } else {
      if (ray.y > maxy) {
        yt = maxy - ray.y;
        if (yt < ray.dy) return null;
        yt /= ray.dy;
        inside = false;
        yn = 1.0;
        yp = maxy;
        yregion = HitRegion.YPos;
      } else {
        yt = -1.0;
      }
    }

    double zt, zn, zp;
    HitRegion zregion;
    if (ray.z < this.z) {
      zt = this.z - ray.z;
      if (zt > ray.dz) return null;
      zt /= ray.dz;
      inside = false;
      zn = -1.0;
      zp = this.z;
      zregion = HitRegion.ZNeg;
    } else {
      if (ray.z > maxz) {
        zt = maxz - ray.z;
        if (zt < ray.dz) return null;
        zt /= ray.dz;
        inside = false;
        zn = 1.0;
        zp = maxz;
        zregion = HitRegion.ZPos;
      } else {
        zt = -1.0;
      }
    }

    if (inside) {
      return new IntersectionRayRegion3(ray.start, -ray.vector.normal(), 0.0, HitRegion.Inside);
    }

    // The farthest plane is the plane of intersection.
    int which = (yt > xt)? ((zt > yt)? 2: 1): ((zt > xt)? 2: 0);
    switch (which) {
    case 0: // intersect with yz plane
      double y = ray.y + ray.dy*xt;
      if (y < this.y || y > maxy) return null;
      double z = ray.z + ray.dz*xt;
      if (z < this.z || z > maxz) return null;
      return new IntersectionRayRegion3(new Point3(xp, y, z), new Vector3(xn, 0.0, 0.0), xt, xregion);

    case 1: // intersect with xz plane
      double x = ray.x + ray.dx*yt;
      if (x < this.x || x > maxx) return null;
      double z = ray.z + ray.dz*yt;
      if (z < this.z || z > maxz) return null;
      return new IntersectionRayRegion3(new Point3(x, yp, z), new Vector3(0.0, yn, 0.0), yt, yregion);

    default: // 2, intersect with xy plane
      double x = ray.x + ray.dx*zt;
      if (x < this.x || x > maxx) return null;
      double y = ray.y + ray.dy*zt;
      if (y < this.y || y > maxy) return null;
      return new IntersectionRayRegion3(new Point3(x, y, zp), new Vector3(0.0, 0.0, zn), zt, zregion);
    }
  }

  /// Determines if the given point is contained inside this region.
  bool contains(Point3 a) {
    if (a.x < this.x) return false;
    else if (a.x >= this.x+this.dx) return false;

    if (a.y < this.y) return false;
    else if (a.y >= this.y+this.dy) return false;

    if (a.z < this.z) return false;
    else if (a.z >= this.z+this.dz) return false;

    return true;
  }

  /// Determines if the two regions overlap even partually.
  bool overlap(Region3 a) =>
    (a.x <= this.x + this.dx) &&
    (a.y <= this.y + this.dy) &&
    (a.z <= this.z + this.dz) &&
    (a.x + a.dx >= this.x) &&
    (a.y + a.dy >= this.y) &&
    (a.z + a.dz >= this.z);

  /// Determines if the given [other] variable is a [Region3] equal to this region.
  ///
  /// The equality of the doubles is tested with the current [Comparer] method.
  bool operator ==(var other) {
    if (identical(this, other)) return true;
    if (other is! Region3) return false;
    Region3 size = other as Region3;
    if (!Comparer.equals(size.x,  this.x))  return false;
    if (!Comparer.equals(size.y,  this.y))  return false;
    if (!Comparer.equals(size.z,  this.z))  return false;
    if (!Comparer.equals(size.dx, this.dx)) return false;
    if (!Comparer.equals(size.dy, this.dy)) return false;
    if (!Comparer.equals(size.dz, this.dz)) return false;
    return true;
  }

  /// Gets the string for this region.
  String toString() => this.format();

  /// Gets the formatted string for this region.
  String format([int fraction = 3, int whole = 0]) =>
    '['+ formatDouble(this.x,  fraction, whole)+
    ', '+formatDouble(this.y,  fraction, whole)+
    ', '+formatDouble(this.z,  fraction, whole)+
    ', '+formatDouble(this.dx, fraction, whole)+
    ', '+formatDouble(this.dy, fraction, whole)+
    ', '+formatDouble(this.dz, fraction, whole)+']';
}
