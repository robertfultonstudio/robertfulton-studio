# SuperCollider patches

Raccolta di patch di sound design sperimentale in [SuperCollider](https://supercollider.github.io/).

## Requisiti
- SuperCollider 3.x (IDE `scide` o estensione editor)

## Uso
1. Apri un file `.scd` nell'IDE di SuperCollider.
2. Avvia il server: valuta `s.boot;`
3. Carica le definizioni (`SynthDef`) valutando i rispettivi blocchi.
4. Suona gli esempi in fondo al file, una riga alla volta.
5. Stop: `Cmd/Ctrl + .` oppure `s.freeAll;`

## File
- `01-starter-patches.scd` — pad caldo (`\warmPad`), drone evolutivo (`\drone`),
  nuvola granulare (`\grainCloud`), più esempi di accordi e sequenza generativa (`Pbind`).
