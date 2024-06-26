// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   ahrs,
         tday,
         alarmday,
         alarmOn,						 
  output logic buzz
);

  always_comb begin
    //buzz = 0;
    /* fill in the guts:
	buzz = 1 when tmin and thrs match amin and ahrs, respectively */
    if (tmin == amin && thrs == ahrs && alarmOn && (alarmday == 7 || (tday == alarmday % 7 || tday == (alarmday+1)%7))) buzz = 1;
    else buzz = 0;
  end
endmodule