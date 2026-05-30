// ============================================================================
// Robert Fulton — SuperCollider starter patches
// Esperimenti di sound design: pad, drone, texture granulare.
//
// USO:
//   1. Avvia il server audio:           s.boot;
//   2. Valuta i blocchi SynthDef qui sotto (Cmd/Ctrl + Invio dentro il blocco).
//   3. Suona gli esempi in fondo al file.
//   4. Per fermare tutto:               s.freeAll;   // oppure Cmd/Ctrl + .
// ============================================================================

s.boot;

// ----------------------------------------------------------------------------
// 1) WARM PAD — pad caldo a due oscillatori detunati, con filtro e riverbero.
//    Buono come letto armonico sotto a immagini lente.
// ----------------------------------------------------------------------------
(
SynthDef(\warmPad, { |out = 0, freq = 220, amp = 0.2, gate = 1,
    cutoff = 1800, rq = 0.5, detune = 0.2, pan = 0|

    var sig, env, osc1, osc2;

    // Inviluppo morbido: attacco lento, rilascio lungo.
    env = EnvGen.kr(
        Env.asr(attackTime: 2.5, sustainLevel: 1, releaseTime: 4, curve: \sin),
        gate, doneAction: Done.freeSelf
    );

    // Due saw leggermente scordati = battimenti e calore.
    osc1 = Saw.ar(freq * (1 - detune * 0.01));
    osc2 = Saw.ar(freq * (1 + detune * 0.01));
    sig  = (osc1 + osc2) * 0.5;

    // Filtro low-pass risonante con leggero movimento.
    sig = RLPF.ar(sig, cutoff * LFNoise2.kr(0.1).range(0.8, 1.2), rq);

    sig = sig * env * amp;
    sig = Pan2.ar(sig, pan);
    sig = sig + (FreeVerb.ar(sig, mix: 0.35, room: 0.8) * 0.6); // coda riverberata

    Out.ar(out, sig);
}).add;
)

// ----------------------------------------------------------------------------
// 2) SHIFTING DRONE — drone evolutivo, additivo, con micro-fluttuazioni.
//    Per tappeti immersivi e installazioni.
// ----------------------------------------------------------------------------
(
SynthDef(\drone, { |out = 0, freq = 55, amp = 0.25, gate = 1, spread = 7|

    var sig, env, partials;

    env = EnvGen.kr(
        Env.asr(8, 1, 10, \sin), gate, doneAction: Done.freeSelf
    );

    // Banco di parziali con frequenze e ampiezze leggermente instabili.
    partials = Mix.fill(spread, { |i|
        var partFreq = freq * (i + 1) * LFNoise1.kr(0.05).range(0.998, 1.002);
        var partAmp  = (1 / (i + 1)) * LFNoise2.kr(rrand(0.03, 0.12)).range(0.3, 1.0);
        SinOsc.ar(partFreq, 0, partAmp);
    }) / spread;

    sig = LeakDC.ar(partials);
    sig = sig * env * amp;
    sig = sig + GVerb.ar(sig, roomsize: 80, revtime: 6, drylevel: 0.5, earlyreflevel: 0.2) * 0.4;
    sig = sig.tanh; // soft clip di sicurezza

    Out.ar(out, sig ! 2);
}).add;
)

// ----------------------------------------------------------------------------
// 3) GRAIN TEXTURE — nuvola granulare sintetica, scintillante e diffusa.
//    Per dettagli, transizioni, atmosfere.
// ----------------------------------------------------------------------------
(
SynthDef(\grainCloud, { |out = 0, freq = 880, amp = 0.2, gate = 1,
    density = 18, dur = 0.08, spread = 1.0|

    var sig, env, trig, grainFreq, pan;

    env = EnvGen.kr(Env.asr(3, 1, 5, \sin), gate, doneAction: Done.freeSelf);

    trig = Dust.kr(density);                       // grani sparsi nel tempo
    grainFreq = freq * (1 + (TRand.kr(-0.5, 0.5, trig)));
    pan = TRand.kr(spread.neg, spread, trig);      // posizione stereo casuale

    sig = GrainSin.ar(2, trig, dur, grainFreq, pan);
    sig = sig * env * amp;
    sig = sig + FreeVerb.ar(sig, mix: 0.5, room: 0.9, damp: 0.3);

    Out.ar(out, sig);
}).add;
)

// ============================================================================
// ESEMPI — valuta una riga alla volta dopo aver caricato i SynthDef.
// ============================================================================

// Pad singolo:
// x = Synth(\warmPad, [\freq, 220, \amp, 0.25]);
// x.set(\gate, 0); // rilascia

// Accordo (sospeso, Dsus2-ish):
// ~chord = [146.83, 220, 329.63].collect { |f| Synth(\warmPad, [\freq, f, \amp, 0.15]) };
// ~chord.do { |n| n.set(\gate, 0) };

// Drone profondo:
// d = Synth(\drone, [\freq, 41.2, \amp, 0.3]);
// d.set(\gate, 0);

// Nuvola granulare sopra al drone:
// g = Synth(\grainCloud, [\freq, 1320, \amp, 0.15, \density, 25]);
// g.set(\gate, 0);

// Sequenza generativa con un pattern (Pbind):
// (
// p = Pbind(
//     \instrument, \warmPad,
//     // gradi di una scala minore esafonica, ottava 4-5, scelti a caso:
//     \midinote, Prand([57, 60, 62, 64, 67, 69, 72], inf),
//     \dur, Pwhite(2.0, 5.0, inf),  // durate irregolari
//     \amp, 0.12,
//     \cutoff, Pwhite(900, 2400, inf),
//     \legato, 0.9,
//     \pan, Pwhite(-0.6, 0.6, inf)
// ).play;
// )
// p.stop;
