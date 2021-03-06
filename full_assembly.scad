$do_prerender=true;

include <config.scad>
include <GDMUtils.scad>
use <NEMA.scad>
use <acme_screw.scad>
use <vitamins.scad>

use <cable_chain_link_parts.scad>
use <cable_chain_mount_parts.scad>
use <cooling_fan_shroud_parts.scad>
use <drive_gear_parts.scad>
use <extruder_fan_clip_parts.scad>
use <extruder_fan_shroud_parts.scad>
use <extruder_idler_parts.scad>
use <extruder_motor_clip_parts.scad>
use <jhead_platform_parts.scad>
use <lifter_lock_nut_parts.scad>
use <lifter_rod_coupler_parts.scad>
use <motor_mount_plate_parts.scad>
use <platform_support_parts.scad>
use <rail_segment_parts.scad>
use <rail_xy_motor_segment_parts.scad>
use <rail_y_endcap_parts.scad>
use <rail_z_endcap_parts.scad>
use <rail_z_motor_segment_parts.scad>
use <ramps_mount_parts.scad>
use <sled_endcap_parts.scad>
use <spool_holder_parts.scad>
use <support_leg_parts.scad>
use <xy_joiner_parts.scad>
use <xy_sled_parts.scad>
use <yz_joiner_parts.scad>
use <z_sled_parts.scad>


hide_endcaps = false;


module xy_motor_assembly(explode=0, arrows=false)
{
	// view: [30, 25, 30] [55, 0, 25] 475
	// desc: Press-fit a drive gear onto the shaft of a stepper motor, making sure to align the flat of the shaft with the flat of the shaft hole. Repeat this with the other drive gear and another stepper.
	nema17_stepper(h=motor_length, shaft_len=motor_shaft_length, $fa=1, $fs=0.5);
	up(gear_base+rack_height/2+2.1+explode) {
		drive_gear();
	}

	// Construction arrow.
	if(arrows && explode>10) {
		up(explode*0.6) {
			yrot(-90) arrow(size=explode/3);
		}
	}
}
//!xy_motor_assembly(explode=100, arrows=true);


module motor_mount_assembly(explode=0, arrows=false)
{
	// view: [50, 50, 50] [55, 0, 25] 675
	// desc: Attach a limit micro-switch (with wiring) to one of the side clips, with the lever end towards the center. Do this again for a second switch and mount plate.
	motor_mount_plate();
	up(motor_length/2+2-endstop_depth/2) {
		fwd(endstop_hole_hoff) {
			right((motor_mount_spacing+joiner_width)/2+endstop_standoff+endstop_thick/2+explode) {
				microswitch();
			}
		}
	}

	// Construction arrow.
	if(arrows && explode>10) {
		up(motor_length/2+2-endstop_depth/2) {
			fwd(endstop_hole_hoff) {
				right((motor_mount_spacing+joiner_width)/2+endstop_standoff+endstop_thick/2+explode/2) {
					xrot(-90) arrow(size=0.75*explode/3);
				}
			}
		}
	}
}
//!motor_mount_assembly(explode=100, arrows=true);


module xy_motor_segment_assembly(explode=0, arrows=false)
{
	// view: [0, 0, 135] [72, 0, 23] 900
	// desc: Seat the stepper motor with drive gear in the X/Y motor rail segment. Clamp it into place with a motor mount plate with micro-switch. Repeat this to make a second XY motor segment assembly. On one, route the wiring out a side wiring access hole opposite the limit switch, and on the other, route it out one end.
	motor_width = nema_motor_width(17)+printer_slop*2;

	rail_xy_motor_segment();

	// Stepper Motor
	up(motor_top_z) {
		up(explode*2.2-motor_length/2) {
			motor_mount_assembly();
		}
		up(explode*1.1) {
			xy_motor_assembly();
		}
	}

	// Construction arrows.
	if(arrows && explode>10) {
		up(rail_height+groove_height+explode/8) {
			yrot(-90) arrow(size=explode/3);
			up(motor_length+explode) {
				yrot(-90) arrow(size=explode/3);
			}
		}
	}
}
//!xy_motor_segment_assembly(explode=100, arrows=true);
//!xy_motor_segment_assembly();


module y_axis_assembly_1(slidepos=0, explode=0, arrows=false)
{
	// view: [0, 0, 0] [45, 0, 240] 1800
	// desc: Join a rail segment to each end of another motor rail assembly.
	platform_vert_off = rail_height+groove_height/2;

	xy_motor_segment_assembly();
	zrot(90) {
		zring(r=(motor_rail_length+rail_length+2*explode)/2, n=2) {
			zrot(90) rail_segment();
		}
	}

