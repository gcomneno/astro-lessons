---
title: "Symlink npm e problemi con cartelle condivise in VirtualBox"
slug: "symlink-npm-e-problemi-con-cartelle-condivise-in-virtualbox"
description: ""
---

## ❌ Il problema

Durante `npm install`, vari errori impedivano la creazione dei **symlink** in `/mnt/progetti`.

## 🧪 Diagnosi

Le cartelle condivise VirtualBox (tipo `/mnt/progetti`) **non supportano bene i symlink**, causando errori `EPERM`, `ETXTBSY`.

## ✅ Soluzione

- Usare le cartelle condivise solo per lo **scambio di file**
- Lavorare direttamente in `~/sviluppo` o simili

## 📌 Lesson Learned

> Evitare di installare progetti Node.js in cartelle condivise con l’host. Meglio copiare i file in una cartella Linux nativa.  "
