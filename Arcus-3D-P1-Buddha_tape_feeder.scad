// Arcus-3D-P1 - Buddha Tape feeder OpenSCAD source

// Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
// http://creativecommons.org/licenses/by-sa/3.0/

// Project home
// https://hackaday.io/project/159792

// Author
// Daren Schwenke at g mail dot com

// Please like my projects if you find them useful.  Thank you.

//////////////////////////////////////////////////////////////
use <./involute_gears.scad>
pitch=0.865;			//diametric pitch = teeth/diam
pressure_angle=22;
render_extrude = 0;
// Globals

// General clearance.  Usually I do 2x this for loose fit 1.5x for slip fit, and 0x to 1x for press fit.
clearance=.20;

// Nozzle size for parts only a few widths thick.  Prints better.
nozzle_dia=.3;

// Rendering circle complexity.  Turn down while editing, up while rendering.
$fn=60; 
//$fn=20;
// Render simple

// Many things are a multiple of this general wall thickness.
wall_thickness=nozzle_dia*4; 

// For differencing so OpenSCAD doesn't freak out
extra=.02;
 
// Cause I'm hungry
pi=3.1415926; 

// Bearing dimensions
bearing_od=13;
bearing_id=4;
bearing_h=5;

// Because I'm all about that base plate thickness
base_thickness=wall_thickness*2;

//body_depth=6+tape_depth;
body_width=12-clearance;

drive_ratio=1.15; // It's actually higher than this as the cover spool outer dia is +nozzle_dia*6
// Tape spool
tape_pitch=4.0-.02;
tape_ratchet_teeth=32;
tape_dia=tape_pitch*tape_ratchet_teeth/pi;
tape_gear_teeth=tape_ratchet_teeth*2;
tape_edge_spacing=(tape_dia/1.75*2+wall_thickness*2)/4;

// Cover spool
cover_pitch=tape_pitch*drive_ratio;
cover_ratchet_teeth=24;
cover_teeth=30;
cover_ratchet_dia=cover_pitch*cover_ratchet_teeth/pi-nozzle_dia*10-clearance*2;
cover_dia=cover_pitch*cover_ratchet_teeth/pi;
cover_spool_depth=3;
cover_gear_teeth=tape_gear_teeth/drive_ratio;

cover_x_offset=tape_dia/2+cover_dia/2+10;
cover_y_offset=tape_edge_spacing*2-cover_dia/2;

// Tuning

// Ratchets inlaid into base so I can get my 12mm target width
ratchet_inset_h=wall_thickness;
ratchet_tooth_h=wall_thickness*1.5;

lever_throw_angle=360/tape_ratchet_teeth*1.7; 
lever_arm_thickness=wall_thickness;

center_distance=sqrt(cover_x_offset*cover_x_offset+cover_y_offset*cover_y_offset);
diametral_pitch= (tape_gear_teeth+cover_gear_teeth)/center_distance/2;

tape_drive_r=tape_gear_teeth/diametral_pitch/2;
cover_drive_r=cover_gear_teeth/diametral_pitch/2;

cover_angle=atan(cover_y_offset/cover_x_offset);
cover_drive_rotation=360/cover_gear_teeth/2;


// Cover tape spool

cover_idler_x_offset=cover_x_offset+cover_dia/1.38;
cover_idler_y_offset=cover_y_offset+cover_dia/4;
cover_idler_teeth=cover_teeth/2;

cover_idler_pivot_x_offset=cover_idler_x_offset;
cover_idler_pivot_y_offset=cover_idler_y_offset-cover_dia/4-4;

servo_x_offset=cover_idler_x_offset+cover_dia/2+base_thickness;
servo_y_offset=cover_dia/1.8;
servo_z_offset=body_width/2;


//////////////////////////////////////////////////////////////
// The parts for rendering
// Uncomment each part here, save, render, then export to STL.
//tape_feeder_body();

//tape_drive();
cover_drive();

//cover_pin_ratchet();
//tape_pin_ratchet();

//tape_drive_sprocket();
//tape_idler_sprocket(width=8);
//tape_slot_cover(width=8);

//cover_drive_sprocket();
//cover_tension_knob();

//////////////////////////////////////////////////////////////
// Assembly views.
//rotate([90,0,0]) tape_feeder_assembly(cross_section=3, explode=00);
//tape_spool_assembly(width=8,cross_section=0);
//cover_spool_assembly(width=8,cross_section=0);
//animate();

module animate() {
	if ($t < .5 ) {
		rotate([90,0,0]) tape_feeder_assembly(rotation=$t*lever_throw_angle*1.5,c_rotation=0);
	} else {
		rotate([90,0,0]) tape_feeder_assembly(rotation=.5*lever_throw_angle*1.5-($t-.5)*lever_throw_angle*1.5,c_rotation=-($t-.5)*lever_throw_angle*1.5);
	}
}


module tape_feeder_assembly(width=8,rotation=0,c_rotation=0,cross_section=0,explode=0) {
	rotation=-7;
	//rotation=lever_throw_angle;
	intersection() {
		if (cross_section == 1) translate([0,0,90]) rotate([0,0,rotation]) cube ([200,extra,200],center=true); 
		if (cross_section == 2) translate([-cover_x_offset,cover_y_offset,0]) rotate([0,0,rotation]) cube ([200,extra,200],center=true); 
		if (cross_section == 3) translate([-cover_x_offset,cover_y_offset,6]) rotate([0,0,-cover_angle+rotation]) cube ([200,extra,12],center=true);
		union() {
			if (1) tape_feeder_body();
			if (1) translate([0,0,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,rotation]) tape_drive(print=0);
			if (1) translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,-rotation*drive_ratio]) cover_drive();
			if (1) translate([0,0,base_thickness-.6+clearance/2+explode*2]) tape_spool_assembly(explode=explode);
			if (1) translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h+lever_arm_thickness+wall_thickness+clearance/2+explode*2]) cover_spool_assembly(explode=explode,print=0);
			if (1) {
				translate([0,0,base_thickness/2+nozzle_dia-clearance/2+explode/2]) tape_pin_ratchet(print=0);
				translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h+clearance/2+explode/2]) cover_pin_ratchet(print=0);
			}
			if (0) translate([-cover_idler_x_offset,cover_idler_y_offset,base_thickness-ratchet_inset_h+lever_arm_thickness+clearance+explode*3]) { 
				rotate([0,0,360/cover_teeth/.85]) cover_idler();
				translate([0,0,3.7-lever_arm_thickness+ratchet_inset_h-explode]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
			}
			if (1) translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,explode]) cover_idler_pivot(clearance=0);
			if (0) translate([-servo_x_offset,cover_y_offset-servo_y_offset,servo_z_offset]) rotate([90,0,0]) 9g_servo(display=1);
			// ghost views for travel
			if (0) translate([0,0,base_thickness-ratchet_inset_h+clearance/2+explode]) %tape_drive(print=0);
			if (0) translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h+clearance/2+explode]) %cover_drive();

		} 
	}
}