	// Construction arrows.
	if(arrows && explode>10) {
		up(rail_height/2+groove_height/2) {
			zrot(90) zring(r=(motor_rail_length+explode)/2) {
				arrow(size=explode/3);
			}
		}
	}

	// Sled
	up(platform_vert_off) {
		fwd(slidepos) {
			children();
		}
	}
}
//!y_axis_assembly_1(explode=100, arrows=true);
//!y_axis_assembly_1(slidepos=90) y_sled_assembly();


module y_axis_assembly_2(explode=0, arrows=false)
{
	// view: [0, 75, 25] [55, 0, 140] 1800
	// desc: Join opposing platform supports to either side of the sled endcap. Point the tabs toward the side with the joiners.
	sled_endcap();
	fwd(20-joiner_width/2) {
		right(platform_width/2+explode*1.5) {
			zrot(90) platform_support2();
		}
		left(platform_width/2+explode*1.5) {
			zrot(-90) platform_support1();
		}
	}

	// Construction arrows.
	if(arrows && explode>20) {
		fwd(20-joiner_width/2) {
			zring(r=(platform_width+explode*1.5)/2) {
				arrow(size=explode/3);
			}
		}
	}
}
//!y_axis_assembly_2(explode=100, arrows=true);


module y_axis_assembly_3(explode=0, arrows=false)
{
	// view: [-40, 10, 40] [55, 0, 55] 1400
	// desc: Join two XY sled parts together. Make sure the bottom racks line up.
	up(groove_height/2+rail_offset) {
		yspread(platform_length+0.5+explode) {
			yrot(180) xy_sled();
		}
		children();
	}

	// Construction arrows.
	if(arrows && explode>20) {
		zrot(-90) arrow(size=explode/3);
	}
}
//!y_axis_assembly_3(explode=100, arrows=true);


module y_axis_assembly_4(explode=0, arrows=false)
{
	// view: [0, -60, 0] [40, 0, 25] 1500
	// desc: Join a Y sled endcap assembly to one end of the Y sled central assembly.
	up(groove_height/2+rail_offset) {
		fwd(platform_length+0.5+explode) {
			y_axis_assembly_2();
		}
	}
	y_axis_assembly_3() children();

	// Construction arrows.
	if(arrows && explode>20) {
		fwd(platform_length+explode*0.5) {
			zrot(-90) arrow(size=explode/3);
		}
	}
}
//!y_axis_assembly_4(explode=100, arrows=true);


module y_axis_assembly_5(slidepos=0, explode=0, arrows=false)
{
	// view: [-70, -70, -50] [55, 0, 55] 1800
	// desc: Slide the Y sled partial assembly onto the Y axis rails assembly, so that it is centered.
	y_axis_assembly_1(slidepos=slidepos) {
		fwd(explode*5) {
			if ($children>1) children(0);
			y_axis_assembly_4() {
				if ($children>1) children(1);
			}

			// Construction arrows.
			if(arrows && explode>75) {
				back(platform_width+explode*0.25) {
					zrot(-90) arrow(size=explode/3);
				}
			}
		}
	}
}
//!y_axis_assembly_5(slidepos=0, explode=100, arrows=true);


module y_axis_assembly_6(slidepos=0, explode=0, arrows=false)
{
	// view: [-15, 75, 75] [55, 0, 55] 1800
	// desc: Join the other Y sled endcap assembly to the end of the Y sled partial assembly.
	y_axis_assembly_5(slidepos=slidepos) {
		back(platform_length+0.5+explode*2) {
			up(groove_height/2+rail_offset) {
				zrot(180) y_axis_assembly_2();
			}

			// Construction arrows.
			if(arrows && explode>75) {
				fwd(explode*0.5) {
					zrot(90) arrow(size=explode/3);
				}
			}
		}
		up(0) children();
	}
}
//!y_axis_assembly_6(slidepos=0, explode=0, arrows=true);


module y_axis_assembly_7(slidepos=0, explode=0, arrows=false)
{
	// view: [0, 0, 0] [45, 0, 50] 2200
	// desc: Join a rail endcap to each end of the Y axis with completed sled assembly.
	platform_vert_off = rail_height+groove_height/2;

	zrot(90) zring(r=(motor_rail_length+2*rail_length+3*explode)/2) {
		if (hide_endcaps == false) {
			zrot(90) rail_y_endcap();
		}
	}
	y_axis_assembly_6(slidepos=slidepos) {
		children();
	}

	// Construction arrows.
	if(arrows && explode>10) {
		up(rail_height/2+groove_height/2) {
			zrot(90) zring(r=(motor_rail_length+2*rail_length+1.5*explode)/2) {
				arrow(size=explode/3);
			}
		}
	}
}
//!y_axis_assembly_7(explode=100, arrows=true);
//!y_axis_assembly_7(slidepos=90) y_sled_assembly();


