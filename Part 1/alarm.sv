// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,
         alarmOn,						 
  output logic buzz
);

  always_comb begin
    //buzz = 0;
    /* fill in the guts:
	buzz = 1 when tmin and thrs match amin and ahrs, respectively */
    if (tmin == amin && thrs == ahrs && alarmOn) buzz = 1;
    else buzz = 0;
  end
endmodule