module tape_spool_assembly(width=8,explode=0,cross_section=0) {
	intersection() {
		if (cross_section) rotate([0,0,30]) cube([100,extra,100],center=true);
		union() {
			if (1) rotate([0,0,180-cover_angle]) tape_drive_sprocket(print=0);
			if (1) translate([0,0,width+1.2+explode]) rotate([180,0,0]) tape_idler_sprocket(width=width);
			if (0) translate([0,0,width-1.1+explode]) cover_tension_knob(width=width);
			if (1) translate([0,0,3.0+explode/2]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
			if (1) rotate([0,0,-45]) translate([tape_dia/2-1.5,0,4.75]) {
				difference() {
					cube([.74,30,8.1],center=true);
					for (i=[0:4:24]) translate([0,-12+i,-8.1/2+1.78]) rotate([0,90,0]) cylinder(r=1.5/2,h=2,center=true);
				}
			}
		}
	}
}

module cover_spool_assembly(explode=0,width=8,cross_section=0) {
	rotation=0;
	rotate([0,0,-rotation-cover_angle]) intersection() {
		if (cross_section) rotate([0,0,rotation]) cube([100,extra,100],center=true);
		union() {
			if (1) translate([0,0,-wall_thickness+clearance/2]) cover_drive_sprocket(print=0);
			if (1) translate([0,0,clearance/2+explode]) cover_spool(print=0);
			if (1) translate([0,0,3.0-lever_arm_thickness+ratchet_inset_h-wall_thickness+explode/2]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
		}
	}
}
//////////////////////////////////////////////////////////////////////////////
// Parts

module tape_slot_cover(width=8) {
	slot_cover_part_l=4;
	slot_cover_slot_offset=slot_cover_part_l*2/3;
	slot_cover_mount_h=6;
	slot_cover_width=width;
	//slot_cover_length=60;
	slot_cover_length=(tape_dia*1.043+slot_cover_mount_h)*pi*(55+55)/360;
	union() {
		difference() {
			union() {
				//base
				hull() {
					translate([-nozzle_dia*2,0,nozzle_dia*2.5/2]) cube([slot_cover_width-nozzle_dia*4,slot_cover_length-slot_cover_mount_h,nozzle_dia*2.5],center=true);
					translate([-nozzle_dia*2,0,nozzle_dia*2.5/2]) cube([slot_cover_width+nozzle_dia*4,slot_cover_length-slot_cover_mount_h*2,nozzle_dia*2.5],center=true);
				}
				// peel slot	
				translate([0,slot_cover_slot_offset+slot_cover_part_l+wall_thickness,0]) hull() {
					translate([-nozzle_dia*3.5,wall_thickness/2,nozzle_dia*4]) cube([slot_cover_width+nozzle_dia,wall_thickness*3,nozzle_dia*3.5],center=true);
					translate([-nozzle_dia*4,0,nozzle_dia/2]) cube([slot_cover_width,slot_cover_length/5,nozzle_dia*1],center=true);
				}
				// part slot
				translate([-slot_cover_width/2+extra,-slot_cover_slot_offset+slot_cover_part_l*.85,0]) hull() {
					translate([-nozzle_dia*2,0,nozzle_dia*4+nozzle_dia/2]) cube([nozzle_dia*4,slot_cover_length/6,nozzle_dia*2.5],center=true);
					translate([-nozzle_dia*1.5,0,nozzle_dia/2]) cube([nozzle_dia*5,slot_cover_length/3,nozzle_dia*1],center=true);
				}
				// drive slot
				translate([slot_cover_width/2-1.75,0,0]) intersection() {
					rotate([90,0,0]) hull() {
						cylinder(r=1.4,h=slot_cover_length-slot_cover_mount_h*2,center=true);
						cylinder(r=nozzle_dia/2,h=slot_cover_length-slot_cover_mount_h/1.5,center=true);
					}
					translate([0,0,3/2]) cube([slot_cover_width,slot_cover_length,3],center=true);
				}
				translate([-wall_thickness/2,0,0]) {
					translate([0,-slot_cover_length/2-3,nozzle_dia*4/2]) cube([slot_cover_width-wall_thickness,body_width,nozzle_dia*4],center=true);
					translate([0,slot_cover_length/2,slot_cover_mount_h/2]) rotate([0,90,0]) cylinder(r=slot_cover_mount_h/2,h=slot_cover_width-wall_thickness,center=true);
					hull() {
						translate([0,slot_cover_length/2,slot_cover_mount_h/2]) rotate([0,90,0]) cylinder(r=slot_cover_mount_h/4,h=slot_cover_width-wall_thickness,center=true);
						translate([0,slot_cover_length/2-slot_cover_mount_h/1.5,extra/2]) cube([slot_cover_width-wall_thickness,slot_cover_mount_h*1.5,extra],center=true);
					}
					hull() {
						translate([0,-slot_cover_length/2,slot_cover_mount_h/2.5]) rotate([0,90,0]) scale([1,1,1]) cylinder(r=slot_cover_mount_h/2.5,h=slot_cover_width-wall_thickness,center=true);
						translate([0,-slot_cover_length/2+slot_cover_mount_h/2.5,extra/2]) cube([slot_cover_width-wall_thickness,slot_cover_mount_h*2.5,extra],center=true);
					}
					hull() {
						translate([0,-slot_cover_length/2,slot_cover_mount_h/2]) rotate([0,90,0]) scale([1,1,1]) cylinder(r=slot_cover_mount_h/2.5,h=slot_cover_width-wall_thickness,center=true);
						translate([0,-slot_cover_length/2,slot_cover_mount_h*1.25]) rotate([0,90,0]) cylinder(r=slot_cover_mount_h/4,h=slot_cover_width-wall_thickness,center=true);
					}
				}
			}
			// peel slot
			translate([-2/2+nozzle_dia/2,slot_cover_slot_offset+slot_cover_part_l,0]) hull() {
				translate([-.25,0,0]) cube([slot_cover_width-2.25,nozzle_dia*3.5,extra],center=true);
				translate([-.25,wall_thickness*4,wall_thickness*3]) cube([slot_cover_width-2.25+nozzle_dia,nozzle_dia*3+wall_thickness*3,extra],center=true);
			}
			// part slot
			translate([0,slot_cover_slot_offset/2-slot_cover_part_l/2,0]) hull() {
				translate([-2.25/2,0,0]) cube([slot_cover_width-2.25-.75,slot_cover_part_l,extra],center=true);
				translate([-1,0,wall_thickness*3]) cube([slot_cover_width-nozzle_dia*2,slot_cover_part_l+wall_thickness*2,extra],center=true);
			}
			translate([slot_cover_width/2-1.75,0,0]) rotate([90,0,0]) cylinder(r=1.25/2,h=slot_cover_length-slot_cover_mount_h*2,center=true);
			translate([0,-slot_cover_length/2,slot_cover_mount_h/2]) {
				translate([0,0,nozzle_dia*4]) rotate([0,90,0]) scale([1.5,.35,1]) cylinder(r=slot_cover_mount_h/3,h=slot_cover_width+extra,center=true);
				translate([0,0,0]) rotate([0,90,0]) scale([1,1,1]) cylinder(r=2/2+clearance/4,h=slot_cover_width+extra,center=true);
				hull() {
					translate([0,0,-slot_cover_mount_h/6]) rotate([0,90,0]) cylinder(r=2/2-clearance*1.5,h=slot_cover_width+extra,center=true);
					translate([0,0,-slot_cover_mount_h/1.5]) rotate([0,90,0]) cylinder(r=2/2+clearance*2,h=slot_cover_width+extra,center=true);
				}
			}
			translate([0,slot_cover_length/2,slot_cover_mount_h/2]) rotate([155,0,0]) {
				translate([0,0,0]) rotate([0,90,0]) scale([1,1,1]) cylinder(r=2/2+clearance/2,h=slot_cover_width+extra,center=true);
				hull() {
					translate([0,0,-slot_cover_mount_h/8]) rotate([0,90,0]) cylinder(r=2/2,h=slot_cover_width+extra,center=true);
					translate([0,0,-slot_cover_mount_h/1.5]) rotate([0,90,0]) cylinder(r=2/2+clearance*2,h=slot_cover_width+extra,center=true);
				}
			}
		}
	}
}

module cover_pin_ratchet(print=1,pin_socket=0) {
	if (pin_socket) {
		rotate([0,0,-360/cover_ratchet_teeth*8.9]) mirror([0,1,0]) pin_ratchet(h=ratchet_tooth_h+lever_arm_thickness-clearance,r=cover_ratchet_dia/2,ratchet_teeth=cover_ratchet_teeth,pin_socket=1,ratchet=0);
	} else if (print) {	
		rotate([180,0,0]) mirror([0,1,]) pin_ratchet(h=ratchet_tooth_h+lever_arm_thickness-clearance,r=cover_ratchet_dia/2,ratchet_teeth=cover_ratchet_teeth);
	} else {
		rotate([0,0,-360/cover_ratchet_teeth*8.9]) mirror([0,1,0]) pin_ratchet(h=ratchet_tooth_h+lever_arm_thickness-clearance,r=cover_ratchet_dia/2,ratchet_teeth=cover_ratchet_teeth);
	}
}

module tape_pin_ratchet(print=1,pin_socket=0) {
	if (pin_socket) {
		rotate([0,0,270-360/cover_ratchet_teeth*2.17]) pin_ratchet(h=ratchet_tooth_h+ratchet_inset_h/2-clearance*1.5,pin_socket=1,ratchet=0);
	} else if (print) {
		rotate([180,0,0]) pin_ratchet(h=ratchet_tooth_h+ratchet_inset_h/2-clearance*1.5);
	} else {
		rotate([0,0,270-360/cover_ratchet_teeth*2.17]) pin_ratchet(h=ratchet_tooth_h+ratchet_inset_h/2-clearance*1.5);
	}
}

module pin_ratchet(pin_depth=base_thickness-nozzle_dia-clearance,r=tape_dia/2,h=ratchet_inset_h+ratchet_tooth_h-clearance,ratchet_teeth=tape_ratchet_teeth,pin_socket=0) {
	union() {
		if (pin_socket) {
			translate([0,0,-pin_depth/2]) tape_ratchet(h=pin_depth,pin_socket=1,r=r,ratchet_teeth=ratchet_teeth,clearance=.4);
		} else {
			tape_ratchet(h=h,pin=1,ratchet=1,r=r,ratchet_teeth=ratchet_teeth,tooth_clearance=.2);
			translate([0,0,-pin_depth/2]) tape_ratchet(h=pin_depth,pin=1,r=r,ratchet_teeth=ratchet_teeth);
		}
	}
}

module cover_tension_knob() {
	difference() {
		union() {
			translate([0,0,.85/2]) cylinder(r2=bearing_od/2-nozzle_dia*6,r1=bearing_od/2-nozzle_dia*7,h=.85,$fn=24,center=true);
			translate([0,0,2.4/2]) cylinder(r=3.3+nozzle_dia*6,h=2.4,$fn=6,center=true);
			translate([0,0,.85+1.5/2]) for (i=[0,120,240]) rotate([0,0,i+30]) cube([nozzle_dia*6,bearing_od-nozzle_dia*13,1.5+extra],center=true);
		}
		translate([0,0,.85+3.5/2]) cylinder(r=3.3-clearance/4,h=3.5+extra,center=true,$fn=6);
		translate([0,0,3.5/2]) cylinder(r=3/2,h=3.5+extra,center=true);
	}
}

module tape_drive(cutout=0) {
	
