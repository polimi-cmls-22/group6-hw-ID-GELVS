s.waitForBoot({
	var fundamentalNote = 261.60 , drumON = -1, time = 128 ;
	var mainWindow;
	var arduinoInput;
	var funSoundType, funNote, funDrumOnOff, funPlayInstrument, funSendOSCtoProc;
	var instrument = 0;
	var kickLoop = [0,0,0,0], snareLoop = [0,0,0,0] ,clapLoop = [0,0,0,0], hitHatLoop = [0,0,0,0];

	/*------------------------------SETUP FOR ARDUINO------------------------------*/
	SerialPort.devices;
	/*Roncuzzi's PC*/
	//~port = SerialPort.new("/dev/tty.usbmodem101",9600);

	/*Gabry's  Pc*/
	~port = SerialPort.new("COM3",9600);
	/*-----------------------------------------------------------------------------*/

	/*------------------------------SETUP FOR PROCESSING GUI-----------------------*/
	~net1 = NetAddr.new("127.0.0.1",12000);
	/*-----------------------------------------------------------------------------*/

	Window.closeAll;
	GUI.current;

/*------------------------------SETUP FOR SYNTHDEFs------------------------------*/
/*=========================================================================================================================================*/
/*PIANO*/
SynthDef(\ring, {
	arg freq = 440, amp = 0.1;
	var env, snd;
	snd = EnvGen.kr(Env.new([1,0.7,0.8,0],[0.1,0.1,0.2,0.1]), doneAction: 2) * LFPulse.ar(freq,0,mul:0.3);
	Out.ar(0, snd*0.5);
	Out.ar(1, snd*0.5);
	}).add;

SynthDef(\bassSimple, {
	arg freq = 440, t_gate = 1,dur = 2;
	var sig, lpf_sig, out;

	sig = Mix.ar(LFSaw.ar(freq * [0.99, 1, 1.01]));
    lpf_sig = LPF.ar(sig, 300);

	//in BPF 2000 is the centre frequency of the butterwoth filter, the second parameter is the reciprocal of Q, rq = bandwidth/centralFreq
    out = lpf_sig + BPF.ar(sig, 2000, 2);

	a = EnvGen.kr(Env.asr(0.01,1,dur), gate:t_gate);
	Out.ar(0, Pan2.ar(FreeVerb.ar(out*a,room:0.3), 0, 0.5));

}).add;

SynthDef(\bassTrance, {
	|freq=220,amp=0.5, out=0, rel=0.3|

	var sig;
	var env;

	sig = Saw.ar(freq);

	sig = sig * EnvGen.kr( Env.perc(rel:rel), doneAction: 2 );

	Out.ar(out, Pan2.ar(sig * amp, 0, amp) / 2);

}).add;

SynthDef(\piano, {
    |
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.9,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.4, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.2
    |
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    lfoSpeed = lfoSpeed * 12;

    freq = freq * 2;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

    // using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
    snd = snd * EnvGen.ar(Env.perc(0, 1, 0.1), doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
}).add;

/*DRUMS*/

/*=========================================================================================================================================*/
SynthDef(\kick, {|amp=0.8, out=0|
    var snd;
    snd = DC.ar(0);
    snd = snd + (SinOsc.ar(XLine.ar(1500, 800, 0.01)) * Env.perc(0.0005, 0.01, curve: \lin).ar);
    snd = snd + (BPF.ar(Impulse.ar(0) * SampleRate.ir / 28000, 6100, 1.0) * 3.dbamp);
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 300, 0.9) * Env.perc(0.001, 0.02).ar);
    snd = snd + (SinOsc.ar(XLine.ar(472, 60, 0.045)) * EnvGen.kr(Env.perc(0.0001, 0.3, curve: \lin).delay(0.005),doneAction: 2));
    snd = snd.tanh;
    Out.ar(out, Pan2.ar(snd * amp, \pan.kr(0), amp) / 2);
}).add;

SynthDef(\snare,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;
	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)
		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)
	) * mul;
	Out.ar(out, membrane!2)
}).add;

SynthDef(\clap, {
	|out = 0, amp = 1.5, pan = 0, dur = 1|
	var env1, env2, snd, noise1, noise2;
	// noise 1 - 4 short repeats
	env1 = EnvGen.ar(
		Env.new(
			[0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
			[0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
			[0, -3, 0, -3, 0, -3, 0, -4]
		)
	);
	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
	noise1 = BPF.ar(noise1, 1620, 3);
	// noise 2 - 1 longer single
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction: 2);
	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = LPF.ar(noise2, 7600);
	noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);
	snd = noise1 + noise2;
	snd = snd * 2;
	snd = snd.softclip;
	Out.ar(out, Pan2.ar(snd,pan,amp) / 2);
}).add;