module x_axis_assembly_1(slidepos=0, explode=0, arrows=false)
{
	// view: [-5, 65, 85] [55, 0,  25] 1750
	// desc: Join a rail segment to each end of a motor rail assembly, to make the X axis slider. Route the wiring to one end of the slider assembly.
	platform_vert_off = rail_height+groove_height/2;

	zrot(90) xy_motor_segment_assembly();
	zring(r=(motor_rail_length+rail_length+2*explode)/2, n=2) {
		zrot(90) rail_segment();
	}

	// Construction arrows.
	if(arrows && explode>10) {
		up(rail_height/2+groove_height/2) {
			zring(r=(motor_rail_length+explode)/2) {
				arrow(size=explode/3);
			}
		}
	}

	// Left Z Tower
	left(motor_rail_length/2+rail_length+2*explode) {
		if ($children > 0) children(0);
	}

	// Right Z Tower
	right(motor_rail_length/2+rail_length+2*explode) {
		if ($children > 1) children(1);
	}

	// Sled
	up(platform_vert_off) {
		left(slidepos) {
			if ($children > 2) children(2);
		}
	}
}
//!x_axis_assembly_1(slidepos=100, explode=100, arrows=true);
//!x_axis_assembly_1(slidepos=0) {sphere(1); sphere(1); x_sled_assembly();}


module x_axis_assembly_2(explode=0, arrows=false)
{
	// view: [0, 0, 0] [55, 0, 25] 1000
	// desc: Join two XY sled parts together. Make sure the bottom racks line up.
	up(groove_height/2+rail_offset) {
		xspread(platform_length+explode) {
			zrot(90) yrot(180) xy_sled();
		}
	}

	// Construction arrows.
	if(arrows && explode>20) {
		arrow(size=explode/3);
	}
}
//!x_axis_assembly_2(explode=100, arrows=true);


module x_axis_assembly_3(explode=0, arrows=false)
{
	// view: [-55, 60, 65] [55, 0, 55] 1500
	// desc: Join an X sled endcap assembly to one end of the X sled central assembly.
	x_axis_assembly_2();
	up(groove_height/2+rail_offset) {
		left(platform_length+0.5+explode) {
			zrot(-90) xy_joiner();
		}
	}

	// Construction arrows.
	if(arrows && explode>20) {
		left(platform_length+explode*0.5) {
			zrot(180) arrow(size=explode/3);
		}
	}
}
//!x_axis_assembly_3(explode=0, arrows=true);


module x_axis_assembly_4(slidepos=0, explode=0, arrows=false)
{
	// view: [-155, -50, 25] [55, 0, 55] 2500
	// desc: Slide the X sled partial assembly onto the X axis rails assembly, so that it is centered.
	x_axis_assembly_1(slidepos=slidepos) {
		if ($children>0) children(0); else nil();
		if ($children>1) children(1); else nil();
		left(explode*4) {
			x_axis_assembly_3();
			if ($children>2) children(2); else nil();

			// Construction arrows.
			if(arrows && explode>75) {
				right(platform_width+explode*0.1) {
					zrot(180) arrow(size=explode/3);
				}
			}
		}
	}
}
//!x_axis_assembly_4(slidepos=0, explode=100, arrows=true);


module x_axis_assembly_5(xslidepos=0, yslidepos=0, explode=0, arrows=false)
{
	// view: [150, 0, 110] [50, 0, 330] 2500
	// desc: Connect the Y axis assembly to the XY joiner on the X axis partial assembly. Route the Y axis wiring through the front hole in the XY joiner.
	x_axis_assembly_4(slidepos=xslidepos) {
		if ($children>0) children(0); else nil();
		if ($children>1) children(1); else nil();
		right(explode*4) {
			if ($children>2) children(2); else nil();
			up(groove_height/2+rail_offset) {
				y_axis_assembly_7(slidepos=yslidepos) {
					if ($children>3) children(3);
				}
			}

			// Construction arrows.
			if(arrows && explode>75) {
				left(explode*1.25) {
					arrow(size=2*explode/3);
				}
			}
		}
	}
}
//!x_axis_assembly_5(explode=100, arrows=true);