	rotate([0,0,-cover_angle]) {
		if (cutout) {
			rotate([0,0,-lever_throw_angle/2])tape_ratchet(drive_r=tape_gear_teeth/diametral_pitch/2+clearance*2,drive_angle=lever_throw_angle,r=tape_dia/2+clearance*2,cutout=1,cutout_dia=tape_dia/1.5+clearance);
		} else {
			difference() {
				union() {
					difference() {
						intersection() {
							rotate([0,0,0]) gear(number_of_teeth=tape_gear_teeth, diametral_pitch=diametral_pitch, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=wall_thickness, rim_width=0, gear_thickness=wall_thickness,clearance=0, backlash=0.1, pressure_angle=pressure_angle);
							rotate([0,0,-lever_throw_angle/2])tape_ratchet(drive_r=tape_gear_teeth/diametral_pitch/2,drive_angle=lever_throw_angle,r=tape_dia/2,cutout=1,cutout_dia=tape_dia/1.5);
						}
						translate([0,0,ratchet_inset_h/2+wall_thickness/2-clearance/4]) difference() {
							cylinder(r=tape_dia/2+1.2+clearance,h=wall_thickness,center=true);
							cylinder(r=tape_dia/2.4,h=wall_thickness+extra,center=true);
						}
					}
					rotate([0,0,360/tape_ratchet_teeth*5]) tape_ratchet(h=wall_thickness/2+ratchet_tooth_h-clearance/2,pivot=1,ratchet=1,tooth_clearance=.2,r=tape_dia/2);
				}
				slip_bearing_cutout();
			}
		}
	}
}

// Lever arm, cover drive ratchet, connected by piano wire to tape_drive
module cover_drive(cutout=0,servo_drive=0) {
	rotate([0,0,180-cover_angle]) { 
		if (cutout) {
			rotate([0,0,360/cover_gear_teeth*1.5])tape_ratchet(drive_r=cover_gear_teeth/diametral_pitch/2+clearance*2,drive_angle=lever_throw_angle*drive_ratio,r=cover_ratchet_dia/2,cutout=2);
			h=base_thickness*2;
			add=clearance*2;
			translate([0,0,h/2]) rotate([0,0,cover_angle+lever_throw_angle*drive_ratio/2]) union() {
				hull() {
					rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.7,cover_dia/6.9,0]) cube([cover_dia/2.5+add,extra,h],center=true);
					translate([0,servo_y_offset,0]) scale([3,1,1]) cylinder(r=cover_dia/4.5/3+add,h=h,center=true);
				}
				hull() {
					rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.2,-cover_dia/6.5,0]) cube([cover_dia/3+add,extra,h],center=true);
					translate([-cover_dia/2.4,-cover_dia/1.7,0]) scale([2,1,1]) cylinder(r=bearing_od/2/3+nozzle_dia*6/3+add*1.5,h=h,center=true);
				}
			}
		} else {
			difference() {
				union() {
					intersection() {
						rotate([0,0,180-360/cover_gear_teeth/2*3]) gear(number_of_teeth=cover_gear_teeth, diametral_pitch=diametral_pitch, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=wall_thickness, rim_width=0, gear_thickness=wall_thickness,clearance=clearance, backlash=0.2, pressure_angle=pressure_angle);
						rotate([0,0,360/cover_gear_teeth*1.5])tape_ratchet(drive_r=cover_gear_teeth/diametral_pitch/2,drive_angle=lever_throw_angle*drive_ratio,r=cover_ratchet_dia/2,cutout=2);
					}
		
					rotate([0,0,-360/cover_ratchet_teeth*4]) mirror([0,1,0]) tape_ratchet(ratchet_teeth=cover_ratchet_teeth,pivot=1,ratchet=1,tooth_clearance=.2,r=cover_ratchet_dia/2);
					translate([0,0,wall_thickness/2+ratchet_tooth_h/2+clearance]) cylinder(r=bearing_od/2+nozzle_dia*6+clearance,h=wall_thickness/2+ratchet_tooth_h+clearance*2,center=true);
					translate([0,0,wall_thickness/2]) rotate([0,0,cover_angle+lever_throw_angle*drive_ratio/2]) difference() {
						h=wall_thickness;
						add=0;
						translate([0,0,0]) union() {
							hull() {
								rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.7,cover_dia/6.9,0]) cube([cover_dia/2.5+add,extra,h],center=true);
								translate([0,servo_y_offset,0]) scale([3,1,1]) cylinder(r=cover_dia/4.5/3+add,h=h,center=true);
							}
							difference() {
								hull() {
									rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.2,-cover_dia/6.5,0]) cube([cover_dia/3+add,extra,h],center=true);
									translate([-cover_dia/2.4,-cover_dia/1.5,h/2]) scale([2,1,1]) cylinder(r=bearing_od/2/3+nozzle_dia*6/3+add,h=h*2,center=true);
								}
								translate([0,0,(lever_arm_thickness/2-ratchet_inset_h+wall_thickness*3)/2-clearance]) cylinder(r=cover_dia/2-nozzle_dia*3,h=lever_arm_thickness-ratchet_inset_h+wall_thickness+extra,center=true);
							}
							hull() {
								translate([-cover_dia/1.3,-cover_dia/1.2,h/2]) scale([1,1,1]) cylinder(r=bearing_od/2/3+nozzle_dia*6/3+add,h=h*2,center=true);
								translate([-cover_dia/2.4,-cover_dia/1.5,h/2]) scale([2,1,1]) cylinder(r=bearing_od/2/3+nozzle_dia*6/3+add,h=h*2,center=true);
							}
							translate([-cover_dia/1.3,-cover_dia/1.2,h/2+5/2]) scale([1,1,1]) cylinder(r=4/2,h=h*2+5+extra,center=true);
							translate([-cover_dia/3.8,-cover_dia/1.6,-h/2]) rotate([0,0,180]) band_mount(h=base_thickness*1.25);
							intersection() {
								difference() {
									translate([0,0,(lever_arm_thickness/2-ratchet_inset_h+wall_thickness*2.5)/2-clearance*.5]) cylinder(r=cover_dia/2,h=lever_arm_thickness-ratchet_inset_h+wall_thickness,center=true);
									translate([0,0,-base_thickness+wall_thickness/2-clearance*.5]) difference() {
										translate([0,0,base_thickness*1.5-ratchet_inset_h+wall_thickness*1.5-clearance*1.5]) cylinder(r=cover_dia/2+extra,h=wall_thickness,center=true);
										translate([0,0,base_thickness*1.5+wall_thickness/2+clearance]) for (i=[0:120:359]) rotate([0,0,i+55]) cube([nozzle_dia*8,tape_dia+3,base_thickness*4],center=true);
									}
									translate([0,0,(lever_arm_thickness/2-ratchet_inset_h+wall_thickness*3)/2-clearance]) cylinder(r=cover_dia/2-nozzle_dia*3,h=lever_arm_thickness-ratchet_inset_h+wall_thickness+extra,center=true);
								}
								h=base_thickness*2;
								union() {
									hull() {
										rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.7,cover_dia/6.9,0]) cube([cover_dia/2.5+add,extra,h],center=true);
										translate([0,servo_y_offset,0]) scale([3,1,1]) cylinder(r=cover_dia/4.5/3+add,h=h,center=true);
									}
									hull() {
										rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.2,-cover_dia/6.5,0]) cube([cover_dia/3+add,extra,h],center=true);
										translate([-cover_dia/2.4,-cover_dia/1.7,0]) scale([2,1,1]) cylinder(r=bearing_od/2/3+nozzle_dia*6/3+add,h=h,center=true);
									}
									hull() {
										rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.2,-cover_dia/6.5,0]) cube([cover_dia/3+add,extra,h],center=true);
										rotate([0,0,-360/cover_gear_teeth*1.5]) translate([-cover_dia/2.7,cover_dia/6.9,0]) cube([cover_dia/2.5+add,extra,h],center=true);
									}
								}
							}
						}
						translate([bearing_od/2+nozzle_dia*2,cover_ratchet_dia/2.85,0]) rotate([0,0,-lever_throw_angle*2]) cube([6,5,wall_thickness+extra],center=true);
						hull() for(i=[-lever_throw_angle/2,lever_throw_angle/2]) rotate([0,0,i]) translate([0,servo_y_offset,0]) cylinder(r=1/2+clearance,h=wall_thickness+extra,center=true);
						translate([-cover_dia/3.8,-cover_dia/1.6,-h/2]) rotate([0,0,180]) band_mount(cutout=1,h=base_thickness*1.25);
						translate([-cover_dia/1.3,-cover_dia/1.2,h/2+5/2]) scale([1,1,1]) cylinder(r=2.8/2,h=h*2+5+extra*4,center=true);
					}
				}
				slip_bearing_cutout();
			}
		}
	}
}
module rack_drive() {
	rack(rack_thickness=3,number_of_teeth=cover_gear_teeth*2, diametral_pitch=diametral_pitch, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=wall_thickness, rim_width=0, gear_thickness=wall_thickness,clearance=clearance, backlash=0.2, pressure_angle=pressure_angle);
}

