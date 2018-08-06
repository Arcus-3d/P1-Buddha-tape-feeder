// Arcus-3D-P1 - Buddha Tape feeder OpenSCAD source

// Licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License
// http://creativecommons.org/licenses/by-sa/3.0/

// Project home
// https://hackaday.io/project/159792

// Author
// Daren Schwenke at g mail dot com

// Please like my projects if you find them useful.  Thank you.

//////////////////////////////////////////////////////////////
// Globals

// General clearance.  Usually I do 2x this for loose fit 1.5x for slip fit, and 0x to 1x for press fit.
clearance=.20;

// Nozzle size for parts only a few widths thick.  Prints better.
nozzle_dia=.3;

// Rendering circle complexity.  Turn down while editing, up while rendering.
$fn=90; 
//$fn=30;


// Many things are a multiple of this general wall thickness.
wall_thickness=nozzle_dia*4; 

// For differencing so OpenSCAD doesn't freak out
extra=.02;
 
// Cause I'm hungry
pi=3.1415926; 

// Skateboard bearing dimensions
bearing_od=22.04;
bearing_id=8.15;
bearing_h=7;

// Because I'm all about that base plate thickness
base_thickness=wall_thickness*2;

// Tape spool
tape_pitch=4.0-.02;
tape_teeth=40;
tape_dia=tape_pitch*tape_teeth/pi;

// Cover spool
cover_pitch=4.5;
cover_teeth=32;
cover_dia=cover_pitch*cover_teeth/pi;
cover_spool_depth=3;

// Tuning
// The cover tape spool can either rotate on release, or on engagement.
// On release, the tape is pulled while the feeder advances.
// On engagement, the tape is pulled only when engaged.  
// Engagement may be used to expose parts, but leave them covered until the head comes to grab the next one.
// This will likely engage the counter-rotation ratchet for the tape drive, so it will become the new stop.
// Set to 1 for engagement style rotation.
cover_rotation_direction=1;
// Controls attachment points for connecting rod, and therefore, the drive ratio
drive_ratio=1.3;
cover_drive_r=cover_dia/2+2.5;
tape_drive_r=cover_drive_r*drive_ratio;

// Ratchets inlaid into base so I can get my 12mm target width
ratchet_inset_h=wall_thickness;
ratchet_tooth_h=wall_thickness*1.5;

// After setting drive ratio, I tuned this to exceed one click on each ratchet by as much as I can, without a second click....
lever_throw_angle=360/cover_teeth*1.9; 
lever_arm_thickness=wall_thickness;

// Useful
cover_h_offset=(tape_dia+cover_dia+cover_spool_depth)*.58;
cover_v_offset=tape_dia/1.75+wall_thickness-cover_dia/2-cover_spool_depth;
cover_angle=atan(cover_v_offset/cover_h_offset);
tape_edge_spacing=(tape_dia/1.75*2+wall_thickness*2)/4;

//////////////////////////////////////////////////////////////
// The parts for rendering
// Uncomment each part here, save, render, then export to STL.

//tape_feeder_body();
//tape_feeder_lever(servo_drive=0);

//tape_drive();
//rotate([90,0,0]) tape_drive_spring_pivot();

//cover_pin_ratchet();
//tape_pin_ratchet();

//tape_drive_sprocket();
//tape_idler_sprocket(width=8);
//tape_slot_cover(width=8);

//print this to make bending the connecting rod to the proper length easier.
//connecting_rod_template(); 

//cover_drive_sprocket();
//cover_idler_sprocket(width=8);
//cover_idler_rim();
//cover_tension_knob();

//////////////////////////////////////////////////////////////
// Assembly views.

rotate([90,0,0]) tape_feeder_assembly(cross_section=0, explode=0);
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
	//rotation=67;
	//rotation=lever_throw_angle;
	intersection() {
		if (cross_section == 1) translate([0,0,90]) rotate([0,0,rotation]) cube ([200,extra,200],center=true); 
		if (cross_section == 2) translate([-cover_h_offset,cover_v_offset,0]) rotate([0,0,rotation]) cube ([200,extra,200],center=true); 
		if (cross_section == 3) translate([-cover_h_offset,cover_v_offset,0]) rotate([0,0,-cover_angle+rotation]) cube ([200,extra,200],center=true); 
		union() {
			if (1) tape_feeder_body();
			if (0) translate([0,0,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,-cover_angle-lever_throw_angle/4+rotation/drive_ratio-4.5]) tape_drive(print=0);
			if (0) translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,rotation]) tape_feeder_lever();
			if (0) translate([0,0,base_thickness+clearance/2+explode*2]) rotate([0,0,180-cover_angle-lever_throw_angle+c_rotation/drive_ratio-15]) tape_spool_assembly(explode=explode);
			if (0) translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h+lever_arm_thickness+wall_thickness+clearance/2+explode*2]) rotate([0,0,-lever_throw_angle-cover_angle+-6.9+c_rotation]) cover_spool_assembly(explode=explode,print=0);
			if (0) {
				translate([0,0,base_thickness/2+nozzle_dia-clearance/2+explode/2]) rotate([0,0,180-(360/tape_teeth/1.95)-cover_angle-lever_throw_angle/2]) tape_pin_ratchet(print=0);
				translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h+clearance/2+explode/2]) rotate([0,0,-lever_throw_angle-cover_angle+(360/cover_teeth*-4.25)-cover_rotation_direction*(270-lever_throw_angle-cover_angle-(360/cover_teeth*2))]) mirror([cover_rotation_direction,0,0]) cover_pin_ratchet(print=0);
			}
			// Ghost views for visualizing part travel
			if (0) translate([0,0,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,lever_throw_angle/drive_ratio-14]) %tape_drive(print=0);
			if (0) translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h+clearance/2+explode]) rotate([0,0,lever_throw_angle]) %tape_feeder_lever();
		} 
	}
}

