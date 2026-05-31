# Runbook — Mostrare il pannello dell'act DENTRO il device M4L

**Per:** Claude Code locale (sul Mac con accesso a `freeverb@.amxd`, Max 9, Ableton Live 12)
**Device prototipo:** `Reverb (Freeverb) — freeverb@.amxd`
**Vincolo assoluto:** NON modificare nulla in `Packages/ppooll/`. Lavora SOLO sul `.amxd` del device.

---

## Fatti verificati (contesto)
- Gli act ppooll non hanno layout di Presentation: il loro pannello **È** la patching view (compatta). `freeverb@` ≈ **159×133 px**.
- Gli act hanno **0 inlet / 0 outlet**; si collegano da soli via `send/receive` (`live.stereo_in` / `live.stereo_out`) e `pattr`. Per mostrarli **NON servono cavi**: basta un `bpatcher` dell'act, solo per visualizzazione.
- Oggi l'act è mostrato in **finestra esterna** dal subpatcher `p create-act-bpatcher` dentro `p LIVE_PPOOLL_ENVIRONMENT`.

---

## 0) Backup (obbligatorio, prima di tutto)
```bash
cd <cartella-del-device>
cp "freeverb@.amxd" "freeverb@.backup-$(date +%Y%m%d-%H%M).amxd"
ls -la "freeverb@.backup-"*.amxd   # conferma che esiste
```
Non proseguire se il backup non c'è.

## 1) Apri il device in Max
In Live, sul device → pulsante **Edit ✎**. Si apre il patch top-level del `.amxd`.

---

## 2) APPROCCIO A — bpatcher statico in Presentation (prova PRIMA questo)

### a. Crea il bpatcher
- Nuovo oggetto `bpatcher`.
- Inspector del bpatcher:
  - **Patcher File** = `freeverb@.maxpat`
  - **Embed Patcher in Parent File** = **OFF** (riferimento, non copia: non duplica/freeza il sorgente ppooll)
  - **Number of Inlets** = `0`, **Number of Outlets** = `0`
  - **Offset X / Y** = `0` / `0` (il pannello parte in alto a sinistra)
  - **Open in Presentation** *(del bpatcher)* = **OFF** ← l'act non ha presentation interna: vuoi la patching view ritagliata.

### b. Metti in Presentation
- Tasto destro sul bpatcher → **Add to Presentation**.
- Vai in Presentation (⌘+Opt+E).
- Posiziona sotto l'header; dimensione box **≈ 159×133** (Inspector → Presentation Rectangle).
- Patcher Inspector (sfondo) → **Open in Presentation** = ON.

### c. Elimina la DOPPIA istanza (causa dello `stack overflow`)
Entra in `p LIVE_PPOOLL_ENVIRONMENT`:
- **Taglia il cavo** `loadmess … ppooll_host.maxpat` → `p create-act-bpatcher` (così al load non si crea una 2ª istanza in finestra).
- **Cancella** l'oggetto statico `freeverb@.maxpat`.
- Deve restare **UNA sola** istanza dell'act = il bpatcher del passo (a).

> Perché: due istanze condividono gli stessi `send/receive` (`live.stereo_in/out`) e gli stessi nomi `pattr` → loop di feedback / clash → "stack overflow".

### d. Salva e verifica
⌘S → torna in Live → re-inserisci il device → esegui la **CHECKLIST** in fondo.

---

## 3) APPROCCIO B — solo se A mostra pannello + audio MA parametri/preset NON rispondono
Sintomo = `ppooll_host` non ha **registrato** l'act (non l'ha creato lui).

- Rimetti il cavo `loadmess → p create-act-bpatcher`.
- Apri `p create-act-bpatcher`: trova il messaggio `thispatcher`/`script …` che crea l'oggetto e il messaggio che apre la finestra (tipicamente `front`, `window front`, `window flags …`).
- **Rimuovi il `front`** (e i `window …` di apertura) → l'act viene creato e **registrato** ma **senza finestra**.
- Fai finire quell'unica istanza nel pannello: target di scripting = **patcher top-level** già in Presentation, oppure dopo la creazione applica all'oggetto l'attributo `presentation 1`.
- Obiettivo: **1 sola istanza, registrata da ppooll_host, visibile inline, zero finestra.**

---

## CHECKLIST di verifica (traccia audio con loop in riproduzione)
- [ ] pannello dell'act visibile DENTRO il device (niente finestra esterna)
- [ ] nessun `stack overflow` in console Max
- [ ] audio passa, riverbero udibile
- [ ] manopole/parametri rispondono
- [ ] salva il set → riapri → ricarica con lo stato corretto

**Decisione:** prova A. Tutto verde → fatto (A è più pulito). Cade SOLO su "parametri/preset" → passa a B.

---

## Report da rimandare (al reviewer / all'utente)
Per ogni tentativo (A e/o B) riporta:
1. Esito di ciascuna voce della checklist (✅/❌).
2. Eventuali messaggi nella **console Max** (copia testuale).
3. Se ❌ su parametri: confermi di essere passato a B? quali oggetti hai trovato in `p create-act-bpatcher` (lista `script`/`window`/`front`)?
4. Nome del file di backup creato al punto 0.