// Tape idler, mates with tape drive.
// This was designed with an intentionally thin face, so it will bend out slightly when the tape enters keeping it centered and pushed up.
module tape_idler_sprocket(width=8) {
	difference() {
		union() {
			// rim
			translate([0,0,.3/2]) cylinder(r=tape_dia/2+1,h=.3,$fn=tape_ratchet_teeth*2,center=true);
			//  lifting wedge
			translate([0,0,.3+.35/2]) cylinder(r1=tape_dia/2+1, r2=tape_dia/2,h=.35,$fn=tape_ratchet_teeth*2,center=true);
			// wedge bottom	
			translate([0,0,.4+.6]) cylinder(r=tape_dia/2,h=.75,$fn=tape_ratchet_teeth*2,center=true);
			// body recess	
			translate([0,0,(width-1.75)/2]) cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_ratchet_teeth*2,center=true,h=width-1.75);
			// drive dado
			translate([0,0,width-1.75+(3.05-ratchet_tooth_h)/2-extra]) intersection () {
				cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_ratchet_teeth*2,center=true,h=3.05-ratchet_tooth_h+extra);
				shaft_dado_coupler(r1=bearing_od/2+clearance,r2=bearing_od/2+clearance+nozzle_dia*10,h=3.05-ratchet_tooth_h,clearance=0,count=6);
			}
		}
		// thin out rim for flexing
		translate([0,0,.4]) difference() {
			translate([0,0,.75+extra]) cylinder(r=tape_dia/2-nozzle_dia*6,$fn=tape_ratchet_teeth*2,center=true,h=.75);
			translate([0,0,.75+extra]) cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_ratchet_teeth*2,center=true,h=.75);
		}
		// bearing lip inner
		translate([0,0,width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*2,center=true,$fn=tape_ratchet_teeth*2,h=width+extra*2);
		// bearing cutout
		translate([0,0,width/2+width-bearing_h+.60]) cylinder(r=bearing_od/2+clearance,center=true,h=width);
		// front rim bevel
		translate([0,0,nozzle_dia*14/2-extra]) cylinder(r2=bearing_od/2-nozzle_dia*8,r1=bearing_od/2+nozzle_dia*4,center=true,$fn=tape_ratchet_teeth*2,h=nozzle_dia*16);
	}
}