module tape_spool_assembly(width=8,explode=0,cross_section=0) {
	intersection() {
		if (cross_section) rotate([0,0,30]) cube([100,extra,100],center=true);
		union() {
			if (1) tape_drive_sprocket(print=0);
			if (1) translate([0,0,width+1.5+explode]) rotate([180,0,0]) tape_idler_sprocket(width=width);
			if (0) translate([0,0,width-1.1+explode]) cover_tension_knob(width=width);
			if (1) translate([0,0,3.4+explode/2]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
			if (0) translate([tape_dia/2-1.5,0,4.85]) {
				difference() {
					cube([.74,30,8.1],center=true);
					for (i=[0:4:24]) translate([0,-12+i,-8.1/2+1.78]) rotate([0,90,0]) cylinder(r=1.5/2,h=2,center=true);
				}
			}
		}
	}
}

module cover_spool_assembly(explode=0,width=8,cross_section=0) {
	rotation=45;
	rotate([0,0,-rotation]) intersection() {
		if (cross_section) rotate([0,0,rotation]) cube([100,extra,100],center=true);
		union() {
			if (1) translate([0,0,-wall_thickness+clearance/2]) cover_drive_sprocket(print=0);
			if (1) translate([0,0,3.4-lever_arm_thickness+ratchet_inset_h-wall_thickness+explode/2]) bearing(r2=bearing_od/2,r1=bearing_id/2,h=bearing_h);
			if (1) translate([0,0,width+.15+explode*1.5]) rotate([180,0,0]) {
				translate([0,0,0]) cover_idler_sprocket();
				if (1) color("darkgray") translate([0,0,width-1.20-ratchet_tooth_h-ratchet_inset_h+wall_thickness+nozzle_dia]) rotate([0,0,0]) rotate_extrude(convexity = 10) translate([bearing_od/2+1.6/1.7,0,0]) circle(r=1.6/2,center=true);
			}
			if (1) translate([0,0,0]) cover_idler_rim();
		}
	}
}

// Parts

module connecting_rod_template() {
	h=wall_thickness;
	difference() {
		hull() {
			translate([-cover_h_offset,cover_v_offset,h/2]) rotate([0,0,-lever_throw_angle/4-cover_angle+4]) translate([0,cover_drive_r,0]) cylinder(r=1/2+wall_thickness,h=h,center=true);
			rotate([0,0,0]) translate([0,tape_drive_r,0]) cylinder(r=1/2+wall_thickness,h=h,center=true);
		}
		translate([-cover_h_offset,cover_v_offset,h/2]) rotate([0,0,-lever_throw_angle/4-cover_angle+4]) translate([0,cover_drive_r,0]) cylinder(r=1/2+clearance/2,h=h+extra*4,center=true);
		rotate([0,0,0]) translate([0,tape_drive_r,0]) cylinder(r=1/2+clearance/2,h=h+extra*4,center=true);
	}
}

module tape_drive_spring_pivot() {
	difference() {
		union() {
			translate([0,0,15]) cylinder(r1=3.4/2,r2=2.8/2,h=1+extra,center=true);
			translate([0,0,9]) cylinder(r=3.4/2,h=11,center=true);
			hull() {
				translate([0,0,4]) cylinder(r=5.1/2,h=.5,center=true);
				translate([-wall_thickness,0,1]) cube([wall_thickness*3,wall_thickness*3,1],center=true);
				translate([-wall_thickness*.75,0,-2.5]) rotate([0,90,0]) cylinder(h=wall_thickness*3.5,r=wall_thickness*3/2,center=true);
			}
		}
		scale([1,1.25,1]) cylinder(r=1.35/2,h=35+extra,center=true);
		translate([-1.5/2-clearance,-tape_drive_r/9,-tape_drive_r/9*2+wall_thickness*3.2]) rotate([0,90,0]) scale([1,2,1]) cylinder(r=tape_drive_r/9,center=true,h=ratchet_inset_h+clearance);
		translate([0,-wall_thickness*3+clearance/2,0]) cube([wall_thickness*6,wall_thickness*3,tape_drive_r],center=true);
	}
}
		
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
					translate([0,-slot_cover_length/2-3,nozzle_dia*4/2]) cube([slot_cover_width-wall_thickness,12,nozzle_dia*4],center=true);
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

module cover_pin_ratchet(print=1) {
	if (print) {	
		rotate([180,0,0]) mirror([cover_rotation_direction,0,0]) pin_ratchet(h=ratchet_tooth_h+lever_arm_thickness-clearance,r=cover_dia/2-nozzle_dia*4-clearance*3,teeth=cover_teeth);
	} else {
		mirror([cover_rotation_direction,0,0]) pin_ratchet(h=ratchet_tooth_h+lever_arm_thickness-clearance,r=cover_dia/2-nozzle_dia*4-clearance*3,teeth=cover_teeth);
	}
}

module tape_pin_ratchet(print=1) {
	if (print) {
		rotate([180,0,0]) pin_ratchet(h=ratchet_tooth_h+ratchet_inset_h-clearance*1.5);
	} else {
		pin_ratchet(h=ratchet_tooth_h+ratchet_inset_h-clearance*1.5);
	}
}

module pin_ratchet(pin_depth=base_thickness-nozzle_dia-clearance,r=tape_dia/2,h=ratchet_inset_h+ratchet_tooth_h-clearance,teeth=tape_teeth) {
	union() {
		tape_ratchet(h=h,pin=1,ratchet=1,r=r,teeth=teeth,tooth_clearance=.2);
		translate([0,0,-pin_depth/2]) tape_ratchet(h=pin_depth,pin=1,r=r,teeth=teeth);
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

// Tape drive ratchet, connected by piano wire to lever arm
module tape_drive(h=ratchet_tooth_h+ratchet_inset_h,supports=0,drive_r=tape_drive_r) {
	union() {
		difference() {
			rotate([0,0,-cover_angle-lever_throw_angle/4+10]) tape_ratchet(h=h,pivot=1,ratchet=1,pin=1,pivot_hole=1,tooth_clearance=.3,spring=1,drive_r=drive_r,supports=supports);
			slip_bearing_cutout();
		}
	}
}

// Lever arm, cover drive ratchet, connected by piano wire to tape_drive
module tape_feeder_lever(cutout=0,servo_drive=0) {
	h=lever_arm_thickness;
	if (cutout) hull() {
		translate([cover_h_offset/8,cover_dia/1.5,h]) cylinder(r=cover_dia/6,h=h*2,center=true);
		translate([0,0,h]) cylinder(r=cover_dia/3.35,h=h*2,center=true);
	} else {
		difference() {
			union() {
				if (! servo_drive) {
					// handle end
					translate([cover_h_offset/1.5,cover_dia*1.1,(h+8)/2-extra]) cylinder(r=cover_dia/12,h=8,center=true);
					// end to first joint
					hull() {
						translate([cover_h_offset/1.5,cover_dia*1.1,h/2]) cylinder(r=cover_dia/12,h=h,center=true);
						translate([cover_h_offset/8,cover_dia/1.5,h/2]) cylinder(r=cover_dia/6,h=h,center=true);
					}
					// support rib
					hull() {
						translate([cover_h_offset/1.5,cover_dia*1.1,8/2]) cylinder(r=h/2,h=8,center=true);
						translate([cover_h_offset/8,cover_dia/2+cover_spool_depth+wall_thickness,h/2]) cylinder(r=h/2,h=h,center=true);
					}
				}
				// first joint to center
				hull() {
					translate([cover_h_offset/8,cover_dia/1.5,h/2]) cylinder(r=cover_dia/6,h=h,center=true);
					translate([0,0,h/2]) cylinder(r=cover_dia/3.35,h=h,center=true);
				}	
				hull() {
					translate([cover_h_offset/4.5,cover_dia/1.3,h/2]) cylinder(r=wall_thickness*2,h=h,center=true);
					translate([cover_h_offset/8,cover_dia/1.5,h/2]) cylinder(r=cover_dia/6,h=h,center=true);
				}
				//servo slot
				translate([0,0,0]) hull() {
					for (i=[0,lever_throw_angle]) rotate([0,0,-i]) 
					translate([-4,cover_dia/2+cover_dia/7,h/2]) cylinder(r=cover_dia/10,h=h,center=true);
				}
				// ratchet
				rotate([0,0,180-lever_throw_angle]) mirror([cover_rotation_direction,0,0]) rotate([0,0,-360/cover_teeth*2])
				tape_ratchet(h=h+ratchet_tooth_h-clearance,r=cover_dia/2-nozzle_dia*4-clearance*3,drive_r=cover_drive_r,teeth=cover_teeth,tooth_clearance=.3,pivot=1,pin=0,ratchet=1);
				translate([0,0,(h+ratchet_tooth_h)/2+clearance/4]) cylinder(r=cover_dia/3.5,h=h+ratchet_tooth_h+clearance/2,center=true);
			}
			translate([0,0,0]) hull() {
				for (i=[0,lever_throw_angle]) rotate([0,0,-i]) 
				translate([-4,cover_dia/2+cover_dia/7,h/2]) cylinder(r=1/2,h=h*2,center=true);
			}
			// bearing slip joint
			slip_bearing_cutout();
			// tape drive hole
			rotate([0,0,-lever_throw_angle/4-cover_angle+4]) translate([0,cover_drive_r,0]) cylinder(r=1/2+clearance/2,h=base_thickness*4,center=true);
		}
	}
}

// Tape idler, mates with tape drive.
// This was designed with an intentionally thin face, so it will bend out slightly when the tape enters keeping it centered and pushed up.
module tape_idler_sprocket(width=8) {
	difference() {
		union() {
			// rim
			translate([0,0,.4/2]) cylinder(r=tape_dia/2+1,h=.4,$fn=tape_teeth*2,center=true);
			//  lifting wedge
			translate([0,0,.4+.35/2]) cylinder(r1=tape_dia/2+1, r2=tape_dia/2,h=.35,$fn=tape_teeth*2,center=true);
			// wedge bottom	
			translate([0,0,.5+.6]) cylinder(r=tape_dia/2,h=.75,$fn=tape_teeth*2,center=true);
			// body recess	
			translate([0,0,(width-1.6)/2]) cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_teeth*2,center=true,h=width-1.6);
			// drive dado
			translate([0,0,width-1.6+(3.05-ratchet_tooth_h)/2-extra]) intersection () {
				cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_teeth*2,center=true,h=3.05-ratchet_tooth_h+extra);
				shaft_dado_coupler(r1=bearing_od/2+clearance,r2=bearing_od/2+clearance+nozzle_dia*10,h=3.05-ratchet_tooth_h,clearance=0,count=6);
			}
		}
		// thin out rim for flexing
		translate([0,0,.4]) difference() {
			translate([0,0,.75+extra]) cylinder(r=tape_dia/2-nozzle_dia*6,$fn=tape_teeth*2,center=true,h=.75);
			translate([0,0,.75+extra]) cylinder(r=bearing_od/2+clearance+nozzle_dia*6,$fn=tape_teeth*2,center=true,h=.75);
		}
		// bearing lip inner
		translate([0,0,width/2]) cylinder(r=bearing_od/2-nozzle_dia*4,center=true,$fn=tape_teeth*2,h=width+extra*2);
		// bearing cutout
		translate([0,0,width/2+width-5.45]) cylinder(r=bearing_od/2+clearance,center=true,h=width);
		// front rim bevel
		translate([0,0,nozzle_dia*4/2-extra]) cylinder(r2=bearing_od/2-nozzle_dia*4,r1=bearing_od/2+clearance,center=true,$fn=tape_teeth*2,h=nozzle_dia*4);
	}
}

// Cover idler, houses cover drive and mates with cover idler rim.
module cover_idler_sprocket(width=8) {
	c_width=width-1;
	difference() {
		union() {
			// rim
			translate([0,0,1/2]) cylinder(r=cover_dia/2+cover_spool_depth,h=1,$fn=tape_teeth*2,center=true);
			// body
			translate([0,0,c_width/2]) cylinder(r=cover_dia/2,$fn=tape_teeth*2,center=true,h=c_width-extra);
			//rear rim dado
			translate([0,0,c_width+1/2]) intersection () {
				cylinder(r=cover_dia/2,$fn=cover_teeth*2,center=true,h=1+extra*2);
				translate([0,0,0]) shaft_dado_coupler(r1=cover_dia/2-nozzle_dia*3,r2=cover_dia/2+nozzle_dia*8,h=1+extra,clearance=0,count=12);
			}
		}
		// hollow out center, minus support ribs
		difference() {
			translate([0,0,c_width/2+1+extra]) cylinder(r=cover_dia/2-nozzle_dia*3,$fn=tape_teeth*2,center=true,h=c_width);
			translate([0,0,c_width/2]) cylinder(r=bearing_od/2+nozzle_dia*6,h=c_width+extra*2,$fn=tape_teeth*2,center=true);
			translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h+wall_thickness+.5/2]) rotate_extrude(convexity = 10) translate([bearing_od/2+nozzle_dia*3,0,0]) circle(r=5/2,$fn=12,center=true);
			translate([0,0,c_width-3-(3.5+wall_thickness)/2]) cylinder(r1=bearing_od/2+nozzle_dia*4,r2=bearing_od/2+5/2,h=3.5+wall_thickness,$fn=tape_teeth*2,center=true);
			for (i=[0:120:359]) translate([0,0,c_width/2]) rotate([0,0,i]) cube([nozzle_dia*2,cover_dia-extra,c_width+extra],center=true);
		}
		// cover tape grab slots
		mirror([cover_rotation_direction,0,0]) for (i=[0:120:359]) rotate([0,0,i]) translate([0,cover_dia/2,4.75/2]) rotate([0,0,-185]) hull() {
			for (j=[0,4]) rotate([0,0,j]) translate([cover_dia/2+nozzle_dia,0,0]) cube([cover_dia,extra,4.75+extra],center=true);
		}
		// bearing cutout
		translate([0,0,c_width/2+c_width-4.8]) cylinder(r=bearing_od/2+clearance/2,center=true,$fn=tape_teeth*2,h=c_width);
		// bearing lip cutout
		translate([0,0,c_width/2]) cylinder(r=bearing_od/2+clearance-nozzle_dia*4,center=true,$fn=tape_teeth*2,h=c_width);
		// front bevel	
		translate([0,0,nozzle_dia*4/2-extra]) cylinder(r2=bearing_od/2-nozzle_dia*4,r1=bearing_od/2+clearance,center=true,$fn=tape_teeth*2,h=nozzle_dia*4);
		// O-ring groove
		// Clutch was too good, so I made two high spots engage first here.  Done by building it as two slightly angled toruses for the O-ring groove.
		translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h+wall_thickness+nozzle_dia*2]) rotate([0,1,0]) rotate_extrude(convexity = 10) translate([bearing_od/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h+wall_thickness+nozzle_dia*2]) rotate([0,-1,0]) rotate_extrude(convexity = 10) translate([bearing_od/2+nozzle_dia*3.25,0,0]) circle(r=2.3/2,$fn=12,center=true);
		//translate([0,0,c_width-ratchet_tooth_h-ratchet_inset_h-clearance]) cylinder(r=bearing_od/2+nozzle_dia*8,h=clearance*2+extra,$fn=tape_teeth*2,center=true);
		// drive sprocket cutout
		translate([0,0,c_width+2.9-(ratchet_tooth_h+wall_thickness+.85)/2]) cylinder(r=cover_dia/2-nozzle_dia*3,h=ratchet_tooth_h+wall_thickness+.85+extra,$fn=tape_teeth*2,center=true);
	}
}

