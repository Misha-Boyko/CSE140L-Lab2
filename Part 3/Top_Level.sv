// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module Top_Level #(parameter NS=60, NH=24, ND = 7, NM=12)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
    Dayadv,
    Datadv,
    Monadv,
		Alarmon,
		Pulse,		  // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output logic [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp,
               H1disp, H0disp,
                       D0disp,
               N1disp, N0disp,
	             T1disp, T0disp,           // for part 2
  output logic Buzz);	           // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs, TMon, TDat,    // clock/time 
             AMin, AHrs;		   // alarm setting
  logic[3:0] TDay, AlarmDay;
  logic[6:0] Min, Hrs;
  logic S_max, M_max, H_max, D_max, Dat_max, Mon_max, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen;

  logic[6:0] MaxDays;

  always_comb begin
    case(TMon)
      0: MaxDays = 31;
      1: MaxDays = 29;
      2: MaxDays = 31;
      3: MaxDays = 30;
      4: MaxDays = 31;
      5: MaxDays = 30;
      6: MaxDays = 31;
      7: MaxDays = 31;
      8: MaxDays = 30;
      9: MaxDays = 31;
      10: MaxDays = 30;
      11: MaxDays = 31;
      default: MaxDays=99;
    endcase
  end

// (almost) free-running seconds counter	-- be sure to set modulus inputs on ct_mod_N modules
  ct_mod_N  Sct(
// input ports
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(NS),
// output ports    
    .ct_out(TSec), .ct_max(S_max));

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
// input ports
    .clk(Pulse), .rst(Reset), .en(S_max || (Timeset && Minadv)), .modulus(NS),
// output ports
    .ct_out(TMin), .ct_max(M_max));

// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Hct(
// input ports
	.clk(Pulse), .rst(Reset), .en((M_max && S_max) || (Timeset && Hrsadv)), .modulus(NH),
// output ports
    .ct_out(THrs), .ct_max(H_max));

  ct_mod_N  Dct(
// input ports
	.clk(Pulse), .rst(Reset), .en((H_max && M_max && S_max) || (Timeset && Dayadv)), .modulus(ND),
// output ports
    .ct_out(TDay), .ct_max(D_max));

  ct_mod_N  Dreg(
// input ports
	.clk(Pulse), .rst(Reset), .en(Alarmset && Dayadv), .modulus(ND),
// output ports
    .ct_out(AlarmDay), .ct_max(D_max));

  ct_mod_N  Datreg(
// input ports
	.clk(Pulse), .rst(Reset), .en((Timeset && Datadv) || (H_max && M_max && S_max)), .modulus(MaxDays),
// output ports
    .ct_out(TDat), .ct_max(Dat_max));

  ct_mod_N  Monreg(         //fix TMon so that 1 is always added once to the value (idk how)
// input ports
	.clk(Pulse), .rst(Reset), .en((Timeset && Monadv) || (H_max && M_max && S_max && Dat_max)), .modulus(NM),
// output ports
    .ct_out(TMon), .ct_max(Mon_max));

// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Minadv), .modulus(NS),   
// output ports    
    .ct_out(AMin), .ct_max(M_max)  );

  ct_mod_N  Hreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Hrsadv), .modulus(NH),
// output ports    
    .ct_out(AHrs), .ct_max(H_max) );

  wire [6:0] M_disp = Alarmset ? AMin : TMin;
  wire [6:0] H_disp = Alarmset ? AHrs : THrs;
  wire [6:0] D_disp = Alarmset ? AlarmDay : TDay;

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(					  // seconds display
    .bin_in    (TSec)  ,  // add more logic to what we're setting use MUX
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in    (M_disp),
	.Segment1  ( M1disp  ),
	.Segment0  ( M0disp  )
	);

  lcd_int Hdisp(
    .bin_in    (H_disp),
	.Segment1  ( H1disp  ),
	.Segment0  ( H0disp  )
	);

  lcd_int Ddisp(
    .bin_in    (D_disp),
	.Segment0  ( D0disp  )
	);

  lcd_int Mondisp(
    .bin_in    (TMon+1),
  .Segment1  ( N1disp  ),
	.Segment0  ( N0disp  )	);
  
  lcd_int Datdisp(
    .bin_in    (TDat+1),
  .Segment1  ( T1disp  ),
	.Segment0  ( T0disp )	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tday(TDay), .alarmday(AlarmDay),  .alarmOn(Alarmon), .buzz(Buzz)
	);

endmodule