// Cover drive sprocket.  Internal ratchet teeth.
// Two sources of friction can drive this.  An O-ring on the bearing against the face, or without the O-ring, the faces rubbing.
module cover_drive_sprocket(print=1) {
	if (print) { 
		rotate([180,0,0]) translate([0,0,-(ratchet_tooth_h+.85)]) mirror([0,1,0]) cover_drive_sprocket_part();
	} else {
		mirror([0,1,0]) cover_drive_sprocket_part();
	}
}

module cover_drive_sprocket_part() {
	difference() {
		translate([0,0,(ratchet_tooth_h+wall_thickness)/2]) cylinder(r=cover_ratchet_dia/2,h=ratchet_tooth_h+wall_thickness,$fn=tape_ratchet_teeth*2,center=true);
		translate([0,0,ratchet_tooth_h/2+extra]) pnp_ratchet_ratchet_teeth(ratchet_teeth=cover_ratchet_teeth,r=cover_ratchet_dia/2,clearance=0,drive_r=cover_drive_r,count=cover_ratchet_teeth,h=ratchet_tooth_h+extra*4);
		slip_bearing_cutout();
	}
}
// Tape drive sprocket.  Internal ratchet teeth, external wedge shape and tape teeth.
module tape_drive_sprocket(print=1) {
	if (print) { 
		rotate([180,0,0]) translate([0,0,-3.05]) tape_drive_sprocket_part();
	} else {
		tape_drive_sprocket_part();
	}
}

module tape_drive_sprocket_part() {
	difference() {
		union() {
			// body
			translate([0,0,.2+2.7/2]) cylinder(r=tape_dia/2,h=2.7,$fn=tape_ratchet_teeth*2,center=true);
			// lifting wedge
			translate([0,0,.4+.5/2]) cylinder(r1=tape_dia/2+1, r2=tape_dia/2,h=.5,$fn=tape_ratchet_teeth*2,center=true);
			// rim
			translate([0,0,.4/2]) cylinder(r=tape_dia/2+1,h=.4,$fn=tape_ratchet_teeth*2,center=true);
			// sprocket teeth
			intersection() {
				union() {
					translate([0,0,2.05+.85/2]) for (i=[0:(360/tape_ratchet_teeth):360]) rotate([0,0,i]) rotate([90,0,0]) translate([0,0,tape_dia/2-.1]) {
						rotate([0,-5,0] ) scale([1,1.75,1]) {
							translate([0,0,1/2]) cylinder(r2=.9/2,r1=ratchet_tooth_h/2,h=1,$fn=6,center=true);
								translate([0,0,1+.5/2]) cylinder(r1=.9/2,r2=.3/2,h=.5,$fn=6,center=true);
						}
					}
				}
				translate([0,0,2.05+.85/2]) cylinder(r=tape_dia/2+4,h=.85,$fn=tape_ratchet_teeth,center=true);
			
			}
		}
		// ratchet cutout
		translate([0,0,(ratchet_tooth_h/2)-extra]) pnp_ratchet_ratchet_teeth(ratchet_teeth=tape_ratchet_teeth,r=tape_dia/2,tooth_clearance=0,count=tape_ratchet_teeth,h=ratchet_tooth_h);
		// dado cutout
		translate([0,0,3.05-(3.05-ratchet_tooth_h)/2]) shaft_dado_coupler(r1=bearing_od/2+clearance,r2=bearing_od/2+clearance+nozzle_dia*10,h=3.05-ratchet_tooth_h,count=6);
		// bearing cutout
		translate([0,0,4/2]) cylinder(r=bearing_od/2+clearance,center=true,$fn=tape_ratchet_teeth*2,h=4);
	}
}

module cover_spool(width=8) {
	c_width=width-.6;
	difference() {
		union() {
			// rim
			// body
			gear(number_of_teeth=cover_teeth, diametral_pitch=cover_teeth/cover_dia, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=c_width, rim_width=0, gear_thickness=c_width,clearance=-nozzle_dia*3, backlash=-nozzle_dia/2, pressure_angle=5);

			//translate([0,0,c_width/2]) cylinder(r=cover_dia/2,$fnfor(j=[0,tape_depth-tape_depth/8=cover_teeth,center=true,h=c_width);
			//for (i=[0:360/cover_teeth:359]) translate([0,0,c_width/2]) rotate([0,0,i+360/cover_teeth/4]) cube([nozzle_dia*6,cover_dia+nozzle_dia*4,c_width-extra],center=true);
			//rear rim dado
		}
		// bearing cutout
		translate([0,0,c_width/2-bearing_h+1.90]) cylinder(r=bearing_od/2+clearance/2,center=true,$fn=cover_teeth*2,h=c_width);
		// bearing lip cutout
		translate([0,0,c_width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*2,center=true,$fn=cover_teeth*2,h=c_width+extra);
		// front bevel	
		translate([0,0,c_width-nozzle_dia*14/2-extra]) cylinder(r1=bearing_od/2-nozzle_dia*8,r2=bearing_od/2+nozzle_dia*4,center=true,$fn=tape_ratchet_teeth*2,h=nozzle_dia*16);
		// O-ring groove
		// Clutch was too good, so I made two high spots engage first here.  Done by building it as two slightly angled toruses for the O-ring groove.
		translate([0,0,ratchet_tooth_h+nozzle_dia*2]) rotate([0,1,0]) rotate_extrude(convexity = 10) translate([20/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		translate([0,0,ratchet_tooth_h+nozzle_dia*2]) rotate([0,-1,0]) rotate_extrude(convexity = 10) translate([20/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		//translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h-clearance]) cylinder(r=bearing_od/2+nozzle_dia*8,h=clearance*2+extra,$fn=cover_teeth*2,center=true);cover_drive_rotation
		// drive sprocket cutout
		translate([0,0,(ratchet_tooth_h+wall_thickness-lever_arm_thickness+clearance)/2]) cylinder(r=cover_ratchet_dia/2+clearance*2,h=ratchet_tooth_h+clearance*2,$fn=cover_teeth*2,center=true);
	}
}
module cover_idler(width=8) {
	c_width=width;
	translate([0,0,base_thickness/2]) difference() {
		union() {
			// rim
			// body
			rotate([0,0,-7.8]) gear(number_of_teeth=cover_idler_teeth, diametral_pitch=cover_teeth/cover_dia, hub_diameter=0, hub_thickness=0, bore_diameter=6, rim_thickness=c_width, rim_width=0, gear_thickness=c_width,clearance=-nozzle_dia*3, backlash=-nozzle_dia/2, pressure_angle=5);
		}
		// bearing cutout
		translate([0,0,c_width/2-c_width+bearing_h]) cylinder(r=bearing_od/2+clearance/2,center=true,$fn=cover_teeth*2,h=c_width);
		// bearing lip cutout
		translate([0,0,c_width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*4,center=true,$fn=cover_teeth*2,h=c_width+extra*2);
		// front bevel	
		translate([0,0,c_width+nozzle_dia-nozzle_dia*4/2-extra]) cylinder(r1=bearing_od/2-nozzle_dia*4,r2=bearing_od/2+clearance,center=true,$fn=tape_ratchet_teeth*2,h=nozzle_dia*4);
	}
}

module cover_idler_pivot(clearance=0) {
	translate([cover_idler_pivot_x_offset,-cover_idler_pivot_y_offset,base_thickness/2]) difference() {
		union() {
			hull() {
				translate([-cover_idler_x_offset,cover_idler_y_offset,base_thickness/2]) cylinder(r=cover_dia/5+clearance*2,h=base_thickness,center=true);
				translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,base_thickness/2]) cylinder(r=cover_dia/5+clearance*2,h=base_thickness,center=true);
			}
			hull() {
				translate([-cover_idler_pivot_x_offset,cover_y_offset+cover_dia/2+wall_thickness/2,base_thickness*.5/2]) cylinder(r=cover_dia/9+clearance*2,h=base_thickness*1.5+extra/2,center=true);
				translate([-cover_idler_x_offset,cover_idler_y_offset,base_thickness*.5/2]) cylinder(r=cover_dia/5+clearance*2,h=base_thickness*1.5,center=true);
			}
			hull() {
				translate([-cover_idler_pivot_x_offset,cover_y_offset+cover_dia/2+wall_thickness/2,base_thickness*.5/2]) cylinder(r=cover_dia/9+clearance*2,h=base_thickness*1.5,center=true);
				translate([-cover_idler_pivot_x_offset+cover_dia/15,cover_y_offset+cover_dia/2+cover_dia/8+wall_thickness*2,base_thickness*.5/2]) cylinder(r=cover_dia/30+clearance*2,h=base_thickness*1.5,center=true);
			}
		}
		translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,clearance/2]) cylinder(r=cover_dia/8-clearance*1.5,h=base_thickness+extra*2,center=true);
		translate([-cover_idler_pivot_x_offset,cover_idler_y_offset,base_thickness/2-base_thickness/1.5]) cylinder(r=3/2,h=base_thickness*3+extra*2,center=true);
		translate([-cover_idler_pivot_x_offset,cover_idler_y_offset,2.5/2-base_thickness/1.25]) cylinder(r=3,h=2.5+extra*2,center=true);
		translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,base_thickness/2]) cylinder(r=3/2-clearance*2,h=base_thickness*3+extra*2,center=true);
		translate([-cover_idler_pivot_x_offset+wall_thickness/8,cover_y_offset+cover_dia/2+wall_thickness/2,0]) rotate([0,0,183]) band_mount(h=base_thickness*1.25,cutout=1);
	}
}


