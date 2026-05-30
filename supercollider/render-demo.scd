// render-demo.scd
// Rendering NON-REALTIME (NRT) con SuperCollider.
// Non serve scheda audio: scsynth legge una "partitura" (Score) di bundle OSC
// con timestamp e scrive direttamente un file audio su disco.
//
// Uso (headless):
//   QT_QPA_PLATFORM=offscreen sclang supercollider/render-demo.scd
//
// Produce: supercollider/out/drone.wav

(
var sampleRate = 48000;
var duration   = 10;            // secondi di render
var outDir     = thisProcess.nowExecutingPath.dirname +/+ "out";
var outFile    = outDir +/+ "drone.wav";

// --- SynthDef: un drone caldo, leggermente vivo -------------------------
var def = SynthDef(\drone, { |out = 0, freq = 55, amp = 0.25, gate = 1|
    var env, sig, detune;

    // inviluppo: fade-in lungo, release lunga (texture, non nota)
    env = EnvGen.kr(Env.asr(3, 1, 4), gate, doneAction: 2);

    // banco di oscillatori leggermente scordati (effetto "ensemble")
    sig = Mix.fill(7, { |i|
        detune = LFNoise2.kr(0.08).range(-0.6, 0.6);
        VarSaw.ar(freq * (i + 1) * 0.5 + detune, 0, LFNoise1.kr(0.1).range(0.1, 0.5))
    }) * 0.15;

    // filtro che respira
    sig = RLPF.ar(sig, SinOsc.kr(0.06).exprange(220, 1800), 0.5);

    // un po' di spazio
    sig = sig + (CombC.ar(sig, 0.4, 0.37, 5) * 0.3);
    sig = sig * env * amp;

    // leggero stereo
    Out.ar(out, [sig, DelayN.ar(sig, 0.02, 0.013)]);
});

// --- Partitura NRT ------------------------------------------------------
var score = Score([
    [0.0, ["/d_recv", def.asBytes]],
    [0.0, Synth.basicNew(\drone, Server.default, 1000).newMsg(args: [\freq, 55, \amp, 0.3])],
    [0.0, Synth.basicNew(\drone, Server.default, 1001).newMsg(args: [\freq, 82.4, \amp, 0.18])],
    [(duration - 4), [\n_set, 1000, \gate, 0]],   // avvia la release
    [(duration - 4), [\n_set, 1001, \gate, 0]],
    [duration,       [\c_set, 0, 0]]              // marca la fine del render
]);

File.mkdir(outDir);

score.recordNRT(
    outputFilePath: outFile,
    sampleRate:     sampleRate,
    headerFormat:   "WAV",
    sampleFormat:   "int24",
    options:        ServerOptions.new.numOutputBusChannels_(2).sampleRate_(sampleRate),
    duration:       duration,
    action: {
        ("Render completato -> " ++ outFile).postln;
        0.exit;   // chiude sclang quando il file e' pronto
    }
);
)