SynthDef(\hihat, {|amp=1,out=0, rel=0.125,pan=0|
	    var hatosc, hatenv, hatnoise, hatoutput;
	    hatnoise = {LPF.ar(WhiteNoise.ar(1),6000)};
	    hatosc = {HPF.ar(hatnoise,2000)};
	    hatenv = EnvGen.kr(Env.perc(0.01,rel),doneAction:2);
	    hatoutput = (hatosc * hatenv)/2;
	    Out.ar(out,
	    Pan2.ar(hatoutput*amp, pan))}).add;

SynthDef(\bglass, {
	|t_trig = 1.0, audioOutBus = 0|
	var major_hit_times, major_hit_deltas, major_hit_levels, major_hit_impulse_levels, major_hit_impulses;
	var major_hit_amp, major_hit_envGen, major_hit_out;
	var klank_freq_array, klank_out;
	var noise, noise_out;
	var additional_tinkles;
	var initial_impact_pitch_envGen, initial_impact_amp_envGen, initial_impact;
	var comb_out, output;
	var last_time;
	major_hit_times = [0.02, 0.1, 0.21, 0.28, 0.32, 0.48, 0.6, 0.69];
	major_hit_deltas = [];
	last_time = 0.0;
	major_hit_times.size.do { |i|
		major_hit_deltas = major_hit_deltas ++
			[
			SampleDur.ir,
			((major_hit_times[i] - last_time) * TRand.kr(0.4, 1.6, t_trig)) - SampleDur.ir
			];

		last_time = major_hit_times[i];
	};
	major_hit_levels = [1.0, 0.3, 0.7, 0.4, 0.65, 0.87, 0.27, 0.4];
	major_hit_levels.size.do { |i|

		major_hit_levels[i] = major_hit_levels[i] * TRand.kr(0.7, 1.0, t_trig);

	};
	major_hit_impulse_levels = [major_hit_levels, 0 ! major_hit_times.size].lace(major_hit_times.size * 2);
	major_hit_impulses = Duty.ar(
		Dseq(major_hit_deltas, 1), K2A.ar(t_trig), Dseq(major_hit_impulse_levels, 1)
		);
	major_hit_amp = Gate.ar(major_hit_impulses, major_hit_impulses);
	major_hit_envGen = EnvGen.ar(Env.perc(0.0, 0.03, 1, -9), major_hit_impulses) * major_hit_amp;
	major_hit_out = major_hit_envGen * WhiteNoise.ar * 0.6;
	major_hit_out = major_hit_out + major_hit_impulses;

	klank_freq_array = [1383, 2831, 3252, 3446, 4547, 4600, 4832, 5863, 6813, 8683, 11196];
	klank_freq_array.size.do { |i|

		klank_freq_array[i] = klank_freq_array[i] * TRand.kr(0.8, 1.2,  Impulse.kr(20));
	};
	klank_out = DynKlank.ar(`[klank_freq_array, nil, 0.2], major_hit_out * 0.05);
	klank_out = DelayC.ar(klank_out, 0.2, 0.009);

	noise = BrownNoise.ar + (WhiteNoise.ar * 0.3) + (PinkNoise.ar * 0.6);
	noise = noise * 0.1;
	noise = noise + Dust.ar(70, 1);
	noise_out = noise * LagUD.ar(major_hit_impulses, 0.0, 0.842);

	additional_tinkles =
	DynKlank.ar(`[ Array.series(8, 1200, 179), nil, 0.7], Dust.ar(14), TRand.kr(2.9, 3.1, Impulse.kr(28)) )
	+
	DynKlank.ar(`[ Array.series(8, 1200, 179), nil, 0.13], Dust.ar(11, 0.7), TRand.kr(1.4, 2.2, Impulse.kr(15)) );

	additional_tinkles = additional_tinkles *
		EnvGen.ar(Env.linen(0.15, 0.3, 0.3, 1.0, -2), t_trig, timeScale: TRand.kr(0.9, 1.12, t_trig));

	initial_impact_pitch_envGen = EnvGen.ar(Env.perc(0.001, 0.03, 1.0, -7), t_trig);
	initial_impact_amp_envGen = EnvGen.ar(Env.perc(0.0, 0.04, 1.0, -9), t_trig);
	initial_impact = SinOsc.ar(initial_impact_pitch_envGen.exprange(20, 4000) * TRand.kr(0.96, 1.03, t_trig)) * 0.5;
	initial_impact = initial_impact + LFNoise1.ar(6800, 1.0) * initial_impact_amp_envGen;
	initial_impact = HPF.ar(initial_impact, 100);
	initial_impact = initial_impact + CombC.ar(initial_impact, 0.2, 0.04, 0.2, 0.12);
	output = (klank_out * 0.5) + (major_hit_out * 0.45);
	output = (output * 0.86) + DelayC.ar(output, 0.2, 0.01);
	output = output + (noise_out * 0.32) + (additional_tinkles * 0.044) + (initial_impact * 0.2);

	comb_out = CombC.ar(output, 0.1, [0.028, 0.031], 0.52, 0.23);
	comb_out = LPF.ar(comb_out, 3000);
	comb_out = HPF.ar(comb_out, 110);
	output = output + comb_out;
	Out.ar(audioOutBus, output);

}).add;

SynthDef(\bell, {
	|freq = 880, t60=9, pitchy=1, amp=0.1, gate=1, pan = 0|
	var sig, exciter;
	exciter = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.05), gate) * 0.25;
	sig = DynKlank.ar(
		`[
			[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
			[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
			[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]*t60     // ring times
		],
		exciter,
		freqscale: freq);
	DetectSilence.ar(sig, 0.001, 0.5, doneAction:2);
	Out.ar(0, Pan2.ar(sig, pan, amp));
}).add;

SynthDef(\laser, {
    var snd;
    // a percussive click to give it some attack
    snd = LPF.ar(HPF.ar(WhiteNoise.ar, 300), 8000) * Env.linen(0.001, 0.01, 0.001).ar;
    // sine sweep body. very important!
    snd = snd + (SinOsc.ar(Env([400, 196, 160], [0.04, 0.2], \exp).ar) * Env.perc(0.04, 0.2).ar * 6.dbamp).tanh;
    // sound of snare coils rattling
    snd = snd + (HPF.ar(BPeakEQ.ar(WhiteNoise.ar, 4000, 0.5, 3), 300) * Env.perc(0.05, 0.2).delay(0.01).ar(2) * -3.dbamp);
    // another sound sweep to improve the attack, optional
    snd = snd + (SinOsc.ar(XLine.kr(3000, 1500, 0.01)) * Env.perc(0.001, 0.02).ar);
    // distortion helps glue everything together and acts as a compressor
    snd = (snd * 1.4).tanh/3;
    snd = Pan2.ar(snd, \pan.kr(0), \amp.kr(0.5));
    Out.ar(\out.kr(0), snd);
}).add;

/*=========================================================================================================================================*/
/*-------------------- COMUNICATION BETWEEN PROCESSING AND SUPERCOLLIDER --------------------*/
	NetAddr.localAddr;
/*------------------------------SETUP FOR FUNCTIONS------------------------------*/
	funNote = {
		arg val;
		o  = fundamentalNote*pow(2,val/12);
		o.postln;
	};

	funDrumOnOff = {
		arg in;
		var value;
		if(in == -1,{value = -2},{value = -1});
		o = value;
	};

	funPlayInstrument = {
		arg input, note;
		case
		{input == 0}{Synth(\bassSimple ,[\freq, fundamentalNote*pow(2,note/12);])}
		{input == 1}{Synth(\ring ,[\freq, fundamentalNote*pow(2,note/12);])}
		{input == 2}{Synth(\bassTrance ,[\freq,fundamentalNote*pow(2,note/12);])}
		{input == 3}{Synth(\piano ,[\freq,fundamentalNote*pow(2,note/12);])}
		{input == 4}{}
		{input == 5}{}
		{input == 6}{}
		;
	};

	funSendOSCtoProc = {
		 arg value;
		~net1.sendMsg('/Accenditi',value);
		SystemClock.sched(0.25, {~net1.sendMsg('/OFF',-3); });
	};

/*-------------------------------------------------------------------------------*/


	//Main Window//
	//mainWindow = Window.new("TFM -  SC",Rect(Window.screenBounds.width/2,Window.screenBounds.height/2,200,100))
	mainWindow = Window.new("TFM - SC",Rect(10,100,200,100))
	.alwaysOnTop_(true)
	.background_(Color.black)
	.front;


	/*CLOSE ALL AND STOP ALL*/
	mainWindow.onClose = {
		//Server.freeAll;
		Server.killAll;
		"Server closed".postln;
		Window.closeAll;
		"Window closed".postln;
		SerialPort.closeAll;
		"Serial port closed".postln;
		"Bye Bye!".postln;
	};

	CmdPeriod.doOnce({mainWindow.close});
	/*--------------------ARDUINO <--> SUPERCOLLIDER <--> PROCESSING--------------------*/

	/* Start The Routine */
	~getValues = Routine.new({
		{
			arduinoInput = ~port.read.asAscii;
			//arduinoInput.postln;

			/* ---------- OSC MESSAGES ---------- */

			/* OSC Messages for change BPM */
			OSCdef(\msgBPM, {
				arg msg;
				time = msg[1];
			}, "/msgBPM");

			/* OSC Messages for change Drum-Insrument modes */
			OSCdef(\msgDrum, {
				arg msg;
				m = msg[1];
				case
				{m == 1}   {drumON = -1;}
				{m == 0}   {drumON = -2;}
				;
			}, "/msgDrum");

			/* OSC Messages for change Drum-Insrument modes */
			OSCdef(\msgPro, {
				arg msg;
				m = msg[1];
				case
				{m == 0}   {instrument = 0;}
				{m == 1}   {instrument = 1;}
				{m == 2}   {instrument = 2;}
				{m == 3}   {instrument = 3;}
				{m == 4}   {instrument = 4;}
				{m == 5}   {instrument = 5;}
				;
			}, "/msgPro");

			/* OSC Messages for loop modality */
			OSCdef(\msgLoop, {
				arg msg;

				l = msg[1];

				kickLoop[0] = msg[2];
				kickLoop[1] = msg[3];
				kickLoop[2] = msg[4];
				kickLoop[3] = msg[5];

				snareLoop[0] = msg[6];
				snareLoop[1] = msg[7];
				snareLoop[2] = msg[8];
				snareLoop[3] = msg[9];

				clapLoop[0] = msg[10];
				clapLoop[1] = msg[11];
				clapLoop[2] = msg[12];
				clapLoop[3] = msg[13];

				hitHatLoop[0] = msg[14];
				hitHatLoop[1] = msg[15];
				hitHatLoop[2] = msg[16];
				hitHatLoop[3] = msg[17];

				if(l == 0,
					{
						i = 0;
						t = Task({{
							if( kickLoop.at(i)== 1,{ Synth(\kick);funSendOSCtoProc.value(0);},{});
							if( snareLoop.at(i)== 1,{ Synth(\snare);funSendOSCtoProc.value(1);},{});
							if( clapLoop.at(i)== 1,{ Synth(\clap);funSendOSCtoProc.value(2);},{});
							if( hitHatLoop.at(i)== 1,{ Synth(\hihat);funSendOSCtoProc.value(3);},{});
							i= i+1;
							if(i==4,{i=0;},{});
							(60/time).wait;

						}.loop });
				t.start;
				},{t.stop;});
			}, "/msgLoopArray");

			/* ---------- -- -- -- --  ---------- */

			/*
			if (arduinoInput ==$6 , {
				//drumON = -1*drumON;
				drumON = funDrumOnOff.value(drumON);
				drumON.postln;
				~net1.sendMsg('/Drum ON',drumON);
				"change".postln;

			});
			*/

			/* Drum - Instrument */
			if (drumON == -1,{
				//then : DRUM ON
			case
				{arduinoInput==$0}   {
					Synth(\kick);
					funSendOSCtoProc.value(0);
				}
				{arduinoInput==$1}   {
					Synth(\snare);
					funSendOSCtoProc.value(1);
				}
				{arduinoInput==$2}   {
					Synth(\clap);
					funSendOSCtoProc.value(2);
				}
				{arduinoInput==$3}   {
					Synth(\hihat);
					funSendOSCtoProc.value(3);
				}
				{arduinoInput==$4}   {
					Synth(\bglass);
					funSendOSCtoProc.value(4);
				}
				{arduinoInput==$5}   {
					Synth(\bell);
					funSendOSCtoProc.value(5);
				}

				{arduinoInput==$6} {
					Synth(\laser);
					funSendOSCtoProc.value(6);
				}
				;
			},{
				//else : INSTRUMENT OFF
			case
				//Notes:  C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11
				{arduinoInput==$0}   {
					funPlayInstrument.value(instrument,4);
					funSendOSCtoProc.value(0);
				}
				{arduinoInput==$1}   {
					funPlayInstrument.value(instrument,7);
					funSendOSCtoProc.value(1);
				}
				{arduinoInput==$2}   {
					funPlayInstrument.value(instrument,9);
					funSendOSCtoProc.value(2);
				}
				{arduinoInput==$3}   {
					funPlayInstrument.value(instrument,11);
					funSendOSCtoProc.value(3);
				}
				{arduinoInput==$4}   {
					funPlayInstrument.value(instrument,12);
					funSendOSCtoProc.value(4);
				}
				{arduinoInput==$5}   {
					funPlayInstrument.value(instrument,9);
					funSendOSCtoProc.value(5);
				}

				{arduinoInput==$6} {
					funPlayInstrument.value(instrument,11);
					funSendOSCtoProc.value(6);
				}
				;
			});
		}.loop;
	}).play;
	/*------------------------------------------------------------------------------*/
	TextView(mainWindow,Rect(10,10,180,80))
		.string_("READY TO PLAY!!! :D")
		.editable_(false)
		.font_(Font("Artifakt Element Light",20))
	    .palette_(QPalette.dark)
		.front;

/* END OF PROGRAM */
});