// Main body
module tape_feeder_body() {
	difference() {
		union() {
			difference() {
				union() {
					// base plate
					translate([0,0,(base_thickness)/2]) {
						hull() {
							translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
							for (i=[-50,50]) rotate([0,0,i]) translate([0,tape_dia/1.67+6.5/2,0]) cylinder(r=6.5/2,h=base_thickness,center=true);
							translate([0,-tape_edge_spacing*2,0]) cube([tape_edge_spacing*4,wall_thickness,base_thickness],center=true);
						}
						hull() {
							translate([-cover_x_offset,cover_y_offset,0]) cylinder(r=cover_dia/2-nozzle_dia,h=base_thickness,center=true);
							intersection() {
								translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
								translate([0,tape_edge_spacing*2,0]) cube([tape_edge_spacing*4,tape_edge_spacing*4,base_thickness],center=true);
							}
							//translate([0,0,0]) cylinder(r=cover_dia/2,h=base_thickness,center=true);
							for (i=[50]) rotate([0,0,i]) translate([0,tape_dia/1.67+6.5/2,0]) cylinder(r=6.5/2,h=base_thickness,center=true);
							translate([-tape_edge_spacing,0,0]) cube([extra,tape_edge_spacing*2,base_thickness],center=true);
						}
						hull() {
							translate([-tape_edge_spacing*1.3/2,0,0]) cube([tape_edge_spacing*5.3,extra,base_thickness],center=true);
							translate([-tape_edge_spacing*1.3/2,-tape_dia/1.75-base_thickness+extra/2,0]) cube([tape_edge_spacing*5.3,extra,base_thickness],center=true);
							translate([-tape_edge_spacing/2,0,0]) cube([tape_edge_spacing*5,extra,base_thickness],center=true);
							translate([-tape_edge_spacing/2,-tape_edge_spacing*2+extra/2,0]) cube([tape_edge_spacing*5,extra,base_thickness],center=true);
						}
					
					}
					translate([0,0,0]) {
						// servo support
						hull() {
							translate([-servo_x_offset+6.2+wall_thickness,cover_y_offset-cover_dia/2+wall_thickness*3,body_width/2]) cylinder(r=nozzle_dia*3,h=body_width,center=true);
							translate([-cover_x_offset-cover_dia/2-wall_thickness,cover_y_offset-cover_dia/2+wall_thickness*3,wall_thickness/2]) cylinder(r=nozzle_dia*3,h=wall_thickness,center=true);
						}

						// servo mount
						translate([-servo_x_offset+6.2+6/2,cover_y_offset-cover_dia/4,body_width/2]) cube([6,cover_dia/2-base_thickness,body_width],center=true);
						// servo and idler plate	
						hull() {
							translate([-servo_x_offset+6*2,cover_y_offset-cover_dia/4,base_thickness/2]) cube([extra,cover_dia/2-base_thickness,base_thickness],center=true);
							translate([-cover_x_offset,cover_y_offset-cover_dia/6+base_thickness/2,base_thickness/2]) cylinder(r=cover_dia/3,h=base_thickness,center=true);
						}
					}
					// cover slip posts
					for (i=[-50,50]) rotate([0,0,i]) translate([0,tape_dia/1.67+6.5/2,base_thickness+base_thickness/4-extra]) cylinder(r=6.5/2, r2=4.5/2,h=base_thickness/2,center=true);
					// cover tape sprocket raised lip
					translate([-cover_x_offset,cover_y_offset,(base_thickness*1.5+lever_arm_thickness/2-ratchet_inset_h+wall_thickness)/2-clearance*1.5]) cylinder(r=cover_dia/2,h=base_thickness+lever_arm_thickness-ratchet_inset_h+wall_thickness,center=true);
					// mounting bracket
					translate([-tape_edge_spacing*1.3/2,-tape_dia/1.75-base_thickness,body_width/2]) cube([tape_edge_spacing*5.3,base_thickness*2,body_width],center=true);
					translate([tape_edge_spacing*2-base_thickness/2,0,0]) hull() {
						translate([0,-tape_edge_spacing/2,base_thickness/2]) cube([base_thickness,base_thickness,base_thickness],center=true);
						translate([0,-tape_edge_spacing*2+body_width/2,body_width/2]) cube([base_thickness,body_width,body_width],center=true);
					}
					translate([0,0,base_thickness+wall_thickness/2]) intersection() {
						hull() {
							translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
							for (i=[-55,55]) rotate([0,0,i]) translate([0,tape_dia/2+6.5+2/2,0]) cylinder(r=6.5/2,h=base_thickness,center=true);
						}
						translate([0,0,0]) cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8+tape_dia*2/9,center=true,h=wall_thickness);
					}
				}
				// spool idler screw hole
				translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,base_thickness]) cylinder(r=2.7/2,h=base_thickness*2+extra,center=true);
				// spool idler pivot cutout
				translate([-cover_idler_pivot_x_offset,cover_idler_pivot_y_offset,0]) for (i=[-3,10]) rotate([0,0,i]) cover_idler_pivot(clearance=.2);
				// servo cutout
				translate([-servo_x_offset,cover_y_offset-servo_y_offset,servo_z_offset]) rotate([90,0,0]) 9g_servo(display=0);
				translate([-servo_x_offset,cover_y_offset-servo_y_offset,servo_z_offset+4]) rotate([90,0,0]) 9g_servo(display=0);
				// mounting bracket cutouts
				translate([0,-tape_edge_spacing*2-wall_thickness/2,6]) {
					rotate([90,0,0]) lego_base();
				}
				translate([tape_edge_spacing*2-tape_edge_spacing/2,-tape_edge_spacing*2+6,6]) {
					rotate([0,0,90]) cylinder(r=4/2,h=tape_edge_spacing,center=true);
					rotate([0,90,0]) cylinder(r=4/2,h=tape_edge_spacing+extra,center=true);
				}
				// sprocket cutouts
				translate([0,0,base_thickness*1.5-ratchet_inset_h/2]) cylinder(r=tape_dia/2+1.5,h=base_thickness+extra*2,center=true);
				difference() {
					translate([0,0,base_thickness*1.5-ratchet_inset_h/2-nozzle_dia]) cylinder(r=tape_dia/2+1.5,h=base_thickness+extra*2,center=true);
					for (i=[0:120:359]) rotate([0,0,i+40]) cube([nozzle_dia*8,tape_dia+3,base_thickness*4],center=true);
				}
				translate([0,0,base_thickness*1.5-ratchet_inset_h+clearance/2]) cylinder(r=tape_dia/2,h=base_thickness+clearance,center=true);
				// cover spool raised lip bumps	
				difference() {
					translate([-cover_x_offset,cover_y_offset,base_thickness*1.5-ratchet_inset_h+wall_thickness*1.5-clearance*1.5]) cylinder(r=cover_dia/2+extra,h=wall_thickness,center=true);
					translate([-cover_x_offset,cover_y_offset,base_thickness*1.5+wall_thickness/2+clearance]) for (i=[0:120:359]) rotate([0,0,i+55]) cube([nozzle_dia*8,tape_dia+3,base_thickness*4],center=true);
				}
				translate([-cover_x_offset,cover_y_offset,base_thickness*1.5-ratchet_inset_h+wall_thickness/2+clearance/2]) cylinder(r=cover_dia/2-nozzle_dia*3,h=base_thickness+wall_thickness+clearance,center=true);
				// tape drive cutouts
				for(i=[0,lever_throw_angle+1]) translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h]) rotate([0,0,-i]) cover_drive(cutout=1);
				for(i=[0,lever_throw_angle]) translate([0,0,base_thickness-ratchet_inset_h]) rotate([0,0,i]) tape_drive(cutout=1);
			}
			// tape drive post
			translate([0,0,base_thickness-ratchet_inset_h]) {
				translate([0,0,bearing_h/2+base_thickness/2-clearance/2]) cylinder(r=bearing_id/2+clearance/6+extra,$fn=12,h=bearing_h+extra,center=true);
				translate([0,0,.8/2]) cylinder(r2=bearing_od/2-clearance*2,r1=bearing_od/2-clearance,center=true,$fn=tape_ratchet_teeth*2,h=.8+extra);
				translate([0,0,.8+.9/2]) cylinder(r2=bearing_od/2.7,r1=bearing_od/2-clearance*2,center=true,h=.9+extra);
			}
			// tape cover post
			translate([-cover_x_offset,cover_y_offset,base_thickness-ratchet_inset_h]) {
				translate([0,0,bearing_h/2+base_thickness/2-clearance/2]) cylinder(r=bearing_id/2+clearance/6+extra,$fn=12,h=bearing_h+extra,center=true);
				translate([0,0,.8/2]) cylinder(r2=bearing_od/2-clearance*2,r1=bearing_od/2-clearance,center=true,$fn=tape_ratchet_teeth*2,h=.8+extra);
				translate([0,0,.8+.9/2]) cylinder(r2=bearing_od/2.7,r1=bearing_od/2-clearance*2,center=true,h=.9+extra);
			}
		}
		// tape drive post cutouts
		translate([0,0,0]) {
			translate([0,0,wall_thickness+nozzle_dia/2]) tape_pin_ratchet(pin_socket=1);
			translate([0,0,10/2+2+nozzle_dia]) cylinder(r=2.9/2+clearance,h=10+extra*2,center=true);
			translate([0,0,2/2]) cylinder(r1=4,r2=2.8,h=2+extra,center=true);
		}
		// tape cover post cutouts
		translate([-cover_x_offset,cover_y_offset,0]) {
			translate([0,0,wall_thickness+nozzle_dia/2]) cover_pin_ratchet(pin_socket=1);
			translate([0,0,10/2+2+nozzle_dia]) cylinder(r=2.9/2+clearance,h=10+extra*2,center=true);
			translate([0,0,2/2]) cylinder(r1=4,r2=2.8,h=2+extra,center=true);
		}
		// cover slip post cutouts	
		for (i=[-50,50]) rotate([0,0,i]) translate([0,tape_dia/1.67+6.5/2,base_thickness+nozzle_dia]) cylinder(r=2/2,h=base_thickness*2,center=true);
		translate([-cover_x_offset/1.7,-tape_dia/2.05,base_thickness-.3]) scale([.25,.25,1]) emboss_logo();
		
	}
}

module lego_base(length=12,width=1) {
	// width 1 is actually 2 posts, because I added a third fitting between.
	u=1.6;
	pin=3*u;
	w=width;
	h=2;
	l=length;
	for (i=[0:1:l]) {
		for (j=[0:1:w*2]) translate([-l*u*5/2+5*u*i,u*5*j/2-2.5*u,h*u/2]) rotate([0,0,22.5]) cylinder(r1=3.25*u/2+clearance,r2=3.25*u/2+clearance/6,h=h*u,$fn=8,center=true);
		translate([-l*u*5/2-2.5*u+5*u*i,0,h*u/2]) cube([.75*u,10*u,h*u],center=true);	
	}
	for (i=[0:2:l]) for (j=[w]) translate([-l*u*5/2+5*u*i,u*5*j/2-2.5*u,-h*u]) rotate([0,0,22.5]) cylinder(r=3*u/2+clearance/6,h=h*u*2+extra*2,center=true);
}

// Generate the ratchet teeth
module pnp_ratchet_ratchet_teeth(h=ratchet_tooth_h,r=0,ratchet_teeth=0,count=0,tooth_clearance=0,solid=1) {
	inset=r/ratchet_teeth+nozzle_dia*7+clearance;
	union() {
		for (i=[0:(360/ratchet_teeth):(360/ratchet_teeth*count)-1]) rotate([0,0,i+60]) translate([r-r/5-nozzle_dia*2.5,0]) rotate([0,0,-40]) scale([1.3,1,1]) {
			if (i == 0 ) {
				cylinder(r=r/5-tooth_clearance/2,$fn=3,h=h,center=true);
			} else {
				cylinder(r=r/5-tooth_clearance/2,$fn=3,h=h,center=true);
			}
		}
			
		if (solid) cylinder(r=r-inset,h=h,center=true);
	}
}


// This is the shape for all the ratchety things 
module tape_ratchet(h=wall_thickness+ratchet_tooth_h-clearance,ratchet_teeth=tape_ratchet_teeth,r=tape_dia/2,tooth_clearance=0,cutout_dia=bearing_od+clearance*8+nozzle_dia*12,drive_angle=0,drive_r=0,pivot=0,pin=0,ratchet=0,pin_socket=0,pivot_hole=0,spring=0,cutout=0) {
	tooth_angle=360/ratchet_teeth;
	inset=r/ratchet_teeth+nozzle_dia*7+clearance;
	translate([0,0,h/2]) {
		difference() {
			union() {
				if (ratchet) {
					difference() {
						union() {
							intersection() {
								cylinder(r=r-inset,h=h,center=true);
								hull() {
									rotate([0,0,tooth_angle*0]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
									rotate([0,0,-60-tooth_angle*2]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
								}
							}
							rotate([0,0,-tooth_angle*4]) pnp_ratchet_ratchet_teeth(r=r,ratchet_teeth=ratchet_teeth,h=h,count=1,tooth_clearance=tooth_clearance,solid=0);
						}
						cylinder(r=r-inset-nozzle_dia*3,h=h+extra*2,center=true);
					}
					rotate([0,0,tooth_angle*0]) hull() {
						rotate([0,0,-tooth_angle*1.5]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16,center=true,h=h);
					}
				}
				if (pivot ) {
					rotate([0,0,tooth_angle*0]) hull() {
						cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8,center=true,h=h);
						translate([0,r-inset-r/10,0]) scale([1.5,1,1]) cylinder(r=r/10,center=true,h=h);
					}
				}
				if (pin || pin_socket) {
					rotate([0,0,-tooth_angle*0]) hull() {
						rotate([0,0,-tooth_angle]) translate([0,r-inset-nozzle_dia*2.5,0]) cylinder(r=nozzle_dia*1.5+clearance,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16+clearance,center=true,h=h);
					}
				}
				if (cutout) {
					hull() {
						for (i=[-drive_angle,drive_angle]) rotate([0,0,i/2]) translate([-drive_r*1.2/2,0,h/2]) cube([drive_r*1.2,extra,h*2],center=true);
						translate([0,0,h/2]) cylinder(r=cutout_dia/2,center=true,h=h*2);
					}
				}

			}
		}
	
	}
}
// Accurate bearing model, so I could get that right.
module bearing(r1=2/2,r2=6/2,h=2.5){
	intersection() {
		difference() {
			union() {
				color("grey") difference() {
					cylinder(r=r2,h=h,center=true);
					cylinder(r=r2/1.15,h=h+extra,center=true);
				}
				color("grey") difference() {
					cylinder(r=r1/.7,h=h,center=true);
					cylinder(r=r1/2,h=h+extra,center=true);
				}
				color("orange") cylinder(r=r2-extra,h=h*.9,center=true);
			}
			color("grey") cylinder(r=r1,h=h+extra*2,center=true);
			translate([0,0,h/2.2]) color("grey") cylinder(r1=0,r2=r1*2,h=h,center=true);
			translate([0,0,-h/2.2]) color("grey") cylinder(r2=0,r1=r1*2,h=h,center=true);
		}
		translate([0,0,h/2.2]) color("grey") cylinder(r2=0,r1=r2*2,h=h*2,center=true);
		translate([0,0,-h/2.2]) color("grey") cylinder(r1=0,r2=r2*2,h=h*2,center=true);
	}
}
// Tuned for a moving, slip fit
module slip_bearing_cutout() {
	// bearing outer slip joint
	// the 12 facets decrease the contact area which allows a greater usable range for the slip fit.
	// However this also reduces the ID, so an inner slip ring like this is actually 10% larger than the OD because of it.
	translate([0,0,20/2-extra]) cylinder(r=bearing_od/1.91,$fn=12,center=true,h=25);
	// bearing bevel
	translate([0,0,nozzle_dia*3/2]) cylinder(r2=bearing_od/2-nozzle_dia*1,r1=bearing_od/2+nozzle_dia*2,center=true,h=nozzle_dia*3+extra*2);
}

// Dado's, they live on in code
module shaft_dado_coupler(r1=bearing_od+clearance*.75,r2=bearing_od+clearance*.75,h=wall_thickness,clearance=.2,count=6) {
	width=r1*3.1415926/count/1.2;
	for (i=[0:360/count:359]) rotate([0,0,i]) {
		translate([0,r1/2+clearance,0]) rotate([0,0,0]) cube([width+clearance*2,r2,h+clearance*2],center=true);
	}
}


module 9g_servo(display=0){
	translate([-5.5,0,-29.25/2-3.65]) difference() {
		union() {
			if (display) {
				color("grey") translate([0,0,2.5*2+2.5/2-3/2]) cube([32,12.5,2.5], center=true);
			} else {
				translate([0,0,2.5*2+2.5/2-3/2]) cube([32+clearance,22.5+clearance,2.5+clearance], center=true);
			}
			union() {	
				color("grey") cube([23+clearance*2,12.5+clearance*2,23+clearance*2], center=true);
				color("grey") translate([-1,0,2.75+clearance]) cube([5+clearance,5.6+clearance,25.75], center=true);
				if (display) {
					color("grey") translate([5.5,0,2.75+clearance]) cylinder(r=6+clearance, h=25.75, $fn=20, center=true);
				} else {
					translate([5.5,0,7.75+clearance]) cube([12,12.5,30.75],center=true);
				}

			}		
			color("grey") translate([-.5,0,1.75]) cylinder(r=1, h=25.75, $fn=20, center=true);
			color("white") translate([5.5,0,3.65]) cylinder(r=2.35, h=29.25, $fn=20, center=true);				
			if (! display) for ( hole = [14,-14] ){
				translate([hole,0,4]) cylinder(r=1.75/2, h=18, $fn=20, center=true);
			}
		}	
		if (display) for ( hole = [14,-14] ){
			translate([hole,0,4]) cylinder(r=2.1/2, h=12, $fn=20, center=true);
		}
	}
}


module band_mount(length=tape_dia,cutout=0,h=base_thickness) {
	difference() {
		if (! cutout) union() {
			hull() {
				translate([-wall_thickness,0,h/2]) cylinder(r=wall_thickness*2,h=h,center=true);
				translate([wall_thickness,0,h/2]) cylinder(r=wall_thickness*2,h=h,center=true);
			}
		}
		union() {
			translate([wall_thickness,0,h/2]) rotate([0,0,-90]) intersection() {
				translate([0,wall_thickness*2,0]) cube([wall_thickness*8,wall_thickness*4,wall_thickness*2], center=true);
				rotate_extrude() translate([wall_thickness*2,0,0]) scale([1,1]) circle(r=wall_thickness/1.25,center=true);
			}
			for (i=[-wall_thickness*2,wall_thickness*2]) translate([wall_thickness-length/2+extra,i,h/2]) scale([1,1,1]) rotate([0,90,0]) cylinder(r=wall_thickness/1.25,h=length,center=true);
			difference() {
				hull() {
					translate([-wall_thickness*4,0,h]) cylinder(r=wall_thickness*2.8,h=h,center=true);
					translate([wall_thickness,0,h]) cylinder(r=wall_thickness*2.8,h=h,center=true);
				}
				hull() {
					translate([-wall_thickness*4,0,h]) cylinder(r=wall_thickness*2,h=h,center=true);
					translate([wall_thickness,0,h]) cylinder(r=wall_thickness*2,h=h,center=true);
				}
			}
		}
	}
}

module emboss_logo(url=0) {
	logo();
	if ( url == 1) translate([-34, -15,0]) linear_extrude(height = .4) scale([.685,.60,1]) text("Arcus3D.com", halign = "left", font="Arial Black");
	translate([0,0,-.2]) intersection() {
		#translate([16,9.5,.105]) rotate([0,0,180]) scale([1,.39,1]) cylinder(r = 49.3, h = .205, center = true, $fn=3);
		scale([1,1,2]) logo();
	}
}

module logo() {
	translate([-25.3,5,.2])rotate([0,0,-30]) cylinder(r = 18, h = .4, center = true, $fn=3);
	translate([15.2,9.1,0]) linear_extrude(height = .4) scale([2.65,2.65,1]) text("3D", halign = "center",valign="center",font="Arial Black");
}

