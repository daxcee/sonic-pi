// SuperCollider port of the Overtone tech_saws_gated synth
// Slightly modified supersaw implementation based on http://sccode.org/1-4YS
// Original Overtone version: sonic-pi/src/sonic_pi/gated/tech_gated.clj
//
// This file is part of Sonic Pi: http://sonic-pi.net
// Full project source: https://github.com/samaaron/sonic-pi
// License: https://github.com/samaaron/sonic-pi/blob/main/LICENSE.md
//
// Copyright 2013, 2014, 2015, 2016 by Sam Aaron (http://sam.aaron.name).
// All rights reserved.
//
// Permission is granted for use, copying, modification, and
// distribution of modified versions of this work as long as this
// notice is included.

(
SynthDef('sonic-pi-tech_saws_gated', {|
	note = 52, note_slide = 0, note_slide_shape = 1, note_slide_curve = 0,
	amp = 1, amp_slide = 0, amp_slide_shape = 1, amp_slide_curve = 0,
	pan = 0, pan_slide = 0, pan_slide_shape = 1, pan_slide_curve = 0,
	attack = 0, decay = 0, sustain = 0, release = 1,
	attack_level = 1, decay_level = -1, sustain_level = 1,
	env_curve = 1,
	cutoff = 130, cutoff_slide = 0, cutoff_slide_shape = 1, cutoff_slide_curve = 0,
	res = 0.7, res_slide = 0, res_slide_shape = 1, res_slide_curve = 0,
	gate = 1,
	out_bus = 0|

	var hi_saws, lo_saws, noise, output, env, freq, cutoff_freq;
	var amp_fudge = 0.9;

	decay_level = Select.kr(decay_level < 0, [decay_level, sustain_level]);
	note = note.varlag(note_slide, note_slide_curve, note_slide_shape);
	amp = amp.varlag(amp_slide, amp_slide_curve, amp_slide_shape);
	pan = pan.varlag(pan_slide, pan_slide_curve, pan_slide_shape);
	cutoff = cutoff.varlag(cutoff_slide, cutoff_slide_curve, cutoff_slide_shape);
	res = res.linlin(1, 0, 0, 1);
	res = res.varlag(res_slide, res_slide_curve, res_slide_shape);

	freq = note.midicps;
	cutoff_freq = cutoff.midicps;

	hi_saws = Splay.ar(Array.fill(5, {
		var tune = Rand(0.99, 1.01);
		DelayC.ar(LFSaw.ar(freq * tune), 0.005, Rand(0.0001, 0.01))
	}));

	lo_saws = Splay.ar(Array.fill(5, {
		var tune = Rand(0.99, 1.01);
		DelayC.ar(LFSaw.ar(freq * 0.5 * tune), 0.005, Rand(0.0001, 0.01))
	}));

	noise = PinkNoise.ar;

	output = (0.65 * hi_saws) + (0.85 * lo_saws) + (0.07 * noise);
	output = output.clip2(0.55);
	output = Normalizer.ar(RLPF.ar(output, cutoff_freq, res));

	env = EnvGen.kr(Env.new(
		[0, attack_level, decay_level, sustain_level, 0],
		[attack, decay, sustain, release],
		env_curve,
		3
	), gate, doneAction: 2);

	output = FreeVerb.ar(output, mix: 0.45, room: 1.8);
	output = amp_fudge * env * output;
	output = Balance2.ar(output[0], output[1], pan, amp);

	Out.ar(out_bus, output);
}).writeDefFile("/home/sam/Development/sonic-pi/etc/synthdefs/compiled/gated/");
)