module x_axis_assembly_6(xslidepos=0, yslidepos=0, explode=0, arrows=false)
{
	// view: [85, 70, 40] [55, 0, 25] 2500
	// desc: Join the other X sled endcap assembly to the end of the X sled assembly, fixing the Y sled assembly in place.
	x_axis_assembly_5(xslidepos=xslidepos, yslidepos=yslidepos) {
		if ($children>0) children(0); else nil();
		if ($children>1) children(1); else nil();
		right(platform_length+0.5+explode*3) {
			up(groove_height/2+rail_offset) {
				zrot(90) xy_joiner();
			}

			// Construction arrows.
			if(arrows && explode>75) {
				left(explode*1.25) {
					arrow(size=explode/3);
				}
			}
		}
		if ($children>2) children(2);
	}
}
//!x_axis_assembly_6(xslidepos=0, yslidepos=0, explode=100, arrows=true);


module z_tower_assembly_1(slidepos=0, explode=0, arrows=false)
{
	// view: [72, 125, -25] [345, 20, 0] 1200
	// desc: Seat the stepper motor in the Z motor rail segment. Clamp it into place with a motor mount plate without micro-switch.
	motor_width = nema_motor_width(17)+printer_slop*2;

	rail_z_motor_segment();

	// Stepper Motor
	up(rail_height+groove_height/2) {
		xrot(-90) {
			up(explode*3) {
				motor_mount_plate();
			}
			up(motor_length/2+explode*1.8) {
				nema17_stepper(h=motor_length, shaft_len=motor_shaft_length);
				up(motor_shaft_length-2+2.1+explode) {
					zrot(180+slidepos*360/lifter_rod_pitch) {
						if ($children > 0) children(0);
					}
					up(lifter_rod_length/2+slidepos) {
						if ($children > 1) children(1);
					}
				}
			}
		}
	}

	// Construction arrows.
	if(arrows && explode>=50) {
		up(rail_height+groove_height/2) {
			xrot(-90) {
				up(explode*1.2) {
					yrot(-90) arrow(size=explode/3);
				}
				up(explode*2.6) {
					yrot(-90) arrow(size=explode/3);
				}
			}
		}
	}
}
//!z_tower_assembly_1(explode=100, arrows=true);
//!z_tower_assembly_1();


module z_tower_assembly_2(explode=0, arrows=false)
{
	// view: [50, 50, 155] [55, 0, 25] 1500
	// desc: Screw the lock nut onto the threaded rod.
	color("Silver") {
		acme_threaded_rod(
			d=lifter_rod_diam,
			l=lifter_rod_length,
			pitch=lifter_rod_pitch,
			thread_depth=lifter_rod_pitch/2,
			$fn=32
		);
	}
	down(lifter_rod_length/2) {
		up(30/2+10/2-explode) {
			zrot(180) lifter_lock_nut();
		}
	}

	// Construction arrow.
	if(arrows && explode>=50) {
		down(lifter_rod_length/2) {
			up(30/2+10/2-explode*0.6) {
				yrot(90) arrow(size=explode/3);
			}
		}
	}
}
//!z_tower_assembly_2(explode=100, arrows=true);


module z_tower_assembly_3(explode=0, arrows=false)
{
	// view: [50, 50, 155] [55, 0, 25] 1500
	// desc: Screw the rod into the coupler fully, then tighten the lock nut up against the coupler.
	lifter_rod_coupler();
	up(lifter_rod_length/2+explode) {
		z_tower_assembly_2();
	}

	// Construction arrow.
	if(arrows && explode>=50) {
		up(30/2+explode*0.4) {
			yrot(-90) arrow(size=explode/3);
		}
	}
}
//!z_tower_assembly_3(explode=100, arrows=true);


module z_tower_assembly_4(slidepos=0, explode=0, arrows=false)
{
	// view: [80, 195, 40] [0, 0, 0] 1500
	// desc: Press-fit the lifter rod assembly to the mounted motor shaft. Make sure the flatted side of the shaft is aligned with the flat of the shaft hole.
	z_tower_assembly_1(slidepos=slidepos) {
		up(explode*1.2) {
			z_tower_assembly_3();
		}
		if ($children > 0) children(0);

		// Construction arrows.
		if(arrows && explode>=50) {
			up(explode*0.7) {
				yrot(-90) arrow(size=explode/3);
			}
		}
	}
}
//!z_tower_assembly_4(explode=100, arrows=true);