module cover_idler_rim() {
	translate([0,0,1.25/2])  difference() {
		cylinder(r=cover_dia/2+cover_spool_depth,h=1,$fn=tape_teeth*2,center=true);
		shaft_dado_coupler(r1=cover_dia/2-nozzle_dia*4+clearance*3,r2=cover_dia/2+clearance*1.5,h=20,clearance=.2,count=12);
		cylinder(r=cover_dia/2-nozzle_dia*4+clearance*2,$fn=cover_teeth*2,center=true,h=20);
	}
}

// Cover drive sprocket.  Internal ratchet teeth.
// Two sources of friction can drive this.  An O-ring on the bearing against the face, or without the O-ring, the faces rubbing.
module cover_drive_sprocket(print=1) {
	if (print) { 
		rotate([180,0,0]) translate([0,0,-(ratchet_tooth_h+.85)]) cover_drive_sprocket_part();
	} else {
		cover_drive_sprocket_part();
	}
}

module cover_drive_sprocket_part() {
	difference() {
		translate([0,0,(ratchet_tooth_h+wall_thickness)/2]) cylinder(r=cover_dia/2-nozzle_dia*3-clearance*2,h=ratchet_tooth_h+wall_thickness,$fn=tape_teeth*2,center=true);
		translate([0,0,ratchet_tooth_h/2+extra]) mirror([cover_rotation_direction,0,0]) pnp_ratchet_teeth(teeth=cover_teeth,r=cover_dia/2-nozzle_dia*4-clearance*3,clearance=0,count=cover_teeth,h=ratchet_tooth_h+extra*4);
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
			translate([0,0,.2+2.85/2]) cylinder(r=tape_dia/2,h=2.85,$fn=tape_teeth*2,center=true);
			// lifting wedge
			translate([0,0,.4+.5/2]) cylinder(r1=tape_dia/2+1, r2=tape_dia/2,h=.5,$fn=tape_teeth*2,center=true);
			// rim
			translate([0,0,.4/2]) cylinder(r=tape_dia/2+1,h=.4,$fn=tape_teeth*2,center=true);
			// sprocket teeth
			intersection() {
				union() {
					translate([0,0,2.2+.85/2]) for (i=[0:(360/tape_teeth):360]) rotate([0,0,i]) rotate([90,0,0]) translate([0,0,tape_dia/2-.1]) {
						rotate([0,-5,0] ) scale([1,1.75,1]) {
							translate([0,0,1/2]) cylinder(r2=.9/2,r1=ratchet_tooth_h/2,h=1,$fn=6,center=true);
								translate([0,0,1+.5/2]) cylinder(r1=.9/2,r2=.3/2,h=.5,$fn=6,center=true);
						}
					}
				}
				translate([0,0,2.2+.85/2]) cylinder(r=tape_dia/2+4,h=.85,$fn=tape_teeth,center=true);
			
			}
		}
		// ratchet cutout
		translate([0,0,(ratchet_tooth_h/2)-extra]) pnp_ratchet_teeth(teeth=tape_teeth,r=tape_dia/2,tooth_clearance=0,count=tape_teeth,h=ratchet_tooth_h);
		// dado cutout
		translate([0,0,3.05-(3.05-ratchet_tooth_h)/2]) shaft_dado_coupler(r1=bearing_od/2+clearance,r2=bearing_od/2+clearance+nozzle_dia*10,h=3.05-ratchet_tooth_h,count=6);
		// bearing cutout
		translate([0,0,4/2]) cylinder(r=bearing_od/2+clearance,center=true,$fn=tape_teeth*2,h=4);
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
							translate([-cover_h_offset,cover_v_offset,0]) cylinder(r=cover_dia/2,h=base_thickness,center=true);
							translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
							for (i=[-55,55]) rotate([0,0,i]) translate([0,tape_dia/2+6.5+2/2,0]) cylinder(r=6.5/2,h=base_thickness,center=true);
							translate([-tape_edge_spacing,0,0]) cube([extra,tape_edge_spacing*2,base_thickness],center=true);
							translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
							translate([0,-tape_edge_spacing*2,0]) cube([tape_edge_spacing*4,wall_thickness,base_thickness],center=true);
							translate([-cover_h_offset-cover_dia/2-cover_spool_depth+6/2,cover_v_offset+cover_dia/2.5-7/2,0]) cube([7,8,base_thickness],center=true);
						}
						// servo mount
						translate([-cover_h_offset-cover_dia/2-cover_spool_depth-6/2,cover_v_offset+cover_dia/2.5-7/2,12/2-base_thickness/2]) cube([7,8,12],center=true);
						hull() {
							translate([-cover_h_offset-cover_dia/2-cover_spool_depth-6/2+6,cover_v_offset+cover_dia/2.35-ratchet_inset_h,0]) cube([7,wall_thickness,base_thickness],center=true);
							translate([-cover_h_offset-cover_dia/2-cover_spool_depth-6/2,cover_v_offset+cover_dia/2.35-ratchet_inset_h,10/2-base_thickness/2]) cube([7,wall_thickness,10],center=true);
						}
					}
					// cover slip posts
					for (i=[-55,55]) rotate([0,0,i]) translate([0,tape_dia/2+6.5+2/2,base_thickness+base_thickness/4-extra]) cylinder(r=6.5/2, r2=4.5/2,h=base_thickness/2,center=true);
					// cover tape sprocket raised lip
					translate([-cover_h_offset,cover_v_offset,(base_thickness*1.5+lever_arm_thickness/2-ratchet_inset_h+wall_thickness)/2-clearance*1.5]) cylinder(r=cover_dia/2+wall_thickness,h=base_thickness+lever_arm_thickness-ratchet_inset_h+wall_thickness,center=true);
					// mounting bracket
					translate([0,-tape_dia/1.75-base_thickness,12/2]) cube([tape_dia/1.75*2+base_thickness,base_thickness,12],center=true);
					translate([tape_edge_spacing*2-base_thickness/2,0,0]) hull() {
						translate([0,-tape_edge_spacing/2,base_thickness/2]) cube([base_thickness,base_thickness,base_thickness],center=true);
						translate([0,-tape_edge_spacing*2+12/2,12/2]) cube([base_thickness,12,12],center=true);
					}
					translate([0,0,base_thickness+wall_thickness/2]) intersection() {
						hull() {
							translate([0,0,0]) cylinder(r=tape_edge_spacing*2,h=base_thickness,center=true);
							for (i=[-55,55]) rotate([0,0,i]) translate([0,tape_dia/2+6.5+2/2,0]) cylinder(r=6.5/2,h=base_thickness,center=true);
						}
						hull() {
							translate([0,tape_drive_r,0]) scale([1.5,1,1]) cylinder(r=tape_dia/2/7,center=true,h=wall_thickness);
							translate([0,0,0]) cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8+tape_dia*2/9,center=true,h=wall_thickness);
						}
						translate([tape_dia/2/4.1,tape_drive_r-tape_dia/2/5.7,-wall_thickness*.75]) rotate([0,25,15]) cube([tape_dia/2/9,tape_dia/2/7,wall_thickness*1.5],center=true);
					}
				}
				// servo mount cutouts
				translate([-cover_h_offset-cover_dia/2-cover_spool_depth-6/2-1,cover_v_offset+cover_dia/2.5-7/2,12/2]) {
					cube([5+extra,2.9+clearance/2,12+extra],center=true);
					for(i=[0,4]) translate([0,0,i]) rotate([90,0,0]) cylinder(r=1.8/2,h=20,center=true);
				}
				// mounting bracket cutouts
				for(i=[tape_edge_spacing/2:tape_edge_spacing:tape_edge_spacing*4]) translate([-tape_edge_spacing*2+i,-tape_edge_spacing*2,6]) {
					rotate([90,0,0]) cylinder(r=4/2,h=base_thickness*2+extra,center=true);
				}
				translate([tape_edge_spacing*2-tape_edge_spacing/2,-tape_edge_spacing*2+6,6]) {
					rotate([0,0,90]) cylinder(r=4/2,h=tape_edge_spacing,center=true);
					rotate([0,90,0]) cylinder(r=4/2,h=tape_edge_spacing+extra,center=true);
				}
				// sprocket cutouts
				difference() {
					translate([0,0,base_thickness*1.5-ratchet_inset_h/2]) cylinder(r=tape_dia/2+1.5,h=base_thickness,center=true);
					for (i=[0:120:359]) rotate([0,0,i+40]) cube([nozzle_dia*4,tape_dia+3,base_thickness*4],center=true);
				}
				translate([0,0,base_thickness*1.5-ratchet_inset_h+clearance/2]) cylinder(r=tape_dia/2,h=base_thickness+clearance,center=true);
				difference() {
					translate([-cover_h_offset,cover_v_offset,base_thickness*1.5-ratchet_inset_h+wall_thickness*1.5-clearance*1.5]) cylinder(r=cover_dia/2+wall_thickness+extra,h=wall_thickness,center=true);
					translate([-cover_h_offset,cover_v_offset,base_thickness*1.5+wall_thickness/2+clearance]) for (i=[0:120:359]) rotate([0,0,i+55]) cube([nozzle_dia*8,tape_dia+3,base_thickness*4],center=true);
				}
				translate([-cover_h_offset,cover_v_offset,base_thickness*1.5-ratchet_inset_h+wall_thickness/2+clearance/2]) cylinder(r=cover_dia/2+wall_thickness-nozzle_dia*3,h=base_thickness+wall_thickness+clearance,center=true);
				// lever arm cutout
				translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h]) for ( i=[-1,lever_throw_angle+2]) rotate([0,0,i]) {
					tape_feeder_lever(cutout=1);
				}
				// tape drive cutout
				if (1) for(i=[0:(lever_throw_angle+2)/2:lever_throw_angle+2]) {
					translate([0,0,base_thickness-ratchet_inset_h]) rotate([0,0,-cover_angle-lever_throw_angle/4+i/drive_ratio-4.5]) tape_ratchet(cutout=1);
				}
			}
			// tape drive post
			translate([0,0,base_thickness-ratchet_inset_h]) {
				translate([0,0,bearing_h/2+base_thickness/2-clearance/2]) cylinder(r=bearing_id/2+clearance/6+extra,$fn=12,h=bearing_h+extra,center=true);
				translate([0,0,.5/2]) cylinder(r2=bearing_od/2-clearance*3,r1=bearing_od/2-clearance*3+.5,center=true,$fn=tape_teeth*2,h=.7+extra);
				translate([0,0,.5+.6/2]) cylinder(r2=14/2,r1=bearing_od/2-clearance*3,center=true,h=.6+extra);
			}
			// tape cover post
			translate([-cover_h_offset,cover_v_offset,base_thickness-ratchet_inset_h]) {
				translate([0,0,bearing_h/2+base_thickness/2-clearance/2]) cylinder(r=bearing_id/2+clearance/6+extra,$fn=12,h=bearing_h+extra,center=true);
				translate([0,0,.5/2]) cylinder(r2=bearing_od/2-clearance*3,r1=bearing_od/2-clearance*3+.5,center=true,$fn=tape_teeth*2,h=.5+extra);
				translate([0,0,.5+.6/2]) cylinder(r2=14/2,r1=bearing_od/2-clearance*3,center=true,h=.6+extra);
			}
			// spring post
			translate([0,0,5/2]) for(i=[0:(lever_throw_angle+2)/2:lever_throw_angle+2]) {
				rotate([0,0,-cover_angle+lever_throw_angle/6]) translate([0,tape_drive_r+.3,0]) rotate([0,90,cover_angle]) translate([0,0,-cover_h_offset/1.75]) {
					difference() {
						hull() {
							translate([0,0,-wall_thickness*3]) cylinder(r2=6.5/2,r1=4/2,h=wall_thickness*3,center=true);
							cylinder(r=6.5/2,h=wall_thickness*5,center=true);
							translate([6.5/2-base_thickness/2,-wall_thickness*2,-wall_thickness]) cube([base_thickness,wall_thickness*7,wall_thickness*7],center=true);
						}
						hull() {
							cylinder(r=2/2+clearance,h=wall_thickness*10,center=true);
							translate([base_thickness*1.5,,0]) cylinder(r=1/2+clearance,h=wall_thickness*10,center=true);
						}
						translate([0,0,wall_thickness*2.25]) cylinder(r2=5.5/2,r1=5/2,h=wall_thickness/2+extra,center=true);
						translate([base_thickness/2+5/2,0,0]) cube([base_thickness,20,20],center=true);
					}
				}
			}
		}
		// connecting rod slot and tape drive cutout
		h=wall_thickness+ratchet_tooth_h;
		// tape drive post cutouts
		translate([0,0,0]) {
			translate([0,0,10/2+base_thickness]) cylinder(r=3/2+clearance,h=10+extra*2,center=true);
			translate([0,0,1.75/2]) cylinder(r1=4,r2=2.8,h=1.75+extra,center=true);
		}
		// tape cover post cutouts
		translate([-cover_h_offset,cover_v_offset,0]) {
			translate([0,0,10/2+base_thickness]) cylinder(r=3/2+clearance,h=10+extra*2,center=true);
			translate([0,0,1.75/2]) cylinder(r1=4,r2=2.8,h=1.75+extra,center=true);
		}
		// ratchet pin cutouts
		translate([0,0,nozzle_dia]) rotate([0,0,180-(360/tape_teeth/1.95)-cover_angle-lever_throw_angle/2]) tape_ratchet(h=base_thickness,pin_socket=1);
		for (i=[0,1]) translate([-cover_h_offset,cover_v_offset,nozzle_dia]) rotate([0,0,-lever_throw_angle-cover_angle+(360/cover_teeth*-4.25)-i*(270-lever_throw_angle-cover_angle-(360/cover_teeth*2))]) mirror([i,0,0]) tape_ratchet(h=base_thickness,pin_socket=1,r=cover_dia/2-nozzle_dia*4.7-clearance*3);
		// cover slip post cutouts	translate([0,slot_cover_length/2,extra]) cube([8.1,slot_cover_length/16,extra/2],center=true);

		for (i=[-55,55]) rotate([0,0,i]) translate([0,tape_dia/2+6.5+2/2,base_thickness+nozzle_dia]) cylinder(r=2/2,h=base_thickness*2,center=true);
		translate([-cover_h_offset/1.75,-tape_dia/2.15,base_thickness-.3]) scale([.25,.25,1]) emboss_logo();
		
	}
}

