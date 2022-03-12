/* [Hanging strip dimensions] */
// Width of the hanging strip (mm)
hanging_strip_width = 18.5;
// Height of the hanging strip (mm)
hanging_strip_height = 93;
// Tickness of two pieces of hanging strip attached (mm)
hanging_strip_tickness = 3.8;

/* [Hook parameters] */
// Hook tickness. Should be at higher than the hanging strip thickness. (mm)
hook_tickness = 5; // [2:0.5:10]
// Diameter of the hook (mm)
hook_diameter = 36; // [20:50]
// Major arc angle of the hook (degrees)
hook_angle = 180; // [140:200]

/* [Hidden] */
$fn=100;
// Groove depth for the hanging strip. Add 0.6 of tolerance to be able to properly press the two strips together
hanging_strip_groove_depth = hanging_strip_tickness - 0.6;
// Width of the flat edges on each side of the hanging strip
hook_flat_edge_width = 2;
// Width of the hook on each side of the hanging strip. Flat edge + chamfer.
hook_strip_edge_width = hook_flat_edge_width + sqrt(pow(hanging_strip_groove_depth, 2));
hook_width = hanging_strip_width + 2 * hook_strip_edge_width;


// Check parameters
assert(hook_tickness > hanging_strip_tickness, "The hook tickeness should be higher than the hanging strip thickness");

base();

module base() {
    hook_radius = hook_diameter/2;

    difference() {
        union() {
            // Base
            cube([hook_tickness,hanging_strip_height+5,hook_width]);

            // Top
            translate([0,hanging_strip_height+5,0]) {
                intersection() {
                    cylinder(r = hook_tickness, h = hook_width);
                    cube([hook_tickness,hook_tickness,hook_width]);
                }
            }

            translate([hook_radius + hook_tickness, hook_radius + hook_tickness,hook_width]) {
                hook(hook_radius);
            }
        }
        
        // Groove for the hanging strip
        translate([0,5,0]) {
            hanging_strip_groove();
        }
    }
}

module hook(hook_radius) {
    rotate([0,180,hook_angle]) {
        rotate_extrude(angle=hook_angle, convexity=10) {
            translate([hook_radius, 0]) {
                square([hook_tickness,hook_width]);
            }
        }
        rotate([0,0,90]) {
            translate([0,-(hook_tickness+hook_radius),0]) {
                tip();
            }
        }
    }
   
    // Bottom fill
    translate([-(hook_radius),-(hook_radius+hook_tickness),-hook_width]) {
        difference() {
            cube([hook_radius,hook_radius,hook_width]);
            translate([hook_radius,hook_radius+hook_tickness,0]) {
                cylinder(r = hook_radius, h = hook_width);
            }
        }
    }
    
    // Rounded part at the end of the hook
    module tip() {
        // Tip of hook chamfer angle
        angle = 25;
        cylinder_diam = hook_width*cos(angle);
        
        translate([0,0,hook_width/2]) {
            rotate([270-hook_angle,270,hook_angle]) {
                scale([1,0.6,1]) {
                    difference() {
                        union() {
                            cylinder(d=cylinder_diam, h = hook_tickness);
                            translate([hook_width/2,0,0]) {
                                rotate([0,0,180-angle]) {
                                cube([cylinder_diam/2, tan(angle)*cylinder_diam/2, hook_tickness]);
                                }
                            }
                            translate([-hook_width/2,0,0]) {
                                rotate([0,0,angle-90]) {
                                    cube([tan(angle)*cylinder_diam/2,cylinder_diam/2, hook_tickness]);
                                }

                            }
                        }
                        translate([-hook_width/2, 0, 0]) {
                            cube([hook_width, hook_width/2, hook_tickness]);
                        }
                    }
                }

            }
        }
    }
}

module hanging_strip_groove() {
    groove_width = hook_width - hook_flat_edge_width * 2;
    groove_length = hanging_strip_height + (2 * hook_flat_edge_width);
    translate([0,-hook_flat_edge_width,hook_flat_edge_width]) {
        difference() {
            cube([hanging_strip_groove_depth,groove_length,groove_width]);
            rotate([0,45,0]) {
                cube([hook_strip_edge_width,groove_length,hook_strip_edge_width]);
            }
            translate([0,0,groove_width]) {
                rotate([0,45,0]) {
                    cube([hook_strip_edge_width,groove_length,hook_strip_edge_width]);
                }
            }
            
        }
    }
}