module z_tower_assembly_5(slidepos=0, explode=0, arrows=false)
{
	// view: [15, 80, 300] [60, 0, 60] 1900
	// desc: Attach two rail segments to the top of the motor Z lifter assembly.
	up(motor_rail_length/2) {
		yrot(90) zrot(90) z_tower_assembly_4(slidepos=slidepos) {
			if ($children > 0) zrot(-90) children(0);
		}
		up(motor_rail_length/2+rail_length/2+explode) {
			yrot(90) zrot(90) rail_segment();
			up(rail_length+0.5+explode*1) {
				yrot(90) zrot(-90) rail_segment();
				up(rail_length/2+explode*1.5) {
					if (hide_endcaps == false) {
						if ($children > 1) children(1);
					}
				}
			}
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		right(rail_height/2+groove_height/2) {
			up(motor_rail_length+explode*0.5) {
				yrot(-90) arrow(size=explode/3);
				up(rail_length+explode*1.0) {
					yrot(-90) arrow(size=explode/3);
				}
			}
		}
	}
}
//!z_tower_assembly_5(slidepos=0, explode=0, arrows=true) z_sled();
//!z_tower_assembly_5(explode=100, arrows=true);


module z_tower_assembly_6(explode=0, arrows=false)
{
	// view: [-110, 20, 80] [55, 0, 60] 1400
	// desc: Attach support legs to each side of the yz_joiner part.
	zrot(-90) yz_joiner();
	left(6+explode) {
		if ($children > 0) zrot(-90) children(0);
	}
	right(platform_length/3) {
		zrot_copies([0,180]) {
			back(rail_width/2+14+explode) {
				zrot(0) support_leg();
			}
		}
	}

	// Construction arrows.
	if (arrows && explode>10) {
		right(10+platform_length/2/2) {
			up(rail_height/2+groove_height/2) {
				zrot(90) zring(r=rail_width/2+explode*0.55) {
					zrot(0) arrow(size=explode/3);
				}
			}
		}
	}
}
//!z_tower_assembly_6(slidepos=0, explode=0, arrows=true) z_sled();
//!z_tower_assembly_6(explode=100, arrows=true);


module z_tower_assembly_7(slidepos=0, explode=0, arrows=false)
{
	// view: [20, 50, 270] [70, 0, 30] 1700
	// desc: Attach the Z rail assembly to the top of the YZ joiner assembly. Repeat steps 1 through 7 to make a second Z tower.
	left(platform_length) {
		z_tower_assembly_6() {
			if ($children > 2) children(2);
		}
		up(rail_height+groove_height+explode) {
			z_tower_assembly_5(slidepos=slidepos) {
				if ($children > 0) children(0);
				if ($children > 1) children(1);
			}
		}

		// Construction arrows.
		if (arrows && explode>10) {
			right(rail_height/2+groove_height/2) {
				up(rail_height+groove_height+explode*0.5) {
					yrot(-90) arrow(size=explode/3);
				}
			}
		}
	}
}
//!z_tower_assembly_7(slidepos=0, explode=0, arrows=true) z_sled();
//!z_tower_assembly_7(explode=100, arrows=true);


module extruder_bridge_assembly_1(explode=0, arrows=false)
{
	// view: [0, -40, 0] [75, 0, 45] 1000
	// desc: Insert the 686 bearing into the extruder idler arm.
	extruder_idler();
	back(extruder_idler_diam/2-explode) {
		idler_bearing();
	}