// Generate the ratchet teeth
module pnp_ratchet_teeth(h=ratchet_tooth_h,r=tape_dia/2,teeth=tape_teeth,count=tape_teeth,tooth_clearance=0,solid=1) {
	inset=r/teeth+nozzle_dia*7+clearance;
	union() {
		for (i=[0:(360/teeth):(360/teeth*count)-1]) rotate([0,0,i+30]) translate([r-r/5-nozzle_dia*2.5,0]) rotate([0,0,-40]) scale([1.3,1,1]) cylinder(r=r/5-tooth_clearance/2,$fn=3,h=h,center=true);
		if (solid) cylinder(r=r-inset,h=h,center=true);
	}
}


// This is the shape for all the ratchety things 
module tape_ratchet(h=wall_thickness+ratchet_tooth_h-clearance,teeth=tape_teeth,r=tape_dia/2,tooth_clearance=0,pivot=0,pin=0,ratchet=0,drive_r=tape_drive_r,pin_socket=0,pivot_hole=0,spring=0,cutout=0) {
	tooth_angle=360/teeth;
	inset=r/teeth+nozzle_dia*7+clearance;
	translate([0,0,h/2]) {
		difference() {
			union() {
				if (ratchet) {
					difference() {
						union() {
							intersection() {
								cylinder(r=r-inset,h=h,center=true);
								hull() {
									rotate([0,0,0]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
									rotate([0,0,-tooth_angle*8]) translate([0,r*2,0]) cube([extra,r*4,h],center=true);
								}
							}
							rotate([0,0,-tooth_angle*2]) pnp_ratchet_teeth(r=r,teeth=teeth,h=h,count=2,tooth_clearance=tooth_clearance,solid=0);
						}
						cylinder(r=r-inset-nozzle_dia*3,h=h+extra*2,center=true);
					}
					hull() {
						rotate([0,0,-18]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16,center=true,h=h);
					}
				}
				if (pivot) {
					hull() {
						cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8,center=true,h=h);
						translate([0,r-inset-r/10,0]) scale([1.5,1,1]) cylinder(r=r/10,center=true,h=h);
					}
				}
				if (pin_socket) {
					hull() {
						rotate([0,0,-18]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5+clearance/2,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16+clearance/2,center=true,h=h);
					}
				}
				if (pin) {
					hull() {
						rotate([0,0,-18]) translate([0,r-inset-nozzle_dia*1.5,0]) cylinder(r=nozzle_dia*1.5,center=true,h=h);
						translate([0,r-inset-r/16,0]) scale([1.5,1,1]) cylinder(r=r/16,center=true,h=h);
					}
				}
				if (spring) {
					rotate([0,0,14]) translate([0,0,-h/2]) {
						hull() {
							translate([0,drive_r,ratchet_inset_h/2]) scale([1.5,1,1]) cylinder(r=r/9,center=true,h=ratchet_inset_h);
							translate([0,0,ratchet_inset_h/2]) cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8,center=true,h=ratchet_inset_h);
						}
						translate([0,0,h*.75/2]) intersection() {
							hull() {
								translate([0,drive_r,0]) scale([1.5,1,1]) cylinder(r=r/9,center=true,h=h*.75);
								translate([0,0,0]) cylinder(r=bearing_od/2+clearance*2+nozzle_dia*8,center=true,h=h*.75);
							}
							translate([r/5,drive_r-r/5,0]) rotate([0,45,15]) cube([r/9,r/7,h+extra],center=true);
						}
					}
							
				}
				if (cutout) {
					rotate([0,0,14]) hull() {
						translate([0,drive_r,0]) scale([1.5,1,1]) cylinder(r=r/9,center=true,h=h);
						translate([0,0,0]) cylinder(r=bearing_od/2+clearance*4+nozzle_dia*8,center=true,h=h);
					}
				}

			}
			if (pivot_hole) {
				rotate([0,0,14]) translate([0,drive_r,0]) {
					cylinder(r=1/2+clearance/2,h=h*2+extra,center=true);
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