	// Construction arrows.
	if (arrows && explode>50) {
		fwd(explode*0.5) {
			zrot(-90) arrow(size=0.5*explode/3);
		}
	}
}
//!extruder_bridge_assembly_1(explode=100, arrows=true);


module extruder_bridge_assembly_2(explode=0, arrows=false)
{
	// view: [0, 15, 15] [75, 0, 20] 1000
	// desc: Insert the idler axle through the 686 bearing, and lock it into the extruder idler arm with the axle cap.
	extruder_bridge_assembly_1();
	back(extruder_idler_diam/2) {
		left(extruder_shaft_len/2/2+1+explode*0.75) {
			yrot(90) extruder_idler_axle();
		}
		right(extruder_shaft_len/2/2+1+explode*0.75) {
			yrot(-90) extruder_idler_axle_cap();
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		back(extruder_idler_diam/2) {
			right(explode*0.4) {
				arrow(size=0.5*explode/3);
			}
			left(explode*0.4) {
				zrot(180) arrow(size=0.5*explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_2(explode=100, arrows=true);


module extruder_bridge_assembly_3(explode=0, arrows=false)
{
	// view: [40, 20, 10] [55, 0, 25] 700
	// desc: Attach the extruder drive gear onto the stepper motor shaft.
	yrot(90) zrot(-90) {
		nema17_stepper(h=motor_length, shaft_len=motor_shaft_length);
		up(4+explode) extruder_drive_gear();
	}

	// Construction arrows.
	if (arrows && explode>50) {
		right(explode*0.6) {
			arrow(size=0.5*explode/3);
		}
	}
}
//!extruder_bridge_assembly_3(explode=100, arrows=true);


module extruder_bridge_assembly_4(explode=0, arrows=false)
{
	// view: [0, 0, 0] [80, 0, 70] 900
	// desc: Slide the JHead extruder hot end into the slot in the bottom of the JHead platform.
	jhead_platform();
	down(explode) jhead_hotend();

	// Construction arrows.
	if (arrows && explode>50) {
		down(explode*0.5) {
			yrot(90)arrow(size=0.5*explode/3);
		}
	}
}
//!extruder_bridge_assembly_4(explode=100, arrows=true);


module extruder_bridge_assembly_5(explode=0, arrows=false)
{
	// view: [10, 85, 230] [55, 0, 55] 1600
	// desc: Clip the extruder motor with drive gear to the jhead platform using the extruder motor clip.
	motor_width = nema_motor_width(17);

	extruder_bridge_assembly_4();
	up(jhead_groove_thick+jhead_shelf_thick+motor_width/2+explode*2) {
		fwd(extruder_drive_diam/2-0.5) {
			left(extruder_shaft_len/2-0.05) {
				extruder_bridge_assembly_3();
				left(motor_length/2) {
					up(explode*2) {
						zrot(-90) extruder_motor_clip();
					}
				}
			}
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		up(jhead_groove_thick+jhead_shelf_thick+motor_width/2+explode) {
			fwd(extruder_drive_diam/2-0.5) {
				left(extruder_shaft_len/2-0.05+motor_length/2) {
					yrot(-90) arrow(size=explode/3);
					up(explode*2) {
						yrot(-90) arrow(size=explode/3);
					}
				}
			}
		}
	}
}
//!extruder_bridge_assembly_5(explode=100, arrows=true);


module extruder_bridge_assembly_6(explode=0, arrows=false)
{
	// view: [70, 0, 60] [55, 0, 55] 1000
	// desc: Insert the idler arm into the idler hinge hole on the JHead platform.
	motor_width = nema_motor_width(17);

	extruder_bridge_assembly_5();
	up(jhead_groove_thick+jhead_shelf_thick+motor_width/2) {
		right(explode*2) {
			extruder_bridge_assembly_2();
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		right(explode*1.25) {
			back(motor_width/2) {
				up(10) arrow(size=explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_6(explode=100, arrows=true);


module extruder_bridge_assembly_7(explode=0, arrows=false)
{
	// view: [70, 0, 60] [55, 0, 55] 1000
	// desc: Insert the idler latch arm into the latch hinge hole on the JHead platform.
	motor_width = nema_motor_width(17);
	extruder_bridge_assembly_6();
	up(jhead_groove_thick+jhead_shelf_thick+motor_width/2) {
		right(explode*2) {
			extruder_latch();
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		right(explode*1.25) {
			fwd(motor_width/2) {
				up(10) arrow(size=explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_7(explode=100, arrows=true);


module extruder_bridge_assembly_8(explode=0, arrows=false)
{
	// view: [90, 70, 95] [55, 0, 25] 1200
	// desc: Insert the extruder fan shroud into the JHead platform, latching the JHead hot end, and idler and latch arms into place.
	extruder_bridge_assembly_7();
	right(extruder_length/4) {
		up(jhead_groove_thick+0.05+explode*2) {
			extruder_fan_shroud() children();
		}
	}

	// Construction arrows.
	if (arrows && explode>50) {
		up(explode*1.25) {
			right(extruder_length/4) {
				yrot(-90) arrow(size=explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_8(explode=100, arrows=true);


module extruder_bridge_assembly_9(explode=0, arrows=false)
{
	// view: [0, 0, 110] [55, 0, 0] 1200
	// desc: Clip a cooling fan to the top of the extruder fan shroud using the extruder fan clip part.
	extruder_bridge_assembly_8() {
		children();
	}
	right(extruder_length/4) {
		up(jhead_groove_thick+jhead_shelf_thick+0.05) {
			up(explode) {
				up(explode/2) {
					cooling_fan();
					up(12-extruder_fan_thick+2+0.05+explode/2) {
						up(explode/2) {
							zrot(90) extruder_fan_clip();
						}

						// Construction arrows.
						if (arrows && explode>50) {
							yrot(-90) arrow(size=0.75*explode/3);
						}
					}
				}

				// Construction arrows.
				if (arrows && explode>50) {
					yrot(-90) arrow(size=0.75*explode/3);
				}
			}
		}
	}
}
//!extruder_bridge_assembly_9(explode=100, arrows=true);


module extruder_bridge_assembly_10(explode=0, arrows=false)
{
	// view: [90, 70, 95] [55, 0, 25] 1200
	// desc: Attach a cooling fan to the cooling fan shroud.
	cooling_fan_shroud() {
		up(explode) cooling_fan();

		// Construction arrows.
		if (arrows && explode>50) {
			up(explode/2) yrot(-90) arrow(size=0.75*explode/3);
		}
	}
}
//!extruder_bridge_assembly_10(explode=100, arrows=true);


module extruder_bridge_assembly_11(explode=0, arrows=false)
{
	// view: [32, -6, -50] [100, 0, 10] 1000
	// desc: Attach the cooling fan shroud assembly to the bottom of the extruder fan shroud.
	extruder_bridge_assembly_9() {
		down(explode) extruder_bridge_assembly_10();

		// Construction arrows.
		if (arrows && explode>50) {
			down(explode/2) {
				yrot(90) arrow(size=0.75*explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_11(explode=100, arrows=true);


module extruder_bridge_assembly_12(explode=0, arrows=false)
{
	// view: [0, 70, 55] [55, 0, 25] 1850
	// desc: Attach rail segments to either end of the extruder platform assembly.
	extruder_bridge_assembly_11();
	xspread(extruder_length+rail_length+2*explode) {
		zrot(90) rail_segment();
	}

	// Construction arrows.
	if(arrows && explode>10) {
		up(rail_height/2+groove_height/2) {
			zring(r=(extruder_length+explode)/2, n=2) {
				arrow(size=explode/3);
			}
		}
	}
}
//!extruder_bridge_assembly_12(explode=100, arrows=true);
//!extruder_bridge_assembly_12();


module extruder_bridge_assembly_13(explode=0, arrows=false)
{
	// view: [0, 0, 18] [55, 0, 25] 2100
	// desc: Attach rail segments to either end of the extruder platform assembly.
	down(platform_length/2) {
		right((extruder_length+rail_length*2+cantilever_length*2)/2) {
			extruder_bridge_assembly_12();
			zring(r=(extruder_length+2*rail_length+2*cantilever_length+3*explode)/2, n=2) {
				zrot(180) z_sled();
			}

			// Construction arrows.
			if(arrows && explode>50) {
				up(rail_height/2+groove_height/2) {
					zring(r=(extruder_length+2*rail_length+2*cantilever_length+0.75*explode)/2, n=2) {
						arrow(size=explode/3);
					}
				}
			}
		}
	}
}
//!extruder_bridge_assembly_13(explode=100, arrows=true);
//!extruder_bridge_assembly_13();


// Borosilicate Glass.  Render last to allow transparency to work.
module build_platform() {
	up(3+glass_thick/2) {
		color([0.75, 1.0, 1.0, 0.5]) {
			cube(size=[glass_length, glass_width, glass_thick], center=true);
		}
	}
}


module final_assembly_1(xslidepos=0, yslidepos=0, zslidepos=0, explode=0, arrows=false)
{
	// view: [0, 0, 240] [70, 0, 30] 2800
	// desc: Attach the two Z tower assemblies to either end of the XY axes assembly.
	x_axis_assembly_6(xslidepos=xslidepos, yslidepos=yslidepos) {
		left(explode*2) {
			z_tower_assembly_7(slidepos=zslidepos) {
				if ($children > 0) children(0);
				if ($children > 1) children(1);
				if ($children > 2) children(2);
			}

			// Construction arrows.
			if (arrows && explode>50) {
				up((rail_height+groove_height)/2) {
					right(explode*1.0) zrot(180) arrow(size=2*explode/3);
				}
			}
		}
		right(explode*2) {
			zrot(180) z_tower_assembly_7(slidepos=zslidepos) {
				nil();
				if ($children > 3) children(3);
				if ($children > 4) children(4);
			}

			// Construction arrows.
			if (arrows && explode>50) {
				up((rail_height+groove_height)/2) {
					left(explode*1.0) arrow(size=2*explode/3);
				}
			}
		}
		if ($children > 5) children(5);
	}
}
//!final_assembly_1(xslidepos=0, yslidepos=0, zslidepos=0, explode=0, arrows=true) z_sled();
//!final_assembly_1(explode=0, arrows=true);


module final_assembly_2(explode=0, arrows=false)
{
	// view: [0, 0, 240] [55, 0, 25] 3000
	// desc: Lower the extruder bridge down into the Z tower grooves, screwing the lifter rods into the Z sleds evenly.
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		up(explode*4) {
			extruder_bridge_assembly_13();

			// Construction arrows.
			if(arrows && explode>50) {
				bridgelen = extruder_length+2*rail_length+2*cantilever_length;
				down(explode*1.2) {
					right(bridgelen/2) {
						xspread(bridgelen) {
							yrot(-90) arrow(size=explode/2);
						}
					}
				}
			}
		}
	}
}
//!final_assembly_2(explode=100, arrows=true);


module final_assembly_3(explode=0, arrows=false)
{
	// view: [0, 0, 240] [60, 0, 125] 400
	// desc: Attach a limit microswitch, with wiring, to the Z rail endcap.
	rail_z_endcap();
	up(rail_height+groove_height-endstop_length/2-2) {
		left(rail_width/2-joiner_width-endstop_thick/2) {
			back(explode-endstop_depth/2) {
				zrot(180) xrot(90) microswitch();
			}
		}
	}

	// Construction arrows.
	if(arrows && explode>50) {
		up(rail_height+groove_height-endstop_length/2-2) {
			left(rail_width/2-joiner_width-endstop_thick/2) {
				back(explode/2-endstop_depth/2) {
					zrot(90) arrow(size=explode/4);
				}
			}
		}
	}
}
//!final_assembly_3(explode=100, arrows=true);


module final_assembly_4(explode=0, arrows=false)
{
	// view: [0, 0, 240] [55, 0, 25] 3000
	// desc: Attach the Z tower endcap.
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		up(explode*2) {
			yrot(90) zrot(-90) final_assembly_3();

			// Construction arrows.
			if(arrows && explode>50) {
				down(explode*1.0) {
					right(rail_height/2+groove_height/2) {
						yrot(-90) arrow(size=explode/2);
					}
				}
			}
		}
	}
}
//!final_assembly_4(explode=100, arrows=true);


module final_assembly_5(explode=0, arrows=false)
{
	// view: [0, 0, 240] [55, 0, 25] 3000
	// desc: Attach the spool holder to the top of the other Z tower.
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		yrot(90) zrot(-90) final_assembly_3();
		nil();

		up(explode*2) {
			right(rail_height/2) spool_holder();

			// Construction arrows.
			if(arrows && explode>50) {
				down(explode*1.0) {
					right(rail_height/2+groove_height/2) {
						yrot(-90) arrow(size=explode/2);
					}
				}
			}
		}
	}
}
//!final_assembly_5(explode=100, arrows=true);


module final_assembly_6(explode=0, arrows=false)
{
	// view: [0, 0, 240] [55, 0, 25] 3000
	// desc: Attach the RAMPS motherboard mount to the end of the printer base.
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		yrot(90) zrot(-90) final_assembly_3();
		fwd(explode*2) {
			ramps_mount();

			// Construction arrows.
			if(arrows && explode>50) {
				back(explode*1.0) {
					up(rail_height/2+groove_height/2) {
						zrot(-90) arrow(size=explode/2);
					}
				}
			}
		}

		right(rail_height/2) spool_holder();
	}
	//cable_chain_xy_joiner_mount();
}
//!final_assembly_6(explode=100, arrows=true);


module final_assembly_7(explode=0, arrows=false)
{
	// view: [0, 0, 0] [80, 0, 20] 2500
	// desc: Clip the glass build platform to the build platform supports using four binder clips.
	xpos = 0;
	ypos = 0;
	zpos = (rail_length*2-platform_length)/2;

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		yrot(90) zrot(-90) final_assembly_3();
		ramps_mount();

		right(rail_height/2) spool_holder();
		nil();
		up(explode) {
			// Construction arrows.
			if(arrows && explode>50) {
				down(explode*0.75) {
					up(rail_height/2+groove_height/2) {
						yrot(-90) arrow(size=explode/3);
					}
				}
			}

			build_platform();
		}
	}
	//cable_chain_xy_joiner_mount();
}
//!final_assembly_7(explode=100, arrows=true);


module final_assembly_8(explode=0, arrows=false)
{
	// view: [0, 0, 0] [80, 0, 20] 2500
	// desc: Cradle the spool axle in the spool holder top.
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		yrot(90) zrot(-90) final_assembly_3();
		ramps_mount();

		right(rail_height/2) {
			spool_holder();
			up(spool_holder_length-15/2*cos(30)+0.25+explode) {
				spool_axle();
				if (!(arrows && explode>50)) {
					down(52.5/2-14) spool();
				}
			}
		}
		nil();
		build_platform();
	}
	//cable_chain_xy_joiner_mount();
}
//!final_assembly_8(explode=100, arrows=true);


module full_rendering()
{
	xpos = 100*cos(360*$t);
	ypos = 100*sin(360*$t);
	zpos = (rail_length*2-platform_length)/3*cos(240+360*$t);

	final_assembly_1(xslidepos=xpos, yslidepos=ypos, zslidepos=zpos) {
		extruder_bridge_assembly_13();
		yrot(90) zrot(-90) final_assembly_3();
		ramps_mount();

		right(rail_height/2) {
			spool_holder();
			up(spool_holder_length-15/2*cos(30)+0.25) {
				spool_axle();
				down(52.5/2-14) spool();
			}
		}
		nil();
		build_platform();
	}
	//cable_chain_xy_joiner_mount();
}



full_rendering();



// vim: noexpandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap
